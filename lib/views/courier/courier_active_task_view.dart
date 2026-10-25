import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/map_service.dart';
import '../../services/order_status_service.dart';
import '../../services/order_tracking_service.dart';
import '../../widgets/otp_verification_dialog.dart';

/// Kurye Aktif Görev Ekranı (Courier Active Task View)
class CourierActiveTaskView extends StatefulWidget {
  final String orderId;

  const CourierActiveTaskView({super.key, required this.orderId});

  @override
  State<CourierActiveTaskView> createState() => _CourierActiveTaskViewState();
}

class _CourierActiveTaskViewState extends State<CourierActiveTaskView> {
  final OrderTrackingService _trackingService = OrderTrackingService();
  final OrderStatusService _statusService = OrderStatusService();
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();

  bool _isLoading = false;

  Future<void> _pickupPackage(OrderModel order) async {
    setState(() => _isLoading = true);
    try {
      await _statusService.markAsPickedUp(order.id);
      if (!mounted) return;
      ErrorHandler.showSuccess(context, 'Paket teslim alındı! Şimdi alıcıya doğru yola çıkın.');
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openOtpDialog(OrderModel order) {
    OtpVerificationDialog.show(
      context: context,
      order: order,
      onDeliverySuccess: () {
        if (!mounted) return;
        Navigator.of(context).pop();
      },
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
            appBar: AppBar(title: const Text('Aktif Görev')),
            body: const Center(child: Text('Görev bulunamadı.')),
          );
        }

        final isAssigned = order.status == AppConstants.statusAssigned;
        final isInTransit = order.status == AppConstants.statusInTransit;
        final isDelivered = order.status == AppConstants.statusDelivered;

        final estimatedMin = _mapService.calculateEstimatedMinutes(
          order.distanceKm,
          order.courierVehicle ?? AppConstants.vehicleMotorcycle,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Aktif Görev: ${order.id}'),
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
                // Durum ve Tahmini Süre Kartı
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF6F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAssigned ? Icons.directions_bike_rounded : Icons.local_shipping_rounded,
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
                              isAssigned ? 'Aşama 1: Paketi Teslim Alma' : 'Aşama 2: Alıcıya Teslimat',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAssigned
                                  ? 'Müşterinin adresine gidip paketi teslim alın.'
                                  : 'Paketi alıcıya götürüp 4 haneli teslimat kodunu alın.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Tahmini Süre', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            '~$estimatedMin dk',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: RouteDuckTheme.emeraldGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Canlı Rota Haritası (OpenStreetMap)
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: isAssigned ? order.pickupLatLng : order.dropoffLatLng,
                      initialZoom: 12.0,
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
                            strokeWidth: 4.5,
                            color: RouteDuckTheme.emeraldGreen,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: order.pickupLatLng,
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.location_on, color: Colors.green, size: 36),
                          ),
                          Marker(
                            point: order.dropoffLatLng,
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sıradaki Hedef Adres Kutusu
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
                      Row(
                        children: [
                          Icon(
                            isAssigned ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
                            color: isAssigned ? RouteDuckTheme.emeraldGreen : Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAssigned ? 'Gideceğiniz Alış Adresi:' : 'Gideceğiniz Teslimat Adresi:',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAssigned ? order.pickupTitle : order.dropoffTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAssigned ? order.pickupAddressDetail : order.dropoffAddressDetail,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                        ),
                      ),
                      const Divider(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Müşteri:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(order.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Net Kazancınız:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(
                                '${order.courierEarnings.toStringAsFixed(2)} TL',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: RouteDuckTheme.emeraldGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paket İçerik ve Özel Donanım Kutusu
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E140E) : const Color(0xFFF9F5F0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paket Bilgileri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Tür: ${order.contentType} • ${order.packageSizeDisplayTr}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Müşteri Açıklaması: "${order.customDescription}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (order.isFragile)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: const Text('⚠️ Kırılabilir Gönderi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.redAccent)),
                            ),
                          if (order.requiresThermalBag)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Text('❄️ Termal Çanta Gerekli', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.orange)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Aksiyon Butonları (Duruma Göre Dinamik)
                if (isAssigned)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickupPackage(order),
                    icon: const Icon(Icons.inventory_2_rounded),
                    label: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Paketi Müşteriden Teslim Aldım'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RouteDuckTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                    ),
                  )
                else if (isInTransit)
                  ElevatedButton.icon(
                    onPressed: () => _openOtpDialog(order),
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('Teslimatı Tamamla (4 Haneli Kod Gir)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                      foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                      minimumSize: const Size.fromHeight(54),
                    ),
                  )
                else if (isDelivered)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RouteDuckTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: const Text('Sipariş Tamamlandı • Havuza Dön'),
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
