# Authentication & User Management Skill (authskill.md)

## 1. Amaç ve Kapsam
Bu modül; Müşteri (`CUSTOMER`) ve Kurye (`COURIER`) kullanıcılarının kayıt olmasını (Register), giriş yapmasını (Login) ve uygulama ilk kez çalıştığında test kolaylığı için varsayılan (seed) kullanıcıların `usersBox` içine yüklenmesini yönetir.

## 2. Kullanıcı Veri Modeli (`UserModel`) ve `usersBox`
Hive'daki `usersBox` içinde her kullanıcı aşağıdaki alanlarla (Map veya Adapter olarak) saklanır:
- `id` (String): Benzersiz kullanıcı ID'si (Örn: `'usr_customer_1'`, `'usr_courier_1'`).
- `fullName` (String): Ad Soyad.
- `phone` (String): Giriş yaparken kullanılacak telefon numarası (Benzersiz anahtar).
- `password` (String): Şifre.
- `role` (String): `'CUSTOMER'` veya `'COURIER'`.
- `vehicleType` (String?): Sadece `COURIER` için zorunludur (`'BICYCLE'`, `'MOTORCYCLE'`, `'CAR'`, `'VAN'`). Müşteri için `null`.
- `plateNumber` (String?): Kurye araç plakası (Opsiyonel).
- `hasThermalBag` (bool): Kuryenin termal çantası var mı? (Varsayılan: `false`).

## 3. İş Kuralları (Business Logic)
1. **Kayıt Olma (Register):**
   - Kullanıcı formda Rol seçer (`Müşteri` veya `Kurye`).
   - Eğer `Kurye` seçilirse ekranda ek olarak **Araç Tipi**, **Plaka** ve **Termal Çanta Var mı?** seçimleri açılır (Dinamik Form).
   - Telefon numarası `usersBox` içinde zaten varsa hata fırlatılır (`"Bu telefon numarası zaten kayıtlı"`).
   - Kayıt başarılıysa kullanıcı `usersBox`'a eklenir ve otomatik olarak `SessionService.saveSession()` çağrılarak içeri alınır.

2. **Giriş Yapma (Login):**
   - Telefon ve şifre `usersBox` içinde aranır.
   - Eşleşen kullanıcı bulunursa `SessionService.saveSession()` tetiklenir ve kullanıcının rolüne göre ilgili ana ekrana yönlendirilir.

3. **Hazır Test Hesapları (Seed Default Users - Çok Önemli):**
   - Uygulama ilk açıldığında `usersBox.isEmpty` ise aşağıdaki 3 hazır hesap otomatik oluşturulmalıdır (Giriş ekranında "Hızlı Test Girişi" butonlarıyla tek tıkla girilebilmelidir):
     1. **Hazır Müşteri:** Ad: `Ahmet Yılmaz`, Tel: `5551112233`, Şifre: `1234`, Rol: `'CUSTOMER'`
     2. **Hazır Moto Kurye:** Ad: `Mehmet Demir`, Tel: `5554445566`, Şifre: `1234`, Rol: `'COURIER'`, Araç: `'MOTORCYCLE'`, Termal Çanta: `true`
     3. **Hazır Araçlı Kurye:** Ad: `Caner Kaya`, Tel: `5557778899`, Şifre: `1234`, Rol: `'COURIER'`, Araç: `'CAR'`, Termal Çanta: `false`

## 4. Beklenen Servis Metotları (`AuthService`)
- `Future<void> seedDefaultUsersIfNeeded()`
- `Future<UserModel?> login(String phone, String password)`
- `Future<UserModel> register({...})`
- `UserModel? getUserById(String userId)`