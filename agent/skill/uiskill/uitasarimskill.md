# UI, Tema ve Tasarım Sistemi Skill (uitasarimskill.md)

## 1. Amaç ve Kapsam
Bu modül; **routeDuck** (Şehir İçi Mikro-Lojistik) uygulamasının tüm arayüz görsel kurallarını, çift tema desteğini (**Dark Mode:** *Glass & Emerald Obsidian*, **Light Mode:** *Warm Linen & Emerald*), 5 kademeli kurye araç seçim ekranı standartlarını ve rol bazlı (Müşteri <-> Kurye) bileşen davranışlarını yönetir.

---

## 2. Renk Paletleri ve Tasarım Dili

### A. Koyu Mod: "Glass & Emerald Obsidian" (Varsayılan Koyu Tema)
- **Ana Zemin (Scaffold Bg):** Radyal derin espresso gradyanı (`#120B07` ➔ `#0A0604`) veya düz `#120B07`
- **Kart ve Panel Zeminleri (Warm Slate):** `#1E140E` / `Color(0xFF1E140E)`
- **Kart Kenarlıkları:** `#2E1E15` / `Color(0xFF2E1E15)`
- **Aktif Görev Kartı (Orman Yeşili Gradyan):** `#182C1C` ➔ `#111A13`, kenarlık `#1F4C27`
- **İkon Rozet Yuvaları:** `#11381A` zemin, `#1E5C2C` kenarlık
- **Birincil Vurgu & Butonlar (Peach Amber):** `#EDA45F` / `Color(0xFFEDA45F)`, metin rengi `#120A05`
- **Canlı Göstergeler & Başarı:** Canlı Zümrüt Yeşili `#10B981` / `Color(0xFF10B981)`
- **Metin Renkleri:** Birincil `#FFFFFF`, İkincil `#A38977`, Muted `#6E5646`

### B. Aydınlık Mod: "Warm Linen & Emerald" (Göz Yormayan Açık Tema)
*Aşırı çiğ, parlayan beyaz (`#FFFFFF`) yerine sıcak keten/kemik ve fildişi tonları kullanılarak göz konforu sağlanır:*
- **Ana Zemin (Scaffold Bg):** Sıcak Keten / Kemik Fildişi (`#F6F3EE` / `Color(0xFFF6F3EE)`)
- **Kart ve Yüzeyler (Surface):** Yumuşak Krem Beyazı (`#FDFAF7` / `Color(0xFFFDFAF7)`)
- **Kart Kenarlıkları:** İnce Sıcak Kum Gri (`#E5DDD3` / `Color(0xFFE5DDD3)`)
- **Aktif Görev Kartı:** Zümrüt Işıltılı Keten Zemin (`#EDF6F0`), kenarlık `#A7D7B5`
- **Birincil Vurgu & Butonlar:**
  - *Ana Buton (CTA):* Derin Orman Zümrütü (`#0D532B` / `Color(0xFF0D532B)`), metin rengi `#FFFFFF`
  - *İkincil / Vurgu:* Sıcak Karamel (`#D97706` / `Color(0xFFD97706)`)
- **Metin Renkleri:** Birincil Başlıklar `#1F1610`, İkincil Açıklamalar `#6E5E52`, Muted `#9C8B7E`

---

## 3. Kurye Araç Seçim Ekranı ve Kapasite Kataloğu

Kurye kayıt ve araç güncelleme ekranlarında (`register_view.dart` & kurye profil ekranı), sisteme tanımlı 6 ana araç kategorisi 3D izometrik şeffaf görsellerle ve kartlar halinde sunulur.

### 6 Araç Kataloğu, Dosya Yolları ve Kapasite Kuralları:
1. **`MOTORCYCLE` (Kurye Maxi Scooter / Motosiklet):**
   - *Görsel:* `assets/images/vehicles/motorcycle.png` (Siperlikli, arka çantalı beyaz maxi scooter)
   - *Taşıma Kapasitesi:* `DOCUMENT`, `SMALL`, `MEDIUM` (Maksimum 15 Kg).
   - *Avantaj:* Yoğun saatlerde en hızlı teslimat, dinamik dar sokak rotaları.
2. **`CAR` (Binek Otomobil / Sedan):**
   - *Görsel:* `assets/images/vehicles/car.png` (Beyaz sedan binek otomobil)
   - *Taşıma Kapasitesi:* `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE` (Maksimum 60 Kg).
   - *Özellik:* Hassas eşya, takım elbise/çiçek ve çoklu paket taşıma.
3. **`MINIVAN` (Küçük Ticari / City Van):**
   - *Görsel:* `assets/images/vehicles/minivan.png` (Beyaz kompakt panelvan - Berlingo/Partner tarzı)
   - *Taşıma Kapasitesi:* `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE`, `XLARGE` (Maksimum 200 Kg).
4. **`PANELVAN` (Standart Hafif Ticari):**
   - *Görsel:* `assets/images/vehicles/panelvan.png` (Kısa şasi kapalı kasa panelvan)
   - *Taşıma Kapasitesi:* `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE`, `XLARGE` (Maksimum 450 Kg).
5. **`MAXIVAN` (Büyük Boy Yüksek Tavan Ticari):**
   - *Görsel:* `assets/images/vehicles/maxivan.png` (Uzun şasi yüksek tavan panelvan - Ducato/Sprinter tarzı)
   - *Taşıma Kapasitesi:* `DOCUMENT`, `SMALL`, `MEDIUM`, `LARGE`, `XLARGE`, `PALLET` (Maksimum 600 Kg).
6. **`TRUCK` (Ağır Ticari Kamyon / Tır):**
   - *Görsel:* `assets/images/vehicles/truck.png` (Beyaz dorse çekici / Ağır ticari tır)
   - *Taşıma Kapasitesi:* Tüm boyutlar + `HEAVY_CARGO` (+600 Kg ve sanayi tipi ağır yükler, Maksimum 25.000 Kg).

### Müşteri Araç Seçim Bileşeni (CreateOrderView):
Müşteri sipariş verirken seçilen kargo boyutuna uyumlu araçlar arasından dilerse belirli bir araç türünü tercih edebilir. Boyuta uygun olmayan araçlar grileşir ve seçilemez.

### Web ve Masaüstü Duyarlılık (Responsive Constraints):
Geniş ekranlarda (web/masaüstü) form elemanlarının ve adres kutularının aşırı yayılmasını ve orantısız büyümesini engellemek için tüm ana görünümler `Center` içinde `ConstrainedBox(constraints: BoxConstraints(maxWidth: 680))` ile sınırlandırılmıştır.

### Araç Seçim Kartı Tasarım Kuralları:
- Seçilmeyen Kart:
  - *Dark:* `#1E140E` zemin, `#2E1E15` sınır çizgisi, yarı saydam araç görseli (`opacity: 0.75`).
  - *Light:* `#FDFAF7` zemin, `#E5DDD3` sınır çizgisi.
- Seçili Kart (Active State):
  - *Dark:* Zemin `#182C1C`, kenarlık `2px solid #10B981` (veya `#EDA45F`), sağ üstte yeşil onay ikonu (`Icons.check_circle`).
  - *Light:* Zemin `#EDF6F0`, kenarlık `2px solid #0D532B`, koyu yeşil onay ikonu.
- Ek Donanım Seçimi: Araç kartının hemen altında **"Termal Çantam Var (Sıcak/Soğuk Gıda Taşıyabilirim)"** onay kutusu (Switch/Checkbox).

---

## 4. Ortak UI Bileşenleri Standartları

### A. 4 Haneli OTP Teslimat Kasası (`teslimatonayskill.md`)
- **Koyu Mod:** Zemin `rgba(0,0,0,0.4)`, kenarlık `1.5px dashed #EDA45F`, kod rengi `#EDA45F`, `letterSpacing: 8.0`.
- **Aydınlık Mod:** Zemin `#F0E9DF`, kenarlık `1.5px dashed #D97706`, kod rengi `#B45309`, `letterSpacing: 8.0`.
- **Gizlilik:** Kurye ekranında OTP girişi klavyeli `PinCodeTextField` ile açılır; müşteri ekranında ise kod net ve büyük olarak gösterilir.

### B. Canlı Durum ve GPS Rozeti
- "routeDuck GPS & Kümeleme Aktif 🦆" mikro hap rozeti.
- Koyu modda `rgba(16, 185, 129, 0.12)` zemin, aydınlık modda `#E2F2E7` zemin ve koyu yeşil metin.

---

## 5. Flutter Tema Kodları (`lib/core/theme/app_theme.dart`)

```dart
import 'package:flutter/material.dart';

class RouteDuckTheme {
  // === Ortak Renkler ===
  static const Color peachAmber = Color(0xFFEDA45F);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color deepForest = Color(0xFF0D532B);
  static const Color duckOrange = Color(0xFFE65C00);

  // === Koyu Mod Renkleri (Glass & Emerald Obsidian) ===
  static const Color darkScaffold = Color(0xFF120B07);
  static const Color darkCard = Color(0xFF1E140E);
  static const Color darkBorder = Color(0xFF2E1E15);
  static const Color darkActiveTaskCard = Color(0xFF162319);
  static const Color darkTextPrimary = Color(0xFFFAF4EF);
  static const Color darkTextSecondary = Color(0xFFA38977);

  // === Aydınlık Mod Renkleri (Warm Linen & Emerald) ===
  static const Color lightScaffold = Color(0xFFF6F3EE);
  static const Color lightCard = Color(0xFFFDFAF7);
  static const Color lightBorder = Color(0xFFE5DDD3);
  static const Color lightActiveTaskCard = Color(0xFFEDF6F0);
  static const Color lightTextPrimary = Color(0xFF1F1610);
  static const Color lightTextSecondary = Color(0xFF6E5E52);

  // === KOYU TEMA (DARK THEME) ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffold,
      primaryColor: peachAmber,
      colorScheme: const ColorScheme.dark(
        primary: peachAmber,
        secondary: emeraldGreen,
        surface: darkCard,
        onSurface: darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkScaffold,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: peachAmber,
          foregroundColor: const Color(0xFF120A05),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  // === AYDINLIK TEMA (LIGHT THEME - WARM LINEN) ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightScaffold,
      primaryColor: deepForest,
      colorScheme: const ColorScheme.light(
        primary: deepForest,
        secondary: Color(0xFFD97706),
        surface: lightCard,
        onSurface: lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightScaffold,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepForest,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}