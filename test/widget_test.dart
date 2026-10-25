import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/core/constants/app_constants.dart';
import 'package:sehir_ici_mikro_lojistik/models/user_model.dart';
import 'package:sehir_ici_mikro_lojistik/services/pricing_service.dart';

void main() {
  group('RouteDuck Core Logic Tests', () {
    test('Dinamik fiyatlandırma hesaplaması kurallara uygun çalışmalıdır', () {
      final pricing = PricingService();

      // Mesafe: 10 km, Document (çarpan 1.0), normal
      // Ham: 60 + 10 * 15 = 210 TL
      final docPrice = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: false,
        requiresThermalBag: false,
      );
      expect(docPrice, 210.0);

      // Kırılabilir (+30 TL) ve Termal Çanta (+25 TL) ek ücretleri
      final withExtras = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: true,
        requiresThermalBag: true,
      );
      expect(withExtras, 265.0);

      // Kurye net kazancı (%85)
      final courierEarnings = pricing.calculateCourierEarnings(200.0);
      expect(courierEarnings, 170.0);
    });

    test('UserModel toMap ve fromMap doğru serileştirilmelidir', () {
      const user = UserModel(
        id: 'usr_test_1',
        fullName: 'Test Kurye',
        phone: '5550001122',
        password: 'pass',
        role: AppConstants.roleCourier,
        vehicleType: AppConstants.vehicleMotorcycle,
        hasThermalBag: true,
      );

      final map = user.toMap();
      final parsed = UserModel.fromMap(map);

      expect(parsed.id, user.id);
      expect(parsed.fullName, user.fullName);
      expect(parsed.isCourier, true);
      expect(parsed.hasThermalBag, true);
    });
    test('Ağır kargo (+600 kg) ve paletli gönderilerde fiyatlandırma doğru çalışmalıdır', () {
      final pricing = PricingService();

      // Mesafe: 10 km, Heavy Cargo (çarpan 7.5)
      // Ham: (60 + 10 * 15) * 7.5 = 210 * 7.5 = 1575 TL
      final heavyPrice = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeHeavyCargo,
        isFragile: false,
        requiresThermalBag: false,
      );
      expect(heavyPrice, 1575.0);

      final breakdown = pricing.getPriceBreakdown(
        distanceKm: 10.0,
        packageSize: AppConstants.sizePallet,
        isFragile: false,
        requiresThermalBag: false,
      );
      expect(breakdown['sizeMultiplier'], 5.0);
    });

    test('Araç büyüklüğüne göre yakıt ek maliyeti doğru hesaplanmalıdır', () {
      final pricing = PricingService();

      // Mesafe: 10 km, Document (sizeMultiplier 1.0)
      // Motosiklet (yakıt çarpanı 1.0x) -> 210.0 TL
      final motoPrice = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: false,
        requiresThermalBag: false,
        vehicleType: AppConstants.vehicleMotorcycle,
      );
      expect(motoPrice, 210.0);

      // Binek Otomobil (yakıt çarpanı 1.25x) -> Mesafe 150 TL * 0.25 = +37.5 TL -> 247.50 TL
      final carPrice = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: false,
        requiresThermalBag: false,
        vehicleType: AppConstants.vehicleCar,
      );
      expect(carPrice, 247.50);

      // Kamyon / Tır (yakıt çarpanı 2.80x) -> Mesafe 150 TL * 1.80 = +270 TL -> 480.00 TL
      final truckPrice = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: false,
        requiresThermalBag: false,
        vehicleType: AppConstants.vehicleTruck,
      );
      expect(truckPrice, 480.00);

      final carBreakdown = pricing.getPriceBreakdown(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        isFragile: false,
        requiresThermalBag: false,
        vehicleType: AppConstants.vehicleCar,
      );
      expect(carBreakdown['fuelSurcharge'], 37.50);
      expect(carBreakdown['fuelMultiplier'], 1.25);
    });

    test('Araç kapasiteleri ve izin verilen paket boyutları doğru eşleşmelidir', () {
      // Motosiklet: Document, Small, Medium (max 15 kg)
      expect(AppConstants.vehicleAllowedSizes[AppConstants.vehicleMotorcycle]!.contains(AppConstants.sizeDocument), true);
      expect(AppConstants.vehicleAllowedSizes[AppConstants.vehicleMotorcycle]!.contains(AppConstants.sizeHeavyCargo), false);

      // TIR / Kamyon: Sadece ağır yükleri taşır (+600 kg ve Palet, zarf taşıyamaz)
      expect(AppConstants.vehicleAllowedSizes[AppConstants.vehicleTruck]!.contains(AppConstants.sizeHeavyCargo), true);
      expect(AppConstants.vehicleAllowedSizes[AppConstants.vehicleTruck]!.contains(AppConstants.sizeDocument), false);

      // Panelvan (max 450 kg): Palet (200-600 kg) taşıyamaz
      expect(AppConstants.vehicleAllowedSizes[AppConstants.vehiclePanelvan]!.contains(AppConstants.sizePallet), false);

      // Kargo araç listesinde 6 araç tipi bulunmalıdır
      expect(AppConstants.courierVehicles.length, 6);
      expect(AppConstants.vehicleMaxCapacityKg[AppConstants.vehicleTruck], 25000);
    });
  });
}
