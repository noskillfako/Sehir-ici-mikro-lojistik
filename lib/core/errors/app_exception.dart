/// Uygulama Genelindeki Standart Hata Sınıfı
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const AppException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'AppException($code): $message';

  // Kimlik Doğrulama Hataları
  factory AppException.userNotFound() => const AppException(
        code: 'AUTH_USER_NOT_FOUND',
        message: 'Bu telefon numarasına ait kayıtlı bir hesap bulunamadı.',
      );

  factory AppException.wrongPassword() => const AppException(
        code: 'AUTH_WRONG_PASSWORD',
        message: 'Girdiğiniz şifre hatalı. Lütfen tekrar deneyin.',
      );

  factory AppException.phoneAlreadyExists() => const AppException(
        code: 'AUTH_PHONE_ALREADY_EXISTS',
        message: 'Bu telefon numarası zaten kayıtlı. Lütfen giriş yapın.',
      );

  factory AppException.missingVehicleInfo() => const AppException(
        code: 'AUTH_MISSING_VEHICLE_INFO',
        message: 'Kurye kaydı için araç tipi seçimi zorunludur.',
      );

  // Sipariş Validasyon Hataları
  factory AppException.sameLocation() => const AppException(
        code: 'ORDER_SAME_LOCATION',
        message: 'Alış noktası ile teslimat noktası aynı olamaz.',
      );

  factory AppException.descriptionTooShort() => const AppException(
        code: 'ORDER_DESCRIPTION_TOO_SHORT',
        message: 'Lütfen paket içeriğini en az 5 karakter olacak şekilde açıklayın.',
      );

  factory AppException.missingOrderFields([String? detail]) => AppException(
        code: 'ORDER_MISSING_FIELDS',
        message: detail ?? 'Lütfen kargo boyutu, içerik türü ve adres detaylarını eksiksiz doldurun.',
      );

  // Kurye Eşleşme Hataları
  factory AppException.courierHasActiveOrder() => const AppException(
        code: 'COURIER_HAS_ACTIVE_ORDER',
        message: 'Üzerinizde zaten aktif bir teslimat var. Yeni sipariş alabilmek için mevcut görevinizi tamamlamalısınız.',
      );

  factory AppException.vehicleIncompatible([String? detail]) => AppException(
        code: 'COURIER_VEHICLE_INCOMPATIBLE',
        message: detail ?? 'Bu paketin boyutu araç tipiniz için uygun değil.',
      );

  factory AppException.thermalBagRequired() => const AppException(
        code: 'COURIER_THERMAL_BAG_REQUIRED',
        message: 'Bu sipariş sıcak/soğuk koruma (Termal Çanta) gerektirmektedir.',
      );

  factory AppException.orderAlreadyTaken() => const AppException(
        code: 'ORDER_ALREADY_TAKEN',
        message: 'Bu sipariş başka bir kurye tarafından kabul edildi veya iptal edildi.',
      );

  // Teslimat ve Durum Hataları
  factory AppException.invalidOtp() => const AppException(
        code: 'INVALID_OTP_CODE',
        message: 'Girdiğiniz 4 haneli teslimat kodu hatalı! Lütfen müşteriden kodu tekrar kontrol edin.',
      );

  factory AppException.invalidStateTransition(String from, String to) => AppException(
        code: 'INVALID_STATE_TRANSITION',
        message: 'Sipariş durumu $from aşamasından $to aşamasına doğrudan geçirilemez.',
      );

  // Veritabanı Hataları
  factory AppException.boxNotOpen(String boxName) => AppException(
        code: 'HIVE_BOX_NOT_OPEN',
        message: 'Veritabanı kutusu ($boxName) henüz açılmadı. Lütfen uygulamayı yeniden başlatın.',
      );

  factory AppException.dataParseError([String? detail]) => AppException(
        code: 'DATA_PARSE_ERROR',
        message: detail ?? 'Veri okunurken beklenmeyen bir format hatası oluştu.',
      );
}
