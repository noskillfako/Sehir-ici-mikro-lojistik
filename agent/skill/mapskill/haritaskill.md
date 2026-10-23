# Map, Location & Distance Calculation Skill (haritaskill.md)

## 1. Amaç ve Kapsam
Bu modül; dışarıdan ücretli bir API (Google Maps Geocoding/Directions vb.) KULLANMADAN, ücretsiz açık kaynaklı harita (`flutter_map` + OpenStreetMap) üzerinde alış ve varış noktalarını göstermeyi, sabit/hazır lokasyonlardan seçim yaptırmayı ve iki nokta arasındaki mesafeyi (km) hesaplamayı yönetir.

## 2. Kullanılacak Paketler
- `flutter_map`: OpenStreetMap tabanlı ücretsiz harita widget'ı (API Key gerektirmez).
- `latlong2`: Enlem/Boylam (`LatLng`) modeli ve mesafe hesaplamaları için.

## 3. Sabit Lokasyon Kataloğu (`PredefinedLocations`)
API üzerinden adres araması (Geocoding) yapılmayacağı için, müşteri sipariş oluştururken "Alış Noktası" ve "Teslimat Noktası"nı aşağıdaki hazır koordinat listesinden (Dropdown / BottomSheet ile) veya doğrudan haritaya dokunarak (`onTap`) seçer:

1. **Kadıköy (Boğa Heykeli):** `LatLng(40.9904, 29.0292)`
2. **Beşiktaş (Meydan / İskele):** `LatLng(41.0422, 29.0067)`
3. **Şişli (Cevahir AVM Önü):** `LatLng(41.0621, 28.9926)`
4. **Üsküdar (Marmaray Çıkışı):** `LatLng(41.0264, 29.0151)`
5. **Levent (Büyükdere Cad. / Plazalar):** `LatLng(41.0772, 29.0108)`
6. **Ataşehir (Finans Merkezi / Bulvar):** `LatLng(40.9932, 29.1130)`
7. **Bakırköy (Özgürlük Meydanı):** `LatLng(40.9801, 28.8722)`
8. **Taksim (AKM Önü):** `LatLng(41.0369, 28.9850)`

*(Not: Kullanıcı haritaya tıklayarak özel bir koordinat da seçebilir, ayrıca seçtiği noktanın altına "Sokak, Bina No, Kat, Daire" bilgisini serbest metin olarak yazar).*

## 4. Mesafe Hesaplama Kuralı (Haversine Formülü)
Müşteri Alış (`pickupLatLng`) ve Varış (`dropoffLatLng`) noktalarını seçtiği anda:
- `latlong2` paketindeki `const Distance()` sınıfı (veya Haversine formülü) kullanılarak iki koordinat arasındaki kuş uçuşu mesafe kilometre (km) cinsinden hesaplanır.
- Şehir içi yol kıvrımlarını simüle etmek için çıkan kuş uçuşu mesafe **`1.3` (Yol Çarpanı)** ile çarpılır ve virgülden sonra 1 basamağa yuvarlanır (Örn: `4.8 km`).
- Alış ve varış noktası aynı seçilirse uyarı verilir (`"Alış ve teslimat noktası aynı olamaz"`).

## 5. Harita Görselleştirme Kuralları (UI)
- **Harita Katmanı (TileLayer):** `https://tile.openstreetmap.org/{z}/{x}/{y}.png` kullanılır (`userAgentPackageName: 'com.mikrolojistik.app'` zorunludur).
- **Pinler (MarkerLayer):**
  - Alış Noktası (Pickup): Yeşil veya Mavi İkon (`Icons.location_on`).
  - Varış Noktası (Dropoff): Kırmızı Bayrak/Pin İkonu (`Icons.flag`).
  - Kurye Konumu (Sipariş aktifse): Motor/Araç İkonu (`Icons.delivery_dining`).
- **Rota Çizgisi (PolylineLayer):** Alış ve varış noktaları arasına kesikli veya düz renkli bir çizgi (`Polyline`) çekilerek rota görselleştirilir.

## 6. Beklenen Servis Metotları (`MapService`)
- `List<LocationPreset> getPredefinedLocations()`
- `double calculateRouteDistanceKm(LatLng pickup, LatLng dropoff)`
- `int calculateEstimatedMinutes(double distanceKm, String vehicleType)`