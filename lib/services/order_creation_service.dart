import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import 'hive_database_service.dart';
import 'map_service.dart';
import 'pricing_service.dart';

/// Sipariş Oluşturma Servisi
class OrderCreationService {
  static final OrderCreationService _instance = OrderCreationService._internal();
  factory OrderCreationService() => _instance;
  OrderCreationService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();
  final MapService _mapService = MapService();
  final PricingService _pricingService = PricingService();
  final Random _random = Random();

  /// 1000 ile 9999 arasında 4 haneli rastgele teslimat onay kodu üretir
  String generateOtpCode() {
    final code = 1000 + _random.nextInt(9000);
    return code.toString();
  }

  /// Yeni sipariş oluşturur ve Hive ordersBox içine kaydeder
  Future<OrderModel> createOrder({
    required String customerId,
    required String customerName,
    required String packageSize,
    int itemCount = 1,
    Map<String, int>? itemQuantities,
    double? totalWeightKg,
    double? totalVolumeLiters,
    String? recommendedVehicle,
    String? preferredVehicle,
    required String contentType,
    required String customDescription,
    required bool isFragile,
    required bool requiresThermalBag,
    required String pickupTitle,
    required String pickupAddressDetail,
    required double pickupLat,
    required double pickupLng,
    required String dropoffTitle,
    required String dropoffAddressDetail,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    // Validasyonlar
    if (customDescription.trim().length < 5) {
      throw AppException.descriptionTooShort();
    }

    if (pickupTitle.trim().isEmpty ||
        dropoffTitle.trim().isEmpty ||
        pickupAddressDetail.trim().isEmpty ||
        dropoffAddressDetail.trim().isEmpty) {
      throw AppException.missingOrderFields('Lütfen adres başlıklarını ve açık adres tariflerini doldurun.');
    }

    if (pickupLat == dropoffLat && pickupLng == dropoffLng) {
      throw AppException.sameLocation();
    }

    // Mesafe ve yük hesaplama
    final pickupPoint = LatLng(pickupLat, pickupLng);
    final dropoffPoint = LatLng(dropoffLat, dropoffLng);
    final distanceKm = _mapService.calculateRouteDistanceKm(pickupPoint, dropoffPoint);

    final weight = totalWeightKg ??
        ((AppConstants.packageUnitWeightsKg[packageSize] ?? 0.5) * itemCount);
    final volume = totalVolumeLiters ??
        ((AppConstants.packageUnitVolumesLiters[packageSize] ?? 2.0) * itemCount);
    final recVehicle = recommendedVehicle ??
        AppConstants.getRecommendedVehicle(weight, volume);

    final price = _pricingService.calculateTotalPrice(
      distanceKm: distanceKm,
      packageSize: packageSize,
      itemCount: itemCount,
      totalWeightKg: weight,
      totalVolumeLiters: volume,
      isFragile: isFragile,
      requiresThermalBag: requiresThermalBag,
      vehicleType: preferredVehicle ?? recVehicle,
    );

    // Sipariş ID'si ve OTP
    final orderNumber = 1000 + _random.nextInt(9000);
    final orderId = 'ORD-$orderNumber';
    final otpCode = generateOtpCode();
    final now = DateTime.now().toIso8601String();

    final order = OrderModel(
      id: orderId,
      customerId: customerId,
      customerName: customerName,
      courierVehicle: null,
      preferredVehicle: preferredVehicle,
      recommendedVehicle: recVehicle,
      packageSize: packageSize,
      itemCount: itemCount,
      itemQuantities: itemQuantities ?? {packageSize: itemCount},
      totalWeightKg: weight,
      totalVolumeLiters: volume,
      contentType: contentType,
      customDescription: customDescription.trim(),
      isFragile: isFragile,
      requiresThermalBag: requiresThermalBag,
      pickupTitle: pickupTitle.trim(),
      pickupAddressDetail: pickupAddressDetail.trim(),
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffTitle: dropoffTitle.trim(),
      dropoffAddressDetail: dropoffAddressDetail.trim(),
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      distanceKm: distanceKm,
      price: price,
      deliveryOtpCode: otpCode,
      status: AppConstants.statusWaiting,
      createdAt: now,
    );

    await _db.ordersBox.put(order.id, order.toMap());
    return order;
  }
}
