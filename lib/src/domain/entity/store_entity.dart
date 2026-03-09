class StoreEntity {
  final String id;
  final String? storeCode;
  final String name;
  final String? address;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  const StoreEntity({
    required this.id,
    this.storeCode,
    required this.name,
    this.address,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  /// Formatted distance string, e.g. "1.2 km" or "850 m"
  String? get formattedDistance {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}
