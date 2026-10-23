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
- `'LARGE'` (Büyük / Hacimli - 15+ Kg): `2.5`

## 4. Hesaplama Formülü
1. **Ham Mesafe Tutarı:** `60.0 + (distanceKm * 15.0)`
2. **Boyut Çarpanlı Tutar:** `Ham Mesafe Tutarı * SizeMultiplier`
3. **Toplam Müşteri Tutarı:** `Boyut Çarpanlı Tutar + (isFragile ? 30 : 0) + (requiresThermalBag ? 25 : 0)`
4. **Kurye Net Kazancı:** `Toplam Müşteri Tutarı * 0.85`
*(Tüm tutarlar virgülden sonra 2 basamağa veya tam sayıya yuvarlanır).*

## 5. Beklenen Servis Metotları (`PricingService`)
- `double calculateTotalPrice({required double distanceKm, required String packageSize, required bool isFragile, required bool requiresThermalBag})`
- `double calculateCourierEarnings(double totalPrice)`
- `Map<String, double> getPriceBreakdown({...})` // Arayüzde "Açılış: 60 TL, Mesafe: 45 TL, Hassas Ek: 30 TL" şeklinde detay göstermek için.