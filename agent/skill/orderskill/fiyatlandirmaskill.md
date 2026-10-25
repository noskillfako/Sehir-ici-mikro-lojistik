# Dinamik Fiyatlandırma Motoru Skill (fiyatlandirmaskill.md)

## 1. Amaç ve Kapsam
Bu modül tamamen saf matematiksel iş mantığından (pure business logic) oluşur. Müşteri sipariş ekranında paket boyutu, mesafe veya ek özellik (kırılabilir, termal çanta) seçtiğinde toplam taşıma ücretini ve kurye kazancını anlık olarak hesaplar.

## 2. Sabit Ücret Parametreleri
- **Açılış Ücreti (`baseFare`):** `60.0 TL`
- **Kilometre Başı Ücret (`perKmRate`):** `15.0 TL`
- **Kırılabilir / Hassas Ek Ücreti (`fragileFee`):** `+30.0 TL`
- **Termal Çanta Ek Ücreti (`thermalBagFee`):** `+25.0 TL`
- **Platform Komisyon Oranı:** `%15` (Toplam tutarın %85'i kurye net kazancı olarak gösterilir).

## 3. Paket Boyutu Çarpanları (`Size Multipliers`)
- `'DOCUMENT'` (Zarf / Evrak - 0-1 Kg): `1.0`
- `'SMALL'` (Küçük Paket - 1-5 Kg): `1.2`
- `'MEDIUM'` (Orta Koli - 5-15 Kg): `1.6`
- `'LARGE'` (Büyük Koli / Eşya - 15-60 Kg): `2.2`
- `'XLARGE'` (Hacimli / Ağır Ticari - 60-200 Kg): `3.5`
- `'PALLET'` (Paletli / Çok Ağır Yük - 200-600 Kg): `5.0`
- `'HEAVY_CARGO'` (Devasa Ağır Yük / Sanayi - +600 Kg): `7.5`

## 4. Araç Büyüklüğü ve Yakıt Tüketim Katsayıları (`Fuel Multipliers`)
Araç büyüdükçe kilometre başına yaktığı yakıt miktarı arttığı için sipariş fiyatına araç yakıt ek maliyeti yansıtılır:
- `'MOTORCYCLE'` (Motosiklet): `1.0x` (~2.5 L/100km, En ekonomik taban)
- `'CAR'` (Binek Otomobil / Sedan): `1.25x` (~6.5 L/100km)
- `'MINIVAN'` (Kompakt Minivan): `1.45x` (~8.0 L/100km)
- `'PANELVAN'` (Standart Panelvan): `1.70x` (~10.5 L/100km)
- `'MAXIVAN'` (Yüksek Tavan Maxi Van): `2.0x` (~13.0 L/100km)
- `'TRUCK'` (Ağır Ticari Kamyon / Tır): `2.8x` (~32.0 L/100km)

## 5. Hesaplama Formülü
1. **Ham Mesafe Tutarı:** `distanceKm * 15.0 TL`
2. **Taban Açılış Tutarı:** `60.0 TL`
3. **Boyut Çarpanlı Tutar:** `(60.0 + Ham Mesafe Tutarı) * SizeMultiplier`
4. **Araç Yakıt Ek Tutarı:** `Ham Mesafe Tutarı * (FuelMultiplier - 1.0)`
5. **Toplam Müşteri Tutarı:** `Boyut Çarpanlı Tutar + Araç Yakıt Ek Tutarı + (isFragile ? 30 : 0) + (requiresThermalBag ? 25 : 0)`
6. **Kurye Net Kazancı:** `Toplam Müşteri Tutarı * 0.85`
*(Tüm tutarlar virgülden sonra 2 basamağa yuvarlanır).*

## 6. Beklenen Servis Metotları (`PricingService`)
- `double calculateTotalPrice({required double distanceKm, required String packageSize, required bool isFragile, required bool requiresThermalBag, String? vehicleType})`
- `double calculateCourierEarnings(double totalPrice)`
- `Map<String, double> getPriceBreakdown({...})` // Arayüzde açılış, mesafe, boyut katsayısı ve araç yakıt ek ücretini detaylı göstermek için.