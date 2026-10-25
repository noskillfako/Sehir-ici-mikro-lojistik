import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/order_model.dart';

/// Sipariş Özeti Kartı Bileşeni
class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final Widget? trailingAction;
  final bool isCourierView;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.onTap,
    this.trailingAction,
    this.isCourierView = false,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusWaiting:
        return Colors.amber.shade700;
      case AppConstants.statusAssigned:
        return Colors.blue.shade600;
      case AppConstants.statusInTransit:
        return Colors.purple.shade600;
      case AppConstants.statusDelivered:
        return RouteDuckTheme.emeraldGreen;
      case AppConstants.statusCancelled:
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Sipariş ID & Durum Rozeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF281C14) : const Color(0xFFF6EDE4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.id,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.contentType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.statusDisplayTr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Rota Görünümü: Alış & Teslimat Noktaları
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 10, color: RouteDuckTheme.emeraldGreen),
                    Container(
                      width: 2,
                      height: 24,
                      color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                    ),
                    const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.pickupTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.dropoffTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Rozetler: Boyut, Hassas, Termal
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF221A14) : const Color(0xFFF3ECE4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.packageSizeDisplayTr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 11,
                        color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${order.itemCount} Adet • ${order.totalWeightKg.toStringAsFixed(order.totalWeightKg.truncateToDouble() == order.totalWeightKg ? 0 : 1)} kg • ${order.totalVolumeLiters.toStringAsFixed(0)} L',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.isFragile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text(
                          'Kırılabilir / Hassas',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order.requiresThermalBag)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Termal Çanta Gerekli',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order.preferredVehicle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.commute_rounded, size: 12, color: RouteDuckTheme.peachAmber),
                        const SizedBox(width: 4),
                        Text(
                          'Araç: ${order.preferredVehicleDisplayTr}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Alt Satır: Mesafe, Tutar / Kazanç ve Trailing Buton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.navigation_outlined,
                      size: 15,
                      color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${order.distanceKm} km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isCourierView ? 'Net Kazanç:' : 'Toplam:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCourierView
                          ? '${order.courierEarnings.toStringAsFixed(2)} TL'
                          : '${order.price.toStringAsFixed(2)} TL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isCourierView
                            ? RouteDuckTheme.emeraldGreen
                            : (isDark ? RouteDuckTheme.peachAmber : const Color(0xFF0D532B)),
                      ),
                    ),
                  ],
                ),
                ?trailingAction,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
