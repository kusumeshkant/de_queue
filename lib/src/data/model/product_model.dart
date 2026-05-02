import 'package:dq_app/src/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.barcode,
    super.sku,
    required super.name,
    super.description,
    super.mrp,
    required super.price,
    super.imageUrl,
    super.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        barcode: json['barcode'] as String,
        sku: json['sku'] as String?,
        name: json['name'] as String,
        description: json['description'] as String?,
        mrp: (json['mrp'] as num?)?.toDouble(),
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
      );
}
