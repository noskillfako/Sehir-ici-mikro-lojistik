# Session & Role Management Skill (sessionskill.md)

## 1. Amaç ve Kapsam
Bu modül, "Şehir İçi Mikro Lojistik" uygulamasında giriş yapmış kullanıcının oturumunu yerel veritabanında (Hive) hatırlar, uygulama açılışında yönlendirme (Routing) yapar ve tek cihazda test/kullanım kolaylığı için **Müşteri (Customer) <-> Kurye (Courier)** profilleri arasında anlık geçişi yönetir.

## 2. Hive Kutusu (Box) Yapısı
- **Kutu Adı:** `sessionBox`
- **Tutulacak Anahtarlar (Keys):**
  - `currentUserId` (String?): Aktif kullanıcının benzersiz ID'si. Oturum yoksa `null`.
  - `activeRole` (String): `'CUSTOMER'` veya `'COURIER'`.
  - `isLoggedIn` (bool): Oturum açık mı kontrolü.
  - `activeVehicleType` (String?): Eğer aktif rol `'COURIER'` ise kuryenin araç tipi (`'MOTORCYCLE'`, `'CAR'`, `'VAN'`, `'BICYCLE'`). Sipariş filtrelemede kullanılır.

## 3. Temel İş Kuralları (Business Logic)
1. **Otomatik Giriş (Auto-Login):** Uygulama başlatıldığında (`SplashScreen` veya `main.dart`), `sessionBox.get('isLoggedIn')` kontrol edilir:
   - `true` ise: `activeRole` değerine bakılır. `'CUSTOMER'` ise Müşteri Ana Sayfasına (`CustomerHomeView`), `'COURIER'` ise Kurye Sipariş Havuzuna (`CourierDashboardView`) yönlendirilir.
   - `false` veya `null` ise: Giriş ekranına (`LoginView`) yönlendirilir.
2. **Hızlı Rol/Profil Değiştirme (Demo & Test Modu):**
   - Uygulama lokalde (Hive) çalıştığı ve aynı cihazdan önce müşteri olup sipariş verileceği, ardından kurye olup siparişin teslim alınacağı için Üst Bar (AppBar) veya Profil sayfasında **"Kurye Moduna Geç / Müşteri Moduna Geç"** (`switchRole()`) aksiyonu bulunmalıdır.
   - Rol değiştirildiğinde `sessionBox` içindeki `activeRole` güncellenir ve arayüz ilgili rolün ana ekranına yenilenerek geçer.
3. **Çıkış Yapma (Logout):**
   - `logout()` çağrıldığında `ordersBox` veya `usersBox` SİLİNMEZ! Sadece `sessionBox.clear()` (veya `isLoggedIn = false`) yapılarak kullanıcı giriş ekranına atılır. Böylece oluşturulan siparişler kaybolmaz.

## 4. Beklenen Servis Metotları (`SessionService`)
Agent bu skill çağrıldığında aşağıdaki metotları içeren bir servis/controller üretmelidir:
- `Future<void> saveSession({required String userId, required String role, String? vehicleType})`
- `String? getCurrentUserId()`
- `String getActiveRole()`
- `Future<void> switchRole()` // CUSTOMER ise COURIER, COURIER ise CUSTOMER yapar
- `Future<void> clearSession()`