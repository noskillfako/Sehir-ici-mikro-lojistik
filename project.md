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

## 4. Kargo Boyutları ve Araç Eşleşme Kuralları (Sabit Katalog)
Müşteri sipariş oluştururken aşağıdaki 4 ana boyuttan birini seçmek zorundadır:
- `DOCUMENT` (Zarf / Evrak - 0-1 Kg): Tüm kuryeler (`BICYCLE`, `MOTORCYCLE`, `CAR`, `VAN`) görebilir.
- `SMALL` (Küçük Paket / Çanta Boy - 1-5 Kg): `BICYCLE`, `MOTORCYCLE`, `CAR`, `VAN` görebilir.
- `MEDIUM` (Orta Koli - 5-15 Kg): Sadece `MOTORCYCLE`, `CAR`, `VAN` görebilir.
- `LARGE` (Büyük / Hacimli Yük - 15+ Kg): Sadece `CAR` ve `VAN` görebilir (Moto kuryeye düşmez).

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