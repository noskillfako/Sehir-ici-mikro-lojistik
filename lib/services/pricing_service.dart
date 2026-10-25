import '../core/constants/app_constants.dart';

/// Dinamik Fiyatlandırma Motoru Servisi
class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  /// Toplam müşteri tutarını hesaplar
  double calculateTotalPrice({
    required double distanceKm,
    required String packageSize,
    required bool isFragile,
    required bool requiresThermalBag,
    String? vehicleType,
  }) {
    final sizeMultiplier = AppConstants.sizeMultipliers[packageSize] ?? 1.0;
    final fuelMultiplier = vehicleType != null
        ? (AppConstants.vehicleFuelMultipliers[vehicleType] ?? 1.0)
        : 1.0;

    // 1. Ham Mesafe Tutarı: 60.0 + (distanceKm * 15.0)
    final baseFare = AppConstants.baseFare;
    final rawDistanceFare = distanceKm * AppConstants.perKmRate;

    // 2. Boyut Çarpanlı Tutar
    final sizeAdjusted = (baseFare + rawDistanceFare) * sizeMultiplier;

    // 3. Araç Büyüklüğü & Yakıt Tüketimi Ek Maliyeti (Büyük araç -> Yüksek yakıt)
    final fuelSurcharge = rawDistanceFare * (fuelMultiplier - 1.0);

    // 4. Ek Özellikler
    final fragileCost = isFragile ? AppConstants.fragileFee : 0.0;
    final thermalCost = requiresThermalBag ? AppConstants.thermalBagFee : 0.0;

    final total = sizeAdjusted + fuelSurcharge + fragileCost + thermalCost;
    return double.parse(total.toStringAsFixed(2));
  }

  /// Kurye net kazancını hesaplar (%15 platform komisyonu düşülür)
  double calculateCourierEarnings(double totalPrice) {
    final earnings = totalPrice * (1.0 - AppConstants.commissionRate);
    return double.parse(earnings.toStringAsFixed(2));
  }

  /// Fiyat kırılımını arayüzde detaylı göstermek için döndürür
  Map<String, double> getPriceBreakdown({
    required double distanceKm,
    required String packageSize,
    required bool isFragile,
    required bool requiresThermalBag,
    String? vehicleType,
  }) {
    final sizeMultiplier = AppConstants.sizeMultipliers[packageSize] ?? 1.0;
    final fuelMultiplier = vehicleType != null
        ? (AppConstants.vehicleFuelMultipliers[vehicleType] ?? 1.0)
        : 1.0;

    final baseFare = AppConstants.baseFare;
    final distanceFare = distanceKm * AppConstants.perKmRate;
    final rawFare = baseFare + distanceFare;
    final sizeAdjusted = rawFare * sizeMultiplier;
    final sizeExtra = sizeAdjusted - rawFare;

    // Araç Yakıt Ek Tüketim Tutarı
    final fuelSurcharge = distanceFare * (fuelMultiplier - 1.0);

    final fragileFee = isFragile ? AppConstants.fragileFee : 0.0;
    final thermalBagFee = requiresThermalBag ? AppConstants.thermalBagFee : 0.0;
    final totalPrice = sizeAdjusted + fuelSurcharge + fragileFee + thermalBagFee;
    final courierEarnings = calculateCourierEarnings(totalPrice);
    final platformCommission = totalPrice - courierEarnings;

    return {
      'baseFare': baseFare,
      'distanceFare': double.parse(distanceFare.toStringAsFixed(2)),
      'sizeMultiplier': sizeMultiplier,
      'sizeExtra': double.parse(sizeExtra.toStringAsFixed(2)),
      'fuelMultiplier': fuelMultiplier,
      'fuelSurcharge': double.parse(fuelSurcharge.toStringAsFixed(2)),
      'fragileFee': fragileFee,
      'thermalBagFee': thermalBagFee,
      'totalPrice': double.parse(totalPrice.toStringAsFixed(2)),
      'courierEarnings': courierEarnings,
      'platformCommission': double.parse(platformCommission.toStringAsFixed(2)),
    };
  }
}
