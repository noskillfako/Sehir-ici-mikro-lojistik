import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/core/constants/app_constants.dart';
import 'package:sehir_ici_mikro_lojistik/models/order_model.dart';
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

    test('OrderModel yeni alanlar (itemCount, totalWeightKg, totalVolumeLiters, recommendedVehicle) toMap ve fromMap doğru çalışmalıdır', () {
      final model = OrderModel(
        id: 'ORD-9999',
        customerId: 'cust-1',
        customerName: 'Ahmet Yılmaz',
        packageSize: AppConstants.sizeMedium,
        itemCount: 3,
        totalWeightKg: 30.0,
        totalVolumeLiters: 150.0,
        recommendedVehicle: AppConstants.vehicleCar,
        preferredVehicle: AppConstants.vehicleCar,
        contentType: 'Koli',
        customDescription: '3 adet orta koli malzeme',
        isFragile: true,
        requiresThermalBag: false,
        pickupTitle: 'Kadıköy',
        pickupAddressDetail: 'Moda Cad. No:5',
        pickupLat: 40.98,
        pickupLng: 29.02,
        dropoffTitle: 'Beşiktaş',
        dropoffAddressDetail: 'Çarşı No:10',
        dropoffLat: 41.04,
        dropoffLng: 29.00,
        distanceKm: 12.0,
        price: 350.0,
        deliveryOtpCode: '5821',
        status: AppConstants.statusWaiting,
        createdAt: DateTime.now().toIso8601String(),
      );

      final map = model.toMap();
      expect(map['itemCount'], 3);
      expect(map['totalWeightKg'], 30.0);
      expect(map['totalVolumeLiters'], 150.0);
      expect(map['recommendedVehicle'], AppConstants.vehicleCar);

      final fromMap = OrderModel.fromMap(map);
      expect(fromMap.itemCount, 3);
      expect(fromMap.totalWeightKg, 30.0);
      expect(fromMap.totalVolumeLiters, 150.0);
      expect(fromMap.recommendedVehicle, AppConstants.vehicleCar);
      expect(fromMap.recommendedVehicleDisplayTr, 'Binek Otomobil (Sedan)');
    });

    test('Akıllı Araç Tavsiye Motoru: Ağırlık ve Hacim Kapasitelerine Göre En Uygun Aracı Seçmelidir', () {
      // 1 Adet Zarf (0.5 kg, 2 L) -> Motosiklet (max 20 kg, 60 L)
      expect(AppConstants.getRecommendedVehicle(0.5, 2.0), AppConstants.vehicleMotorcycle);

      // 1 Adet Orta Koli (10 kg, 50 L) -> Motosiklet (max 20 kg, 60 L)
      expect(AppConstants.getRecommendedVehicle(10.0, 50.0), AppConstants.vehicleMotorcycle);

      // 2 Adet Orta Koli (20 kg, 100 L) -> Hacim 100 L > Motosiklet 60 L -> Binek Otomobil (max 200 kg, 500 L)
      expect(AppConstants.getRecommendedVehicle(20.0, 100.0), AppConstants.vehicleCar);

      // 10 Adet Büyük Koli (300 kg, 1500 L) -> Binek Otomobil yetmez -> Minivan (max 600 kg, 3000 L)
      expect(AppConstants.getRecommendedVehicle(300.0, 1500.0), AppConstants.vehicleMinivan);

      // 1 Adet Sanayi Yükü (500 kg, 2000 L) -> Minivan (max 600 kg, 3000 L)
      expect(AppConstants.getRecommendedVehicle(500.0, 2000.0), AppConstants.vehicleMinivan);

      // 2 Adet Sanayi Yükü (1000 kg, 4000 L) -> Panelvan (max 1200 kg, 8000 L)
      expect(AppConstants.getRecommendedVehicle(1000.0, 4000.0), AppConstants.vehiclePanelvan);

      // 3 Adet Sanayi Yükü (1500 kg, 6000 L) -> Maxi Van (max 1800 kg, 14000 L)
      expect(AppConstants.getRecommendedVehicle(1500.0, 6000.0), AppConstants.vehicleMaxivan);

      // 6 Adet Sanayi Yükü (3000 kg, 12000 L) -> Ağır Ticari Kamyon/Tır
      expect(AppConstants.getRecommendedVehicle(3000.0, 12000.0), AppConstants.vehicleTruck);
    });

    test('Dinamik adet ve toplam ağırlık/hacim baremi fiyatı doğru güncellemelidir', () {
      final pricing = PricingService();

      // 1 Adet Zarf (0.5 kg, 2 L), 10 km -> Barem: 1.0 -> 210 TL
      final singleDoc = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        itemCount: 1,
        totalWeightKg: 0.5,
        totalVolumeLiters: 2.0,
        isFragile: false,
        requiresThermalBag: false,
      );
      expect(singleDoc, 210.0);

      // 10 Adet Zarf (5 kg, 20 L), 10 km -> Barem: Küçük Paket baremi (1.2) -> (60 + 150) * 1.2 = 252 TL
      final multiDoc = pricing.calculateTotalPrice(
        distanceKm: 10.0,
        packageSize: AppConstants.sizeDocument,
        itemCount: 10,
        totalWeightKg: 5.0,
        totalVolumeLiters: 20.0,
        isFragile: false,
        requiresThermalBag: false,
      );
      expect(multiDoc, 252.0);
    });

    test('Araç sembolleri (getVehicleIcon) ve başlıkları (getVehicleTitle) doğru eşleşmeli, bisiklet sembolü kullanılmamalıdır', () {
      // Motosiklet: Bisiklet (directions_bike) DEĞİL, motor/scooter (two_wheeler_rounded) olmalıdır
      expect(AppConstants.getVehicleIcon(AppConstants.vehicleMotorcycle), Icons.two_wheeler_rounded);
      expect(AppConstants.getVehicleIcon(AppConstants.vehicleCar), Icons.directions_car_rounded);
      expect(AppConstants.getVehicleIcon(AppConstants.vehicleMinivan), Icons.airport_shuttle_rounded);
      expect(AppConstants.getVehicleIcon(AppConstants.vehiclePanelvan), Icons.local_shipping_rounded);
      expect(AppConstants.getVehicleIcon(AppConstants.vehicleMaxivan), Icons.rv_hookup_rounded);
      expect(AppConstants.getVehicleIcon(AppConstants.vehicleTruck), Icons.fire_truck_rounded);

      // Başlıklar
      expect(AppConstants.getVehicleTitle(AppConstants.vehicleMotorcycle), 'Motosiklet / Scooter');
      expect(AppConstants.getVehicleTitle(AppConstants.vehicleCar), 'Binek Otomobil (Sedan)');
    });
  });
}
