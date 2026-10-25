import 'package:flutter/material.dart';

/// Uygulama Genelindeki Sabit Değerler ve Kataloglar
class AppConstants {
  // Hive Kutu Adları
  static const String usersBox = 'users_box';
  static const String sessionBox = 'session_box';
  static const String ordersBox = 'orders_box';

  // Session Anahtarları
  static const String keyCurrentUserId = 'currentUserId';
  static const String keyActiveRole = 'activeRole';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyActiveVehicleType = 'activeVehicleType';

  // Roller
  static const String roleCustomer = 'CUSTOMER';
  static const String roleCourier = 'COURIER';

  // Kargo Boyutları (0 Kg'dan +600 Kg'a kadar)
  static const String sizeDocument = 'DOCUMENT';       // 0-1 Kg (Zarf/Evrak)
  static const String sizeSmall = 'SMALL';             // 1-5 Kg (Küçük Paket)
  static const String sizeMedium = 'MEDIUM';           // 5-15 Kg (Orta Koli)
  static const String sizeLarge = 'LARGE';             // 15-60 Kg (Büyük Koli / Eşya)
  static const String sizeXLarge = 'XLARGE';           // 60-200 Kg (Hacimli / Ağır Ticari Yük)
  static const String sizePallet = 'PALLET';           // 200-600 Kg (Paletli / Çok Ağır Yük)
  static const String sizeHeavyCargo = 'HEAVY_CARGO';   // +600 Kg (Devasa Ağır Yük / Sanayi)

  static const List<String> packageSizes = [
    sizeDocument,
    sizeSmall,
    sizeMedium,
    sizeLarge,
    sizeXLarge,
    sizePallet,
    sizeHeavyCargo,
  ];

  // 6 Araç Sınıfı (Görsel Kataloğuna Birebir Uygun)
  static const String vehicleMotorcycle = 'MOTORCYCLE'; // Motosiklet / Maxi Scooter (0-15 Kg)
  static const String vehicleCar = 'CAR';               // Binek Otomobil / Sedan (0-60 Kg)
  static const String vehicleMinivan = 'MINIVAN';       // Kompakt Minivan / City Van (0-200 Kg)
  static const String vehiclePanelvan = 'PANELVAN';     // Standart Hafif Ticari Panelvan (0-450 Kg)
  static const String vehicleMaxivan = 'MAXIVAN';       // Yüksek Tavan Maxi Panelvan (0-600 Kg)
  static const String vehicleTruck = 'TRUCK';           // Ağır Ticari Kamyon / Tır (+600 Kg)

  static const List<String> courierVehicles = [
    vehicleMotorcycle,
    vehicleCar,
    vehicleMinivan,
    vehiclePanelvan,
    vehicleMaxivan,
    vehicleTruck,
  ];

  // Araç Görsel Dosya Yolları (Şeffaf PNG'ler)
  static const Map<String, String> vehicleImages = {
    vehicleMotorcycle: 'assets/images/vehicles/motorcycle.png',
    vehicleCar: 'assets/images/vehicles/car.png',
    vehicleMinivan: 'assets/images/vehicles/minivan.png',
    vehiclePanelvan: 'assets/images/vehicles/panelvan.png',
    vehicleMaxivan: 'assets/images/vehicles/maxivan.png',
    vehicleTruck: 'assets/images/vehicles/truck.png',
  };

  // Araç Maksimum Taşıma Kapasiteleri (Kg) - Gerçek Dünya Standartları
  static const Map<String, double> vehicleMaxCapacityKg = {
    vehicleMotorcycle: 20.0,
    vehicleCar: 200.0,
    vehicleMinivan: 600.0,
    vehiclePanelvan: 1200.0,
    vehicleMaxivan: 1800.0,
    vehicleTruck: 25000.0, // 5.000+ kg / Ağır Ticari Kamyon/Tır
  };

  // Araç Maksimum Hacim Kapasiteleri (Litre) - Gerçek Dünya Standartları
  static const Map<String, double> vehicleMaxCapacityLiters = {
    vehicleMotorcycle: 60.0,
    vehicleCar: 500.0,
    vehicleMinivan: 3000.0,
    vehiclePanelvan: 8000.0,
    vehicleMaxivan: 14000.0,
    vehicleTruck: 30000.0,
  };

  // Araç Maksimum Hacim Gösterge Metinleri
  static const Map<String, String> vehicleMaxCapacityM3Text = {
    vehicleMotorcycle: '~0.06 m³',
    vehicleCar: '~0.5 m³',
    vehicleMinivan: '~3.0 m³',
    vehiclePanelvan: '~8.0 m³',
    vehicleMaxivan: '~14.0 m³',
    vehicleTruck: '~30.0+ m³',
  };

  // Paket Birim Boyut Standartları: Ağırlık (Kg)
  static const Map<String, double> packageUnitWeightsKg = {
    sizeDocument: 0.5,
    sizeSmall: 3.0,
    sizeMedium: 10.0,
    sizeLarge: 30.0,
    sizeXLarge: 75.0,
    sizePallet: 150.0,
    sizeHeavyCargo: 500.0,
  };

  // Paket Birim Boyut Standartları: Hacim (Litre)
  static const Map<String, double> packageUnitVolumesLiters = {
    sizeDocument: 2.0,
    sizeSmall: 15.0,
    sizeMedium: 50.0,
    sizeLarge: 150.0,
    sizeXLarge: 300.0,
    sizePallet: 600.0,
    sizeHeavyCargo: 2000.0,
  };

  // Paket Birim Boyut Standartları: Hacim (m³)
  static const Map<String, String> packageUnitVolumeM3Text = {
    sizeDocument: '0.002 m³',
    sizeSmall: '0.015 m³',
    sizeMedium: '0.05 m³',
    sizeLarge: '0.15 m³',
    sizeXLarge: '0.30 m³',
    sizePallet: '0.60 m³',
    sizeHeavyCargo: '2.00 m³',
  };

  /// Akıllı Araç Tavsiye Motoru: Ağırlık ve Hacme göre en düşük maliyetli/en uygun aracı önerir
  static String getRecommendedVehicle(double totalWeightKg, double totalVolumeLiters) {
    for (final v in courierVehicles) {
      final maxKg = vehicleMaxCapacityKg[v] ?? 0.0;
      final maxL = vehicleMaxCapacityLiters[v] ?? 0.0;
      if (totalWeightKg <= maxKg && totalVolumeLiters <= maxL) {
        return v;
      }
    }
    return vehicleTruck;
  }

  /// Seçilen ürünler arasından en büyük/en kısıtlayıcı kargo boyutunu döndürür
  static String getPrimaryPackageSize(Map<String, int> itemQuantities) {
    const priority = [
      sizeHeavyCargo,
      sizePallet,
      sizeXLarge,
      sizeLarge,
      sizeMedium,
      sizeSmall,
      sizeDocument,
    ];

    for (final size in priority) {
      if ((itemQuantities[size] ?? 0) > 0) {
        return size;
      }
    }
    return sizeDocument;
  }

  /// Kargo boyutu anahtarına karşılık gelen Türkçe başlık
  static String packageSizeTitle(String sizeKey) {
    switch (sizeKey) {
      case sizeDocument:
        return 'Zarf / Evrak';
      case sizeSmall:
        return 'Küçük Paket';
      case sizeMedium:
        return 'Orta Koli';
      case sizeLarge:
        return 'Büyük Koli';
      case sizeXLarge:
        return 'Ağır Ticari';
      case sizePallet:
        return 'Paletli Malzeme';
      case sizeHeavyCargo:
        return 'Sanayi / Devasa Yük';
      default:
        return sizeKey;
    }
  }

  /// Araç türüne göre uygun simgeyi döndürür (Motosiklet, Binek Araç, Minivan, Panelvan, Maxivan, Kamyon)
  static IconData getVehicleIcon(String? vehicleKey) {
    switch (vehicleKey) {
      case vehicleMotorcycle:
        return Icons.two_wheeler_rounded;
      case vehicleCar:
        return Icons.directions_car_rounded;
      case vehicleMinivan:
        return Icons.airport_shuttle_rounded;
      case vehiclePanelvan:
        return Icons.local_shipping_rounded;
      case vehicleMaxivan:
        return Icons.rv_hookup_rounded;
      case vehicleTruck:
        return Icons.fire_truck_rounded;
      default:
        return Icons.two_wheeler_rounded;
    }
  }

  /// Araç anahtarına karşılık gelen Türkçe başlık
  static String getVehicleTitle(String? vehicleKey) {
    switch (vehicleKey) {
      case vehicleMotorcycle:
        return 'Motosiklet / Scooter';
      case vehicleCar:
        return 'Binek Otomobil (Sedan)';
      case vehicleMinivan:
        return 'Kompakt Minivan';
      case vehiclePanelvan:
        return 'Standart Panelvan';
      case vehicleMaxivan:
        return 'Maxi Panelvan';
      case vehicleTruck:
        return 'Ağır Ticari / Kamyon (Tır)';
      default:
        return vehicleKey ?? 'Kurye';
    }
  }

  // Araç Yakıt Tüketim ve Büyüklük Maliyet Katsayıları (Daha büyük araç -> Daha yüksek yakıt)
  static const Map<String, double> vehicleFuelMultipliers = {
    vehicleMotorcycle: 1.0,   // ~2.5 L/100km (En ekonomik, taban tüketim)
    vehicleCar: 1.25,          // ~6.5 L/100km (Binek sedan)
    vehicleMinivan: 1.45,      // ~8.0 L/100km (Kompakt ticari)
    vehiclePanelvan: 1.70,     // ~10.5 L/100km (Standart hafif ticari)
    vehicleMaxivan: 2.00,      // ~13.0 L/100km (Yüksek tavan maxi van)
    vehicleTruck: 2.80,        // ~32.0 L/100km (Ağır ticari kamyon / tır)
  };

  // Araç Yakıt Tüketim Gösterge Etiketleri
  static const Map<String, String> vehicleFuelConsumptionText = {
    vehicleMotorcycle: 'Düşük Yakıt (1.0x)',
    vehicleCar: 'Standart Yakıt (1.25x)',
    vehicleMinivan: 'Orta Yakıt (1.45x)',
    vehiclePanelvan: 'Yüksek Yakıt (1.70x)',
    vehicleMaxivan: 'Çok Yüksek Yakıt (2.0x)',
    vehicleTruck: 'Ağır Ticari Yakıt (2.8x)',
  };

  // Araçların Taşıyabileceği Kargo Boyutları (Gerçekçi Lojistik ve Kapasite Kuralları)
  static const Map<String, List<String>> vehicleAllowedSizes = {
    vehicleMotorcycle: [sizeDocument, sizeSmall, sizeMedium],
    vehicleCar: [sizeDocument, sizeSmall, sizeMedium, sizeLarge],
    vehicleMinivan: [sizeSmall, sizeMedium, sizeLarge, sizeXLarge],
    vehiclePanelvan: [sizeMedium, sizeLarge, sizeXLarge],
    vehicleMaxivan: [sizeLarge, sizeXLarge, sizePallet],
    vehicleTruck: [sizePallet, sizeHeavyCargo],
  };

  // İçerik Kategorileri
  static const List<String> contentCategories = [
    'Evrak / Belge',
    'Elektronik / Cihaz',
    'Gıda / Pasta / Sıcak Yemek',
    'Kıyafet / Tekstil',
    'Unutulan Eşya (Anahtar, Cüzdan)',
    'Koli / Ticari Malzeme',
    'Paletli Ağır Yük / Sanayi Parçası',
    'Evcil Hayvan',
    'Diğer',
  ];

  // Sipariş Durumları
  static const String statusWaiting = 'WAITING_FOR_COURIER';
  static const String statusAssigned = 'COURIER_ASSIGNED';
  static const String statusInTransit = 'IN_TRANSIT';
  static const String statusDelivered = 'DELIVERED';
  static const String statusCancelled = 'CANCELLED';

  // Fiyatlandırma Sabitleri
  static const double baseFare = 60.0;
  static const double perKmRate = 15.0;
  static const double fragileFee = 30.0;
  static const double thermalBagFee = 25.0;
  static const double commissionRate = 0.15; // Platform %15 komisyonu

  // Boyut Çarpanları
  static const Map<String, double> sizeMultipliers = {
    sizeDocument: 1.0,
    sizeSmall: 1.2,
    sizeMedium: 1.6,
    sizeLarge: 2.2,
    sizeXLarge: 3.5,
    sizePallet: 5.0,
    sizeHeavyCargo: 7.5,
  };

  // Harita Sabitleri
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackage = 'com.mikrolojistik.app';
  static const double roadDistanceMultiplier = 1.3;
}
