import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/predefined_locations.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location_preset_model.dart';
import '../../services/auth_service.dart';
import '../../services/map_service.dart';
import '../../services/order_creation_service.dart';
import '../../services/pricing_service.dart';
import '../../widgets/cargo_size_selector.dart';

class CustomerVehicleOption {
  final String key;
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData icon;

  const CustomerVehicleOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.icon,
  });
}

/// Yeni Sipariş Oluşturma Ekranı (Create Order View)
/// 3 Adımlı Modern Sayfalı Sipariş Akışı (Wizard / Step Flow)
class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  final PageController _pageController = PageController();
  final MapController _mapController = MapController();
  final OrderCreationService _orderCreationService = OrderCreationService();
  final PricingService _pricingService = PricingService();
  final MapService _mapService = MapService();
  final AuthService _authService = AuthService();

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _pickupDetailController = TextEditingController();
  final TextEditingController _dropoffDetailController = TextEditingController();

  int _currentStep = 0; // 0: Paket & Adet, 1: Araç & Kapasite, 2: Adres & Harita
  Map<String, int> _itemQuantities = {
    AppConstants.sizeDocument: 1,
  };
  String? _preferredVehicle; // null = otomatik tavsiye edilen araç kullanılır
  bool _isFragile = false;
  bool _requiresThermalBag = false;

  late LocationPresetModel _pickupPreset;
  late LocationPresetModel _dropoffPreset;
  LatLng? _customPickupPoint;
  LatLng? _customDropoffPoint;

  bool _isMapSelectingPickup = false;
  bool _isMapSelectingDropoff = false;
  bool _isSubmitting = false;

  static const List<CustomerVehicleOption> vehicleOptions = [
    CustomerVehicleOption(
      key: AppConstants.vehicleMotorcycle,
      title: 'Motosiklet (Maxi Scooter)',
      subtitle: 'Hızlı kentsel teslimat, yoğun trafik avantajı',
      imagePath: 'assets/images/vehicles/motorcycle.png',
      icon: Icons.two_wheeler_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleCar,
      title: 'Binek Otomobil (Sedan)',
      subtitle: 'Hassas eşya, bagaj ve çoklu paket taşıma',
      imagePath: 'assets/images/vehicles/car.png',
      icon: Icons.directions_car_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleMinivan,
      title: 'Kompakt Minivan (City Van)',
      subtitle: 'Kompakt ticari koli ve kutu taşımacılığı',
      imagePath: 'assets/images/vehicles/minivan.png',
      icon: Icons.airport_shuttle_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehiclePanelvan,
      title: 'Standart Panelvan',
      subtitle: 'Geniş hacimli kapalı kasa taşımacılık',
      imagePath: 'assets/images/vehicles/panelvan.png',
      icon: Icons.local_shipping_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleMaxivan,
      title: 'Yüksek Tavan Maxi Van',
      subtitle: 'Uzun şasi, paletli ve yüksek hacimli yük',
      imagePath: 'assets/images/vehicles/maxivan.png',
      icon: Icons.rv_hookup_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleTruck,
      title: 'Ağır Ticari Kamyon / Tır',
      subtitle: 'Endüstriyel tonaj, sanayi ve devasa yükler',
      imagePath: 'assets/images/vehicles/truck.png',
      icon: Icons.fire_truck_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pickupPreset = PredefinedLocations.kadikoy;
    _dropoffPreset = PredefinedLocations.besiktas;
    _pickupDetailController.text = _pickupPreset.description;
    _dropoffDetailController.text = _dropoffPreset.description;
  }

  @override
  void dispose() {
    _descController.dispose();
    _pickupDetailController.dispose();
    _dropoffDetailController.dispose();
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  LatLng get _currentPickup => _customPickupPoint ?? _pickupPreset.latLng;
  LatLng get _currentDropoff => _customDropoffPoint ?? _dropoffPreset.latLng;

  double get _calculatedDistance {
    try {
      return _mapService.calculateRouteDistanceKm(_currentPickup, _currentDropoff);
    } catch (_) {
      return 1.0;
    }
  }

  String get _selectedSize => AppConstants.getPrimaryPackageSize(_itemQuantities);
  int get _itemCount => _itemQuantities.values.fold(0, (sum, q) => sum + q);

  double get _totalWeightKg {
    if (_itemQuantities.isEmpty) return 0.0;
    return _itemQuantities.entries.fold(0.0, (sum, e) {
      final unitWeight = AppConstants.packageUnitWeightsKg[e.key] ?? 0.5;
      return sum + (unitWeight * e.value);
    });
  }

  double get _totalVolumeLiters {
    if (_itemQuantities.isEmpty) return 0.0;
    return _itemQuantities.entries.fold(0.0, (sum, e) {
      final unitVolume = AppConstants.packageUnitVolumesLiters[e.key] ?? 2.0;
      return sum + (unitVolume * e.value);
    });
  }

  String get _recommendedVehicleKey {
    return AppConstants.getRecommendedVehicle(
      _totalWeightKg > 0 ? _totalWeightKg : 0.5,
      _totalVolumeLiters > 0 ? _totalVolumeLiters : 2.0,
    );
  }

  bool _isVehicleCompatible(String vehicleKey) {
    final maxWeight = AppConstants.vehicleMaxCapacityKg[vehicleKey] ?? 0.0;
    final maxVolume = AppConstants.vehicleMaxCapacityLiters[vehicleKey] ?? 0.0;
    return _totalWeightKg <= maxWeight && _totalVolumeLiters <= maxVolume;
  }

  String get _activeSelectedVehicle {
    if (_preferredVehicle != null && _isVehicleCompatible(_preferredVehicle!)) {
      return _preferredVehicle!;
    }
    return _recommendedVehicleKey;
  }

  Map<String, double> get _priceBreakdown {
    return _pricingService.getPriceBreakdown(
      distanceKm: _calculatedDistance,
      packageSize: _selectedSize,
      itemCount: _itemCount > 0 ? _itemCount : 1,
      totalWeightKg: _totalWeightKg > 0 ? _totalWeightKg : 0.5,
      totalVolumeLiters: _totalVolumeLiters > 0 ? _totalVolumeLiters : 2.0,
      isFragile: _isFragile,
      requiresThermalBag: _requiresThermalBag,
      vehicleType: _activeSelectedVehicle,
    );
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextFromStep1() {
    if (_itemCount == 0) {
      ErrorHandler.showWarning(context, 'Lütfen en az bir gönderi ürünü ekleyin.');
      return;
    }
    final desc = _descController.text.trim();
    if (desc.length < 5) {
      ErrorHandler.showWarning(context, 'Lütfen paket içeriğini en az 5 karakter olacak şekilde açıklayın.');
      return;
    }
    _goToStep(1);
  }

  void _nextFromStep2() {
    final selectedVehicle = _activeSelectedVehicle;
    if (!_isVehicleCompatible(selectedVehicle)) {
      ErrorHandler.showWarning(
        context,
        'Seçtiğiniz araç bu toplam yükü (${_totalWeightKg.toStringAsFixed(1)} kg / ${_totalVolumeLiters.toStringAsFixed(0)} L) taşımak için yeterli kapasiteye sahip değil.',
      );
      return;
    }
    _goToStep(2);
  }

  Future<void> _submitOrder() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      ErrorHandler.showError(context, 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }

    if (_itemCount == 0) {
      ErrorHandler.showWarning(context, 'Lütfen en az bir gönderi ürünü ekleyin.');
      _goToStep(0);
      return;
    }

    final desc = _descController.text.trim();
    if (desc.length < 5) {
      ErrorHandler.showWarning(context, 'Lütfen paket içeriğini en az 5 karakter olacak şekilde açıklayın.');
      _goToStep(0);
      return;
    }

    final selectedVehicle = _activeSelectedVehicle;
    if (!_isVehicleCompatible(selectedVehicle)) {
      ErrorHandler.showWarning(
        context,
        'Seçtiğiniz araç bu toplam yükü (${_totalWeightKg.toStringAsFixed(1)} kg / ${_totalVolumeLiters.toStringAsFixed(0)} L) taşımak için yeterli kapasiteye sahip değil.',
      );
      _goToStep(1);
      return;
    }

    if (_currentPickup.latitude == _currentDropoff.latitude &&
        _currentPickup.longitude == _currentDropoff.longitude) {
      ErrorHandler.showWarning(context, 'Alış ve teslimat noktaları aynı olamaz.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await _orderCreationService.createOrder(
        customerId: user.id,
        customerName: user.fullName,
        packageSize: _selectedSize,
        itemCount: _itemCount,
        itemQuantities: _itemQuantities,
        totalWeightKg: _totalWeightKg,
        totalVolumeLiters: _totalVolumeLiters,
        recommendedVehicle: _recommendedVehicleKey,
        preferredVehicle: selectedVehicle,
        contentType: 'Genel Kargo',
        customDescription: desc,
        isFragile: _isFragile,
        requiresThermalBag: _requiresThermalBag,
        pickupTitle: _pickupPreset.name,
        pickupAddressDetail: _pickupDetailController.text.trim().isNotEmpty
            ? _pickupDetailController.text.trim()
            : _pickupPreset.description,
        pickupLat: _currentPickup.latitude,
        pickupLng: _currentPickup.longitude,
        dropoffTitle: _dropoffPreset.name,
        dropoffAddressDetail: _dropoffDetailController.text.trim().isNotEmpty
            ? _dropoffDetailController.text.trim()
            : _dropoffPreset.description,
        dropoffLat: _currentDropoff.latitude,
        dropoffLng: _currentDropoff.longitude,
      );

      if (!mounted) return;
      ErrorHandler.showSuccess(context, 'Sipariş ${order.id} oluşturuldu! Kurye havuzuna iletildi.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          _goToStep(_currentStep - 1);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Yeni Kurye Çağır (Adım ${_currentStep + 1}/3)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (_currentStep > 0) {
                _goToStep(_currentStep - 1);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Üst İlerleme Çubuğu (Step Progress Indicator)
              _buildStepIndicator(isDark),

              // Sayfalı Akış (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1PackagePage(isDark),
                    _buildStep2VehiclePage(isDark),
                    _buildStep3LocationPage(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern Üst Adım İlerleme Çubuğu
  Widget _buildStepIndicator(bool isDark) {
    const steps = [
      {'title': '1. Ürün & Adet', 'icon': Icons.inventory_2_outlined},
      {'title': '2. Araç & Doluluk', 'icon': Icons.local_shipping_outlined},
      {'title': '3. Adres & Onay', 'icon': Icons.map_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141F16) : const Color(0xFFF3ECE4),
        border: Border(
          bottom: BorderSide(
            color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isPassed = _currentStep > lineIndex;
                return Container(
                  width: 10,
                  height: 2.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? RouteDuckTheme.emeraldGreen
                        : (isDark ? const Color(0xFF2C221A) : const Color(0xFFDDD2C6)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isCurrent = _currentStep == stepIndex;
              final isDone = _currentStep > stepIndex;
              final stepData = steps[stepIndex];

              return Expanded(
                child: InkWell(
                  onTap: isDone ? () => _goToStep(stepIndex) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? (isDark ? const Color(0xFF1A3822) : const Color(0xFFD6EDE0))
                          : (isDone
                              ? (isDark ? const Color(0xFF16251A) : const Color(0xFFE4F2E9))
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                            : (isDone
                                ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.4)
                                : Colors.transparent),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isCurrent || isDone
                                ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                : (isDark ? const Color(0xFF2C221A) : const Color(0xFFD4C8BC)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : (stepData['icon'] as IconData),
                            size: 11,
                            color: isCurrent || isDone
                                ? Colors.white
                                : (isDark ? Colors.grey : const Color(0xFF6B5E52)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            stepData['title'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                              color: isCurrent
                                  ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                  : (isDone
                                      ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                                      : (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 1. Sayfa: Ürün Boyutu ve Gönderi Adedi (+ Açıklama & Özel Etiketler)
  Widget _buildStep1PackagePage(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kargo Boyut ve Bağımsız Adet Seçici
              CargoSizeSelector(
                itemQuantities: _itemQuantities,
                onQuantitiesChanged: (quantities) {
                  setState(() {
                    _itemQuantities = quantities;
                    if (_preferredVehicle != null && !_isVehicleCompatible(_preferredVehicle!)) {
                      _preferredVehicle = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Paket Açıklaması
              const Text(
                'Paket İçeriği Açıklaması',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Paket İçeriği Açıklaması *',
                  hintText: 'Örn: 2 adet laptop çantası, mühürlü evrak veya 3 koli malzeme',
                  helperText: 'Kuryenin ne taşıdığını bilmesi için en az 5 karakter yazın',
                ),
              ),
              const SizedBox(height: 16),

              // Özel Taşıma İhtiyaçları (Kırılabilir & Termal Çanta)
              const Text(
                'Özel Taşıma İhtiyaçları',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isFragile = !_isFragile),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isFragile
                              ? Colors.red.withValues(alpha: 0.15)
                              : (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isFragile
                                ? Colors.redAccent
                                : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isFragile ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 20,
                              color: _isFragile ? Colors.redAccent : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kırılabilir Eşya',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '+30 TL Hassas',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _requiresThermalBag = !_requiresThermalBag),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _requiresThermalBag
                              ? Colors.orange.withValues(alpha: 0.15)
                              : (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _requiresThermalBag
                                ? Colors.orange
                                : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _requiresThermalBag ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 20,
                              color: _requiresThermalBag ? Colors.orange : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Termal Çanta',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '+25 TL Sıcak/Soğuk',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Devam Butonu
              ElevatedButton.icon(
                onPressed: _nextFromStep1,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Devam Et: Araç Seçimi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                  foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Sayfa: Araç Kapasite ve Doluluk Durumu
  Widget _buildStep2VehiclePage(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '2. Araç Kapasite ve Doluluk Durumu',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                            .withValues(alpha: 0.3),
                      ),
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
                          _preferredVehicle != null && _preferredVehicle != _recommendedVehicleKey
                              ? 'Manuel Seçim'
                              : 'Önerilen Seçildi',
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
              const SizedBox(height: 12),

              // Araç Tercih Kartları Listesi (Kapasite Doluluk Barlarıyla)
              ...vehicleOptions.map((vOpt) {
                final isRecommended = vOpt.key == _recommendedVehicleKey;
                final isSelected = vOpt.key == _activeSelectedVehicle;
                final isCompatible = _isVehicleCompatible(vOpt.key);

                final maxKg = AppConstants.vehicleMaxCapacityKg[vOpt.key] ?? 0.0;
                final maxL = AppConstants.vehicleMaxCapacityLiters[vOpt.key] ?? 0.0;
                final maxM3 = AppConstants.vehicleMaxCapacityM3Text[vOpt.key] ?? '';
                final fuelText = AppConstants.vehicleFuelConsumptionText[vOpt.key] ?? '';

                final weightRatio = _totalWeightKg / maxKg;
                final volumeRatio = _totalVolumeLiters / maxL;
                final occupancyRatio = math.max(weightRatio, volumeRatio);
                final occupancyPercent = (occupancyRatio * 100).round();

                return InkWell(
                  onTap: isCompatible
                      ? () => setState(() => _preferredVehicle = vOpt.key)
                      : () {
                          ErrorHandler.showWarning(
                            context,
                            '${vOpt.title} bu gönderi yükünü (${_totalWeightKg.toStringAsFixed(1)} kg / ${_totalVolumeLiters.toStringAsFixed(0)} L) taşımak için yeterli kapasiteye sahip değildir.',
                          );
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF182C1C) : const Color(0xFFEDF6F0))
                          : (isCompatible
                              ? (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard)
                              : (isDark ? const Color(0xFF160E0A) : const Color(0xFFF7EFE9))),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                            : (isCompatible
                                ? (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder)
                                : (isDark
                                    ? Colors.redAccent.withValues(alpha: 0.35)
                                    : Colors.redAccent.withValues(alpha: 0.25))),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tavsiye Edilen Araç Yeşil Rozeti
                        if (isRecommended)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 16,
                                  color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '★ EN UYGUN TAVSİYE EDİLEN ARAÇ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'En Ekonomik & Uyumlu',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Araç Görseli, Başlık, Kapasite ve Seçim İkonu
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 46,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0))
                                    : (isDark ? const Color(0xFF1A110B) : const Color(0xFFF3EBE2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Opacity(
                                opacity: isCompatible ? 1.0 : 0.45,
                                child: Image.asset(
                                  vOpt.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    vOpt.icon,
                                    size: 24,
                                    color: isCompatible ? null : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vOpt.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isCompatible
                                                ? (isSelected
                                                    ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                                                    : null)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      if (!isCompatible)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.block_rounded, size: 10, color: Colors.redAccent),
                                              SizedBox(width: 3),
                                              Text(
                                                'Kapasite Yetersiz',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Maks ${maxKg.toStringAsFixed(0)} kg • Maks ${maxL.toStringAsFixed(0)} L ($maxM3)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isCompatible
                                          ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309))
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '⛽ $fuelText',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isCompatible
                                          ? (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 22,
                                color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                              )
                            else if (isCompatible)
                              Icon(
                                Icons.circle_outlined,
                                size: 20,
                                color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                              )
                            else
                              Icon(
                                Icons.remove_circle_outline_rounded,
                                size: 20,
                                color: Colors.redAccent.withValues(alpha: 0.4),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Kapasite Doluluk Barı (LinearProgressIndicator)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kapasite Doluluğu:',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCompatible
                                      ? '%$occupancyPercent Doluluk'
                                      : '%$occupancyPercent Doluluk (Aşıldı)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: !isCompatible
                                        ? Colors.redAccent
                                        : (occupancyPercent > 85
                                            ? Colors.orangeAccent
                                            : (occupancyPercent > 50
                                                ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))
                                                : (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: occupancyRatio.clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: isDark
                                    ? const Color(0xFF281C14)
                                    : const Color(0xFFE5DDD3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  !isCompatible
                                      ? Colors.redAccent
                                      : (occupancyPercent > 85
                                          ? Colors.orangeAccent
                                          : (occupancyPercent > 50
                                              ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))
                                              : (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Geri ve İleri Gezinme Butonları
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _goToStep(0),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Geri'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _nextFromStep2,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Devam Et: Adres & Harita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                        foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Sayfa: Alış ve Teslimat Noktaları (+ Harita & Fiyat Dökümü & Sipariş Tamamlama)
  Widget _buildStep3LocationPage(bool isDark) {
    final breakdown = _priceBreakdown;
    final locations = PredefinedLocations.list;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '3. Alış ve Teslimat Noktaları',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mesafe: ${_calculatedDistance.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Alış Noktası Seçimi (Kompakt Kutu)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: RouteDuckTheme.emeraldGreen, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'Alış Noktası (Nereden Alınacak)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        if (_isMapSelectingPickup)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Haritadan Seçiliyor', style: TextStyle(fontSize: 10, color: RouteDuckTheme.emeraldGreen)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<LocationPresetModel>(
                      initialValue: _pickupPreset,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: locations.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (loc) {
                        if (loc != null) {
                          setState(() {
                            _pickupPreset = loc;
                            _customPickupPoint = null;
                            _pickupDetailController.text = loc.description;
                          });
                          _mapController.move(loc.latLng, 13.0);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pickupDetailController,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        labelText: 'Alış Açık Adres / Kapı No',
                        hintText: 'Sokak, Bina No, Kat, Daire vb.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Teslimat Noktası Seçimi (Kompakt Kutu)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'Teslimat Noktası (Nereye Gidecek)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        if (_isMapSelectingDropoff)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Haritadan Seçiliyor', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<LocationPresetModel>(
                      initialValue: _dropoffPreset,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: locations.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (loc) {
                        if (loc != null) {
                          setState(() {
                            _dropoffPreset = loc;
                            _customDropoffPoint = null;
                            _dropoffDetailController.text = loc.description;
                          });
                          _mapController.move(loc.latLng, 13.0);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dropoffDetailController,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        labelText: 'Teslimat Açık Adres / Kapı No',
                        hintText: 'Sokak, Bina No, Kat, Daire vb.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // İnteraktif Harita Önizleme
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPickup,
                        initialZoom: 11.5,
                        onTap: (tapPosition, point) {
                          if (_isMapSelectingPickup) {
                            setState(() {
                              _customPickupPoint = point;
                              _isMapSelectingPickup = false;
                            });
                            ErrorHandler.showSuccess(context, 'Alış noktası haritadan belirlendi.');
                          } else if (_isMapSelectingDropoff) {
                            setState(() {
                              _customDropoffPoint = point;
                              _isMapSelectingDropoff = false;
                            });
                            ErrorHandler.showSuccess(context, 'Teslimat noktası haritadan belirlendi.');
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConstants.osmTileUrl,
                          userAgentPackageName: AppConstants.userAgentPackage,
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [_currentPickup, _currentDropoff],
                              strokeWidth: 4.0,
                              color: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPickup,
                              width: 36,
                              height: 36,
                              child: const Icon(Icons.location_on, color: RouteDuckTheme.emeraldGreen, size: 36),
                            ),
                            Marker(
                              point: _currentDropoff,
                              width: 36,
                              height: 36,
                              child: const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'pick_pickup',
                            backgroundColor: _isMapSelectingPickup
                                ? RouteDuckTheme.emeraldGreen
                                : (isDark ? RouteDuckTheme.darkCard : Colors.white),
                            foregroundColor: _isMapSelectingPickup
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            tooltip: 'Alış Noktasını Haritadan Seç',
                            onPressed: () {
                              setState(() {
                                _isMapSelectingPickup = !_isMapSelectingPickup;
                                _isMapSelectingDropoff = false;
                              });
                            },
                            child: const Icon(Icons.add_location_alt_outlined, size: 18),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'pick_dropoff',
                            backgroundColor: _isMapSelectingDropoff
                                ? Colors.redAccent
                                : (isDark ? RouteDuckTheme.darkCard : Colors.white),
                            foregroundColor: _isMapSelectingDropoff
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            tooltip: 'Teslimat Noktasını Haritadan Seç',
                            onPressed: () {
                              setState(() {
                                _isMapSelectingDropoff = !_isMapSelectingDropoff;
                                _isMapSelectingPickup = false;
                              });
                            },
                            child: const Icon(Icons.flag_outlined, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Fiyat Kırılımı ve Tutar Kartı (Breakdown)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E140E) : const Color(0xFFF9F5F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Açılış Ücreti (Taban):', style: TextStyle(fontSize: 12)),
                        Text('${breakdown['baseFare']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mesafe Tutarı (${_calculatedDistance.toStringAsFixed(1)} km x 15 TL):', style: const TextStyle(fontSize: 12)),
                        Text('${breakdown['distanceFare']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Boyut & Adet (${AppConstants.packageSizeTitle(_selectedSize)} • $_itemCount Adet x${breakdown['sizeMultiplier']}):', style: const TextStyle(fontSize: 12)),
                        Text('+${breakdown['sizeExtra']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if ((breakdown['fuelSurcharge'] ?? 0.0) > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Araç Yakıt Maliyeti (${AppConstants.getVehicleTitle(_activeSelectedVehicle)} x${breakdown['fuelMultiplier']}):',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.amberAccent : const Color(0xFFB45309),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '+${breakdown['fuelSurcharge']?.toStringAsFixed(2)} TL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.amberAccent : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_isFragile) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kırılabilir / Hassas Gönderi:', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                          Text('+${breakdown['fragileFee']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                        ],
                      ),
                    ],
                    if (_requiresThermalBag) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Termal Sıcak/Soğuk Çanta:', style: TextStyle(fontSize: 12, color: Colors.orange)),
                          Text('+${breakdown['thermalBagFee']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
                        ],
                      ),
                    ],
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ödenecek Toplam Tutar:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${breakdown['totalPrice']?.toStringAsFixed(2)} TL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Geri ve Onayla / Sipariş Ver Butonları
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _goToStep(1),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Geri'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                        foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Siparişi Onayla ve Kurye Çağır',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
