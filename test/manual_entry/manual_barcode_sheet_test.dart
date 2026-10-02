// Widget tests for the "Enter barcode" sheet.
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/presentation/scanner_page/manual_barcode_lookup.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/manual_barcode_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _rice = ProductEntity(id: 'p1', barcode: 'UAT-0001', name: 'UAT Basmati Rice 1kg', price: 249, stock: 50);

void main() {
  late List<ProductEntity> found;
  late int cancels;
  late int lookups;

  Widget sheet(ProductLookup lookup) => MaterialApp(
        home: Scaffold(
          body: ManualBarcodeSheet(
            lookup: ManualBarcodeLookup((b, s) {
              lookups++;
              return lookup(b, s);
            }),
            storeId: 'store-1',
            storeName: 'DQ UAT Demo Mart',
            onFound: found.add,
            onCancel: () => cancels++,
          ),
        ),
      );

  setUp(() {
    found = [];
    cancels = 0;
    lookups = 0;
  });

  testWidgets('a valid barcode that exists goes to the confirm step (onFound), adding nothing itself', (t) async {
    await t.pumpWidget(sheet((b, s) async => _rice));
    await t.enterText(find.byKey(const Key('manual-barcode-field')), 'uat-0001');
    await t.tap(find.byKey(const Key('manual-barcode-find')));
    await t.pumpAndSettle();
    expect(found.single.barcode, 'UAT-0001');
    expect(cancels, 0);
  });

  testWidgets('invalid input shows the validation message and never queries', (t) async {
    await t.pumpWidget(sheet((b, s) async => _rice));
    await t.enterText(find.byKey(const Key('manual-barcode-field')), '12345');
    await t.tap(find.byKey(const Key('manual-barcode-find')));
    await t.pumpAndSettle();
    expect(find.textContaining('8, 12, 13 or 14 digits'), findsOneWidget);
    expect(found, isEmpty);
    expect(lookups, 0); // rejected by validation — the backend lookup was never called
  });

  testWidgets('not found shows a clear message and nothing is handed on', (t) async {
    await t.pumpWidget(sheet((b, s) async => null));
    await t.enterText(find.byKey(const Key('manual-barcode-field')), 'UAT-9999');
    await t.tap(find.byKey(const Key('manual-barcode-find')));
    await t.pumpAndSettle();
    expect(find.text('No product with barcode UAT-9999 is available in DQ UAT Demo Mart.'), findsOneWidget);
    expect(found, isEmpty);
  });

  testWidgets('input filter drops spaces and symbols as they are typed', (t) async {
    await t.pumpWidget(sheet((b, s) async => _rice));
    await t.enterText(find.byKey(const Key('manual-barcode-field')), 'UAT 0001!');
    expect(find.text('UAT0001'), findsOneWidget);
  });

  testWidgets('cancel calls onCancel and hands nothing on', (t) async {
    await t.pumpWidget(sheet((b, s) async => _rice));
    await t.enterText(find.byKey(const Key('manual-barcode-field')), 'UAT-0001');
    await t.tap(find.byKey(const Key('manual-barcode-cancel')));
    await t.pumpAndSettle();
    expect(cancels, 1);
    expect(found, isEmpty);
  });
}
