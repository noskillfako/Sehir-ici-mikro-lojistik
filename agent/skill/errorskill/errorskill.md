# Merkezi Hata Yönetimi ve Kullanıcı Bildirimleri Skill (errorskill.md)

## 1. Amaç ve Kapsam
Bu modül; "Şehir İçi Mikro Lojistik" uygulamasında kullanıcı girdilerinden (validasyon), iş kuralları ihlallerinden (kurye kapasitesi, aktif görev kilidi, OTP uyuşmazlığı) veya yerel veritabanı (Hive) işlemlerinden kaynaklanan hataların yakalanmasını, standartlaştırılmasını ve kullanıcıya anlaşılır Türkçe mesajlarla (SnackBar / AlertDialog) gösterilmesini yönetir.

## 2. Özel Hata Sınıfı (`AppException`) ve Hata Kodları
Uygulama içinde rastgele `Exception('hata')` fırlatmak yerine aşağıdaki standart hata tiplerini barındıran `AppException` sınıfı kullanılır:

### A. Kimlik Doğrulama ve Oturum Hataları (`AuthError`)
- `AUTH_USER_NOT_FOUND`: "Bu telefon numarasına ait kayıtlı bir hesap bulunamadı."
- `AUTH_WRONG_PASSWORD`: "Girdiğiniz şifre hatalı. Lütfen tekrar deneyin."
- `AUTH_PHONE_ALREADY_EXISTS`: "Bu telefon numarası zaten kayıtlı. Lütfen giriş yapın."
- `AUTH_MISSING_VEHICLE_INFO`: "Kurye kaydı için araç tipi seçimi zorunludur."

### B. Sipariş Oluşturma ve Validasyon Hataları (`ValidationError`)
- `ORDER_SAME_LOCATION`: "Alış noktası ile teslimat noktası aynı olamaz."
- `ORDER_DESCRIPTION_TOO_SHORT`: "Lütfen paket içeriğini en az 5 karakter olacak şekilde açıklayın."
- `ORDER_MISSING_FIELDS`: "Lütfen kargo boyutu, içerik türü ve adres detaylarını eksiksiz doldurun."

### C. Kurye Eşleşme ve İş Kuralı Hataları (`BusinessRuleError`)
- `COURIER_HAS_ACTIVE_ORDER`: "Üzerinizde zaten aktif bir teslimat var. Yeni sipariş alabilmek için mevcut görevinizi tamamlamalısınız."
- `COURIER_VEHICLE_INCOMPATIBLE`: "Bu paketin boyutu araç tipiniz için uygun değil."
- `COURIER_THERMAL_BAG_REQUIRED`: "Bu sipariş sıcak/soğuk koruma (Termal Çanta) gerektirmektedir."
- `ORDER_ALREADY_TAKEN`: "Bu sipariş başka bir kurye tarafından kabul edildi veya iptal edildi."

### D. Teslimat ve Durum Geçiş Hataları (`DeliveryError`)
- `INVALID_OTP_CODE`: "Girdiğiniz 4 haneli teslimat kodu hatalı! Lütfen müşteriden kodu tekrar kontrol edin."
- `INVALID_STATE_TRANSITION`: "Sipariş henüz müşteriden teslim alınmadan (Yola Çıkmadan) teslim edilemez."

### E. Veritabanı ve Sistem Hataları (`DatabaseError`)
- `HIVE_BOX_NOT_OPEN`: "Veritabanı bağlantısı kurulamadı. Lütfen uygulamayı yeniden başlatın."
- `DATA_PARSE_ERROR`: "Veri okunurken beklenmeyen bir format hatası oluştu."

## 3. Hata Yakalama ve Gösterim Kuralları (UI Feedback)
1. **Asenkron İşlem Koruması (`try-catch`):**
   - Tüm Hive okuma/yazma ve servis çağrıları `try-catch` bloğu içinde çalıştırılır.
   - Yakalanan hata `AppException` ise doğrudan içindeki Türkçe `message` kullanıcıya gösterilir; bilinmeyen bir hata ise `"Beklenmeyen bir hata oluştu, lütfen tekrar deneyin."` mesajı gösterilir ve konsola `debugPrint` ile loglanır.
2. **Görsel Bildirim Standartları:**
   - **Hata Bildirimi (`showErrorSnackBar`):** Kırmızı arka plan (`Colors.red.shade700`), beyaz metin ve sol tarafta uyarı ikonu (`Icons.error_outline`).
   - **Uyarı Bildirimi (`showWarningSnackBar`):** Turuncu arka plan (`Colors.orange.shade800`), iş kuralı kısıtlamaları için (Örn: Aktif sipariş kilidi).
   - **Başarı Bildirimi (`showSuccessSnackBar`):** Yeşil arka plan (`Colors.green.shade700`), sipariş oluşturulduğunda veya OTP doğrulandığında.

## 4. Beklenen Servis ve Yardımcı Metotlar (`ErrorHandler`)
Agent bu skill çağrıldığında aşağıdaki yapıyı üretmelidir:
- `class AppException implements Exception { final String code; final String message; ... }`
- `void ErrorHandler.handle(BuildContext context, Object error)`
- `void ErrorHandler.showError(BuildContext context, String message)`
- `void ErrorHandler.showSuccess(BuildContext context, String message)`
- `void ErrorHandler.showWarning(BuildContext context, String message)`