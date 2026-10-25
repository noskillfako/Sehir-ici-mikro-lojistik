import 'dart:math';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import 'hive_database_service.dart';

/// Teslimat Doğrulama Sonuç Modeli
class DeliveryResult {
  final bool success;
  final double courierEarnings;
  final String message;
  final OrderModel? order;

  const DeliveryResult({
    required this.success,
    required this.courierEarnings,
    required this.message,
    this.order,
  });
}

/// Güvenli Teslimat ve 4 Haneli OTP Doğrulama Servisi
class DeliveryConfirmationService {
  static final DeliveryConfirmationService _instance = DeliveryConfirmationService._internal();
  factory DeliveryConfirmationService() => _instance;
  DeliveryConfirmationService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();
  final Random _random = Random();

  /// 4 haneli rastgele OTP kodu üretir
  String generate4DigitOtp() {
    return (1000 + _random.nextInt(9000)).toString();
  }

  /// Sadece CUSTOMER rolüne açık olan OTP kodunu döndürür (Kurye arayüzünde doğrudan gösterilmez)
  String? getCustomerVisibleOtp({
    required String orderId,
    required String activeRole,
  }) {
    final raw = _db.ordersBox.get(orderId);
    if (raw == null) return null;
    final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));

    if (activeRole == AppConstants.roleCustomer) {
      return order.deliveryOtpCode;
    }
    return null;
  }

  /// Kuryenin girdiği 4 haneli kodu doğrular ve siparişi DELIVERED yapar
  Future<DeliveryResult> verifyOtpAndCompleteOrder({
    required String orderId,
    required String enteredOtp,
  }) async {
    final raw = _db.ordersBox.get(orderId);
    if (raw == null) {
      throw AppException(code: 'ORDER_NOT_FOUND', message: 'Sipariş bulunamadı.');
    }

    final order = OrderModel.fromMap(Map<String, dynamic>.from(raw as Map));

    // Ön Koşul: Sipariş mutlaka IN_TRANSIT (Yolda) durumunda olmalıdır
    if (order.status != AppConstants.statusInTransit) {
      throw AppException.invalidStateTransition(order.status, AppConstants.statusDelivered);
    }

    final cleanEntered = enteredOtp.trim();
    if (cleanEntered != order.deliveryOtpCode) {
      throw AppException.invalidOtp();
    }

    final now = DateTime.now().toIso8601String();
    final deliveredOrder = order.copyWith(
      status: AppConstants.statusDelivered,
      deliveredAt: now,
    );

    await _db.ordersBox.put(orderId, deliveredOrder.toMap());

    final earnings = deliveredOrder.courierEarnings;
    return DeliveryResult(
      success: true,
      courierEarnings: earnings,
      message: 'Teslimat başarıyla onaylandı! Kazancınız: ${earnings.toStringAsFixed(2)} TL',
      order: deliveredOrder,
    );
  }
}
