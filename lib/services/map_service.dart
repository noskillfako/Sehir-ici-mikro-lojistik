import 'package:latlong2/latlong.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/predefined_locations.dart';
import '../core/errors/app_exception.dart';
import '../models/location_preset_model.dart';

/// Harita, Mesafe ve Süre Hesaplama Servisi
class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  final Distance _distanceCalculator = const Distance();

  /// Sabit lokasyon listesi
  List<LocationPresetModel> getPredefinedLocations() {
    return PredefinedLocations.list;
  }

  /// İki koordinat arasındaki kuş uçuşu mesafeyi yol kıvrım katsayısı (1.3) ile çarparak km olarak hesaplar
  double calculateRouteDistanceKm(LatLng pickup, LatLng dropoff) {
    if (pickup.latitude == dropoff.latitude && pickup.longitude == dropoff.longitude) {
      throw AppException.sameLocation();
    }

    final meters = _distanceCalculator.as(LengthUnit.Meter, pickup, dropoff);
    final airKm = meters / 1000.0;
    final simulatedRoadKm = airKm * AppConstants.roadDistanceMultiplier;

    // Minimum 1.0 km taban mesafe
    final finalKm = simulatedRoadKm < 1.0 ? 1.0 : simulatedRoadKm;
    return double.parse(finalKm.toStringAsFixed(1));
  }

  /// Araç tipine ve mesafeye göre tahmini teslimat süresini (dakika) hesaplar
  int calculateEstimatedMinutes(double distanceKm, String vehicleType) {
    double averageSpeedKmH;
    int handlingBufferMinutes;

    switch (vehicleType) {
      case AppConstants.vehicleMotorcycle:
        averageSpeedKmH = 32.0;
        handlingBufferMinutes = 6;
        break;
      case AppConstants.vehicleTruck:
        averageSpeedKmH = 18.0;
        handlingBufferMinutes = 15;
        break;
      case AppConstants.vehicleCar:
      case AppConstants.vehicleMinivan:
        averageSpeedKmH = 22.0;
        handlingBufferMinutes = 10;
        break;
      case AppConstants.vehiclePanelvan:
      case AppConstants.vehicleMaxivan:
        averageSpeedKmH = 20.0;
        handlingBufferMinutes = 12;
        break;
      default:
        averageSpeedKmH = 25.0;
        handlingBufferMinutes = 8;
    }

    final drivingMinutes = (distanceKm / averageSpeedKmH) * 60;
    return (drivingMinutes + handlingBufferMinutes).round();
  }
}
