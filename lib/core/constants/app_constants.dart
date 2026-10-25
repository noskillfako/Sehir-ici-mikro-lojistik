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

  // Araç Maksimum Taşıma Kapasiteleri (Kg)
  static const Map<String, double> vehicleMaxCapacityKg = {
    vehicleMotorcycle: 15.0,
    vehicleCar: 60.0,
    vehicleMinivan: 200.0,
    vehiclePanelvan: 450.0,
    vehicleMaxivan: 600.0,
    vehicleTruck: 25000.0, // Ağır tonaj / Tır
  };

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
