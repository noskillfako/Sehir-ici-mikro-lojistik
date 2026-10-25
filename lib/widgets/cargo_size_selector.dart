import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Gerçek dünya standartlarına dayalı paket birim boyut seçeneği
class CargoSizeOption {
  final String key;
  final String title;
  final double unitWeightKg;
  final double unitVolumeLiters;
  final String volumeM3Text;
  final IconData icon;

  const CargoSizeOption({
    required this.key,
    required this.title,
    required this.unitWeightKg,
    required this.unitVolumeLiters,
    required this.volumeM3Text,
    required this.icon,
  });
}

/// Her ürün için bağımsız adet seçilebilen, toplam ağırlık/hacim hesaplayan kargo boyut seçici bileşeni
class CargoSizeSelector extends StatelessWidget {
  /// Her kargo türünden seçilen adetleri içeren harita (örn: {'DOCUMENT': 2, 'MEDIUM': 1})
  final Map<String, int>? itemQuantities;

  /// Adetler değiştiğinde tetiklenen callback
  final ValueChanged<Map<String, int>>? onQuantitiesChanged;

  /// Geriye dönük uyumluluk (Legacy / Test) için tekil seçim özellikleri
  final String? selectedSize;
  final int? itemCount;
  final ValueChanged<String>? onSizeSelected;
  final ValueChanged<int>? onItemCountChanged;

  const CargoSizeSelector({
    super.key,
    this.itemQuantities,
    this.onQuantitiesChanged,
    this.selectedSize,
    this.itemCount,
    this.onSizeSelected,
    this.onItemCountChanged,
  });

  static const List<CargoSizeOption> options = [
    CargoSizeOption(
      key: AppConstants.sizeDocument,
      title: 'Zarf / Evrak',
      unitWeightKg: 0.5,
      unitVolumeLiters: 2.0,
      volumeM3Text: '0.002 m³',
      icon: Icons.markunread_mailbox_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeSmall,
      title: 'Küçük Paket / Çanta',
      unitWeightKg: 3.0,
      unitVolumeLiters: 15.0,
      volumeM3Text: '0.015 m³',
      icon: Icons.inventory_2_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeMedium,
      title: 'Orta Koli',
      unitWeightKg: 10.0,
      unitVolumeLiters: 50.0,
      volumeM3Text: '0.05 m³',
      icon: Icons.all_inbox_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizeLarge,
      title: 'Büyük Koli',
      unitWeightKg: 30.0,
      unitVolumeLiters: 150.0,
      volumeM3Text: '0.15 m³',
      icon: Icons.local_shipping_outlined,
    ),
    CargoSizeOption(
      key: AppConstants.sizePallet,
      title: 'Ağır / Paletli Malzeme',
      unitWeightKg: 150.0,
      unitVolumeLiters: 600.0,
      volumeM3Text: '0.6 m³',
      icon: Icons.grid_view_rounded,
    ),
    CargoSizeOption(
      key: AppConstants.sizeHeavyCargo,
      title: 'Sanayi / Devasa Yük',
      unitWeightKg: 500.0,
      unitVolumeLiters: 2000.0,
      volumeM3Text: '2.0 m³',
      icon: Icons.fire_truck_outlined,
    ),
  ];

  Map<String, int> get _effectiveQuantities {
    if (itemQuantities != null) {
      return Map<String, int>.from(itemQuantities!);
    }
    final size = selectedSize ?? AppConstants.sizeDocument;
    final count = itemCount ?? 1;
    return {size: count};
  }

  void _updateItemQuantity(BuildContext context, String key, int newCount) {
    final next = Map<String, int>.from(_effectiveQuantities);
    if (newCount <= 0) {
      next.remove(key);
    } else {
      next[key] = newCount;
    }

    if (onQuantitiesChanged != null) {
      onQuantitiesChanged!(next);
    }

    if (onItemCountChanged != null) {
      final total = next.values.fold(0, (sum, q) => sum + q);
      onItemCountChanged!(total > 0 ? total : 1);
    }

    if (onSizeSelected != null) {
      final primary = AppConstants.getPrimaryPackageSize(next);
      onSizeSelected!(primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quantities = _effectiveQuantities;

    // Toplam adet, ağırlık ve hacim hesabı
    int totalCount = 0;
    double totalWeight = 0.0;
    double totalVolume = 0.0;

    for (final opt in options) {
      final qty = quantities[opt.key] ?? 0;
      if (qty > 0) {
        totalCount += qty;
        totalWeight += opt.unitWeightKg * qty;
        totalVolume += opt.unitVolumeLiters * qty;
      }
    }

    final totalM3 = totalVolume / 1000.0;

    final weightStr = totalWeight.truncateToDouble() == totalWeight
        ? totalWeight.toStringAsFixed(0)
        : totalWeight.toStringAsFixed(1);
    final volumeStr = totalVolume.truncateToDouble() == totalVolume
        ? totalVolume.toStringAsFixed(0)
        : totalVolume.toStringAsFixed(1);
    final m3Str = totalM3 >= 1.0
        ? totalM3.toStringAsFixed(2)
        : totalM3.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

    // Seçilen ürünlerin özet metni
    final selectedDescriptions = <String>[];
    for (final opt in options) {
      final qty = quantities[opt.key] ?? 0;
      if (qty > 0) {
        selectedDescriptions.add('$qty Adet ${opt.title}');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve Bilgi Rozeti
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                '1. Ürün Boyutu ve Gönderi Adedi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF281C14) : const Color(0xFFF6EDE4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Çoklu Ürün Desteği',
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

        // Dikey Kargo Türü ve Her Biri Bağımsız Adet Kartları
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final opt = options[index];
            final currentQty = quantities[opt.key] ?? 0;
            final isSelected = currentQty > 0;

            return InkWell(
              onTap: () {
                if (!isSelected) {
                  _updateItemQuantity(context, opt.key, 1);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    // Kategori İkon Kutusu
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0))
                            : (isDark ? const Color(0xFF1A110B) : const Color(0xFFF3EBE2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        opt.icon,
                        size: 22,
                        color: isSelected
                            ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                            : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Kargo Başlık & Birim Bilgileri
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
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$currentQty Adet',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Birim: ${opt.unitWeightKg} kg • ${opt.unitVolumeLiters.toStringAsFixed(0)} L (${opt.volumeM3Text})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309))
                                  : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sağ Taraf: Bağımsız Adet Kontrolü (Seçili ise - / + Stepper, Seçili değilse + Ekle butonu)
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF112215) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Eksi / Sil Butonu
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: ValueKey('stepper_remove_${opt.key}'),
                                onTap: () => _updateItemQuantity(context, opt.key, currentQty - 1),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    currentQty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                                    size: 18,
                                    color: currentQty == 1
                                        ? Colors.redAccent.withValues(alpha: 0.85)
                                        : (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 32),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              child: Text(
                                '$currentQty Adet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary,
                                ),
                              ),
                            ),
                            // Artı Butonu
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: ValueKey('stepper_add_${opt.key}'),
                                onTap: () => _updateItemQuantity(context, opt.key, math.min(99, currentQty + 1)),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Seçili Değilse: "+ Ekle" Butonu
                      Container(
                        key: ValueKey('add_button_${opt.key}'),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 15,
                              color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ekle',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // TOPLAM ÖZET ŞERİDİ ("Toplam: X Adet | Y kg | Z Litre")
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A261D), const Color(0xFF1E1610)]
                  : [const Color(0xFFEDF6F0), const Color(0xFFFAF4EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.4)
                  : RouteDuckTheme.deepForest.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.scale_rounded,
                      size: 20,
                      color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yük Hesaplama Özeti',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalCount > 0
                              ? 'Toplam: $totalCount Adet | $weightStr kg | $volumeStr Litre (~$m3Str m³)'
                              : 'Henüz ürün seçilmedi (Yukarıdan ürün ekleyin)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFF0D532B),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dinamik',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selectedDescriptions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    'Seçilen Ürünler: ${selectedDescriptions.join(' • ')}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? RouteDuckTheme.darkTextSecondary
                          : RouteDuckTheme.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
