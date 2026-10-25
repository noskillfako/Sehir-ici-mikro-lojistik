import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/predefined_locations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_tracking_service.dart';
import '../../services/session_service.dart';
import '../../widgets/order_card_widget.dart';
import '../../widgets/theme_avatar_illustration.dart';
import '../auth/login_view.dart';
import '../courier/courier_pool_view.dart';
import 'customer_home_view.dart';
import 'customer_order_detail_view.dart';

/// Müşteri Profil ve Geçmiş Siparişler Ekranı
class CustomerProfileView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const CustomerProfileView({super.key, this.onToggleTheme});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final OrderTrackingService _trackingService = OrderTrackingService();

  UserModel? _currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
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

  Future<void> _switchAccount(UserModel targetUser) async {
    final currentUserId = _currentUser?.id ?? _sessionService.getCurrentUserId();
    if (targetUser.id == currentUserId) return;
    await _sessionService.saveSession(
      userId: targetUser.id,
      role: targetUser.role,
      vehicleType: targetUser.vehicleType,
    );
    if (!mounted) return;
    if (targetUser.role == AppConstants.roleCourier) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customerId = _currentUser?.id ?? _sessionService.getCurrentUserId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Profili'),
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
            final activeOrders = _trackingService.getCustomerActiveOrders(customerId);
            final pastOrders = _trackingService.getCustomerPastOrders(customerId);
            final totalOrders = activeOrders.length + pastOrders.length;
            final completedOrders = pastOrders.where((o) => o.status == AppConstants.statusDelivered).toList();
            final totalSpent = completedOrders.fold<double>(0.0, (sum, o) => sum + o.price);

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
                        // 1. Profil Bilgi Kartı
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
                                  ThemeAvatarIllustration.customer(
                                    size: 64,
                                    borderRadius: BorderRadius.circular(32),
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
                                                _currentUser?.fullName ?? 'Müşteri',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'MÜŞTERİ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: RouteDuckTheme.emeraldGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_rounded, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              _currentUser?.phone ?? 'Telefon belirtilmemiş',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.verified_user_outlined, size: 14, color: RouteDuckTheme.emeraldGreen),
                                            const SizedBox(width: 4),
                                            Text(
                                              'ID: ${_currentUser?.id ?? customerId}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                              ),
                                            ),
                                          ],
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

                        // 2. İstatistik Rozetleri
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Toplam Sipariş',
                                value: '$totalOrders',
                                icon: Icons.local_shipping_outlined,
                                isDark: isDark,
                                color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Tamamlanan',
                                value: '${completedOrders.length}',
                                icon: Icons.check_circle_outline_rounded,
                                isDark: isDark,
                                color: RouteDuckTheme.emeraldGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Toplam Harcama',
                                value: '${totalSpent.toStringAsFixed(0)} TL',
                                icon: Icons.wallet_rounded,
                                isDark: isDark,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 3. Tab Seçici
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: RouteDuckTheme.emeraldGreen,
                            labelColor: isDark ? Colors.white : RouteDuckTheme.deepForest,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(
                                icon: const Icon(Icons.history_rounded, size: 18),
                                text: 'Geçmiş Siparişler (${pastOrders.length})',
                              ),
                              const Tab(
                                icon: Icon(Icons.location_on_outlined, size: 18),
                                text: 'Kayıtlı Adresler',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Tab İçeriği
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            if (_tabController.index == 0) {
                              // Geçmiş Siparişler Listesi
                              if (pastOrders.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Henüz tamamlanmış bir gönderiniz yok.',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tamamlanan ve teslim edilen kargolarınız burada arşivlenir.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: pastOrders.map((order) {
                                  return OrderCardWidget(
                                    order: order,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CustomerOrderDetailView(orderId: order.id),
                                        ),
                                      );
                                    },
                                    trailingAction: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                  );
                                }).toList(),
                              );
                            } else {
                              // Kayıtlı Adresler
                              return Column(
                                children: PredefinedLocations.list.map((loc) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: RouteDuckTheme.emeraldGreen,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.name,
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                loc.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // 5. Hızlı Hesap Değiştir (Test Profilleri)
                        _buildAccountSwitcher(isDark, customerId),
                        const SizedBox(height: 20),

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
                          label: const Text('Hesaptan Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700)),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSwitcher(bool isDark, String currentId) {
    final seedUsers = _authService.getSeedUsers();
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.switch_account_rounded,
                size: 18,
                color: RouteDuckTheme.emeraldGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hesap Değiştir (Test Profilleri)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...seedUsers.map((u) {
            final isCurrent = u.id == currentId;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: isCurrent ? null : () => _switchAccount(u),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (isDark ? const Color(0xFF16251B) : const Color(0xFFE2F4E7))
                        : (isDark ? const Color(0xFF160E09) : const Color(0xFFF8F4EE)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? RouteDuckTheme.emeraldGreen
                          : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ThemeAvatarIllustration.fromUser(
                        u,
                        size: 38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.fullName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              u.isCustomer
                                  ? 'Müşteri Profili'
                                  : 'Kurye (${u.vehicleType ?? "Araç"})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: RouteDuckTheme.emeraldGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        )
                      else
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
