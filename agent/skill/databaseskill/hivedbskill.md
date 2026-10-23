# Hive Yerel Veritabanı ve Kutu Yönetimi Skill (hivedbskill.md)

## 1. Amaç ve Kapsam
Bu modül; "Şehir İçi Mikro Lojistik" uygulamasının tüm verilerini harici bir API olmadan cihaz hafızasında tutan **Hive (`hive_flutter`)** veritabanının başlatılmasını, kutuların (Boxes) açılmasını, serileştirme (Serialization) standartlarını ve demo sıfırlama işlemlerini yönetir.

## 2. Mimari Standart: Adapter Yerine `Map<String, dynamic>` Kullanımı
- Kod üretiminde `build_runner` veya `.g.dart` (TypeAdapter) bağımlılığı ve derleme hataları **OLMAMASI İÇİN** tüm modeller (`UserModel`, `OrderModel`) Hive kutularına `toMap()` metodu ile `Map<String, dynamic>` olarak kaydedilecek, okunurken `Map<String, dynamic>.from(rawMap)` ile `fromMap()` üzerinden nesneye dönüştürülecektir.

## 3. Uygulama Genelindeki Sabit Kutular (Box Names)
Veritabanında yalnızca aşağıdaki 3 kutu açılır ve kullanılır (Sabit `String` olarak tanımlanmalıdır):
1. **`usersBox` (`'users_box'`):**
   - **Anahtar (Key):** `user.id` (String)
   - **Değer (Value):** `UserModel.toMap()`
   - **Görevi:** Müşteri ve kurye profillerini saklar.
2. **`sessionBox` (`'session_box'`):**
   - **Anahtarlar:** `'currentUserId'`, `'activeRole'`, `'isLoggedIn'`, `'activeVehicleType'`
   - **Görevi:** Aktif oturumu ve o anki rolü (`CUSTOMER` / `COURIER`) hatırlar.
3. **`ordersBox` (`'orders_box'`):**
   - **Anahtar (Key):** `order.id` (String - Örn: `'ORD-1042'`)
   - **Değer (Value):** `OrderModel.toMap()`
   - **Görevi:** Oluşturulan, bekleyen, taşınan ve teslim edilen tüm siparişleri saklar.

## 4. Başlatma ve İlk Kurulum Akışı (`main.dart` / `HiveDatabaseService`)
Uygulama ayağa kalkarken (`runApp` öncesi) sırasıyla şu adımlar çalıştırılır:
1. `WidgetsFlutterBinding.ensureInitialized()` çağrılır.
2. `await Hive.initFlutter()` ile Hive başlatılır.
3. `usersBox`, `sessionBox` ve `ordersBox` kutuları `await Hive.openBox(...)` ile aynı anda açılır.
4. Kutu açılışları tamamlandıktan sonra `AuthService.seedDefaultUsersIfNeeded()` tetiklenerek hazır test profilleri (1 Müşteri, 1 Moto Kurye, 1 Araçlı Kurye) oluşturulur.

## 5. Reaktif Dinleme ve Demo Verilerini Sıfırlama
- **Canlı Arayüz Güncellemesi:** Sipariş durumu değiştiğinde arayüzün anında güncellenmesi için `Hive.box('orders_box').listenable()` (`ValueListenableBuilder` ile) kullanılır.
- **Demo Sıfırlama (Reset Database):** Test veya sunum sırasında bozulan verileri temizlemek için; sadece `ordersBox.clear()` yapan (kullanıcıları silmeden siparişleri temizleyen) ve tüm kutuları sıfırlayıp varsayılan kullanıcıları baştan yükleyen (`fullFactoryReset()`) iki yardımcı metot bulunmalıdır.

## 6. Beklenen Servis Metotları (`HiveDatabaseService`)
Agent bu skill çağrıldığında aşağıdaki merkezi veritabanı yönetim sınıfını üretmelidir:
- `Future<void> initDatabase()` // Hive'ı başlatır ve 3 kutuyu açar
- `Box get usersBox`
- `Box get sessionBox`
- `Box get ordersBox`
- `ValueListenable<Box> listenOrdersBox()`
- `Future<void> clearAllOrders()` // Sadece sipariş geçmişini temizler
- `Future<void> fullResetAndSeed()` // Tüm veritabanını sıfırlar ve test hesaplarını yeniden yükler