# Kurye Eşleştirme ve Sipariş Havuzu Filtreleme Skill (kuryeeslesmeskill.md)

## 1. Amaç ve Kapsam
Bu modül; kurye profiline geçildiğinde `ordersBox` (Hive) içinde bekleyen (`WAITING_FOR_COURIER`) siparişlerin kuryenin **araç tipine**, **taşıma kapasitesine** ve **ekipmanına (termal çanta)** göre filtrelenmesini, sıralanmasını ve kuryenin siparişi kendi üzerine almasını (eşleşme) yönetir.

## 2. Araç Tipi ve Paket Boyutu Eşleşme Matrisi (Kapasite Kuralı)
Bir kurye havuza baktığında tüm siparişleri göremez; sadece kendi aracına sığabilecek paket boyutlarını görebilir:

- **`BICYCLE` (Bisiklet / Scooter Kurye):**
  - Görebileceği Boyutlar: `DOCUMENT`, `SMALL`
  - Göremeyeceği Boyutlar: `MEDIUM`, `LARGE`
- **`MOTORCYCLE` (Moto Kurye):**
  - Görebileceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`
  - Göremeyeceği Boyutlar: `LARGE` (Büyük koli ve hacimli eşyalar motora sığmaz)
- **`CAR` (Binek Araçlı Kurye):**
  - Görebileceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE` (Tüm boyutlar)
- **`VAN` (Panelvan / Hafif Ticari Kurye):**
  - Görebileceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE` (Tüm boyutlar, `LARGE` öncelikli)

## 3. Özel Ekipman ve Hassasiyet Filtresi (Donanım Kuralı)
1. **Termal Çanta Kuralı (`requiresThermalBag`):**
   - Müşteri siparişte `requiresThermalBag == true` (Gıda, Yaş Pasta, Sıcak Yemek vb.) seçmişse; bu sipariş SADECE profilinde `hasThermalBag == true` olan kuryelerin havuzunda listelenir.
   - Termal çantası olmayan kuryeler bu siparişi havuzda göremez veya "Ekipman Uyumsuz" uyarısıyla kilitli görür.
2. **Kırılabilir Eşya Gösterimi (`isFragile`):**
   - `isFragile == true` olan siparişler tüm uygun araçlara gösterilir ancak kurye kartında kırmızı/turuncu **"Hassas / Kırılabilir Gönderi"** rozeti (Badge) ile vurgulanır.

## 4. Eşleşme ve Sipariş Kabul Kuralları (Business Logic)
1. **Tek Aktif Görev Kısıtlaması (Active Task Lock):**
   - Kuryenin üzerinde halihazırda `COURIER_ASSIGNED` veya `IN_TRANSIT` durumunda bir sipariş varsa, kurye havuzdan yeni bir sipariş kabul edemez.
   - Yeni sipariş almaya çalıştığında `"Önce mevcut aktif teslimatınızı tamamlamalısınız"` hatası döner.
2. **Siparişi Üstlenme (Accept Order):**
   - Kurye uygun bir siparişte **"Siparişi Kabul Et"** butonuna bastığında:
     - Siparişin `status` alanı `'WAITING_FOR_COURIER'` -> `'COURIER_ASSIGNED'` olarak güncellenir.
     - Siparişin `courierId` alanına aktif kuryenin ID'si, `courierName` alanına kuryenin adı, `courierVehicle` alanına kuryenin araç tipi yazılır ve `ordersBox` güncellenir.
3. **Havuz Sıralaması (Sorting):**
   - Kurye havuzundaki uygun siparişler varsayılan olarak **en yeni oluşturulandan en eskiye (`createdAt` azalan)** doğru sıralanır.
   - Opsiyonel olarak kurye **"En Yüksek Kazanç (`price` azalan)"** veya **"En Kısa Mesafe (`distanceKm` artan)"** filtresiyle havuzu yeniden sıralayabilir.

## 5. Beklenen Servis Metotları (`CourierMatchingService`)
Agent bu skill çağrıldığında aşağıdaki metotları içeren bir servis üretmelidir:
- `bool isOrderCompatibleWithCourier({required OrderModel order, required UserModel courier})`
- `List<OrderModel> getFilteredOrderPool({required UserModel courier, String sortBy = 'NEWEST'})`
- `bool hasActiveOrder(String courierId)`
- `Future<bool> matchCourierWithOrder({required String orderId, required UserModel courier})`