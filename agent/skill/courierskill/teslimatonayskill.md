# Güvenli Teslimat ve OTP Doğrulama Skill (teslimatonayskill.md)

## 1. Amaç ve Kapsam
Bu modül; kuryenin paketi alıcıya ulaştırdığında teslimatı tamamlaması için gereken **4 haneli Güvenlik Kodu (OTP - One Time Password)** üretimini, müşteri ekranında bu kodun gösterilmesini, kurye ekranında kodun doğrulanmasını ve başarılı teslimat sonrası siparişin kapatılmasını yönetir.

## 2. OTP (Teslimat Kodu) Üretim ve Saklama Kuralları
- **Üretim Anı:** Müşteri siparişi oluşturduğu anda (`OrderCreationService` içinde) `1000` ile `9999` arasında rastgele 4 haneli sayısal bir kod üretilir (Örn: `'4829'`).
- **Saklama:** Üretilen bu kod, `ordersBox` (Hive) içindeki ilgili siparişin `deliveryOtpCode` (String) alanında saklanır.
- **Gizlilik Kuralı (Çok Önemli):**
  - **Müşteri Görünümü:** Müşteri kendi sipariş detay ve canlı takip ekranında `deliveryOtpCode` değerini açıkça görür (*"Kuryeye Söyleyeceğiniz Teslimat Kodu: 4829"*).
  - **Kurye Görünümü:** Kurye ekranında bu kod **ASLA** gösterilmez (Kurye kodu müşteriden sözlü olarak öğrenip girmek zorundadır).
  - *(Not: Tek cihazda test kolaylığı sağlamak adına, kuryenin OTP giriş penceresinin en altında küçük ve silik bir fontla `[Demo İpucu - Müşteri Kodu: 4829]` şeklinde geliştirici ipucu gösterilebilir).*

## 3. Teslimat Doğrulama İş Kuralları (Business Logic)
1. **Ön Koşul Kontrolü:**
   - Bir siparişin teslim edilebilmesi için mevcut durumunun (`status`) mutlaka `'IN_TRANSIT'` (Paket Dağıtımda / Yolda) olması gerekir.
   - Henüz müşteriden teslim alınmamış (`COURIER_ASSIGNED`) bir sipariş doğrudan teslim edilemez.
2. **Kod Doğrulama (Verification):**
   - Kurye **"Teslimatı Tamamla (Kod Gir)"** butonuna bastığında 4 haneli PIN/OTP giriş diyaloğu (`BottomSheet` veya `AlertDialog`) açılır.
   - Kuryenin girdiği `enteredOtp` (String) ile Hive'daki siparişin `deliveryOtpCode` değeri karşılaştırılır:
     - **Eşleşme Başarısızsa (`false`):** Sipariş durumu değişmez. Kuryeye `"Hatalı teslimat kodu! Lütfen müşteriden aldığınız 4 haneli kodu kontrol edin."` hatası gösterilir.
     - **Eşleşme Başarılıysa (`true`):**
       - Siparişin `status` alanı `'DELIVERED'` olarak güncellenir.
       - Siparişin `deliveredAt` alanına o anki zaman damgası (`DateTime.now().toIso8601String()`) yazılır ve `ordersBox` içine kaydedilir.
3. **Teslimat Sonrası Tetiklemeler:**
   - Sipariş `'DELIVERED'` olduğu anda kuryenin üzerindeki "Aktif Görev Kilidi" kalkar (Kurye artık havuzdan yeni sipariş alabilir).
   - Kuryeye başarılı teslimat özeti ve bu siparişten elde ettiği net kazanç (`price * 0.85`) tebrik mesajıyla gösterilir.

## 4. Beklenen Servis Metotları (`DeliveryConfirmationService`)
Agent bu skill çağrıldığında aşağıdaki metotları içeren bir servis ve OTP doğrulama diyaloğu üretmelidir:
- `String generate4DigitOtp()`
- `String? getCustomerVisibleOtp({required String orderId, required String activeRole})` // Sadece CUSTOMER rolüne kodu döndürür
- `Future<DeliveryResult> verifyOtpAndCompleteOrder({required String orderId, required String enteredOtp})`