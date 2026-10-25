import 'package:flutter/material.dart';
import '../core/errors/error_handler.dart';
import '../core/theme/app_theme.dart';
import '../models/order_model.dart';
import '../services/delivery_confirmation_service.dart';

/// Kuryenin 4 haneli teslimat kodunu girdiği güvenlik onay diyaloğu
class OtpVerificationDialog extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onDeliverySuccess;

  const OtpVerificationDialog({
    super.key,
    required this.order,
    required this.onDeliverySuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required OrderModel order,
    required VoidCallback onDeliverySuccess,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpVerificationDialog(
        order: order,
        onDeliverySuccess: onDeliverySuccess,
      ),
    );
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  final DeliveryConfirmationService _deliveryService = DeliveryConfirmationService();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitOtp() async {
    final entered = _otpController.text.trim();
    if (entered.length != 4) {
      ErrorHandler.showWarning(context, 'Lütfen 4 haneli teslimat kodunu eksiksiz girin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _deliveryService.verifyOtpAndCompleteOrder(
        orderId: widget.order.id,
        enteredOtp: entered,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      // Başarı kutlaması
      _showSuccessSheet(result.courierEarnings);
      widget.onDeliverySuccess();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet(double earnings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162319) : const Color(0xFFEDF6F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: RouteDuckTheme.emeraldGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Teslimat Başarıyla Tamamlandı!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sipariş başarıyla müşteriye teslim edildi ve kapatıldı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1A12) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RouteDuckTheme.emeraldGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bu Teslimattan Kazancınız:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '+${earnings.toStringAsFixed(2)} TL',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: RouteDuckTheme.emeraldGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RouteDuckTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Harika, Sipariş Havuzuna Dön'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? RouteDuckTheme.darkCard : RouteDuckTheme.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? RouteDuckTheme.darkBorder : RouteDuckTheme.lightBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: RouteDuckTheme.peachAmber, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Teslimat Onay Kodu',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Alıcı müşteriden aldığınız 4 haneli güvenlik kodunu girerek teslimatı onaylayın.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // OTP Giriş Alanı (4 Haneli Vurgulu Kasa)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFFF0E9DF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                autofocus: true,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 14.0,
                  color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309),
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  hintText: '••••',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    letterSpacing: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Demo Test Kolaylığı İpucu (Tek cihazda test için)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF22160F) : const Color(0xFFF7EFE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tips_and_updates_outlined, size: 13, color: RouteDuckTheme.peachAmber),
                  const SizedBox(width: 6),
                  Text(
                    '[Demo Test İpucu - Müşteri Kodu: ${widget.order.deliveryOtpCode}]',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? RouteDuckTheme.peachAmber : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Onay Butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? RouteDuckTheme.peachAmber : RouteDuckTheme.deepForest,
                foregroundColor: isDark ? const Color(0xFF120A05) : Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kodu Doğrula ve Teslim Et'),
            ),
          ],
        ),
      ),
    );
  }
}
