/// How a line got into the cart. Manually entered barcodes are not proof the
/// customer is holding that item, so staff can check them at exit (the
/// highlighting itself comes with the exit-flow task; this is client-side only).
enum CartEntryMethod { scan, manual }

class CartItemEntity {
  final String barcode;
  final String name;
  final String subtitle;
  final String? sku;
  final double? mrp;
  final double price;
  final int stock;
  int quantity;

  /// Sticky: once any unit of this line was entered manually, the line stays
  /// [CartEntryMethod.manual] even if more units are scanned later.
  CartEntryMethod entryMethod;

  CartItemEntity({
    required this.barcode,
    required this.name,
    required this.subtitle,
    this.sku,
    this.mrp,
    required this.price,
    this.stock = 0,
    this.quantity = 1,
    this.entryMethod = CartEntryMethod.scan,
  });

  bool get isManualEntry => entryMethod == CartEntryMethod.manual;
}
