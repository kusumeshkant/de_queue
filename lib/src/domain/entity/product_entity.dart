class ProductEntity {
  final String id;
  final String barcode;
  final String? sku;
  final String name;
  final String? description;
  final double? mrp;
  final double price;
  final String? imageUrl;
  final int stock;

  const ProductEntity({
    required this.id,
    required this.barcode,
    this.sku,
    required this.name,
    this.description,
    this.mrp,
    required this.price,
    this.imageUrl,
    this.stock = 0,
  });
}
