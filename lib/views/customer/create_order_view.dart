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
  final String? key; // null = Fark etmez / Tüm uygun araçlar
  final String title;
  final String subtitle;
  final String capacityText;
  final String? fuelText;
  final String? imagePath;
  final IconData icon;

  const CustomerVehicleOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.capacityText,
    this.fuelText,
    this.imagePath,
    required this.icon,
  });
}

/// Yeni Sipariş Oluşturma Ekranı (Create Order View)
class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  final MapController _mapController = MapController();
  final OrderCreationService _orderCreationService = OrderCreationService();
  final PricingService _pricingService = PricingService();
  final MapService _mapService = MapService();
  final AuthService _authService = AuthService();

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _pickupDetailController = TextEditingController();
  final TextEditingController _dropoffDetailController = TextEditingController();

  String _selectedSize = AppConstants.sizeDocument;
  String _selectedCategory = AppConstants.contentCategories[0];
  String? _preferredVehicle; // null = Otomatik / Fark etmez
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
      key: null,
      title: 'Tüm Uygun Araçlar (Önerilen)',
      subtitle: 'Paketime uygun ilk kurye yönlendirilir',
      capacityText: 'En Hızlı Eşleşme',
      fuelText: 'Taban Yakıt',
      icon: Icons.all_inclusive_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleMotorcycle,
      title: 'Motosiklet / Scooter',
      subtitle: '0 - 15 Kg arası koli ve evraklar',
      capacityText: 'Maks 15 Kg',
      fuelText: 'Düşük Yakıt (1.0x)',
      imagePath: 'assets/images/vehicles/motorcycle.png',
      icon: Icons.two_wheeler_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleCar,
      title: 'Binek Otomobil (Sedan)',
      subtitle: '0 - 60 Kg arası hassas veya çoklu paketler',
      capacityText: 'Maks 60 Kg',
      fuelText: 'Standart Yakıt (1.25x)',
      imagePath: 'assets/images/vehicles/car.png',
      icon: Icons.directions_car_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleMinivan,
      title: 'Kompakt Minivan (City Van)',
      subtitle: '0 - 200 Kg orta ticari koli ve eşyalar',
      capacityText: 'Maks 200 Kg',
      fuelText: 'Orta Yakıt (1.45x)',
      imagePath: 'assets/images/vehicles/minivan.png',
      icon: Icons.airport_shuttle_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehiclePanelvan,
      title: 'Standart Panelvan',
      subtitle: '0 - 450 Kg büyük koliler ve hacimli yük',
      capacityText: 'Maks 450 Kg',
      fuelText: 'Yüksek Yakıt (1.70x)',
      imagePath: 'assets/images/vehicles/panelvan.png',
      icon: Icons.local_shipping_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleMaxivan,
      title: 'Yüksek Tavan Maxi Panelvan',
      subtitle: '0 - 600 Kg paletli ve ağır mikro lojistik',
      capacityText: 'Maks 600 Kg',
      fuelText: 'Çok Yüksek (2.0x)',
      imagePath: 'assets/images/vehicles/maxivan.png',
      icon: Icons.rv_hookup_rounded,
    ),
    CustomerVehicleOption(
      key: AppConstants.vehicleTruck,
      title: 'Ağır Ticari / Kamyon (Tır)',
      subtitle: '+600 Kg ve üstü sanayi ve palet taşımacılığı',
      capacityText: '+600 Kg Sınırsız',
      fuelText: 'Ağır Yakıt (2.8x)',
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

  Map<String, double> get _priceBreakdown {
    return _pricingService.getPriceBreakdown(
      distanceKm: _calculatedDistance,
      packageSize: _selectedSize,
      isFragile: _isFragile,
      requiresThermalBag: _requiresThermalBag,
      vehicleType: _preferredVehicle,
    );
  }

  bool _isVehicleCompatible(String? vehicleKey) {
    if (vehicleKey == null) return true;
    final allowed = AppConstants.vehicleAllowedSizes[vehicleKey];
    return allowed?.contains(_selectedSize) ?? false;
  }

  Future<void> _submitOrder() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      ErrorHandler.showError(context, 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }

    final desc = _descController.text.trim();
    if (desc.length < 5) {
      ErrorHandler.showWarning(context, 'Lütfen paket içeriğini en az 5 karakter olacak şekilde açıklayın.');
      return;
    }

    if (_currentPickup.latitude == _currentDropoff.latitude &&
        _currentPickup.longitude == _currentDropoff.longitude) {
      ErrorHandler.showWarning(context, 'Alış ve teslimat noktaları aynı olamaz.');
      return;
    }

    // Seçilen araç paketi taşıyabilir mi kontrolü
    if (_preferredVehicle != null && !_isVehicleCompatible(_preferredVehicle)) {
      ErrorHandler.showWarning(context, 'Seçtiğiniz araç bu paket boyutunu taşımak için yeterli kapasiteye sahip değil.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await _orderCreationService.createOrder(
        customerId: user.id,
        customerName: user.fullName,
        packageSize: _selectedSize,
        contentType: _selectedCategory,
        customDescription: desc,
        isFragile: _isFragile,
        requiresThermalBag: _requiresThermalBag,
        preferredVehicle: _preferredVehicle,
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
    final breakdown = _priceBreakdown;
    final locations = PredefinedLocations.list;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kurye Çağır'),
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
                  // 1. Paket Boyutu Seçimi (0 - +600 Kg)
                  CargoSizeSelector(
                    selectedSize: _selectedSize,
                    onSizeSelected: (size) {
                      setState(() {
                        _selectedSize = size;
                        // Eğer önceden seçilen araç yeni boyutu desteklemiyorsa sıfırla
                        if (_preferredVehicle != null && !_isVehicleCompatible(_preferredVehicle)) {
                          _preferredVehicle = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // 2. Müşterinin Tercih Ettiği Araç Seçimi (Kilo Aralıklarına Uygun)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teslim Alacak Aracı Seçin',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _preferredVehicle == null ? 'Fark Etmez' : 'Seçildi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Araç Tercih Kartları Listesi
                  ...vehicleOptions.map((vOpt) {
                    final isSelected = _preferredVehicle == vOpt.key;
                    final isCompatible = _isVehicleCompatible(vOpt.key);

                    return InkWell(
                      onTap: isCompatible
                          ? () => setState(() => _preferredVehicle = vOpt.key)
                          : () {
                              ErrorHandler.showWarning(
                                context,
                                '${vOpt.title} bu paket ağırlığı ($_selectedSize) için uygun kapasitede değildir.',
                              );
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF182C1C) : const Color(0xFFEDF6F0))
                              : (isCompatible
                                  ? (isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard)
                                  : (isDark ? const Color(0xFF140D09) : const Color(0xFFF3EDE6))),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                : (isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 42,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF11381A) : const Color(0xFFD6EDE0))
                                    : (isDark ? const Color(0xFF1A110B) : const Color(0xFFF3EBE2)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: vOpt.imagePath != null
                                  ? Image.asset(
                                      vOpt.imagePath!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        vOpt.icon,
                                        size: 22,
                                        color: isCompatible ? null : Colors.grey,
                                      ),
                                    )
                                  : Icon(
                                      vOpt.icon,
                                      size: 22,
                                      color: isSelected
                                          ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                                          : (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)),
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
                                        vOpt.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isCompatible
                                              ? (isSelected
                                                  ? (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary)
                                                  : null)
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (!isCompatible)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('Kapasite Yetersiz', style: TextStyle(fontSize: 9, color: Colors.redAccent, fontWeight: FontWeight.w700)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vOpt.subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isCompatible
                                          ? (isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    vOpt.capacityText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isCompatible
                                          ? (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706))
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (vOpt.fuelText != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    '⛽ ${vOpt.fuelText!}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isCompatible
                                          ? (isDark ? Colors.amberAccent : const Color(0xFFB45309))
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // 3. İçerik Türü (Kategori)
                  const Text(
                    'Paket İçerik Kategorisi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
                        items: AppConstants.contentCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Serbest Açıklama (Zorunlu Metin Alanı)
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Paket İçeriği Açıklaması *',
                      hintText: 'Örn: 2 adet laptop çantası, mühürlü zarf veya 300 kg paletli malzeme',
                      helperText: 'Kuryenin ne taşıdığını bilmesi için en az 5 karakter yazın',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Özel Etiketler (Kırılabilir & Termal Çanta)
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
                  const SizedBox(height: 20),

                  // 6. Düzenlenmiş ve Kompakt Adres Bölümü
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alış ve Teslimat Noktaları',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
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

                  // Alış Noktası Seçimi (Daha Kompakt ve Orantılı Kutu)
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

                  // Teslimat Noktası Seçimi (Daha Kompakt ve Orantılı Kutu)
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

                  // 7. Fiyat Kırılımı ve Tutar Kartı (Breakdown)
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
                            Text('Boyut Katsayısı ($_selectedSize x${breakdown['sizeMultiplier']}):', style: const TextStyle(fontSize: 12)),
                            Text('+${breakdown['sizeExtra']?.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        if ((breakdown['fuelSurcharge'] ?? 0.0) > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Araç Yakıt Maliyeti ($_preferredVehicle x${breakdown['fuelMultiplier']}):',
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
                  const SizedBox(height: 18),

                  // Onayla ve Sipariş Ver
                  ElevatedButton(
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
                        : const Text('Siparişi Onayla ve Kurye Çağır'),
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
}
}
