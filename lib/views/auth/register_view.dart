import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../courier/courier_pool_view.dart';
import '../customer/customer_home_view.dart';

class VehicleCardData {
  final String key;
  final String title;
  final String subtitle;
  final String capacityInfo;
  final String imagePath;
  final IconData icon;

  const VehicleCardData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.capacityInfo,
    required this.imagePath,
    required this.icon,
  });
}

/// Kayıt Ol Ekranı (Register View)
class RegisterView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const RegisterView({super.key, this.onToggleTheme});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  final AuthService _authService = AuthService();

  String _selectedRole = AppConstants.roleCustomer;
  String _selectedVehicle = AppConstants.vehicleMotorcycle;
  bool _hasThermalBag = false;
  bool _isLoading = false;

  static const List<VehicleCardData> vehicleList = [
    VehicleCardData(
      key: AppConstants.vehicleMotorcycle,
      title: 'Motosiklet / Maxi Scooter',
      subtitle: 'Siperlikli, arka çantalı kurye motoru',
      capacityInfo: '0 - 15 Kg (Zarf, Küçük Paket, Orta Koli)',
      imagePath: 'assets/images/vehicles/motorcycle.png',
      icon: Icons.two_wheeler_rounded,
    ),
    VehicleCardData(
      key: AppConstants.vehicleCar,
      title: 'Binek Otomobil (Sedan)',
      subtitle: 'Sedan binek otomobil ile hassas dağıtım',
      capacityInfo: '0 - 60 Kg (Tüm paketler, çoklu koli, elbise)',
      imagePath: 'assets/images/vehicles/car.png',
      icon: Icons.directions_car_rounded,
    ),
    VehicleCardData(
      key: AppConstants.vehicleMinivan,
      title: 'Kompakt Minivan (City Van)',
      subtitle: 'Kompakt panelvan (Berlingo / Partner / Nemo)',
      capacityInfo: '0 - 200 Kg (Koli & orta hacimli ticari sevkiyat)',
      imagePath: 'assets/images/vehicles/minivan.png',
      icon: Icons.airport_shuttle_rounded,
    ),
    VehicleCardData(
      key: AppConstants.vehiclePanelvan,
      title: 'Standart Hafif Ticari Panelvan',
      subtitle: 'Kısa/orta şasi kapalı kasa panelvan',
      capacityInfo: '0 - 450 Kg (Büyük koliler ve toptan sevkiyat)',
      imagePath: 'assets/images/vehicles/panelvan.png',
      icon: Icons.local_shipping_rounded,
    ),
    VehicleCardData(
      key: AppConstants.vehicleMaxivan,
      title: 'Yüksek Tavan Maxi Panelvan',
      subtitle: 'Uzun şasi yüksek tavan (Sprinter / Ducato)',
      capacityInfo: '0 - 600 Kg (Ağır yük, büyük hacimli mikro lojistik)',
      imagePath: 'assets/images/vehicles/maxivan.png',
      icon: Icons.rv_hookup_rounded,
    ),
    VehicleCardData(
      key: AppConstants.vehicleTruck,
      title: 'Ağır Ticari / Kamyon (Tır)',
      subtitle: 'Ağır tonajlı sanayi ve tır dorsesi taşımacılığı',
      capacityInfo: '+600 Kg ve üstü (Paletli yük, fabrika nakliyesi)',
      imagePath: 'assets/images/vehicles/truck.png',
      icon: Icons.fire_truck_rounded,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final plate = _plateController.text.trim();

    if (name.isEmpty || phone.isEmpty || pass.isEmpty) {
      ErrorHandler.showWarning(context, 'Lütfen ad, telefon ve şifre alanlarını eksiksiz doldurun.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        fullName: name,
        phone: phone,
        password: pass,
        role: _selectedRole,
        vehicleType: _selectedRole == AppConstants.roleCourier ? _selectedVehicle : null,
        plateNumber: plate.isNotEmpty ? plate : null,
        hasThermalBag: _hasThermalBag,
      );

      if (!mounted) return;

      if (user.role == AppConstants.roleCourier) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => CourierPoolView(onToggleTheme: widget.onToggleTheme)),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => CustomerHomeView(onToggleTheme: widget.onToggleTheme)),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCourier = _selectedRole == AppConstants.roleCourier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hesap Oluştur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Rol Seçim Segmenti (Müşteri vs Kurye)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E140E) : const Color(0xFFEFE9E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedRole = AppConstants.roleCustomer),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isCourier
                                    ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Müşteri Olarak',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: !isCourier
                                        ? Colors.white
                                        : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedRole = AppConstants.roleCourier),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isCourier
                                    ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Kurye Olarak',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isCourier
                                        ? (isDark ? const Color(0xFF120A05) : Colors.white)
                                        : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Temel Bilgiler
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      hintText: 'Örn: Ahmet Yılmaz',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                      hintText: '5551234567',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      hintText: '••••',
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kurye Ek Bilgileri
                  if (isCourier) ...[
                    Row(
                      children: [
                        const Icon(Icons.commute_outlined, color: RouteDuckTheme.peachAmber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Kurye Araç Kategorisi Seçimi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 6 Kademe Araç Seçim Kartları (Görsellerle Birlikte)
                    ...vehicleList.map((veh) {
                      final isSelected = _selectedVehicle == veh.key;
                      return InkWell(
                        onTap: () => setState(() => _selectedVehicle = veh.key),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF182C1C) : const Color(0xFFEDF6F0))
                                : (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                  : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                              width: isSelected ? 2.0 : 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 56,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0))
                                      : (isDark ? const Color(0xFF1A110B) : const Color(0xFFF3EBE2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  veh.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    veh.icon,
                                    color: isSelected
                                        ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                        : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      veh.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      veh.subtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Kapasite: ${veh.capacityInfo}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),

                    // Plaka
                    TextField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        labelText: 'Araç Plakası (Opsiyonel)',
                        hintText: '34 XYZ 123',
                        prefixIcon: Icon(Icons.pin_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Termal Çanta Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.ac_unit, color: Colors.orange, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Termal Çantam Var',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Sıcak/soğuk gıda ve pasta siparişlerini alabilirim',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _hasThermalBag,
                            activeThumbColor: RouteDuckTheme.emeraldGreen,
                            onChanged: (val) => setState(() => _hasThermalBag = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Kayıt Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCourier
                          ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))
                          : (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest),
                      foregroundColor: isCourier && isDark ? const Color(0xFF120A05) : Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isCourier ? 'Kurye Hesabımı Başlat' : 'Müşteri Olarak Kaydol'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
