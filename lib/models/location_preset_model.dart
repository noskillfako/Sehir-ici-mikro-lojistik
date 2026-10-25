import 'package:latlong2/latlong.dart';

/// Haritada hızlı seçim için önceden tanımlı lokasyon modeli
class LocationPresetModel {
  final String id;
  final String name;
  final String district;
  final double lat;
  final double lng;
  final String description;

  const LocationPresetModel({
    required this.id,
    required this.name,
    required this.district,
    required this.lat,
    required this.lng,
    required this.description,
  });

  LatLng get latLng => LatLng(lat, lng);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'lat': lat,
      'lng': lng,
      'description': description,
    };
  }

  factory LocationPresetModel.fromMap(Map<String, dynamic> map) {
    return LocationPresetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      district: map['district'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      description: map['description'] as String? ?? '',
    );
  }
}
