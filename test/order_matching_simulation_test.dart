import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sehir_ici_mikro_lojistik/core/constants/app_constants.dart';
import 'package:sehir_ici_mikro_lojistik/models/order_model.dart';
import 'package:sehir_ici_mikro_lojistik/models/user_model.dart';
import 'package:sehir_ici_mikro_lojistik/services/courier_matching_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box ordersBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    ordersBox = await Hive.openBox(AppConstants.ordersBox);
  });

  tearDown(() async {
    await ordersBox.close();
    await tempDir.delete(recursive: true);
  });

  group('Kurye ve Sipariş Uyumluluk Testleri (Courier Matching Tests)', () {
    final matchingService = CourierMatchingService();

    const motoCourier = UserModel(
      id: 'usr_courier_1',
      fullName: 'Mehmet Demir',
      phone: '5554445566',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehicleMotorcycle,
      hasThermalBag: true,
    );

    const carCourier = UserModel(
      id: 'usr_courier_2',
      fullName: 'Caner Kaya',
      phone: '5557778899',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehicleCar,
      hasThermalBag: false,
    );

    const minivanCourier = UserModel(
      id: 'usr_courier_minivan',
      fullName: 'Emre Şahin',
      phone: '5553334455',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehicleMinivan,
      hasThermalBag: true,
    );

    const panelvanCourier = UserModel(
      id: 'usr_courier_3',
      fullName: 'Serkan Yıldız',
      phone: '5552223344',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehiclePanelvan,
      hasThermalBag: false,
    );

    const maxivanCourier = UserModel(
      id: 'usr_courier_maxivan',
      fullName: 'Hakan Demir',
      phone: '5556667788',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehicleMaxivan,
      hasThermalBag: false,
    );

    const truckCourier = UserModel(
      id: 'usr_courier_4',
      fullName: 'Burak Koç',
      phone: '5558889900',
      password: '1234',
      role: AppConstants.roleCourier,
      vehicleType: AppConstants.vehicleTruck,
      hasThermalBag: false,
    );

    test('1. Varsayılan evrak siparişi tüm araç tipleri tarafından görülebilir', () {
      final order = OrderModel(
        id: 'ORD-1001',
        customerId: 'usr_customer_1',
        customerName: 'Ahmet Yılmaz',
        preferredVehicle: null,
        recommendedVehicle: AppConstants.vehicleMotorcycle,
        packageSize: AppConstants.sizeDocument,
        itemCount: 1,
        totalWeightKg: 0.5,
        totalVolumeLiters: 2.0,
        contentType: 'Genel Kargo',
        customDescription: 'Önemli evraklar',
        isFragile: false,
        requiresThermalBag: false,
        pickupTitle: 'Kadıköy',
        pickupAddressDetail: 'Moda',
        pickupLat: 40.98,
        pickupLng: 29.02,
        dropoffTitle: 'Beşiktaş',
        dropoffAddressDetail: 'Çarşı',
        dropoffLat: 41.04,
        dropoffLng: 29.00,
        distanceKm: 12.0,
        price: 240.0,
        deliveryOtpCode: '1234',
        status: AppConstants.statusWaiting,
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: motoCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: carCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: minivanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: panelvanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: maxivanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: order, courier: truckCourier), isTrue);
    });

    test('2. 50 kg ağırlığındaki koli motosiklet tarafından görülemez, otomobil ve üstü görür', () {
      final heavyOrder = OrderModel(
        id: 'ORD-1002',
        customerId: 'usr_customer_1',
        customerName: 'Ahmet Yılmaz',
        preferredVehicle: null,
        recommendedVehicle: AppConstants.vehicleCar,
        packageSize: AppConstants.sizeLarge,
        itemCount: 2,
        totalWeightKg: 50.0,
        totalVolumeLiters: 100.0,
        contentType: 'Genel Kargo',
        customDescription: '2 adet ağır koli',
        isFragile: false,
        requiresThermalBag: false,
        pickupTitle: 'Kadıköy',
        pickupAddressDetail: 'Moda',
        pickupLat: 40.98,
        pickupLng: 29.02,
        dropoffTitle: 'Beşiktaş',
        dropoffAddressDetail: 'Çarşı',
        dropoffLat: 41.04,
        dropoffLng: 29.00,
        distanceKm: 12.0,
        price: 450.0,
        deliveryOtpCode: '1234',
        status: AppConstants.statusWaiting,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Motosiklet max 20 kg taşıyabildiği için uygun değil
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: motoCourier), isFalse);
      // Otomobil (200 kg) ve üstü araçlar için uygun
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: carCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: minivanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: panelvanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: maxivanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: heavyOrder, courier: truckCourier), isTrue);
    });

    test('3. Müşteri manuel olarak PANELVAN seçtiğinde sadece panelvan ve üstü görür', () {
      final panelvanPreferredOrder = OrderModel(
        id: 'ORD-1003',
        customerId: 'usr_customer_1',
        customerName: 'Ahmet Yılmaz',
        preferredVehicle: AppConstants.vehiclePanelvan,
        recommendedVehicle: AppConstants.vehicleCar,
        packageSize: AppConstants.sizeMedium,
        itemCount: 1,
        totalWeightKg: 10.0,
        totalVolumeLiters: 50.0,
        contentType: 'Genel Kargo',
        customDescription: 'Panelvan ile taşınacak koli',
        isFragile: false,
        requiresThermalBag: false,
        pickupTitle: 'Kadıköy',
        pickupAddressDetail: 'Moda',
        pickupLat: 40.98,
        pickupLng: 29.02,
        dropoffTitle: 'Beşiktaş',
        dropoffAddressDetail: 'Çarşı',
        dropoffLat: 41.04,
        dropoffLng: 29.00,
        distanceKm: 12.0,
        price: 520.0,
        deliveryOtpCode: '1234',
        status: AppConstants.statusWaiting,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Panelvan kapasitesinden küçük olanlar kabul edilemez
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: motoCourier), isFalse);
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: carCourier), isFalse);
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: minivanCourier), isFalse);

      // Panelvan ve üstü kabul edebilir
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: panelvanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: maxivanCourier), isTrue);
      expect(matchingService.isOrderCompatibleWithCourier(order: panelvanPreferredOrder, courier: truckCourier), isTrue);
    });

    test('4. Termal çanta gerektiren sipariş sadece termal çantalı kuryelere görünür', () {
      final foodOrder = OrderModel(
        id: 'ORD-1004',
        customerId: 'usr_customer_1',
        customerName: 'Ahmet Yılmaz',
        preferredVehicle: null,
        recommendedVehicle: AppConstants.vehicleMotorcycle,
        packageSize: AppConstants.sizeSmall,
        itemCount: 1,
        totalWeightKg: 2.0,
        totalVolumeLiters: 10.0,
        contentType: 'Sıcak Yemek / Pasta',
        customDescription: 'Sıcak pizza teslimatı',
        isFragile: false,
        requiresThermalBag: true,
        pickupTitle: 'Kadıköy',
        pickupAddressDetail: 'Moda',
        pickupLat: 40.98,
        pickupLng: 29.02,
        dropoffTitle: 'Beşiktaş',
        dropoffAddressDetail: 'Çarşı',
        dropoffLat: 41.04,
        dropoffLng: 29.00,
        distanceKm: 12.0,
        price: 260.0,
        deliveryOtpCode: '1234',
        status: AppConstants.statusWaiting,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Mehmet Demir (Moto) termal çantalı -> true
      expect(matchingService.isOrderCompatibleWithCourier(order: foodOrder, courier: motoCourier), isTrue);
      // Caner Kaya (Car) termal çantasız -> false
      expect(matchingService.isOrderCompatibleWithCourier(order: foodOrder, courier: carCourier), isFalse);
      // Emre Şahin (Minivan) termal çantalı -> true
      expect(matchingService.isOrderCompatibleWithCourier(order: foodOrder, courier: minivanCourier), isTrue);
      // Serkan Yıldız (Panelvan) termal çantasız -> false
      expect(matchingService.isOrderCompatibleWithCourier(order: foodOrder, courier: panelvanCourier), isFalse);
    });
  });
}
