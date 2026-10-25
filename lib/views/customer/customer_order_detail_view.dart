import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_status_service.dart';
import '../../services/order_tracking_service.dart';

/// Müşteri Sipariş Detay ve Canlı İzleme Ekranı (Order Detail View)
class CustomerOrderDetailView extends StatefulWidget {
  final String orderId;

  const CustomerOrderDetailView({super.key, required this.orderId});

  @override
  State<CustomerOrderDetailView> createState() => _CustomerOrderDetailViewState();
}

class _CustomerOrderDetailViewState extends State<CustomerOrderDetailView> {
  final OrderTrackingService _trackingService = OrderTrackingService();
  final OrderStatusService _statusService = OrderStatusService();
  final MapController _mapController = MapController();

  Future<void> _cancelOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: const Text('Bu kargo talebinizi iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _statusService.cancelOrder(order.id);
        if (!mounted) return;
        ErrorHandler.showSuccess(context, 'Siparişiniz iptal edildi.');
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.handle(context, e);
      }
    }
  }

  Widget _buildStepItem({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required IconData icon,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDone
        ? RouteDuckTheme.emeraldGreen
        : (isActive ? RouteDuckTheme.peachAmber : (isDark ? Colors.grey.shade700 : Colors.grey.shade400));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                size: 18,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? RouteDuckTheme.emeraldGreen : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive || isDone ? FontWeight.w800 : FontWeight.w600,
                  color: isActive || isDone
                      ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                      : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: _trackingService.listenToOrdersBox(),
      builder: (context, box, child) {
        final order = _trackingService.getOrderById(widget.orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sipariş Detayı')),
            body: const Center(child: Text('Sipariş bulunamadı.')),
          );
        }

        final isWaiting = order.status == AppConstants.statusWaiting;
        final isAssigned = order.status == AppConstants.statusAssigned;
        final isInTransit = order.status == AppConstants.statusInTransit;
        final isDelivered = order.status == AppConstants.statusDelivered;
        final isCancelled = order.status == AppConstants.statusCancelled;

        return Scaffold(
          appBar: AppBar(
            title: Text('${order.id} Detayı'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                // 1. Canlı Durum Stepper Kutusu
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gönderi Durum Akışı',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDelivered
                                  ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.15)
                                  : (isCancelled
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : RouteDuckTheme.peachAmber.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.statusDisplayTr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDelivered
                                    ? RouteDuckTheme.emeraldGreen
                                    : (isCancelled ? Colors.redAccent : (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildStepItem(
                        title: '1. Kurye Aranıyor',
                        subtitle: isWaiting ? 'Sipariş havuzda bekliyor, kuryeler inceliyor...' : 'Sipariş sisteme iletildi.',
                        isDone: isAssigned || isInTransit || isDelivered,
                        isActive: isWaiting,
                        icon: Icons.search_rounded,
                      ),
                      _buildStepItem(
                        title: '2. Kurye Yola Çıktı',
                        subtitle: order.courierName != null
                            ? '${order.courierName} (${order.courierVehicle ?? "Kurye"}) paketi teslim almaya geliyor'
                            : 'Kurye ataması bekleniyor',
                        isDone: isInTransit || isDelivered,
                        isActive: isAssigned,
                        icon: Icons.two_wheeler_rounded,
                      ),
                      _buildStepItem(
                        title: '3. Paket Dağıtımda',
                        subtitle: isInTransit
                            ? 'Paket müşteriden alındı, teslimat adresine doğru taşınıyor'
                            : 'Paket henüz kuryeye verilmedi',
                        isDone: isDelivered,
                        isActive: isInTransit,
                        icon: Icons.inventory_2_rounded,
                      ),
                      _buildStepItem(
                        title: '4. Güvenli Teslimat',
                        subtitle: isDelivered
                            ? 'Sipariş OTP doğrulamasıyla başarıyla alıcıya teslim edildi.'
                            : 'Teslimat anında kuryeye güvenlik kodunuzu söyleyin',
                        isDone: isDelivered,
                        isActive: isDelivered,
                        icon: Icons.check_circle_rounded,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. 4 Haneli Teslimat Kodu Kasası (Büyük Puntolarla Gösterim)
                if (isWaiting || isAssigned || isInTransit)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF6F0),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_clock_outlined, color: RouteDuckTheme.emeraldGreen, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Kuryeye Söyleyeceğiniz Teslimat Kodu:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            order.deliveryOtpCode,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 10.0,
                              color: RouteDuckTheme.emeraldGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kurye paketi teslim ederken bu 4 haneli kodu doğrulamadan görevi kapatamaz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // 3. Harita Önizleme
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: order.pickupLatLng,
                      initialZoom: 11.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.osmTileUrl,
                        userAgentPackageName: AppConstants.userAgentPackage,
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [order.pickupLatLng, order.dropoffLatLng],
                            strokeWidth: 4.0,
                            color: RouteDuckTheme.emeraldGreen,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: order.pickupLatLng,
                            width: 32,
                            height: 32,
                            child: const Icon(Icons.location_on, color: Colors.green, size: 32),
                          ),
                          Marker(
                            point: order.dropoffLatLng,
                            width: 32,
                            height: 32,
                            child: const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Adres & Paket Özeti
                Container(
                  padding: const EdgeInsets.all(18),
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
                      const Text('Adres ve Rota Bilgileri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text('Alış Noktası: ${order.pickupTitle}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(order.pickupAddressDetail, style: TextStyle(fontSize: 12, color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary)),
                      const SizedBox(height: 10),
                      Text('Teslimat Noktası: ${order.dropoffTitle}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(order.dropoffAddressDetail, style: TextStyle(fontSize: 12, color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary)),
                      const Divider(height: 20),
                      const Text('Paket Detayları', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Kategori: ${order.contentType} • ${order.packageSizeDisplayTr}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      if (order.preferredVehicle != null) ...[
                        const SizedBox(height: 4),
                        Text('Tercih Edilen Araç: ${order.preferredVehicleDisplayTr}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))),
                      ],
                      const SizedBox(height: 4),
                      Text('Müşteri Açıklaması: "${order.customDescription}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toplam Tutar:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          Text(
                            '${order.price.toStringAsFixed(2)} TL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. İptal Butonu (Yalnızca WAITING_FOR_COURIER durumunda izinli)
                if (isWaiting)
                  OutlinedButton.icon(
                    onPressed: () => _cancelOrder(order),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                    label: const Text('Siparişi İptal Et', style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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
},
    );
  }
}
