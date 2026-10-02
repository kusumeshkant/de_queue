import 'package:dq_app/src/domain/barcode/manual_barcode.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';

/// Result of looking up a manually entered barcode. Exactly one of
/// [product] / [message] is set; only a product may go on to the confirm step.
class ManualLookupOutcome {
  final ProductEntity? product;
  final String? message;

  const ManualLookupOutcome.found(ProductEntity this.product) : message = null;
  const ManualLookupOutcome.rejected(String this.message) : product = null;

  bool get isFound => product != null;
}

typedef ProductLookup = Future<ProductEntity?> Function(String barcode, String storeId);

/// Validates a typed barcode and looks it up in the selected store through the
/// same productByBarcode query scanning uses. Never adds anything to the cart —
/// adding happens only after the customer confirms on the product sheet.
class ManualBarcodeLookup {
  final ProductLookup lookup;

  const ManualBarcodeLookup(this.lookup);

  Future<ManualLookupOutcome> run(String raw, {required String storeId, String storeName = ''}) async {
    final validation = validateManualBarcode(raw);
    if (!validation.isValid) return ManualLookupOutcome.rejected(validation.error!);
    if (storeId.isEmpty) {
      return const ManualLookupOutcome.rejected('Select a store before adding products.');
    }

    final ProductEntity? product;
    try {
      product = await lookup(validation.barcode!, storeId);
    } catch (_) {
      return const ManualLookupOutcome.rejected('Could not look up the product. Check your connection and try again.');
    }

    final where = storeName.isEmpty ? 'this store' : storeName;
    if (product == null) {
      // productByBarcode returns null for unknown AND unavailable (soft-deleted) products.
      return ManualLookupOutcome.rejected('No product with barcode ${validation.barcode} is available in $where.');
    }
    if (product.stock <= 0) {
      return ManualLookupOutcome.rejected('${product.name} is out of stock in $where.');
    }
    return ManualLookupOutcome.found(product);
  }
}
