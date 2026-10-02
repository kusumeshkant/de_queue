import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/data/datasources/remote/profile_remote_ds.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/service_core/payment/checkout_contact.dart';
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CreateRazorpayOrderUseCase createRazorpayOrderUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final ValidateCartStockUseCase validateCartStockUseCase;
  final PaymentGateway paymentGateway;
  final OrderRemoteDataSource _orderDs;
  final ProfileLoader _profileLoader;

  CartController({
    required this.createRazorpayOrderUseCase,
    required this.createOrderUseCase,
    required this.validateCartStockUseCase,
    required this.paymentGateway,
    OrderRemoteDataSource? orderDs,
    ProfileLoader? profileLoader,
  })  : _orderDs = orderDs ?? OrderRemoteDataSource(),
        _profileLoader = profileLoader ?? ProfileRemoteDataSource().getProfile;

  final RxList<CartItemEntity> items = <CartItemEntity>[].obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool hasPaymentFailed = false.obs;
  final RxString failureMessage = ''.obs;

  // ── Discount code state ───────────────────────────────────────────────────────
  final discountCodeCtrl    = TextEditingController();
  final isValidatingCode    = false.obs;
  final discountResult      = Rx<Map<String, dynamic>?>(null);
  String? _appliedCode;

  /// The grand total after discount (falls back to grandTotal if no discount applied).
  double get effectiveGrandTotal {
    final result = discountResult.value;
    if (result == null) return grandTotal;
    return (result['finalAmount'] as num).toDouble();
  }

  double get discountAmount {
    final result = discountResult.value;
    if (result == null) return 0;
    return (result['discountAmount'] as num).toDouble();
  }

  String? get appliedDiscountCode => discountResult.value != null ? _appliedCode : null;

  void Function(OrderEntity order)? _onSuccess;
  void Function(String message)? _onError;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get tax => subtotal * 0.18;
  double get grandTotal => subtotal + tax;
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onClose() {
    discountCodeCtrl.dispose();
    paymentGateway.dispose();
    super.onClose();
  }

  /// Returns true if item was added/incremented, false if rejected (stock limit).
  bool addItem(CartItemEntity newItem) {
    final index = items.indexWhere((i) => i.barcode == newItem.barcode);
    if (index != -1) {
      final item = items[index];
      if (item.stock > 0 && item.quantity >= item.stock) {
        return false; // rejected — stock limit reached
      }
      item.quantity++;
      if (newItem.isManualEntry) item.entryMethod = CartEntryMethod.manual;
      items.refresh();
    } else {
      items.add(newItem);
    }
    return true;
  }

  /// Adds [qty] units of [newItem]. Returns actual quantity added (0 if stock limit hit).
  int addItemWithQuantity(CartItemEntity newItem, int qty) {
    final index = items.indexWhere((i) => i.barcode == newItem.barcode);
    if (index != -1) {
      final item = items[index];
      if (item.stock > 0 && item.quantity >= item.stock) return 0;
      final canAdd = item.stock > 0 ? (item.stock - item.quantity) : qty;
      final toAdd = qty.clamp(0, canAdd);
      if (toAdd == 0) return 0;
      item.quantity += toAdd;
      // Sticky: once any unit of a line was typed in, the line stays manual.
      if (newItem.isManualEntry) item.entryMethod = CartEntryMethod.manual;
      items.refresh();
      return toAdd;
    } else {
      final effectiveQty =
          newItem.stock > 0 ? qty.clamp(1, newItem.stock) : qty;
      items.add(CartItemEntity(
        barcode: newItem.barcode,
        name: newItem.name,
        subtitle: newItem.subtitle,
        sku: newItem.sku,
        mrp: newItem.mrp,
        price: newItem.price,
        stock: newItem.stock,
        quantity: effectiveQty,
        entryMethod: newItem.entryMethod,
      ));
      return effectiveQty;
    }
  }

  void incrementQuantity(String barcode) {
    final index = items.indexWhere((i) => i.barcode == barcode);
    if (index != -1) {
      final item = items[index];
      if (item.stock > 0 && item.quantity >= item.stock) {
        Get.snackbar(
          'Stock Limit',
          'Only ${item.stock} unit(s) of ${item.name} available.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      item.quantity++;
      items.refresh();
    }
  }

  void decrementQuantity(String barcode) {
    final index = items.indexWhere((i) => i.barcode == barcode);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
      } else {
        items.removeAt(index);
      }
    }
  }

  void removeItem(String barcode) {
    items.removeWhere((i) => i.barcode == barcode);
  }

  void clearCart() {
    items.clear();
    hasPaymentFailed.value = false;
    failureMessage.value = '';
    discountResult.value = null;
    _appliedCode = null;
    discountCodeCtrl.clear();
  }

  // ── Discount code ─────────────────────────────────────────────────────────────

  Future<void> validateAndApplyDiscount() async {
    final code = discountCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar('Missing', 'Enter a discount code.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('Empty Cart', 'Add items to cart before applying a discount.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dashboard = Get.find<DashboardController>();
    final storeId = dashboard.selectedStoreId.value;
    if (storeId.isEmpty) {
      Get.snackbar('No Store', 'Select a store first.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isValidatingCode.value = true;
    try {
      final result = await _orderDs.validateDiscountCode(
        code: code,
        storeId: storeId,
        subtotal: grandTotal,
      );
      _appliedCode = code;
      discountResult.value = result;
      Get.snackbar(
        'Discount Applied!',
        '${(result['discountPercent'] as num).toStringAsFixed(0)}% off — '
            'saving ₹${(result['discountAmount'] as num).toStringAsFixed(0)}',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Invalid Code',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isValidatingCode.value = false;
    }
  }

  void removeDiscount() {
    discountResult.value = null;
    _appliedCode = null;
    discountCodeCtrl.clear();
  }

  Future<void> checkout({
    required void Function(OrderEntity order) onSuccess,
    required void Function(String message) onError,
  }) async {
    // Duplicate-submit guard: a second tap while a checkout is in flight
    // must not create a second Razorpay order or open a second sheet.
    if (isCheckingOut.value) return;

    // Reset previous failure state on new attempt
    hasPaymentFailed.value = false;
    failureMessage.value = '';

    if (items.isEmpty) {
      onError('Your cart is empty');
      return;
    }

    final dashboard = Get.find<DashboardController>();
    if (dashboard.selectedStoreId.value.isEmpty) {
      onError('No store selected. Please select a store first.');
      return;
    }

    _onSuccess = onSuccess;
    _onError = onError;

    isCheckingOut.value = true;
    // Fetched alongside the stock check and Razorpay order, so pre-filling the
    // customer's phone/email adds no wait. Missing or failed → empty prefill.
    final contactFuture = loadCheckoutContact(_profileLoader);
    try {
      // Validate stock before opening payment sheet
      final outOfStock = await validateCartStockUseCase.execute(
        dashboard.selectedStoreId.value,
        List.from(items),
      );
      if (outOfStock.isNotEmpty) {
        isCheckingOut.value = false;
        final names = outOfStock.join(', ');
        onError('${outOfStock.length == 1 ? '$names is' : '$names are'} no longer available. Please remove from cart.');
        return;
      }

      final razorpayOrder = await createRazorpayOrderUseCase.execute(
        storeId: dashboard.selectedStoreId.value,
        items: List.from(items),
        discountCode: appliedDiscountCode,
      );

      final contact = await contactFuture;

      // Open checkout with the key the server created the order with, so the
      // client and server keys can never disagree. AppConfig is only a
      // fallback for a backend that predates keyId.
      await paymentGateway.open(
        PaymentRequest(
          orderId: razorpayOrder.id,
          amountInPaise: razorpayOrder.amount,
          keyId: razorpayOrder.keyId ?? AppConfig.razorpayKeyId,
          currency: razorpayOrder.currency,
          contact: contact.contact,
          email: contact.email,
        ),
        PaymentCallbacks(
          onSuccess: _handlePaymentSuccess,
          onFailure: _handlePaymentFailure,
          onCancelled: _handlePaymentCancelled,
        ),
      );
    } catch (e) {
      isCheckingOut.value = false;
      onError(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccess payment) async {
    try {
      // Only the three Razorpay values are sent. The server builds the order —
      // store, items, totals, discount — from its own record of what was paid for.
      final order = await createOrderUseCase.execute(
        razorpayOrderId: payment.orderId,
        razorpayPaymentId: payment.paymentId,
        razorpaySignature: payment.signature,
      );

      // Persist the order BEFORE clearing cart — if the app is killed between
      // these two operations, the user retains the order reference rather than losing both.
      await LocalStorage.savePendingOrder(order);
      clearCart();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().setActiveOrder(order);
      }
      _onSuccess?.call(order);
    } catch (e) {
      _onError?.call('Payment succeeded but order failed: ${e.toString()}');
    } finally {
      isCheckingOut.value = false;
    }
  }

  void _handlePaymentFailure(PaymentFailure failure) {
    isCheckingOut.value = false;
    hasPaymentFailed.value = true;
    failureMessage.value = failure.message;
    _onError?.call(failure.message);
  }

  // Closing the sheet behaves as it always has on mobile (razorpay_flutter
  // reported it as a payment error): the cart stays, the retry sheet shows.
  void _handlePaymentCancelled() {
    _handlePaymentFailure(const PaymentFailure(code: 'CANCELLED', message: 'Payment cancelled.'));
  }
}
