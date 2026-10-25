# Sipariş Oluşturma ve Veri Modeli Skill (siparisolusturmaskill.md)

## 1. Amaç ve Kapsam
Bu modül sadece müşterinin yeni bir kargo/kurye siparişi oluşturmasını, sipariş veri modelini (`OrderModel`) ve siparişin `ordersBox` (Hive) içine ilk kez kaydedilmesini yönetir. Fiyat hesaplama veya durum güncelleme işlemleri bu modülün dışındadır.

## 2. Sipariş Veri Modeli (`OrderModel`) ve `ordersBox`
Hive'daki `ordersBox` içinde her sipariş aşağıdaki alanlarla saklanır:
- `id` (String): Benzersiz sipariş numarası (Örn: `'ORD-1042'`).
- `customerId` (String): Siparişi oluşturan müşterinin ID'si.
- `customerName` (String): Müşterinin adı soyadı.
- `courierId` (String?): İlk oluşturulduğunda `null`.
- `courierName` (String?): İlk oluşturulduğunda `null`.
- `courierVehicle` (String?): Kurye atandığında atanan kuryenin araç tipi.
- `preferredVehicle` (String?): Müşterinin seçtiği opsiyonel araç tercihi (`MOTORCYCLE`, `CAR`, `MINIVAN`, `PANELVAN`, `MAXIVAN`, `TRUCK` veya hepsi için `null`).
- `packageSize` (String): `'DOCUMENT'`, `'SMALL'`, `'MEDIUM'`, `'LARGE'`, `'XLARGE'`, `'PALLET'`, `'HEAVY_CARGO'` (0 kg - +600 kg).
- `contentType` (String): `'Evrak'`, `'Elektronik'`, `'Gıda / Pasta'`, `'Kıyafet'`, `'Anahtar/Unutulan Eşya'`, `'Paletli Ağır Yük / Sanayi Parçası'`, `'Evcil Hayvan'`, `'Diğer'`.
- `customDescription` (String): Müşterinin tamamen kendi belirlediği serbest paket içeriği metni.
- `isFragile` (bool): Kırılabilir/Hassas gönderi mi?
- `requiresThermalBag` (bool): Termal çanta gerekiyor mu?
- `pickupTitle` & `pickupAddressDetail` (String): Alış noktası başlığı ve açık adres tarifi.
- `pickupLat` & `pickupLng` (double): Alış koordinatları.
- `dropoffTitle` & `dropoffAddressDetail` (String): Teslimat noktası başlığı ve açık adres tarifi.
- `dropoffLat` & `dropoffLng` (double): Teslimat koordinatları.
- `distanceKm` (double): `MapService` üzerinden gelen mesafe (km).
- `price` (double): `PricingService` üzerinden gelen hesaplanmış tutar (TL).
- `deliveryOtpCode` (String): Sipariş oluşturulurken `1000` - `9999` arasında rastgele üretilen 4 haneli teslimat onay kodu.
- `status` (String): İlk oluşturulduğunda her zaman `'WAITING_FOR_COURIER'`.
- `createdAt` (String): ISO-8601 oluşturulma tarihi.

## 3. Sipariş Oluşturma Validasyon Kuralları
1. `packageSize`, `contentType`, `customDescription`, alış ve varış noktaları boş bırakılamaz.
2. `customDescription` en az 5 karakter olmalıdır (Müşteri ne gönderdiğini açıkça yazmalıdır).
3. Sipariş kaydedilirken `Random()` ile 4 haneli `deliveryOtpCode` otomatik üretilir.

## 4. Beklenen Servis Metotları (`OrderCreationService`)
- `Future<OrderModel> createOrder({...})`
- `String generateOtpCode()`