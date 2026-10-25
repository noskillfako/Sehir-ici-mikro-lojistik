import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/order_model.dart';
import 'hive_database_service.dart';

/// Sipariş Takip ve Canlı İzleme Servisi
class OrderTrackingService {
  static final OrderTrackingService _instance = OrderTrackingService._internal();
  factory OrderTrackingService() => _instance;
  OrderTrackingService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();

  /// Arayüzün ValueListenableBuilder ile anlık reaktif güncellenmesi için
  ValueListenable<Box> listenToOrdersBox() {
    return _db.listenOrdersBox();
  }

  /// Tek sipariş detayı
  OrderModel? getOrderById(String orderId) {
    final raw = _db.ordersBox.get(orderId);
    if (raw == null) return null;
    return OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Müşterinin aktif (devam eden) siparişleri
  List<OrderModel> getCustomerActiveOrders(String customerId) {
    final list = <OrderModel>[];
    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.customerId == customerId &&
            (order.status == AppConstants.statusWaiting ||
             order.status == AppConstants.statusAssigned ||
             order.status == AppConstants.statusInTransit)) {
          list.add(order);
        }
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Müşterinin tamamlanmış veya iptal edilmiş geçmiş siparişleri
  List<OrderModel> getCustomerPastOrders(String customerId) {
    final list = <OrderModel>[];
    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.customerId == customerId &&
            (order.status == AppConstants.statusDelivered ||
             order.status == AppConstants.statusCancelled)) {
          list.add(order);
        }
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Kuryenin o anki aktif görevi (Varsa 1 adet, tek görev kilidi)
  OrderModel? getCourierCurrentTask(String courierId) {
    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.courierId == courierId &&
            (order.status == AppConstants.statusAssigned ||
             order.status == AppConstants.statusInTransit)) {
          return order;
        }
      }
    }
    return null;
  }

  /// Kuryenin başarıyla tamamladığı geçmiş teslimatlar
  List<OrderModel> getCourierCompletedOrders(String courierId) {
    final list = <OrderModel>[];
    for (var key in _db.ordersBox.keys) {
      final raw = _db.ordersBox.get(key);
      if (raw != null) {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
        if (order.courierId == courierId && order.status == AppConstants.statusDelivered) {
          list.add(order);
        }
      }
    }
    list.sort((a, b) => (b.deliveredAt ?? b.createdAt).compareTo(a.deliveredAt ?? a.createdAt));
    return list;
  }
}
