# Kurye Eşleştirme ve Sipariş Havuzu Filtreleme Skill (kuryeeslesmeskill.md)

## 1. Amaç ve Kapsam
Bu modül; kurye profiline geçildiğinde `ordersBox` (Hive) içinde bekleyen (`WAITING_FOR_COURIER`) siparişlerin kuryenin **araç tipine**, **taşıma kapasitesine** ve **ekipmanına (termal çanta)** göre filtrelenmesini, sıralanmasını ve kuryenin siparişi kendi üzerine almasını (eşleşme) yönetir.

## 2. Araç Tipi ve Paket Boyutu Eşleşme Matrisi (Kapasite Kuralı)
Bir kurye havuza baktığında tüm siparişleri göremez; sadece kendi aracının taşıma kapasitesine sığabilecek paket boyutlarını görebilir:

- **`MOTORCYCLE` (Motosiklet / Maxi Scooter - Max 15 Kg):**
  - Görebileceği Boyutlar: `DOCUMENT` (0-1 Kg), `SMALL` (1-5 Kg), `MEDIUM` (5-15 Kg)
  - Göremeyeceği Boyutlar: `LARGE`, `XLARGE`, `PALLET`, `HEAVY_CARGO`
- **`CAR` (Binek Otomobil / Sedan - Max 60 Kg):**
  - Görebileceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE` (15-60 Kg)
  - Göremeyeceği Boyutlar: `XLARGE`, `PALLET`, `HEAVY_CARGO`
- **`MINIVAN` (Kompakt Minivan / City Van - Max 200 Kg):**
  - Görebileceği Boyutlar: `SMALL`, `MEDIUM`, `LARGE`, `XLARGE` (60-200 Kg)
  - Göremeyeceği Boyutlar: `DOCUMENT` (Zarf için minivan çağrılamaz), `PALLET`, `HEAVY_CARGO`
- **`PANELVAN` (Standart Panelvan - Max 450 Kg):**
  - Görebileceği Boyutlar: `MEDIUM`, `LARGE`, `XLARGE` (60-200 Kg)
  - Göremeyeceği Boyutlar: `DOCUMENT`, `SMALL`, `PALLET` (200-600 Kg - Panelvan azami 450 kg'dır), `HEAVY_CARGO` (+600 Kg)
- **`MAXIVAN` (Yüksek Tavan Maxi Panelvan - Max 600 Kg):**
  - Görebileceği Boyutlar: `LARGE`, `XLARGE`, `PALLET` (200-600 Kg)
  - Göremeyeceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`, `HEAVY_CARGO` (+600 Kg)
- **`TRUCK` (Ağır Ticari Kamyon / Tır - Max 25.000 Kg):**
  - Görebileceği Boyutlar: `PALLET` (200-600 Kg), `HEAVY_CARGO` (+600 Kg devasa yükler)
  - Göremeyeceği Boyutlar: `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE`, `XLARGE` (Hafif ve orta paketler için tır çağrılamaz)

## 3. Müşteri Araç Tercihi Filtresi (`preferredVehicle`)
Müşteri sipariş oluştururken paket kilo aralığına uygun spesifik bir araç seçtiyse (`order.preferredVehicle != null`):
- Bu sipariş SADECE o araç türüne sahip kuryelerin havuzunda listelenir (`courier.vehicleType == order.preferredVehicle`).
- Müşteri araç tercihi belirtmediyse (`order.preferredVehicle == null`), paket boyutunu taşıma kapasitesi olan tüm kuryeler siparişi görebilir.

## 4. Özel Ekipman ve Hassasiyet Filtresi (Donanım Kuralı)
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