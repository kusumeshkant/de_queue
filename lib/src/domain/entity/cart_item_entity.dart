class CartItemEntity {
  final String barcode;
  final String name;
  final String subtitle;
  final String? sku;
  final double? mrp;
  final double price;
  final int stock;
  int quantity;

  CartItemEntity({
    required this.barcode,
    required this.name,
    required this.subtitle,
    this.sku,
    this.mrp,
    required this.price,
    this.stock = 0,
    this.quantity = 1,
  });
}
