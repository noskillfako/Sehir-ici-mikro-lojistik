import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_tracking_service.dart';
import '../../services/session_service.dart';
import '../../widgets/order_card_widget.dart';
import '../../widgets/route_duck_logo.dart';
import '../auth/login_view.dart';
import 'create_order_view.dart';
import 'customer_order_detail_view.dart';
import 'customer_profile_view.dart';

/// Müşteri Ana Sayfası (Customer Home View)
class CustomerHomeView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const CustomerHomeView({super.key, this.onToggleTheme});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final OrderTrackingService _trackingService = OrderTrackingService();

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _currentUser = _authService.getCurrentUser();
    });
  }



  Future<void> _logout() async {
    await _sessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginView(onToggleTheme: widget.onToggleTheme)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customerId = _currentUser?.id ?? _sessionService.getCurrentUserId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3623) : const Color(0xFFE2F4E7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🦆', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            const RouteDuckLogo(
              fontSize: 17,
              suffix: ' Müşteri',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profilim',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerProfileView(onToggleTheme: widget.onToggleTheme),
                ),
              );
            },
          ),
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: 'Tema Değiştir',
              onPressed: widget.onToggleTheme,
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
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

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hoşgeldin & Profil Kartı (Tıklanabilir)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CustomerProfileView(onToggleTheme: widget.onToggleTheme),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFE2F3E7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: RouteDuckTheme.emeraldGreen,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hoş geldin, ${_currentUser?.fullName ?? "Değerli Müşterimiz"}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Şehir içi hızlı kurye ve mikro lojistik',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Profilim',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: RouteDuckTheme.emeraldGreen,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: RouteDuckTheme.emeraldGreen),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                // Sipariş Oluştur CTA Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateOrderView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  label: const Text('Yeni Gönderi Oluştur / Kurye Çağır'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                    foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                    minimumSize: const Size.fromHeight(54),
                  ),
                ),
                const SizedBox(height: 24),

                // Aktif Siparişler Başlığı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktif Gönderilerim',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: activeOrders.isNotEmpty
                            ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${activeOrders.length} Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: activeOrders.isNotEmpty ? RouteDuckTheme.emeraldGreen : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Aktif Sipariş Listesi
                if (activeOrders.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF160F0A) : const Color(0xFFF9F5F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 42,
                          color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Şu anda devam eden aktif bir gönderiniz yok.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yukarıdaki butona dokunarak hemen yeni bir kurye çağırabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...activeOrders.map((order) {
                    final hasCourier = order.status == AppConstants.statusAssigned ||
                                       order.status == AppConstants.statusInTransit;

                    return Column(
                      children: [
                        OrderCardWidget(
                          order: order,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CustomerOrderDetailView(orderId: order.id),
                              ),
                            );
                          },
                          trailingAction: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ),
                        // Eğer kurye atandıysa veya yoldaysa, hemen kartın altında 4 Haneli OTP Kutusunu göster!
                        if (hasCourier)
                          Container(
                            margin: const EdgeInsets.only(bottom: 14, top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF6F0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: RouteDuckTheme.emeraldGreen, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kuryeye Söyleyeceğiniz Teslimat Kodu:',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.deliveryOtpCode,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 4.0,
                                          color: RouteDuckTheme.emeraldGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Güvenlik',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: RouteDuckTheme.emeraldGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),

                const SizedBox(height: 24),

                // Geçmiş Siparişler Başlığı
                if (pastOrders.isNotEmpty) ...[
                  const Text(
                    'Geçmiş Gönderilerim',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...pastOrders.map((order) {
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
                  }),
                ],
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
}
