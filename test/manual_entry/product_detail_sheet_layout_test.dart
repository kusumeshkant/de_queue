// The confirm sheet must keep "Add to Cart" fully on screen and tappable on
// short viewports (laptop browsers are often ~650px tall, phones in landscape less).
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/product_detail_sheet.dart';
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Worst case the sheet shows: long name, colour/size, MRP discount, SKU,
// a 4-line description and the manual-entry note.
const _product = ProductEntity(
  id: 'p1',
  barcode: 'UAT-0001',
  name: 'UAT Basmati Rice Premium Long Grain Extra Aged 1kg Family Pack',
  mrp: 299,
  price: 249,
  stock: 50,
  sku: 'SKU-UAT-0001',
  color: 'White',
  size: '1kg',
  description: 'A long description that wraps over several lines so the scrollable '
      'part of the sheet is as tall as it can get. A long description that wraps '
      'over several lines so the scrollable part of the sheet is as tall as it can '
      'get. A long description that wraps over several lines.',
);

class _UnusedRepo implements OrderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('not used in these tests');
}

class _UnusedGateway implements PaymentGateway {
  @override
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks) async {}
  @override
  void dispose() {}
}

CartController _registerCart() {
  final repo = _UnusedRepo();
  return Get.put(CartController(
    createRazorpayOrderUseCase: CreateRazorpayOrderUseCase(repository: repo),
    createOrderUseCase: CreateOrderUseCase(repository: repo),
    validateCartStockUseCase: ValidateCartStockUseCase(repository: repo),
    paymentGateway: _UnusedGateway(),
  ));
}

// A typical fashion line: a longer name plus colour and size.
const _typical = ProductEntity(
  id: 'p1', barcode: 'UAT-0001', name: 'UAT Slim Fit Cotton Shirt Navy', mrp: 299, price: 249, stock: 50,
  color: 'Navy', size: 'M',
);

Future<void> _openSheet(WidgetTester t, Size size, {ProductEntity product = _product}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox.expand())));
  Get.bottomSheet(
    ProductDetailSheet(product: product, entryMethod: CartEntryMethod.manual),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });
  tearDown(Get.reset);

  for (final size in const [Size(1280, 650), Size(390, 650), Size(640, 360)]) {
    testWidgets('Add to Cart is fully visible and tappable at ${size.width.toInt()}x${size.height.toInt()}', (t) async {
      final cart = _registerCart();
      await _openSheet(t, size);

      final button = find.widgetWithText(ElevatedButton, 'Add to Cart');
      expect(button, findsOneWidget);
      final rect = t.getRect(button);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(size.height), reason: 'button bottom ${rect.bottom} is below the screen');
      expect(t.getRect(find.widgetWithText(OutlinedButton, 'Cancel')).bottom, lessThanOrEqualTo(size.height));

      // A real tap at the button's centre must land on it (no warning, no miss).
      await t.tapAt(rect.center);
      await t.pumpAndSettle(const Duration(seconds: 3)); // let the confirmation snackbar finish
      expect(t.takeException(), isNull);
      expect(cart.items.single.barcode, 'UAT-0001');
      expect(cart.items.single.entryMethod, CartEntryMethod.manual);
    });
  }

  for (final size in const [Size(1280, 650), Size(390, 650)]) {
    testWidgets('price and the manual-entry note are visible without scrolling at ${size.width.toInt()}x${size.height.toInt()}', (t) async {
      _registerCart();
      await _openSheet(t, size, product: _typical);
      final buttonTop = t.getRect(find.widgetWithText(ElevatedButton, 'Add to Cart')).top;
      for (final f in [find.text('₹249'), find.text('₹299'), find.textContaining('Entered by barcode UAT-0001')]) {
        final r = t.getRect(f);
        expect(r.bottom, lessThanOrEqualTo(buttonTop), reason: '$f ends at ${r.bottom}, buttons start at $buttonTop');
      }
    });
  }

  testWidgets('product details scroll while the buttons stay pinned', (t) async {
    _registerCart();
    await _openSheet(t, const Size(390, 650));
    final before = t.getRect(find.widgetWithText(ElevatedButton, 'Add to Cart'));
    await t.drag(find.byIcon(Icons.inventory_2_rounded), const Offset(0, -400));
    await t.pumpAndSettle();
    expect(t.getRect(find.text('Quantity')).bottom, lessThanOrEqualTo(before.top), reason: 'details scrolled up into view');
    final after = t.getRect(find.widgetWithText(ElevatedButton, 'Add to Cart'));
    expect(after, before);
  });
}
