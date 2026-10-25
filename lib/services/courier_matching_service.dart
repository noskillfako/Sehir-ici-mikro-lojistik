import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'hive_database_service.dart';

/// Kurye Eşleştirme ve Sipariş Havuzu Filtreleme Servisi
class CourierMatchingService {
  static final CourierMatchingService _instance = CourierMatchingService._internal();
  factory CourierMatchingService() => _instance;
  CourierMatchingService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();

  /// Siparişin kuryenin araç tipi ve ekipmanına uygun olup olmadığını denetler
  bool isOrderCompatibleWithCourier({
    required OrderModel order,
    required UserModel courier,
  }) {
    final vehicle = courier.vehicleType ?? AppConstants.vehicleMotorcycle;

    // 1. Müşterinin Özel Araç Tercihi Varsa
    if (order.preferredVehicle != null && order.preferredVehicle!.isNotEmpty) {
      if (vehicle != order.preferredVehicle) {
        return false;
      }
    }

    // 2. Gerçek Dünya Kapasite ve Boyut Kontrolü (Ağırlık ve Hacim)
    final maxWeight = AppConstants.vehicleMaxCapacityKg[vehicle] ?? 20.0;
    final maxVolume = AppConstants.vehicleMaxCapacityLiters[vehicle] ?? 60.0;
    if (order.totalWeightKg > 0 && order.totalVolumeLiters > 0) {
      if (order.totalWeightKg > maxWeight || order.totalVolumeLiters > maxVolume) {
        return false;
      }
    } else {
      final allowedSizes = AppConstants.vehicleAllowedSizes[vehicle] ?? [AppConstants.sizeDocument];
      if (!allowedSizes.contains(order.packageSize)) {
        return false;
      }
    }

    // 3. Termal Çanta Kontrolü
    if (order.requiresThermalBag && !courier.hasThermalBag) {
      return false;
    }

    return true;
  }

  /// Kuryenin üzerinde atanmış veya taşınmakta olan aktif bir sipariş var mı?
  bool hasActiveOrder(String courierId) {
    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.courierId == courierId &&
            (order.status == AppConstants.statusAssigned ||
             order.status == AppConstants.statusInTransit)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Kurye için uygun sipariş havuzunu filtreler ve sıralar
  List<OrderModel> getFilteredOrderPool({
    required UserModel courier,
    String sortBy = 'NEWEST', // 'NEWEST', 'PRICE', 'DISTANCE'
  }) {
    final pool = <OrderModel>[];

    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.status == AppConstants.statusWaiting &&
            isOrderCompatibleWithCourier(order: order, courier: courier)) {
          pool.add(order);
        }
      }
    }

    // Sıralama
    if (sortBy == 'PRICE') {
      pool.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'DISTANCE') {
      pool.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else {
      // NEWEST
      pool.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return pool;
  }

  /// Kuryenin siparişi kabul etmesi
  Future<bool> matchCourierWithOrder({
    required String orderId,
    required UserModel courier,
  }) async {
    if (hasActiveOrder(courier.id)) {
      throw AppException.courierHasActiveOrder();
    }

    final raw = _db.ordersBox.get(orderId);
    if (raw == null) {
      throw AppException.orderAlreadyTaken();
    }

    final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));

    if (order.status != AppConstants.statusWaiting) {
      throw AppException.orderAlreadyTaken();
    }

    if (!isOrderCompatibleWithCourier(order: order, courier: courier)) {
      if (order.requiresThermalBag && !courier.hasThermalBag) {
        throw AppException.thermalBagRequired();
      }
      throw AppException.vehicleIncompatible();
    }

    final updatedOrder = order.copyWith(
      status: AppConstants.statusAssigned,
      courierId: courier.id,
      courierName: courier.fullName,
      courierVehicle: courier.vehicleType ?? AppConstants.vehicleMotorcycle,
    );

    await _db.ordersBox.put(orderId, updatedOrder.toMap());
    return true;
  }
}
