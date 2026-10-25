import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import 'delivery_confirmation_service.dart';
import 'hive_database_service.dart';

/// Sipariş Durum Yönetim ve Yaşam Döngüsü Servisi (State Machine)
class OrderStatusService {
  static final OrderStatusService _instance = OrderStatusService._internal();
  factory OrderStatusService() => _instance;
  OrderStatusService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();
  final DeliveryConfirmationService _deliveryConfirmation = DeliveryConfirmationService();

  OrderModel _getOrderOrThrow(String orderId) {
    final raw = _db.ordersBox.get(orderId);
    if (raw == null) {
      throw AppException(code: 'ORDER_NOT_FOUND', message: 'Sipariş bulunamadı.');
    }
    return OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Kuryenin siparişi kabul etmesi
  Future<void> assignCourierToOrder({
    required String orderId,
    required String courierId,
    required String courierName,
    String? courierVehicle,
  }) async {
    final order = _getOrderOrThrow(orderId);

    if (order.status != AppConstants.statusWaiting) {
      throw AppException.orderAlreadyTaken();
    }

    final updated = order.copyWith(
      status: AppConstants.statusAssigned,
      courierId: courierId,
      courierName: courierName,
      courierVehicle: courierVehicle,
    );

    await _db.ordersBox.put(orderId, updated.toMap());
  }

  /// Kuryenin paketi müşteriden teslim alması (COURIER_ASSIGNED -> IN_TRANSIT)
  Future<void> markAsPickedUp(String orderId) async {
    final order = _getOrderOrThrow(orderId);

    if (order.status != AppConstants.statusAssigned) {
      throw AppException.invalidStateTransition(order.status, AppConstants.statusInTransit);
    }

    final updated = order.copyWith(
      status: AppConstants.statusInTransit,
    );

    await _db.ordersBox.put(orderId, updated.toMap());
  }

  /// OTP doğrulayarak teslimatı tamamlama
  Future<bool> verifyOtpAndDeliver({
    required String orderId,
    required String enteredOtp,
  }) async {
    final result = await _deliveryConfirmation.verifyOtpAndCompleteOrder(
      orderId: orderId,
      enteredOtp: enteredOtp,
    );
    return result.success;
  }

  /// Henüz kurye atanmamış siparişi iptal etme (WAITING_FOR_COURIER -> CANCELLED)
  Future<void> cancelOrder(String orderId) async {
    final order = _getOrderOrThrow(orderId);

    if (order.status != AppConstants.statusWaiting) {
      throw AppException(
        code: 'CANNOT_CANCEL_ORDER',
        message: 'Kurye tarafından kabul edilmiş veya yola çıkmış siparişler iptal edilemez.',
      );
    }

    final updated = order.copyWith(
      status: AppConstants.statusCancelled,
    );

    await _db.ordersBox.put(orderId, updated.toMap());
  }
}
