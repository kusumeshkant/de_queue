// Manual barcode entry — validation, lookup, confirm-then-add, entryMethod.
import 'package:dq_app/src/domain/barcode/manual_barcode.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/scanner_page/manual_barcode_lookup.dart';
import 'package:dq_app/src/presentation/scanner_page/product_detail_controller.dart';
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

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

const _rice = ProductEntity(
  id: 'p1', barcode: 'UAT-0001', name: 'UAT Basmati Rice 1kg', mrp: 299, price: 249, stock: 50,
  color: 'White', size: '1kg',
);

CartController _registerCart() {
  final repo = _UnusedRepo();
  return Get.put(CartController(
    createRazorpayOrderUseCase: CreateRazorpayOrderUseCase(repository: repo),
    createOrderUseCase: CreateOrderUseCase(repository: repo),
    validateCartStockUseCase: ValidateCartStockUseCase(repository: repo),
    paymentGateway: _UnusedGateway(),
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('validateManualBarcode — input validation', () {
    test('trims and upper-cases', () {
      expect(validateManualBarcode('  uat-0001 ').barcode, 'UAT-0001');
    });

    test('accepts retail EAN/UPC/GTIN lengths (8, 12, 13, 14 digits)', () {
      for (final code in ['12345670', '012345678905', '8901030870011', '18901030870018']) {
        expect(validateManualBarcode(code).isValid, isTrue, reason: code);
      }
    });

    test('accepts the store-code formats in the catalogue (production ZUD…, UAT UAT-…)', () {
      expect(validateManualBarcode('ZUD0000000001').barcode, 'ZUD0000000001');
      expect(validateManualBarcode('UAT-0010').barcode, 'UAT-0010');
    });

    test('rejects all-digit codes of a non-retail length', () {
      for (final code in ['1234567', '1234567890', '123456789012345']) {
        final v = validateManualBarcode(code);
        expect(v.isValid, isFalse, reason: code);
        expect(v.error, contains('8, 12, 13 or 14 digits'));
      }
    });

    test('rejects empty, spaces, symbols, too short and too long', () {
      expect(validateManualBarcode('   ').isValid, isFalse);
      expect(validateManualBarcode('UAT 0001').isValid, isFalse);
      expect(validateManualBarcode('UAT_0001').isValid, isFalse);
      expect(validateManualBarcode('8901030870011;DROP').isValid, isFalse);
      expect(validateManualBarcode('AB1').isValid, isFalse);
      expect(validateManualBarcode('A' * 33).isValid, isFalse);
    });
  });

  group('ManualBarcodeLookup — lookup paths', () {
    test('invalid input is rejected and the backend is never called', () async {
      var calls = 0;
      final lookup = ManualBarcodeLookup((b, s) async {
        calls++;
        return _rice;
      });
      final out = await lookup.run('12 34', storeId: 'store-1');
      expect(out.isFound, isFalse);
      expect(out.message, isNotNull);
      expect(calls, 0);
    });

    test('looks up the normalised barcode in the selected store', () async {
      final seen = <String>[];
      final lookup = ManualBarcodeLookup((b, s) async {
        seen.addAll([b, s]);
        return _rice;
      });
      final out = await lookup.run(' uat-0001', storeId: 'store-1');
      expect(out.product, same(_rice));
      expect(seen, ['UAT-0001', 'store-1']);
    });

    test('not found (or unavailable) gives a clear message and no product', () async {
      final lookup = ManualBarcodeLookup((b, s) async => null);
      final out = await lookup.run('UAT-9999', storeId: 'store-1', storeName: 'DQ UAT Demo Mart');
      expect(out.isFound, isFalse);
      expect(out.message, 'No product with barcode UAT-9999 is available in DQ UAT Demo Mart.');
    });

    test('out of stock is rejected before the confirm step', () async {
      final lookup = ManualBarcodeLookup((b, s) async => const ProductEntity(
          id: 'p10', barcode: 'UAT-0010', name: 'UAT Last Unit Item', price: 10, stock: 0));
      final out = await lookup.run('UAT-0010', storeId: 'store-1', storeName: 'DQ UAT Demo Mart');
      expect(out.isFound, isFalse);
      expect(out.message, contains('out of stock'));
    });

    test('no store selected is rejected without calling the backend', () async {
      var calls = 0;
      final lookup = ManualBarcodeLookup((b, s) async {
        calls++;
        return _rice;
      });
      final out = await lookup.run('UAT-0001', storeId: '');
      expect(out.isFound, isFalse);
      expect(calls, 0);
    });

    test('a network error is a clear message, not a crash', () async {
      final lookup = ManualBarcodeLookup((b, s) async => throw Exception('offline'));
      final out = await lookup.run('UAT-0001', storeId: 'store-1');
      expect(out.isFound, isFalse);
      expect(out.message, contains('Check your connection'));
    });
  });

  group('confirm-then-add and entryMethod', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
    });
    tearDown(Get.reset);

    test('looking a product up adds nothing — only confirming adds it', () async {
      final cart = _registerCart();
      final out = await ManualBarcodeLookup((b, s) async => _rice).run('UAT-0001', storeId: 'store-1');
      expect(out.isFound, isTrue);
      expect(cart.items, isEmpty, reason: 'lookup alone must not touch the cart');

      final added = await ProductDetailController().addToCart(out.product!, entryMethod: CartEntryMethod.manual);
      expect(added, 1);
      expect(cart.items.single.barcode, 'UAT-0001');
      expect(cart.items.single.entryMethod, CartEntryMethod.manual);
    });

    test('cancel after lookup leaves the cart unchanged', () async {
      final cart = _registerCart();
      final out = await ManualBarcodeLookup((b, s) async => _rice).run('UAT-0001', storeId: 'store-1');
      expect(out.isFound, isTrue);
      // Customer closes the product sheet without pressing "Add to Cart".
      expect(cart.items, isEmpty);
    });

    test('a scanned line is recorded as scan by default', () async {
      final cart = _registerCart();
      await ProductDetailController().addToCart(_rice);
      expect(cart.items.single.entryMethod, CartEntryMethod.scan);
      expect(cart.items.single.isManualEntry, isFalse);
    });

    test('manual is sticky: scanned then typed (or typed then scanned) stays manual', () async {
      final cart = _registerCart();
      await ProductDetailController().addToCart(_rice);
      await ProductDetailController().addToCart(_rice, entryMethod: CartEntryMethod.manual);
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.entryMethod, CartEntryMethod.manual);

      cart.clearCart();
      await ProductDetailController().addToCart(_rice, entryMethod: CartEntryMethod.manual);
      await ProductDetailController().addToCart(_rice);
      expect(cart.items.single.entryMethod, CartEntryMethod.manual);
    });
  });
}
