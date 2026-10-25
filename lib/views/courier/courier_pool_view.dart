import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/courier_matching_service.dart';
import '../../services/order_tracking_service.dart';
import '../../services/session_service.dart';
import '../../widgets/order_card_widget.dart';
import '../auth/login_view.dart';
import 'courier_active_task_view.dart';
import 'courier_profile_view.dart';

/// Kurye Sipariş Havuzu Ekranı (Courier Pool View)
class CourierPoolView extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const CourierPoolView({super.key, this.onToggleTheme});

  @override
  State<CourierPoolView> createState() => _CourierPoolViewState();
}

class _CourierPoolViewState extends State<CourierPoolView> {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final CourierMatchingService _matchingService = CourierMatchingService();
  final OrderTrackingService _trackingService = OrderTrackingService();

  UserModel? _currentCourier;
  String _sortBy = 'NEWEST'; // 'NEWEST', 'PRICE', 'DISTANCE'

  @override
  void initState() {
    super.initState();
    _loadCourier();
  }

  void _loadCourier() {
    setState(() {
      _currentCourier = _authService.getCurrentUser();
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

  Future<void> _acceptOrder(OrderModel order) async {
    if (_currentCourier == null) return;

    try {
      await _matchingService.matchCourierWithOrder(
        orderId: order.id,
        courier: _currentCourier!,
      );

      if (!mounted) return;
      ErrorHandler.showSuccess(context, '${order.id} siparişi üzerinize alındı! Görev başladı.');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CourierActiveTaskView(orderId: order.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentCourier == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final courier = _currentCourier!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF382315) : const Color(0xFFFDEEE3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🛵', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            const Text('routeDuck Kurye Havuzu'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Kurye Profilim',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CourierProfileView(onToggleTheme: widget.onToggleTheme),
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
            final activeTask = _trackingService.getCourierCurrentTask(courier.id);
            final poolOrders = _matchingService.getFilteredOrderPool(
              courier: courier,
              sortBy: _sortBy,
            );
            final completedOrders = _trackingService.getCourierCompletedOrders(courier.id);
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kurye Bilgi Kartı (Tıklanabilir -> Kurye Profili)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CourierProfileView(onToggleTheme: widget.onToggleTheme),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF382315) : const Color(0xFFFDEEE3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AppConstants.vehicleImages[courier.vehicleType] != null
                            ? Image.asset(
                                AppConstants.vehicleImages[courier.vehicleType]!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.delivery_dining_rounded,
                                  color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                  size: 26,
                                ),
                              )
                            : Icon(
                                Icons.delivery_dining_rounded,
                                color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                size: 26,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courier.fullName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 6,
                              children: [
                                Text(
                                  'Araç: ${courier.vehicleType ?? "MOTORCYCLE"}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                  ),
                                ),
                                if (courier.hasThermalBag)
                                  const Text(
                                    '• Termal Çanta Var',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RouteDuckTheme.emeraldGreen),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Toplam Kazanç', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            '${totalEarnings.toStringAsFixed(2)} TL',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: RouteDuckTheme.emeraldGreen),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profilim',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: RouteDuckTheme.emeraldGreen,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios_rounded, size: 8, color: RouteDuckTheme.emeraldGreen),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

                // Aktif Görev Uyarısı / Kilidi Bannerı
                if (activeTask != null)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourierActiveTaskView(orderId: activeTask.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF6F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: RouteDuckTheme.emeraldGreen,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delivery_dining_rounded, color: RouteDuckTheme.emeraldGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aktif Göreviniz Devam Ediyor (${activeTask.id})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Durum: ${activeTask.statusDisplayTr} • Teslimat için dokunun',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RouteDuckTheme.emeraldGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Göreve Git',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Havuz Başlığı ve Sıralama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Uygun Siparişler Havuzu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF382315) : const Color(0xFFFDEEE3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${poolOrders.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sıralama Filtre Çipleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('En Yeni'),
                        selected: _sortBy == 'NEWEST',
                        onSelected: (_) => setState(() => _sortBy = 'NEWEST'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('En Yüksek Kazanç'),
                        selected: _sortBy == 'PRICE',
                        onSelected: (_) => setState(() => _sortBy = 'PRICE'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('En Kısa Mesafe'),
                        selected: _sortBy == 'DISTANCE',
                        onSelected: (_) => setState(() => _sortBy = 'DISTANCE'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Havuz Listesi
                if (poolOrders.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF160F0A) : const Color(0xFFF9F5F0),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'Şu anda aracınıza uygun bekleyen sipariş yok.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Müşteri moduna geçerek yeni bir sipariş oluşturabilir ve ardından burada test edebilirsiniz.',
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
                  ...poolOrders.map((order) {
                    final isLocked = activeTask != null;

                    return OrderCardWidget(
                      order: order,
                      isCourierView: true,
                      trailingAction: ElevatedButton(
                        onPressed: isLocked ? null : () => _acceptOrder(order),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(110, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                          foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                        ),
                        child: Text(
                          isLocked ? 'Kilitli' : 'Kabul Et',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    );
                  }),
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
