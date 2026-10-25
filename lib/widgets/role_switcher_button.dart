import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';

/// Müşteri <-> Kurye arasında tek tıkla geçiş sağlayan dinamik buton
class RoleSwitcherButton extends StatelessWidget {
  final VoidCallback onRoleSwitched;

  const RoleSwitcherButton({
    super.key,
    required this.onRoleSwitched,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    final activeRole = session.getActiveRole();
    final isCustomer = activeRole == AppConstants.roleCustomer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        await session.switchRole();
        onRoleSwitched();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCustomer
              ? (isDark ? const Color(0xFF1E2E22) : const Color(0xFFE2F3E7))
              : (isDark ? const Color(0xFF332014) : const Color(0xFFFDEEE3)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCustomer
                ? (isDark ? RouteDuckTheme.emeraldGreen.withValues(alpha: 0.6) : RouteDuckTheme.deepForest)
                : (isDark ? RouteDuckTheme.peachAmber.withValues(alpha: 0.6) : const Color(0xFFD97706)),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCustomer ? Icons.person_rounded : Icons.two_wheeler_rounded,
              size: 16,
              color: isCustomer
                  ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                  : (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)),
            ),
            const SizedBox(width: 6),
            Text(
              isCustomer ? 'Müşteri Modu' : 'Kurye Modu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isCustomer
                    ? (isDark ? RouteDuckTheme.emeraldGreen : RouteDuckTheme.deepForest)
                    : (isDark ? RouteDuckTheme.peachAmber : const Color(0xFFD97706)),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: isDark ? RouteDuckTheme.darkTextSecondary : RouteDuckTheme.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
