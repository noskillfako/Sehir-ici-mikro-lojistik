import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// RouteDuck Marka Logosu Widget'ı
/// "Route" (R harfi büyük) ve "Duck" (kullanıcının görselindeki özel #EDA45F renginde)
class RouteDuckLogo extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final String? suffix;
  final TextStyle? suffixStyle;
  final Color? routeColor;
  final Color duckColor;

  const RouteDuckLogo({
    super.key,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = -0.5,
    this.suffix,
    this.suffixStyle,
    this.routeColor,
    this.duckColor = const Color(0xFFEDA45F), // Kullanıcının görselindeki özel renk (#EDA45F)
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultRouteColor = routeColor ??
        (isDark ? RouteDuckTheme.darkTextPrimary : RouteDuckTheme.lightTextPrimary);

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          color: defaultRouteColor,
        ),
        children: [
          const TextSpan(text: 'Route'),
          TextSpan(
            text: 'Duck',
            style: TextStyle(
              color: duckColor,
              fontWeight: fontWeight,
            ),
          ),
          if (suffix != null)
            TextSpan(
              text: suffix!,
              style: suffixStyle ??
                  TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.w700,
                    color: defaultRouteColor,
                  ),
            ),
        ],
      ),
    );
  }
}
