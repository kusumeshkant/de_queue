import 'package:dq_app/src/domain/entity/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    super.address,
    super.imageUrl,
    super.latitude,
    super.longitude,
    super.distanceKm,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
        imageUrl: json['imageUrl'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      );
}
