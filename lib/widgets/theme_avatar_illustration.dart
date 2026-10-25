import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/user_model.dart';

/// RouteDuck Temasına Uygun Özel Çizim Profil İllüstrasyonu
/// Gerçek araç fotoğrafları yerine; RouteDuck sıcak renk paletine (Peach Amber & Emerald),
/// modern vektörel çizgi diline ve sevimli detaylara sahip özgün bir çizim sunar.
class ThemeAvatarIllustration extends StatelessWidget {
  final UserModel? user;
  final String? vehicleType;
  final bool isCustomer;
  final double size;
  final bool showContainer;
  final BorderRadius? borderRadius;
  final Color? containerColor;

  const ThemeAvatarIllustration({
    super.key,
    this.user,
    this.vehicleType,
    this.isCustomer = false,
    this.size = 44,
    this.showContainer = true,
    this.borderRadius,
    this.containerColor,
  });

  /// Kullanıcı modeli üzerinden kolay oluşturucu
  factory ThemeAvatarIllustration.fromUser(
    UserModel user, {
    double size = 44,
    bool showContainer = true,
    BorderRadius? borderRadius,
  }) {
    return ThemeAvatarIllustration(
      user: user,
      vehicleType: user.vehicleType,
      isCustomer: user.isCustomer,
      size: size,
      showContainer: showContainer,
      borderRadius: borderRadius,
    );
  }

  /// Belirli bir araç tipi için çizim
  factory ThemeAvatarIllustration.forVehicle(
    String vehicleType, {
    double size = 44,
    bool showContainer = true,
    BorderRadius? borderRadius,
  }) {
    return ThemeAvatarIllustration(
      vehicleType: vehicleType,
      isCustomer: false,
      size: size,
      showContainer: showContainer,
      borderRadius: borderRadius,
    );
  }

  /// Müşteri rolü için çizim
  factory ThemeAvatarIllustration.customer({
    double size = 44,
    bool showContainer = true,
    BorderRadius? borderRadius,
  }) {
    return ThemeAvatarIllustration(
      isCustomer: true,
      size: size,
      showContainer: showContainer,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIsCustomer = isCustomer || (user?.isCustomer ?? false);
    final effectiveVehicle = vehicleType ?? user?.vehicleType;

    final defaultRadius = borderRadius ?? BorderRadius.circular(size * 0.28);

    Color bg;
    Color border;

    if (effectiveIsCustomer) {
      bg = containerColor ??
          (isDark ? const Color(0xFF14291B) : const Color(0xFFE3F6E9));
      border = isDark
          ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.35)
          : RouteDuckTheme.emeraldGreen.withValues(alpha: 0.25);
    } else {
      bg = containerColor ??
          (isDark ? const Color(0xFF2E190E) : const Color(0xFFFDEFE4));
      border = isDark
          ? RouteDuckTheme.peachAmber.withValues(alpha: 0.35)
          : const Color(0xFFD97706).withValues(alpha: 0.25);
    }

    Widget illustration = CustomPaint(
      size: Size(size, size),
      painter: _ThemeAvatarPainter(
        isCustomer: effectiveIsCustomer,
        vehicleType: effectiveVehicle,
        isDark: isDark,
      ),
    );

    if (!showContainer) {
      return SizedBox(
        width: size,
        height: size,
        child: illustration,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: defaultRadius,
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: (effectiveIsCustomer
                    ? RouteDuckTheme.emeraldGreen
                    : RouteDuckTheme.peachAmber)
                .withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultRadius,
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: illustration,
          ),
        ),
      ),
    );
  }
}

/// 100x100 normalize koordinat alanında çalışan dinamik vektör çizer
class _ThemeAvatarPainter extends CustomPainter {
  final bool isCustomer;
  final String? vehicleType;
  final bool isDark;

  _ThemeAvatarPainter({
    required this.isCustomer,
    required this.vehicleType,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // 100x100 alanına ölçeklendir
    canvas.scale(size.width / 100.0, size.height / 100.0);

    if (isCustomer) {
      _paintCustomer(canvas);
    } else {
      switch (vehicleType) {
        case AppConstants.vehicleMotorcycle:
          _paintMotorcycle(canvas);
          break;
        case AppConstants.vehicleCar:
          _paintCar(canvas);
          break;
        case AppConstants.vehicleMinivan:
          _paintMinivan(canvas);
          break;
        case AppConstants.vehiclePanelvan:
          _paintPanelvan(canvas);
          break;
        case AppConstants.vehicleMaxivan:
          _paintMaxivan(canvas);
          break;
        case AppConstants.vehicleTruck:
          _paintTruck(canvas);
          break;
        default:
          _paintCar(canvas);
          break;
      }
    }

    canvas.restore();
  }

  // ==========================================
  // 1. MÜŞTERİ (ROUTEDUCK MASCOT MÜŞTERİ ÇİZİMİ)
  // ==========================================
  void _paintCustomer(Canvas canvas) {
    // Yumuşak arka plan aurası
    final auraPaint = Paint()
      ..color = RouteDuckTheme.emeraldGreen.withValues(alpha: isDark ? 0.22 : 0.16)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(50, 50), 38, auraPaint);

    // Duck Gövde (Peach Amber)
    final bodyPaint = Paint()
      ..color = RouteDuckTheme.peachAmber
      ..style = PaintingStyle.fill;

    // Baş ve gövde konturu
    final bodyPath = Path()
      ..moveTo(30, 78)
      ..cubicTo(24, 65, 30, 42, 46, 36)
      ..cubicTo(56, 32, 68, 36, 72, 46)
      ..cubicTo(76, 56, 72, 68, 66, 74)
      ..cubicTo(60, 80, 36, 82, 30, 78)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Sevimli Ördek Gagası (Duck Orange)
    final beakPaint = Paint()
      ..color = RouteDuckTheme.duckOrange
      ..style = PaintingStyle.fill;
    final beakPath = Path()
      ..moveTo(68, 48)
      ..quadraticBezierTo(86, 50, 84, 57)
      ..quadraticBezierTo(72, 60, 66, 56)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Göz
    final eyePaint = Paint()..color = const Color(0xFF1E140E);
    canvas.drawCircle(const Offset(58, 45), 4.2, eyePaint);
    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(59.5, 43.5), 1.6, sparkPaint);

    // Zümrüt Müşteri Şapkası / Beresi (Emerald Green Beanie)
    final hatPaint = Paint()
      ..color = RouteDuckTheme.emeraldGreen
      ..style = PaintingStyle.fill;
    final hatPath = Path()
      ..moveTo(36, 38)
      ..cubicTo(38, 22, 62, 20, 68, 35)
      ..cubicTo(60, 32, 44, 33, 36, 38)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Şapka Püskülü
    canvas.drawCircle(const Offset(52, 21), 4, Paint()..color = Colors.white);

    // Kollarında tuttuğu sevimli kargo paketi (Craft parcel)
    final parcelPaint = Paint()..color = const Color(0xFFE2B27A);
    final parcelRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 60, 28, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(parcelRRect, parcelPaint);

    // Paket Şeridi (Zümrüt Yeşili koli bandı)
    final tapePaint = Paint()
      ..color = RouteDuckTheme.emeraldGreen
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(46, 60, 4, 22), tapePaint);
    canvas.drawRect(const Rect.fromLTWH(34, 69, 28, 4), tapePaint);

    // Sevimli küçük kanat
    final wingPaint = Paint()
      ..color = const Color(0xFFD98C46)
      ..style = PaintingStyle.fill;
    canvas.drawOval(const Rect.fromLTWH(26, 60, 16, 12), wingPaint);
  }

  // ==========================================
  // 2. MOTOSİKLET (ROUTEDUCK MOTO-EXPRESS)
  // ==========================================
  void _paintMotorcycle(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final rimPaint = Paint()..color = amber;
    final tirePaint = Paint()..color = darkTire;

    // Arka Plan Hafif Hız Çizgileri
    final speedLine = Paint()
      ..color = amber.withValues(alpha: isDark ? 0.3 : 0.25)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(8, 48), const Offset(20, 48), speedLine);
    canvas.drawLine(const Offset(12, 54), const Offset(22, 54), speedLine);

    // Arka Kurye Termal Çantası (Emerald Box with RouteDuck badge)
    final boxPaint = Paint()..color = RouteDuckTheme.emeraldGreen;
    final boxRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 36, 22, 22),
      const Radius.circular(5),
    );
    canvas.drawRRect(boxRRect, boxPaint);

    // Çanta Reflektör Şeridi
    final reflexPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(23, 45, 16, 4),
        const Radius.circular(2),
      ),
      reflexPaint,
    );

    // Scooter Gövdesi (Peach Amber)
    final bodyPaint = Paint()
      ..color = amber
      ..style = PaintingStyle.fill;
    final bodyPath = Path()
      ..moveTo(38, 56)
      ..lineTo(54, 56) // taban
      ..lineTo(68, 44) // ön panel eğimi
      ..lineTo(64, 40)
      ..lineTo(48, 44) // sele altı
      ..lineTo(36, 50)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Sele (Koltuk)
    final seatPaint = Paint()..color = RouteDuckTheme.duckOrange;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 45, 20, 6),
        const Radius.circular(3),
      ),
      seatPaint,
    );

    // Ön Siperlik / Cam
    final glassPaint = Paint()
      ..color = const Color(0xFF90CAF9).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final glassPath = Path()
      ..moveTo(67, 39)
      ..lineTo(73, 27)
      ..lineTo(68, 26)
      ..lineTo(63, 38)
      ..close();
    canvas.drawPath(glassPath, glassPaint);

    // Gidon & Far
    final lightPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(const Offset(70, 42), 3.5, lightPaint);

    // Ön Tekerlek
    canvas.drawCircle(const Offset(72, 68), 12, tirePaint);
    canvas.drawCircle(const Offset(72, 68), 6, rimPaint);
    canvas.drawCircle(const Offset(72, 68), 2.5, Paint()..color = Colors.white);

    // Arka Tekerlek
    canvas.drawCircle(const Offset(32, 68), 12, tirePaint);
    canvas.drawCircle(const Offset(32, 68), 6, rimPaint);
    canvas.drawCircle(const Offset(32, 68), 2.5, Paint()..color = Colors.white);
  }

  // ==========================================
  // 3. BİNEK OTOMOBİL (ROUTEDUCK CITY CAR)
  // ==========================================
  void _paintCar(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final tirePaint = Paint()..color = darkTire;
    final rimPaint = Paint()..color = amber;

    // Tavan Kurye Tabelası (RouteDuck Roof Sign)
    final signPaint = Paint()..color = RouteDuckTheme.emeraldGreen;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 28, 16, 6),
        const Radius.circular(3),
      ),
      signPaint,
    );

    // Araba Gövdesi (Peach Amber)
    final carPaint = Paint()..color = amber;
    final carPath = Path()
      ..moveTo(14, 58)
      ..lineTo(16, 50)
      ..cubicTo(20, 48, 28, 47, 34, 38) // arka cam
      ..lineTo(60, 36) // tavan
      ..cubicTo(68, 44, 72, 48, 80, 50) // ön cam & kaput
      ..lineTo(86, 52)
      ..cubicTo(88, 54, 88, 62, 84, 65) // ön tampon
      ..lineTo(14, 65) // taban
      ..close();
    canvas.drawPath(carPath, carPaint);

    // Camlar (Tinted glass with reflection)
    final glassPaint = Paint()..color = const Color(0xFF90CAF9);
    final winPath = Path()
      ..moveTo(36, 40)
      ..lineTo(48, 38)
      ..lineTo(48, 49)
      ..lineTo(32, 49)
      ..close();
    canvas.drawPath(winPath, glassPaint);

    final frontWinPath = Path()
      ..moveTo(52, 38)
      ..lineTo(62, 38)
      ..lineTo(72, 49)
      ..lineTo(52, 49)
      ..close();
    canvas.drawPath(frontWinPath, glassPaint);

    // Ön Far (Glow)
    final lightPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawOval(const Rect.fromLTWH(82, 53, 5, 6), lightPaint);

    // Kapı Çizgisi
    final linePaint = Paint()
      ..color = RouteDuckTheme.duckOrange
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(50, 49), const Offset(50, 64), linePaint);

    // Tekerlekler
    canvas.drawCircle(const Offset(28, 67), 10, tirePaint);
    canvas.drawCircle(const Offset(28, 67), 5, rimPaint);
    canvas.drawCircle(const Offset(28, 67), 2, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(70, 67), 10, tirePaint);
    canvas.drawCircle(const Offset(70, 67), 5, rimPaint);
    canvas.drawCircle(const Offset(70, 67), 2, Paint()..color = Colors.white);
  }

  // ==========================================
  // 4. MİNİVAN (ROUTEDUCK COMPACT CITY VAN)
  // ==========================================
  void _paintMinivan(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final tirePaint = Paint()..color = darkTire;
    final rimPaint = Paint()..color = amber;

    // Tavan Rayları
    final railPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(25, 29), const Offset(62, 29), railPaint);

    // Minivan Gövdesi
    final vanPaint = Paint()..color = amber;
    final vanPath = Path()
      ..moveTo(15, 64)
      ..lineTo(15, 38)
      ..cubicTo(15, 33, 20, 32, 26, 32) // arka üst köşe
      ..lineTo(60, 32) // tavan
      ..cubicTo(68, 40, 74, 46, 82, 50) // ön cam
      ..lineTo(86, 53)
      ..cubicTo(88, 56, 88, 62, 85, 65)
      ..lineTo(15, 65)
      ..close();
    canvas.drawPath(vanPath, vanPaint);

    // Ön Cam
    final glassPaint = Paint()..color = const Color(0xFF90CAF9);
    final winPath = Path()
      ..moveTo(56, 35)
      ..lineTo(64, 35)
      ..lineTo(76, 49)
      ..lineTo(56, 49)
      ..close();
    canvas.drawPath(winPath, glassPaint);

    // Arka Kargo Camı
    final rearWinPath = Path()
      ..moveTo(22, 35)
      ..lineTo(51, 35)
      ..lineTo(51, 48)
      ..lineTo(22, 48)
      ..close();
    canvas.drawPath(rearWinPath, glassPaint);

    // Emerald Yan Dalga / Şerit (RouteDuck Wave)
    final wavePaint = Paint()
      ..color = RouteDuckTheme.emeraldGreen
      ..style = PaintingStyle.fill;
    final wavePath = Path()
      ..moveTo(15, 52)
      ..lineTo(83, 52)
      ..lineTo(82, 56)
      ..lineTo(15, 56)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    // Tekerlekler
    canvas.drawCircle(const Offset(30, 67), 10.5, tirePaint);
    canvas.drawCircle(const Offset(30, 67), 5.5, rimPaint);
    canvas.drawCircle(const Offset(30, 67), 2, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(71, 67), 10.5, tirePaint);
    canvas.drawCircle(const Offset(71, 67), 5.5, rimPaint);
    canvas.drawCircle(const Offset(71, 67), 2, Paint()..color = Colors.white);
  }

  // ==========================================
  // 5. PANELVAN (HAFİF TİCARİ PANELVAN)
  // ==========================================
  void _paintPanelvan(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final tirePaint = Paint()..color = darkTire;
    final rimPaint = Paint()..color = amber;

    // Panelvan Dikdörtgen Ana Gövdesi (Sağlam ticari form)
    final vanPaint = Paint()..color = amber;
    final vanPath = Path()
      ..moveTo(14, 65)
      ..lineTo(14, 34)
      ..lineTo(64, 34) // uzun düz tavan
      ..cubicTo(70, 42, 75, 47, 82, 51) // burun
      ..lineTo(86, 54)
      ..cubicTo(88, 57, 87, 63, 84, 66)
      ..lineTo(14, 66)
      ..close();
    canvas.drawPath(vanPath, vanPaint);

    // Şoför Camı (Yalnızca önde cam vardır)
    final glassPaint = Paint()..color = const Color(0xFF90CAF9);
    final winPath = Path()
      ..moveTo(56, 37)
      ..lineTo(66, 37)
      ..lineTo(77, 49)
      ..lineTo(56, 49)
      ..close();
    canvas.drawPath(winPath, glassPaint);

    // Kargo Bölümü RouteDuck Zümrüt Logosu & Rozeti
    final badgePaint = Paint()..color = RouteDuckTheme.emeraldGreen;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 40, 24, 16),
        const Radius.circular(4),
      ),
      badgePaint,
    );
    // İç minik paket ikonu
    final iconPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(33, 44, 6, 8), iconPaint);

    // Kargo Kapı Dikişi (Dikey)
    final seamPaint = Paint()
      ..color = RouteDuckTheme.duckOrange
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(53, 35), const Offset(53, 65), seamPaint);

    // Tekerlekler
    canvas.drawCircle(const Offset(28, 68), 11, tirePaint);
    canvas.drawCircle(const Offset(28, 68), 5.5, rimPaint);
    canvas.drawCircle(const Offset(28, 68), 2, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(72, 68), 11, tirePaint);
    canvas.drawCircle(const Offset(72, 68), 5.5, rimPaint);
    canvas.drawCircle(const Offset(72, 68), 2, Paint()..color = Colors.white);
  }

  // ==========================================
  // 6. MAXİVAN (YÜKSEK TAVAN MAXI PANELVAN)
  // ==========================================
  void _paintMaxivan(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final tirePaint = Paint()..color = darkTire;
    final rimPaint = Paint()..color = amber;

    // Yüksek Tavan Başlığı (High Roof Extension)
    final roofPaint = Paint()..color = const Color(0xFFFDEEE3);
    final roofPath = Path()
      ..moveTo(13, 34)
      ..lineTo(13, 27)
      ..cubicTo(13, 24, 18, 23, 24, 23)
      ..lineTo(62, 23)
      ..cubicTo(66, 26, 68, 30, 70, 34)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Tavan Uyarı Işıkları
    final lampPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(const Offset(66, 26), 2, lampPaint);

    // Ana Gövde (Peach Amber)
    final vanPaint = Paint()..color = amber;
    final vanPath = Path()
      ..moveTo(13, 65)
      ..lineTo(13, 34)
      ..lineTo(68, 34)
      ..cubicTo(74, 43, 78, 48, 85, 52)
      ..lineTo(88, 55)
      ..cubicTo(89, 58, 88, 63, 85, 66)
      ..lineTo(13, 66)
      ..close();
    canvas.drawPath(vanPath, vanPaint);

    // Şoför Camı
    final glassPaint = Paint()..color = const Color(0xFF90CAF9);
    final winPath = Path()
      ..moveTo(58, 37)
      ..lineTo(69, 37)
      ..lineTo(80, 50)
      ..lineTo(58, 50)
      ..close();
    canvas.drawPath(winPath, glassPaint);

    // Çift Zümrüt Kargo Şeritleri
    final stripePaint = Paint()..color = RouteDuckTheme.emeraldGreen;
    canvas.drawRect(const Rect.fromLTWH(13, 44, 42, 3.5), stripePaint);
    canvas.drawRect(const Rect.fromLTWH(13, 50, 42, 2.5), stripePaint);

    // Tekerlekler
    canvas.drawCircle(const Offset(27, 69), 11, tirePaint);
    canvas.drawCircle(const Offset(27, 69), 5.5, rimPaint);
    canvas.drawCircle(const Offset(27, 69), 2, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(74, 69), 11, tirePaint);
    canvas.drawCircle(const Offset(74, 69), 5.5, rimPaint);
    canvas.drawCircle(const Offset(74, 69), 2, Paint()..color = Colors.white);
  }

  // ==========================================
  // 7. KAMYON / TIR (AĞIR TİCARİ TRUCK)
  // ==========================================
  void _paintTruck(Canvas canvas) {
    final amber = RouteDuckTheme.peachAmber;
    final darkTire = isDark ? const Color(0xFF1C130D) : const Color(0xFF2E2219);
    final tirePaint = Paint()..color = darkTire;
    final rimPaint = Paint()..color = amber;

    // Arka Konteyner / Kargo Kasası (Emerald Freight Box)
    final boxPaint = Paint()..color = RouteDuckTheme.emeraldGreen;
    final boxRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 26, 44, 38),
      const Radius.circular(5),
    );
    canvas.drawRRect(boxRRect, boxPaint);

    // Konteyner Kaburga Çizgileri
    final ribPaint = Paint()
      ..color = RouteDuckTheme.deepForest
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(24, 26), const Offset(24, 64), ribPaint);
    canvas.drawLine(const Offset(36, 26), const Offset(36, 64), ribPaint);
    canvas.drawLine(const Offset(48, 26), const Offset(48, 64), ribPaint);

    // Ön Kamyon Kabini (Cab-Over Design in Peach Amber)
    final cabPaint = Paint()..color = amber;
    final cabPath = Path()
      ..moveTo(58, 64)
      ..lineTo(58, 30)
      ..lineTo(84, 30)
      ..cubicTo(87, 30, 88, 32, 88, 35)
      ..lineTo(88, 60)
      ..lineTo(85, 64)
      ..close();
    canvas.drawPath(cabPath, cabPaint);

    // Güneş Siperliği (Sun Visor)
    final visorPaint = Paint()..color = const Color(0xFF2E190E);
    canvas.drawRect(const Rect.fromLTWH(62, 28, 26, 3.5), visorPaint);

    // Panoramik Kamyon Camı
    final glassPaint = Paint()..color = const Color(0xFF90CAF9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(64, 34, 22, 13),
        const Radius.circular(2),
      ),
      glassPaint,
    );

    // Ön Izgara & Farlar
    final grillPaint = Paint()..color = RouteDuckTheme.duckOrange;
    canvas.drawRect(const Rect.fromLTWH(74, 52, 13, 6), grillPaint);
    final lightPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(const Offset(84, 59), 3, lightPaint);

    // Tekerlekler (Ağır Vasıta Çoklu Tekerlek)
    canvas.drawCircle(const Offset(22, 69), 10.5, tirePaint);
    canvas.drawCircle(const Offset(22, 69), 5, rimPaint);

    canvas.drawCircle(const Offset(42, 69), 10.5, tirePaint);
    canvas.drawCircle(const Offset(42, 69), 5, rimPaint);

    canvas.drawCircle(const Offset(75, 69), 10.5, tirePaint);
    canvas.drawCircle(const Offset(75, 69), 5, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _ThemeAvatarPainter oldDelegate) {
    return oldDelegate.isCustomer != isCustomer ||
        oldDelegate.vehicleType != vehicleType ||
        oldDelegate.isDark != isDark;
  }
}
