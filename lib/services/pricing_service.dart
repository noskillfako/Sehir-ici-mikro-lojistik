import '../core/constants/app_constants.dart';

/// Dinamik Fiyatlandırma Motoru Servisi
class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  /// Toplam ağırlık (kg) ve hacim (Litre) değerine göre boyut/adet barem çarpanını hesaplar
  double getWeightVolumeMultiplier({
    required double totalWeightKg,
    required double totalVolumeLiters,
    String? fallbackPackageSize,
  }) {
    if (totalWeightKg <= 0 && fallbackPackageSize != null) {
      return AppConstants.sizeMultipliers[fallbackPackageSize] ?? 1.0;
    }
    // 1. Zarf / Evrak baremi: <= 1.0 kg ve <= 5 Litre
    if (totalWeightKg <= 1.0 && totalVolumeLiters <= 5.0) {
      return 1.0;
    }
    // 2. Küçük Paket baremi: <= 5.0 kg ve <= 25 Litre
    if (totalWeightKg <= 5.0 && totalVolumeLiters <= 25.0) {
      return 1.2;
    }
    // 3. Orta Koli baremi: <= 15.0 kg ve <= 75 Litre
    if (totalWeightKg <= 15.0 && totalVolumeLiters <= 75.0) {
      return 1.6;
    }
    // 4. Büyük Koli baremi: <= 60.0 kg ve <= 250 Litre
    if (totalWeightKg <= 60.0 && totalVolumeLiters <= 250.0) {
      return 2.2;
    }
    // 5. Ağır Ticari baremi: <= 120.0 kg ve <= 500 Litre
    if (totalWeightKg <= 120.0 && totalVolumeLiters <= 500.0) {
      return 3.5;
    }
    // 6. Paletli Malzeme baremi: <= 450.0 kg ve <= 1500 Litre
    if (totalWeightKg <= 450.0 && totalVolumeLiters <= 1500.0) {
      return 5.0;
    }
    // 7. Sanayi / Devasa Yük baremi: > 450 kg veya > 1500 Litre
    return 7.5;
  }

  /// Toplam müşteri tutarını hesaplar
  double calculateTotalPrice({
    required double distanceKm,
    required String packageSize,
    int itemCount = 1,
    double? totalWeightKg,
    double? totalVolumeLiters,
    required bool isFragile,
    required bool requiresThermalBag,
    String? vehicleType,
  }) {
    final weight = totalWeightKg ??
        ((AppConstants.packageUnitWeightsKg[packageSize] ?? 0.5) * itemCount);
    final volume = totalVolumeLiters ??
        ((AppConstants.packageUnitVolumesLiters[packageSize] ?? 2.0) * itemCount);

    final sizeMultiplier = getWeightVolumeMultiplier(
      totalWeightKg: weight,
      totalVolumeLiters: volume,
      fallbackPackageSize: packageSize,
    );

    final fuelMultiplier = vehicleType != null
        ? (AppConstants.vehicleFuelMultipliers[vehicleType] ?? 1.0)
        : 1.0;

    // 1. Ham Mesafe Tutarı: 60.0 + (distanceKm * 15.0)
    final baseFare = AppConstants.baseFare;
    final rawDistanceFare = distanceKm * AppConstants.perKmRate;

    // 2. Boyut ve Adet Katsayılı Tutar
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
    int itemCount = 1,
    double? totalWeightKg,
    double? totalVolumeLiters,
    required bool isFragile,
    required bool requiresThermalBag,
    String? vehicleType,
  }) {
    final weight = totalWeightKg ??
        ((AppConstants.packageUnitWeightsKg[packageSize] ?? 0.5) * itemCount);
    final volume = totalVolumeLiters ??
        ((AppConstants.packageUnitVolumesLiters[packageSize] ?? 2.0) * itemCount);

    final sizeMultiplier = getWeightVolumeMultiplier(
      totalWeightKg: weight,
      totalVolumeLiters: volume,
      fallbackPackageSize: packageSize,
    );

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
      'itemCount': itemCount.toDouble(),
      'totalWeightKg': double.parse(weight.toStringAsFixed(2)),
      'totalVolumeLiters': double.parse(volume.toStringAsFixed(2)),
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
