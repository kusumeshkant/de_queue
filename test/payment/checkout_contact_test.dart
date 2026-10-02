// Razorpay checkout is pre-filled with the customer's phone/email when the
// profile has them, and checkout is never blocked when it doesn't.
import 'dart:async';

import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_order_by_id_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_store_by_code_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/service_core/payment/checkout_contact.dart';
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Repo implements OrderRepository {
  @override
  Future<List<String>> validateCartStock({required String storeId, required List<CartItemEntity> items}) async => [];

  @override
  Future<RazorpayOrderEntity> createRazorpayOrder({
    required String storeId,
    required List<CartItemEntity> items,
    String? discountCode,
  }) async =>
      const RazorpayOrderEntity(id: 'order_test', amount: 29382, currency: 'INR', keyId: 'rzp_test_x');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StoreRepo implements StoreRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Only selectedStoreId matters here; skip loading stores / pending orders.
class _Dashboard extends DashboardController {
  _Dashboard()
      : super(
          getStoresUseCase: GetStoresUseCase(repository: _StoreRepo()),
          getNearbyStoresUseCase: GetNearbyStoresUseCase(repository: _StoreRepo()),
          getOrderByIdUseCase: GetOrderByIdUseCase(repository: _Repo()),
          getStoreByCodeUseCase: GetStoreByCodeUseCase(repository: _StoreRepo()),
        );

  @override
  void onInit() {}
}

class _CapturingGateway implements PaymentGateway {
  final requests = <PaymentRequest>[];
  @override
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks) async => requests.add(request);
  @override
  void dispose() {}
}

CartItemEntity _item() => CartItemEntity(barcode: 'UAT-0001', name: 'UAT Basmati Rice 1kg', subtitle: '', price: 249, stock: 50);

Future<PaymentRequest> _checkout(ProfileLoader loader) async {
  final repo = _Repo();
  final gateway = _CapturingGateway();
  final cart = Get.put(CartController(
    createRazorpayOrderUseCase: CreateRazorpayOrderUseCase(repository: repo),
    createOrderUseCase: CreateOrderUseCase(repository: repo),
    validateCartStockUseCase: ValidateCartStockUseCase(repository: repo),
    paymentGateway: gateway,
    profileLoader: loader,
  ));
  cart.addItem(_item());
  final errors = <String>[];
  await cart.checkout(onSuccess: (_) {}, onError: errors.add);
  expect(errors, isEmpty);
  expect(gateway.requests, hasLength(1), reason: 'checkout must open even without a profile');
  return gateway.requests.single;
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<DashboardController>(_Dashboard()).selectedStoreId.value = 'store-1';
  });
  tearDown(Get.reset);

  group('CheckoutContact.fromUser', () {
    test('uses phone and email from the profile', () {
      final c = CheckoutContact.fromUser(const UserEntity(id: 'u', phone: '+91 98765-43210', email: ' a@b.in '));
      expect(c.contact, '+919876543210');
      expect(c.email, 'a@b.in');
    });

    test('drops values Razorpay would reject instead of failing checkout', () {
      final c = CheckoutContact.fromUser(const UserEntity(id: 'u', phone: '12345', email: 'not-an-email'));
      expect(c.contact, '');
      expect(c.email, '');
    });

    test('no user → empty', () {
      expect(CheckoutContact.fromUser(null).contact, '');
      expect(CheckoutContact.fromUser(const UserEntity(id: 'u')).email, '');
    });
  });

  group('checkout prefill', () {
    test('the logged-in customer\'s phone and email reach the Razorpay checkout', () async {
      final req = await _checkout(() async => const UserEntity(id: 'u', phone: '+919876543210', email: 'cust@dqstore.in'));
      expect(req.contact, '+919876543210');
      expect(req.email, 'cust@dqstore.in');
      expect(req.orderId, 'order_test');
      expect(req.amountInPaise, 29382);
    });

    test('profile with only an email: email pre-filled, phone left to the customer', () async {
      final req = await _checkout(() async => const UserEntity(id: 'u', email: 'cust@dqstore.in'));
      expect(req.contact, '');
      expect(req.email, 'cust@dqstore.in');
    });

    test('profile lookup fails → checkout still opens with an empty prefill', () async {
      final req = await _checkout(() async => throw Exception('network down'));
      expect(req.contact, '');
      expect(req.email, '');
    });

    test('profile lookup hangs → checkout opens after the timeout, not never', () async {
      final never = Completer<UserEntity?>();
      final started = DateTime.now();
      final req = await _checkout(() => never.future);
      expect(req.contact, '');
      expect(DateTime.now().difference(started), lessThan(const Duration(seconds: 10)));
    });
  });
}
