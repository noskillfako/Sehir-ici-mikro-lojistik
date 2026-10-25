import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class CargoSizeOption {
  final String key;
  final String title;
  final String weightText;
  final String vehicleInfo;
  final IconData icon;

  const CargoSizeOption({
    required this.key,
    required this.title,
    required this.weightText,
    required this.vehicleInfo,
    required this.icon,
  });
}

/// 0 Kg'dan +600 Kg'a kadar kargo ağırlık ve boyutunu seçtiren kompakt ve estetik bileşen
class CargoSizeSelector extends StatelessWidget {
  final String selectedSize;
  final ValueChanged<String> onSizeSelected;

  const CargoSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  static const List<CargoSizeOption> options = [
    CargoSizeOption(
      key: AppConstants.sizeDocument,
      title: 'Zarf / Evrak',
      weightText: '0 - 1 Kg',
      vehicleInfo: 'Motosiklet veya Binek Otomobil',
      icon: Icons.markunread_mailbox_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeSmall,
      title: 'Küçük Paket / Çanta',
      weightText: '1 - 5 Kg',
      vehicleInfo: 'Motosiklet, Binek Otomobil, Minivan',
      icon: Icons.inventory_2_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeMedium,
      title: 'Orta Koli',
      weightText: '5 - 15 Kg',
      vehicleInfo: 'Motosiklet, Binek Otomobil, Minivan, Panelvan',
      icon: Icons.all_inbox_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeLarge,
      title: 'Büyük Koli / Eşya',
      weightText: '15 - 60 Kg',
      vehicleInfo: 'Binek Otomobil, Minivan, Panelvan, Maxi Van',
      icon: Icons.local_shipping_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeXLarge,
      title: 'Ağır Ticari Yük',
      weightText: '60 - 200 Kg',
      vehicleInfo: 'Minivan, Standart Panelvan, Maxi Van',
      icon: Icons.airport_shuttle_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizePallet,
      title: 'Paletli / Hacimli Yük',
      weightText: '200 - 600 Kg',
      vehicleInfo: 'Yüksek Tavan Maxi Van, Ağır Ticari (Tır)',
      icon: Icons.grid_view_rounded,
    ),
    CargoSizeOption(
      key: AppConstants.sizeHeavyCargo,
      title: 'Devasa Sanayi Yükü',
      weightText: '+600 Kg ve üstü',
      vehicleInfo: 'Sadece Ağır Ticari Kamyon / Tır',
      icon: Icons.fire_truck_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Paket Boyutu ve Ağırlığı',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF281C14) : const Color(0xFFF6EDE4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '0 - +600 Kg',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Kompakt, dengeli ve estetik yatay/dikey kart listesi
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final opt = options[index];
            final isSelected = selectedSize == opt.key;

            return InkWell(
              onTap: () => onSizeSelected(opt.key),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF1E2E22) : const Color(0xFFEDF6F0))
                      : (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard),
                  borderRadius: BorderRadius.circular(14),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0))
                            : (isDark ? const Color(0xFF1A110B) : const Color(0xFFF3EBE2)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        opt.icon,
                        size: 20,
                        color: isSelected
                            ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                            : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                opt.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  opt.weightText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt.vehicleInfo,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        size: 18,
                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
