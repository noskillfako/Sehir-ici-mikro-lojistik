import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_database_service.dart';
import '../../services/session_service.dart';
import '../courier/courier_pool_view.dart';
import '../customer/customer_home_view.dart';
import 'register_view.dart';

/// Giriş Ekranı (Login View)
class LoginView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const LoginView({super.key, this.onToggleTheme});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final HiveDatabaseService _dbService = HiveDatabaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _routeByUser(UserModel user) {
    if (!mounted) return;
    if (user.role == AppConstants.roleCourier) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CourierPoolView(onToggleTheme: widget.onToggleTheme)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CustomerHomeView(onToggleTheme: widget.onToggleTheme)),
      );
    }
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      ErrorHandler.showWarning(context, 'Lütfen telefon numaranızı ve şifrenizi girin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(phone, pass);
      _routeByUser(user);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickLogin(UserModel user) async {
    setState(() => _isLoading = true);
    try {
      await _sessionService.saveSession(
        userId: user.id,
        role: user.role,
        vehicleType: user.vehicleType,
      );
      _routeByUser(user);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Veritabanını Sıfırla'),
        content: const Text('Tüm sipariş ve kullanıcı kayıtları silinip varsayılan test hesapları baştan yüklenecektir. Devam edilsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.fullResetAndSeed();
      if (!mounted) return;
      ErrorHandler.showSuccess(context, 'Veritabanı başarıyla sıfırlandı.');
      setState(() {});
    }
  }

  Widget _buildUserAvatar(UserModel user, bool isDark) {
    if (user.isCustomer) {
      return const Icon(
        Icons.person_rounded,
        color: RouteDuckTheme.emeraldGreen,
        size: 22,
      );
    }

    final imgPath = AppConstants.vehicleImages[user.vehicleType];
    if (imgPath != null) {
      return Image.asset(
        imgPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          _getFallbackVehicleIcon(user.vehicleType),
          color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
          size: 20,
        ),
      );
    }

    return Icon(
      _getFallbackVehicleIcon(user.vehicleType),
      color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
      size: 20,
    );
  }

  IconData _getFallbackVehicleIcon(String? vehicleType) {
    switch (vehicleType) {
      case AppConstants.vehicleMotorcycle:
        return Icons.two_wheeler_rounded;
      case AppConstants.vehicleCar:
        return Icons.directions_car_rounded;
      case AppConstants.vehicleMinivan:
        return Icons.airport_shuttle_rounded;
      case AppConstants.vehiclePanelvan:
      case AppConstants.vehicleMaxivan:
        return Icons.local_shipping_rounded;
      case AppConstants.vehicleTruck:
        return Icons.rv_hookup_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seedUsers = _authService.getSeedUsers();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: 'Tema Değiştir',
              onPressed: widget.onToggleTheme,
            ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Veritabanını Sıfırla',
            onPressed: _resetDatabase,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              // Logo & Başlık
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F3D24) : const Color(0xFFE2F4E7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🦆', style: TextStyle(fontSize: 36)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'routeDuck',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Şehir İçi Akıllı Mikro Lojistik',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Telefon Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  hintText: '5551112233',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // Şifre Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  hintText: '••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Giriş Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Giriş Yap'),
              ),
              const SizedBox(height: 14),

              // Kayıt Ol Butonu
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegisterView(onToggleTheme: widget.onToggleTheme),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                ),
                child: const Text('Yeni Hesap Oluştur (Kayıt Ol)'),
              ),
              const SizedBox(height: 32),

              // Hızlı Test Girişi Bölümü (Seed Users)
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'HIZLI TEST GİRİŞİ (TEK TIKLA)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder)),
                ],
              ),
              const SizedBox(height: 16),

              // Hazır kullanıcı kartları
              ...seedUsers.map((user) {
                final isCust = user.isCustomer;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _quickLogin(user),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E140E) : const Color(0xFFFDFAF7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isCust
                                  ? (isDark ? const Color(0xFF1A3320) : const Color(0xFFE2F4E7))
                                  : (isDark ? const Color(0xFF382315) : const Color(0xFFFDEEE3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _buildUserAvatar(user, isDark),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isCust
                                      ? 'Müşteri Profili'
                                      : 'Kurye (${user.vehicleType} • ${user.hasThermalBag ? "Termal Var" : "Standart"})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
