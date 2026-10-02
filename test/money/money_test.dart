// Amounts the customer sees must equal what the server computes and charges.
import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
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
import 'package:dq_app/src/presentation/order/order_confirmation_page.dart';
import 'package:dq_app/src/presentation/order/order_detail_page.dart';
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/money.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// (lines, discount %, subtotal, discount, tax, grand total — paise).
/// Expected values were produced by running the server's own code, copied
/// verbatim from origin/main (razorpayService.createRazorpayOrderFromCart +
/// discountService._calcDiscount), over fixed and pseudo-random carts.
/// Row 1 is the real UAT order: ₹249 → GST ₹44.82 → ₹293.82 (29382 paise).
const _serverCases = <(List<(num, int)>, num?, int, int, int, int)>[
    ([(249, 1)], null, 24900, 0, 4482, 29382),
    ([(249, 1)], 10, 24900, 2490, 4034, 26444),
    ([(99.99, 3)], 15, 29997, 4500, 4589, 30086),
    ([(0.05, 1), (10.5, 2)], null, 2105, 0, 379, 2484),
    ([(1999, 2), (49.5, 1)], 7.5, 404750, 30356, 67391, 441785),
    ([(100, 1)], 100, 10000, 10000, 0, 0),
    ([(333.33, 3)], 33, 99999, 33000, 12060, 79059),
    ([(2930.2, 2), (2429.88, 2), (3727.71, 3)], 16, 2190329, 350453, 331178, 2171054),
    ([(1684.51, 5), (2387.39, 1)], 31.5, 1080994, 340513, 133287, 873768),
    ([(4768.51, 5)], null, 2384255, 0, 429166, 2813421),
    ([(490.51, 3), (4188.33, 2)], 18, 984819, 177267, 145359, 952911),
    ([(2377.4, 1)], null, 237740, 0, 42793, 280533),
    ([(1070.42, 1)], 8, 107042, 8563, 17726, 116205),
    ([(1557.07, 2), (2564.58, 1)], null, 567872, 0, 102217, 670089),
    ([(532.89, 1), (1709.11, 3)], null, 566022, 0, 101884, 667906),
    ([(1798.11, 5), (376.46, 5), (1214.43, 5)], 44, 1694500, 745580, 170806, 1119726),
    ([(869.56, 3), (1404.44, 5), (2520.06, 5), (2210.69, 5)], 9.5, 3328463, 316204, 542207, 3554466),
    ([(4592.93, 1), (3079.34, 1)], 23, 767227, 176462, 106338, 697103),
    ([(89.71, 2), (2984.37, 2)], null, 614816, 0, 110667, 725483),
    ([(2246.71, 1), (3549.3, 2)], 40, 934531, 373812, 100929, 661648),
    ([(3070.69, 5), (4716.92, 2), (3645.57, 2), (3945.97, 3)], 28.5, 4391634, 1251616, 565203, 3705221),
    ([(614.96, 4)], null, 245984, 0, 44277, 290261),
    ([(4800.61, 5), (3486.93, 1), (3905.36, 3)], 4, 3920606, 156824, 677481, 4441263),
    ([(3314.31, 1), (1274.65, 3), (150.21, 3), (70.5, 5)], null, 794139, 0, 142945, 937084),
    ([(2582.26, 4)], 42, 1032904, 433820, 107835, 706919),
    ([(4183.19, 4), (902.64, 4)], 36.5, 2034332, 742531, 232524, 1524325),
    ([(351.27, 5), (3959, 1), (257.37, 1)], 10.5, 597272, 62714, 96220, 630778),
    ([(1997.08, 2)], 13, 399416, 51924, 62549, 410041),
    ([(4966.48, 3), (3810.53, 3), (2816.79, 4)], 0.5, 3759819, 18799, 673384, 4414404),
    ([(907.6, 3)], null, 272280, 0, 49010, 321290),
    ([(4435.16, 4), (934.59, 2), (4415.2, 1), (3911.37, 2)], 39, 3184776, 1242063, 349688, 2292401),
    ([(3115.52, 1), (1381.7, 3)], 26, 726062, 188776, 96711, 633997),
];

class _Repo implements OrderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StoreRepo implements StoreRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Dashboard extends DashboardController {
  _Dashboard()
      : super(
          getStoresUseCase: GetStoresUseCase(repository: _StoreRepo()),
          getNearbyStoresUseCase: GetNearbyStoresUseCase(repository: _StoreRepo()),
          getOrderByIdUseCase: GetOrderByIdUseCase(repository: _Repo()),
          getStoreByCodeUseCase: GetStoreByCodeUseCase(repository: _StoreRepo()),
        );

  // Skips loading stores / saved orders: not under test, needs platform plugins.
  @override
  // ignore: must_call_super
  void onInit() {}
}

/// Skips reading the saved theme from Hive.
class _Theme extends ThemeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _DiscountDs extends OrderRemoteDataSource {
  final subtotalsSent = <double>[];
  @override
  Future<Map<String, dynamic>> validateDiscountCode({
    required String code,
    required String storeId,
    required double subtotal,
  }) async {
    subtotalsSent.add(subtotal);
    // What the server returns for a 10% code (discount on what it was sent).
    final discount = (subtotal * 10).round() / 100;
    return {'valid': true, 'discountPercent': 10, 'discountAmount': discount, 'finalAmount': subtotal - discount};
  }
}

class _NoGateway implements PaymentGateway {
  @override
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks) async {}
  @override
  void dispose() {}
}

CartController _cart({OrderRemoteDataSource? ds}) {
  final repo = _Repo();
  return Get.put(CartController(
    createRazorpayOrderUseCase: CreateRazorpayOrderUseCase(repository: repo),
    createOrderUseCase: CreateOrderUseCase(repository: repo),
    validateCartStockUseCase: ValidateCartStockUseCase(repository: repo),
    paymentGateway: _NoGateway(),
    orderDs: ds,
  ));
}

CartItemEntity _line(num price, int qty) =>
    CartItemEntity(barcode: 'B$price', name: 'Item', subtitle: '', price: price.toDouble(), stock: 99, quantity: qty);

// A discounted order as the server returns it (S-7: total + tax == grandTotal).
const _discountedOrder = OrderEntity(
  id: '6ac02873ef56a98ea03e3764',
  storeName: 'DQ UAT Demo Mart',
  total: 224.1,
  discountAmount: 24.9,
  tax: 40.34,
  grandTotal: 264.44,
  status: 'pending',
  createdAt: '2026-10-03T03:26:03.898Z',
  items: [OrderItemEntity(barcode: 'UAT-0001', name: 'UAT Basmati Rice 1kg', price: 249, quantity: 1)],
);

void main() {
  group('formatRupees', () {
    test('whole rupees without decimals, otherwise exact paise', () {
      expect(formatRupees(249), '₹249');
      expect(formatRupees(44.82), '₹44.82');
      expect(formatRupees(293.82), '₹293.82');
      expect(formatRupees(10.5), '₹10.50');
      expect(formatRupees(0.05), '₹0.05');
      expect(formatRupees(0), '₹0');
      expect(formatRupees(-24.9), '-₹24.90');
    });

    test('rounds float noise to the paisa', () {
      expect(formatRupees(0.1 + 0.2), '₹0.30');
      expect(formatRupees(249 * 0.18), '₹44.82');
    });
  });

  group('CartTotals mirrors the server exactly', () {
    for (final (lines, pct, sub, disc, tax, grand) in _serverCases) {
      test('$lines @ ${pct ?? 0}%', () {
        final t = CartTotals.compute(lines, discountPercent: pct);
        expect([t.subtotalPaise, t.discountPaise, t.taxPaise, t.grandTotalPaise], [sub, disc, tax, grand]);
        expect(t.discountedPaise + t.taxPaise, t.grandTotalPaise);
      });
    }
  });

  group('CartController totals', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
      Get.put<DashboardController>(_Dashboard()).selectedStoreId.value = 'store-1';
    });
    tearDown(Get.reset);

    test('₹249 → GST ₹44.82 → total ₹293.82, as charged in UAT', () {
      final c = _cart();
      c.addItem(_line(249, 1));
      expect(formatRupees(c.subtotal), '₹249');
      expect(formatRupees(c.tax), '₹44.82');
      expect(formatRupees(c.effectiveGrandTotal), '₹293.82');
      expect(toPaise(c.effectiveGrandTotal), 29382);
    });

    // validateAndApplyDiscount shows a snackbar, which needs an app overlay.
    testWidgets('a discount code is validated on the pre-tax subtotal, and GST is on the discounted amount', (t) async {
      await t.pumpWidget(const GetMaterialApp(home: SizedBox()));
      final ds = _DiscountDs();
      final c = _cart(ds: ds);
      c.addItem(_line(249, 1));
      c.discountCodeCtrl.text = 'save10';
      await c.validateAndApplyDiscount();
      await t.pumpAndSettle(const Duration(seconds: 4));
      expect(ds.subtotalsSent, [249.0], reason: 'the server applies the discount before GST');
      expect(formatRupees(c.discountAmount), '₹24.90');
      expect(formatRupees(c.tax), '₹40.34');
      expect(toPaise(c.effectiveGrandTotal), 26444); // server: 22410 + 4034
    });

    testWidgets('changing the cart after applying a code re-computes the discount', (t) async {
      await t.pumpWidget(const GetMaterialApp(home: SizedBox()));
      final c = _cart(ds: _DiscountDs());
      c.addItem(_line(249, 1));
      c.discountCodeCtrl.text = 'save10';
      await c.validateAndApplyDiscount();
      await t.pumpAndSettle(const Duration(seconds: 4));
      c.incrementQuantity('B249');
      final server = CartTotals.compute([(249, 2)], discountPercent: 10);
      expect(toPaise(c.effectiveGrandTotal), server.grandTotalPaise);
    });
  });

  test('the saved pending order keeps the discount across an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.savePendingOrder(_discountedOrder);
    final loaded = (await LocalStorage.loadPendingOrder())!;
    expect(loaded.discountAmount, 24.9);
    expect(formatRupees(loaded.subtotalBeforeDiscount), '₹249');
    expect(formatRupees(loaded.grandTotal), '₹264.44');
  });

  group("order screens show the server's exact values", () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
      Get.put<ThemeController>(_Theme());
    });
    tearDown(Get.reset);

    Future<void> pump(WidgetTester t, Widget page) async {
      t.view.physicalSize = const Size(900, 2400); // wide: the test font is much wider than real fonts
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(GetMaterialApp(home: page));
      await t.pump();
    }

    testWidgets('confirmation: subtotal before discount, discount, GST, total to the paisa', (t) async {
      await pump(t, const OrderConfirmationPage(order: _discountedOrder));
      expect(find.text('₹249'), findsWidgets); // subtotal before discount
      expect(find.text('−₹24.90'), findsOneWidget);
      expect(find.text('₹40.34'), findsOneWidget);
      expect(find.text('₹264.44'), findsOneWidget);
    });

    testWidgets('order detail: same values, discount line shown', (t) async {
      await pump(t, const OrderDetailPage(order: _discountedOrder));
      expect(find.text('−₹24.90'), findsOneWidget);
      expect(find.text('₹40.34'), findsOneWidget);
      expect(find.text('₹264.44'), findsOneWidget);
    });
  });
}
