import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/service_core/payment/razorpay_service.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartController extends GetxController {
  final CreateRazorpayOrderUseCase createRazorpayOrderUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final ValidateCartStockUseCase validateCartStockUseCase;
  final RazorpayService razorpayService;
  final OrderRemoteDataSource _orderDs;

  CartController({
    required this.createRazorpayOrderUseCase,
    required this.createOrderUseCase,
    required this.validateCartStockUseCase,
    required this.razorpayService,
    OrderRemoteDataSource? orderDs,
  }) : _orderDs = orderDs ?? OrderRemoteDataSource();

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
  void onInit() {
    super.onInit();
    razorpayService.registerCallbacks(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void onClose() {
    discountCodeCtrl.dispose();
    razorpayService.dispose();
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
          backgroundColor: Colors.orange,
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
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('Empty Cart', 'Add items to cart before applying a discount.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dashboard = Get.find<DashboardController>();
    final storeId = dashboard.selectedStoreId.value;
    if (storeId.isEmpty) {
      Get.snackbar('No Store', 'Select a store first.',
          backgroundColor: Colors.orange,
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
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Invalid Code',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
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

      final razorpayOrder =
          await createRazorpayOrderUseCase.execute(effectiveGrandTotal);

      razorpayService.openPaymentSheet(
        razorpayOrderId: razorpayOrder.id,
        amountInPaise: razorpayOrder.amount,
      );
    } catch (e) {
      isCheckingOut.value = false;
      onError(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final dashboard = Get.find<DashboardController>();

      final order = await createOrderUseCase.execute(
        storeId: dashboard.selectedStoreId.value,
        items: List.from(items),
        total: subtotal,
        tax: tax,
        grandTotal: effectiveGrandTotal,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        discountCode: appliedDiscountCode,
      );

      clearCart();
      await LocalStorage.savePendingOrder(order);
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

  void _handlePaymentError(PaymentFailureResponse response) {
    isCheckingOut.value = false;
    final msg = response.message ?? 'Payment failed. Please try again.';
    hasPaymentFailed.value = true;
    failureMessage.value = msg;
    _onError?.call(msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isCheckingOut.value = false;
    _onError?.call('External wallet payment is not supported. Please use a card or UPI.');
  }
}
