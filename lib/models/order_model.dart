import 'package:latlong2/latlong.dart';
import '../core/constants/app_constants.dart';

/// Sipariş Veri Modeli
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? courierId;
  final String? courierName;
  final String? courierVehicle;
  final String? preferredVehicle; // Müşterinin tercih ettiği teslimat aracı (Opsiyonel)
  final String packageSize; // 'DOCUMENT', 'SMALL', 'MEDIUM', 'LARGE', 'XLARGE', 'PALLET', 'HEAVY_CARGO'
  final int itemCount; // Taşınacak toplam ürün/koli adedi (varsayılan: 1)
  final Map<String, int> itemQuantities; // Her ürün boyutundan seçilen adetler
  final double totalWeightKg; // Toplam ağırlık: Birim Ağırlık x Adet
  final double totalVolumeLiters; // Toplam hacim: Birim Hacim x Adet
  final String recommendedVehicle; // Algoritmanın önerdiği ideal araç anahtarı
  final String contentType;
  final String customDescription;
  final bool isFragile;
  final bool requiresThermalBag;
  final String pickupTitle;
  final String pickupAddressDetail;
  final double pickupLat;
  final double pickupLng;
  final String dropoffTitle;
  final String dropoffAddressDetail;
  final double dropoffLat;
  final double dropoffLng;
  final double distanceKm;
  final double price;
  final String deliveryOtpCode;
  final String status;
  final String createdAt;
  final String? deliveredAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.courierId,
    this.courierName,
    this.courierVehicle,
    this.preferredVehicle,
    required this.packageSize,
    this.itemCount = 1,
    this.itemQuantities = const {},
    this.totalWeightKg = 0.5,
    this.totalVolumeLiters = 2.0,
    this.recommendedVehicle = AppConstants.vehicleMotorcycle,
    required this.contentType,
    required this.customDescription,
    required this.isFragile,
    required this.requiresThermalBag,
    required this.pickupTitle,
    required this.pickupAddressDetail,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffTitle,
    required this.dropoffAddressDetail,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distanceKm,
    required this.price,
    required this.deliveryOtpCode,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
  });

  LatLng get pickupLatLng => LatLng(pickupLat, pickupLng);
  LatLng get dropoffLatLng => LatLng(dropoffLat, dropoffLng);

  bool get isWaiting => status == AppConstants.statusWaiting;
  bool get isAssigned => status == AppConstants.statusAssigned;
  bool get isInTransit => status == AppConstants.statusInTransit;
  bool get isDelivered => status == AppConstants.statusDelivered;
  bool get isCancelled => status == AppConstants.statusCancelled;

  double get courierEarnings => price * (1.0 - AppConstants.commissionRate);

  String get statusDisplayTr {
    switch (status) {
      case AppConstants.statusWaiting:
        return 'Kurye Bekleniyor';
      case AppConstants.statusAssigned:
        return 'Kurye Yolda';
      case AppConstants.statusInTransit:
        return 'Paket Dağıtımda';
      case AppConstants.statusDelivered:
        return 'Teslim Edildi';
      case AppConstants.statusCancelled:
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  String get packageSizeDisplayTr {
    switch (packageSize) {
      case AppConstants.sizeDocument:
        return 'Zarf / Evrak (0-1 Kg)';
      case AppConstants.sizeSmall:
        return 'Küçük Paket (1-5 Kg)';
      case AppConstants.sizeMedium:
        return 'Orta Koli (5-15 Kg)';
      case AppConstants.sizeLarge:
        return 'Büyük Koli (15-60 Kg)';
      case AppConstants.sizeXLarge:
        return 'Ağır Ticari (60-200 Kg)';
      case AppConstants.sizePallet:
        return 'Paletli Yük (200-600 Kg)';
      case AppConstants.sizeHeavyCargo:
        return 'Devasa Ağır Yük (+600 Kg)';
      default:
        return packageSize;
    }
  }

  String get preferredVehicleDisplayTr {
    switch (preferredVehicle) {
      case AppConstants.vehicleMotorcycle:
        return 'Motosiklet / Scooter';
      case AppConstants.vehicleCar:
        return 'Binek Otomobil (Sedan)';
      case AppConstants.vehicleMinivan:
        return 'Kompakt Minivan';
      case AppConstants.vehiclePanelvan:
        return 'Standart Panelvan';
      case AppConstants.vehicleMaxivan:
        return 'Maxi Panelvan';
      case AppConstants.vehicleTruck:
        return 'Ağır Ticari / Kamyon (Tır)';
      default:
        return 'Tüm Uygun Araçlar';
    }
  }

  String get recommendedVehicleDisplayTr {
    switch (recommendedVehicle) {
      case AppConstants.vehicleMotorcycle:
        return 'Motosiklet (Maxi Scooter)';
      case AppConstants.vehicleCar:
        return 'Binek Otomobil (Sedan)';
      case AppConstants.vehicleMinivan:
        return 'Kompakt Minivan';
      case AppConstants.vehiclePanelvan:
        return 'Standart Panelvan';
      case AppConstants.vehicleMaxivan:
        return 'Maxi Panelvan';
      case AppConstants.vehicleTruck:
        return 'Ağır Ticari Kamyon / Tır';
      default:
        return recommendedVehicle;
    }
  }

  String get itemQuantitiesSummaryTr {
    if (itemQuantities.isEmpty) {
      return '$itemCount Adet $packageSizeDisplayTr';
    }
    final parts = <String>[];
    itemQuantities.forEach((size, qty) {
      if (qty > 0) {
        parts.add('$qty Adet ${AppConstants.packageSizeTitle(size)}');
      }
    });
    return parts.isEmpty ? '$itemCount Adet $packageSizeDisplayTr' : parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'courierId': courierId,
      'courierName': courierName,
      'courierVehicle': courierVehicle,
      'preferredVehicle': preferredVehicle,
      'packageSize': packageSize,
      'itemCount': itemCount,
      'itemQuantities': itemQuantities,
      'totalWeightKg': totalWeightKg,
      'totalVolumeLiters': totalVolumeLiters,
      'recommendedVehicle': recommendedVehicle,
      'contentType': contentType,
      'customDescription': customDescription,
      'isFragile': isFragile,
      'requiresThermalBag': requiresThermalBag,
      'pickupTitle': pickupTitle,
      'pickupAddressDetail': pickupAddressDetail,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffTitle': dropoffTitle,
      'dropoffAddressDetail': dropoffAddressDetail,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'distanceKm': distanceKm,
      'price': price,
      'deliveryOtpCode': deliveryOtpCode,
      'status': status,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      courierId: map['courierId'] as String?,
      courierName: map['courierName'] as String?,
      courierVehicle: map['courierVehicle'] as String?,
      preferredVehicle: map['preferredVehicle'] as String?,
      packageSize: map['packageSize'] as String,
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 1,
      itemQuantities: map['itemQuantities'] != null
          ? (map['itemQuantities'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : {map['packageSize'] as String? ?? AppConstants.sizeDocument: (map['itemCount'] as num?)?.toInt() ?? 1},
      totalWeightKg: (map['totalWeightKg'] as num?)?.toDouble() ?? 0.5,
      totalVolumeLiters: (map['totalVolumeLiters'] as num?)?.toDouble() ?? 2.0,
      recommendedVehicle: map['recommendedVehicle'] as String? ?? AppConstants.vehicleMotorcycle,
      contentType: map['contentType'] as String,
      customDescription: map['customDescription'] as String,
      isFragile: map['isFragile'] as bool? ?? false,
      requiresThermalBag: map['requiresThermalBag'] as bool? ?? false,
      pickupTitle: map['pickupTitle'] as String,
      pickupAddressDetail: map['pickupAddressDetail'] as String,
      pickupLat: (map['pickupLat'] as num).toDouble(),
      pickupLng: (map['pickupLng'] as num).toDouble(),
      dropoffTitle: map['dropoffTitle'] as String,
      dropoffAddressDetail: map['dropoffAddressDetail'] as String,
      dropoffLat: (map['dropoffLat'] as num).toDouble(),
      dropoffLng: (map['dropoffLng'] as num).toDouble(),
      distanceKm: (map['distanceKm'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      deliveryOtpCode: map['deliveryOtpCode'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as String,
      deliveredAt: map['deliveredAt'] as String?,
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? courierId,
    String? courierName,
    String? courierVehicle,
    String? preferredVehicle,
    String? packageSize,
    int? itemCount,
    Map<String, int>? itemQuantities,
    double? totalWeightKg,
    double? totalVolumeLiters,
    String? recommendedVehicle,
    String? contentType,
    String? customDescription,
    bool? isFragile,
    bool? requiresThermalBag,
    String? pickupTitle,
    String? pickupAddressDetail,
    double? pickupLat,
    double? pickupLng,
    String? dropoffTitle,
    String? dropoffAddressDetail,
    double? dropoffLat,
    double? dropoffLng,
    double? distanceKm,
    double? price,
    String? deliveryOtpCode,
    String? status,
    String? createdAt,
    String? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
      courierVehicle: courierVehicle ?? this.courierVehicle,
      preferredVehicle: preferredVehicle ?? this.preferredVehicle,
      packageSize: packageSize ?? this.packageSize,
      itemCount: itemCount ?? this.itemCount,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      totalVolumeLiters: totalVolumeLiters ?? this.totalVolumeLiters,
      recommendedVehicle: recommendedVehicle ?? this.recommendedVehicle,
      contentType: contentType ?? this.contentType,
      customDescription: customDescription ?? this.customDescription,
      isFragile: isFragile ?? this.isFragile,
      requiresThermalBag: requiresThermalBag ?? this.requiresThermalBag,
      pickupTitle: pickupTitle ?? this.pickupTitle,
      pickupAddressDetail: pickupAddressDetail ?? this.pickupAddressDetail,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffTitle: dropoffTitle ?? this.dropoffTitle,
      dropoffAddressDetail: dropoffAddressDetail ?? this.dropoffAddressDetail,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      distanceKm: distanceKm ?? this.distanceKm,
      price: price ?? this.price,
      deliveryOtpCode: deliveryOtpCode ?? this.deliveryOtpCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
