import 'package:flutter/material.dart';

/// Brand palette: growth (teal) + money (amber), used for gradients and accents.
abstract final class AppColors {
  static const Color growth = Color(0xFF0D9488);
  static const Color growthDark = Color(0xFF0F766E);
  static const Color growthLight = Color(0xFF5EEAD4);

  static const Color money = Color(0xFFF59E0B);
  static const Color moneyDeep = Color(0xFFD97706);

  static const Color slateBg = Color(0xFFF8FAFC);
  static const Color slateCard = Color(0xFFFFFFFF);

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F766E),
      Color(0xFF0D9488),
      Color(0xFF14B8A6),
    ],
  );

  static const LinearGradient authGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE0F2F1),
      Color(0xFFF8FAFC),
      Color(0xFFFFFFFF),
    ],
  );
}
