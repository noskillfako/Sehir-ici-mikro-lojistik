# Proje Adı: Şehir İçi Mikro Lojistik (Sehir-ici-mikro-lojistik)

## 1. Proje Özeti
Siparişi olan müşteriler ile şehir içi kuryeleri (yaya, moto, binek araç, panelvan) bir araya getiren iki taraflı (two-sided marketplace) mobil uygulama. Harici bir backend/API kullanılmaz; tüm veriler cihaz içinde **Hive (NoSQL)** veritabanında saklanır. Aynı cihaz üzerinden önce müşteri profiliyle sipariş oluşturulur, ardından kurye profiline geçilerek sipariş kabul edilip teslim edilir.

## 2. Teknoloji Yığını (Tech Stack)
- **Framework:** Flutter (Dart)
- **Yerel Veritabanı:** `hive` ve `hive_flutter` (Tüm veriler JSON/Map veya TypeAdapter olarak lokalde tutulur)
- **Harita:** `flutter_map` (OpenStreetMap tabanlı, ücretsiz, API Key gerektirmez) ve `latlong2`
- **Mimari Yaklaşım:** Feature-first veya katmanlı mimari (`models`, `services`, `views`, `widgets`)

## 3. Standart Hive Kutuları (Boxes)
Uygulama genelinde sadece aşağıdaki 3 ana Hive kutusu kullanılacaktır:
1. `usersBox`: Kayıtlı müşteri ve kurye hesaplarını tutar.
2. `sessionBox`: Aktif oturumu ve o anki rolü (`CUSTOMER` veya `COURIER`) tutar.
3. `ordersBox`: Müşterilerin oluşturduğu tüm kargo/kurye siparişlerini tutar.

## 4. Kargo Boyutları ve Gerçekçi Araç Eşleşme Kuralları (Sabit Katalog)
Müşteri sipariş oluştururken 0 kg'dan +600 kg'a kadar 7 ana boyuttan birini seçer:
- `DOCUMENT` (Zarf / Evrak - 0-1 Kg): Sadece `MOTORCYCLE` ve `CAR` (Bir evrak için TIR veya büyük ticari araç çağrılamaz).
- `SMALL` (Küçük Paket - 1-5 Kg): `MOTORCYCLE`, `CAR`, `MINIVAN`.
- `MEDIUM` (Orta Koli - 5-15 Kg): `MOTORCYCLE`, `CAR`, `MINIVAN`, `PANELVAN`.
- `LARGE` (Büyük Koli / Eşya - 15-60 Kg): `CAR`, `MINIVAN`, `PANELVAN`, `MAXIVAN` (Motosiklete sığmaz).
- `XLARGE` (Hacimli / Ağır Ticari - 60-200 Kg): `MINIVAN`, `PANELVAN`, `MAXIVAN`.
- `PALLET` (Paletli / Çok Ağır Yük - 200-600 Kg): `MAXIVAN`, `TRUCK` (Standart Panelvan 450 kg azami kapasiteye sahip olduğundan 450+ kg paleti taşıyamaz).
- `HEAVY_CARGO` (Devasa Ağır Yük / Sanayi - +600 Kg): Sadece `TRUCK` (Ağır Ticari Kamyon / Tır).

### 4.1. 6 Araç Sınıfı Kataloğu ve Kapasiteleri
Uygulama 6 gerçek araç sınıfını ve şeffaf görsel kataloglarını destekler:
1. `MOTORCYCLE` (Motosiklet / Maxi Scooter): Maksimum 15 Kg
2. `CAR` (Binek Otomobil / Sedan): Maksimum 60 Kg
3. `MINIVAN` (Kompakt Minivan / City Van): Maksimum 200 Kg
4. `PANELVAN` (Standart Hafif Ticari Panelvan): Maksimum 450 Kg
5. `MAXIVAN` (Yüksek Tavan Maxi Panelvan): Maksimum 600 Kg
6. `TRUCK` (Ağır Ticari Kamyon / Tır): +600 Kg (Maksimum 25.000 Kg)

### 4.2. Müşteri Araç Tercihi (Customer Preferred Vehicle)
Müşteri sipariş oluştururken seçtiği paket boyutuna ve kilo aralığına uygun araçlar arasından dilerse doğrudan istediği araç sınıfını (`preferredVehicle`) seçebilir veya "Tüm Uygun Araçlar" seçeneğini bırakarak havuza gönderebilir. Kurye eşleşmesinde kuryenin araç türü hem paket boyutuna hem de müşterinin araç tercihine uymalıdır.

## 5. İçerik Kategorileri ve Etiketler
- **Kategoriler:** `Evrak`, `Elektronik`, `Gıda / Pasta`, `Kıyafet / Tekstil`, `Unutulan Eşya (Anahtar vb.)`, `Evcil Hayvan`, `Diğer`
- **Özel Etiketler (Boolean Flags):**
  - `isFragile` (Kırılabilir / Hassas Gönderi)
  - `requiresThermalBag` (Sıcak/Soğuk Koruma Gerektirir)
- **Serbest Açıklama (`customDescription`):** Müşterinin paket içeriğini kendi cümleleriyle yazdığı zorunlu metin alanı.

## 6. Sipariş Durum Döngüsü (Order Status Enum)
1. `WAITING_FOR_COURIER`: Müşteri siparişi oluşturdu, kurye havuzunda bekliyor.
2. `COURIER_ASSIGNED`: Kurye siparişi kabul etti, müşteriye doğru yola çıktı.
3. `IN_TRANSIT`: Kurye paketi müşteriden teslim aldı, alıcıya götürüyor.
4. `DELIVERED`: Kurye 4 haneli teslimat kodunu (OTP) girdi ve teslimat tamamlandı.
5. `CANCELLED`: Sipariş iptal edildi.