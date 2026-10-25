import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_tracking_service.dart';
import '../../services/session_service.dart';
import '../../widgets/order_card_widget.dart';
import '../auth/login_view.dart';
import 'courier_active_task_view.dart';

/// Kurye Profil, Araç ve Görev Geçmişi Ekranı
class CourierProfileView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const CourierProfileView({super.key, this.onToggleTheme});

  @override
  State<CourierProfileView> createState() => _CourierProfileViewState();
}

class _CourierProfileViewState extends State<CourierProfileView> {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final OrderTrackingService _trackingService = OrderTrackingService();

  UserModel? _currentCourier;

  @override
  void initState() {
    super.initState();
    _currentCourier = _authService.getCurrentUser();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Kurye hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sessionService.clearSession();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginView(onToggleTheme: widget.onToggleTheme)),
        (route) => false,
      );
    }
  }

  String _getVehicleTitle(String? vType) {
    switch (vType) {
      case AppConstants.vehicleMotorcycle:
        return 'Motosiklet / Maxi Scooter';
      case AppConstants.vehicleCar:
        return 'Binek Otomobil (Sedan)';
      case AppConstants.vehicleMinivan:
        return 'Kompakt Minivan (City Van)';
      case AppConstants.vehiclePanelvan:
        return 'Standart Hafif Ticari Panelvan';
      case AppConstants.vehicleMaxivan:
        return 'Yüksek Tavan Maxi Panelvan';
      case AppConstants.vehicleTruck:
        return 'Ağır Ticari Kamyon / Tır';
      default:
        return 'Kurye Aracı';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courier = _currentCourier;

    if (courier == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kurye Profili')),
        body: const Center(child: Text('Kurye bilgisi bulunamadı.')),
      );
    }

    final vehicleImage = AppConstants.vehicleImages[courier.vehicleType];
    final vehicleCapacity = AppConstants.vehicleMaxCapacityKg[courier.vehicleType] ?? 15.0;
    final allowedSizes = AppConstants.vehicleAllowedSizes[courier.vehicleType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurye Profili'),
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: 'Tema Değiştir',
              onPressed: widget.onToggleTheme,
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Çıkış Yap',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _trackingService.listenToOrdersBox(),
          builder: (context, box, child) {
            final completedOrders = _trackingService.getCourierCompletedOrders(courier.id);
            final activeTask = _trackingService.getCourierCurrentTask(courier.id);
            final totalEarnings = completedOrders.fold<double>(
              0.0,
              (sum, item) => sum + item.courierEarnings,
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Profil ve Araç Kartı
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF382315) : const Color(0xFFFDEEE3),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: vehicleImage != null
                                        ? Image.asset(
                                            vehicleImage,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.delivery_dining_rounded,
                                              size: 36,
                                              color: RouteDuckTheme.peachAmber,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delivery_dining_rounded,
                                            size: 36,
                                            color: RouteDuckTheme.peachAmber,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                courier.fullName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'KURYE',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getVehicleTitle(courier.vehicleType),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_rounded, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              courier.phone,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            const Text(
                                              '4.9',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.scale_rounded, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Maks. Kapasite: ${vehicleCapacity.toStringAsFixed(0)} Kg',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: courier.hasThermalBag
                                          ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.15)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          courier.hasThermalBag ? Icons.ac_unit_rounded : Icons.block_rounded,
                                          size: 13,
                                          color: courier.hasThermalBag ? RouteDuckTheme.emeraldGreen : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          courier.hasThermalBag ? 'Termal Çanta Var' : 'Termal Yok',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: courier.hasThermalBag ? RouteDuckTheme.emeraldGreen : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. Performans İstatistikleri
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Toplam Kazanç (%85)',
                                value: '${totalEarnings.toStringAsFixed(2)} TL',
                                icon: Icons.payments_rounded,
                                isDark: isDark,
                                color: RouteDuckTheme.emeraldGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Tamamlanan Teslimat',
                                value: '${completedOrders.length}',
                                icon: Icons.check_circle_rounded,
                                isDark: isDark,
                                color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Aktif Görev',
                                value: activeTask != null ? '1 Aktif' : 'Boşta',
                                icon: Icons.navigation_rounded,
                                isDark: isDark,
                                color: activeTask != null ? Colors.cyanAccent : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 3. Taşıyabildiği Paket Boyutları Rozetleri
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Yetkili Olduğunuz Kargo Boyutları',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: allowedSizes.map((sz) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      sz,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: RouteDuckTheme.emeraldGreen,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. Tamamlanan Teslimatlar (Görev Geçmişi)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Teslimat Geçmişi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${completedOrders.length} Teslimat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (completedOrders.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.assignment_turned_in_outlined, size: 44, color: Colors.grey.withValues(alpha: 0.5)),
                                const SizedBox(height: 10),
                                const Text(
                                  'Henüz tamamlanmış teslimatınız bulunmuyor.',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sipariş havuzundan aldığınız ve OTP ile teslim ettiğiniz görevler burada listelenir.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        else
                          ...completedOrders.map((order) {
                            return OrderCardWidget(
                              order: order,
                              isCourierView: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CourierActiveTaskView(orderId: order.id),
                                  ),
                                );
                              },
                              trailingAction: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            );
                          }),
                        const SizedBox(height: 24),

                        // Çıkış Yap Butonu
                        OutlinedButton.icon(
                          onPressed: _logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text('Kurye Hesabından Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
