import 'package:flutter/material.dart';

/// Shared visual foundation for the Sigma customer and vendor applications.
/// Feature screens should use these tokens instead of introducing ad-hoc values.
abstract final class AppDesign {
  static const Color primary = Color(0xFF1A428A);
  static const Color primaryDark = Color(0xFF173A79);
  static const Color brandLight = Color(0xFF59C9FA);
  static const Color success = Color(0xFF11875D);
  static const Color warning = Color(0xFF825000);
  static const Color danger = Color(0xFFC62828);

  static const Color lightBackground = Color(0xFFF4F7FB);
  static const Color lightSurface = Colors.white;
  static const Color darkBackground = Color(0xFF081525);
  static const Color darkSurface = Color(0xFF102239);

  /// Accent for text, icons and outlines placed on the current surface.
  static Color foregroundAccent(Brightness brightness) =>
      brightness == Brightness.dark ? brandLight : primary;

  static const double radiusSmall = 10;
  static const double radiusMedium = 16;
  static const double radiusLarge = 16;

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static List<BoxShadow> softShadow(Brightness brightness) => [
        BoxShadow(
          color: Colors.black
              .withValues(alpha: brightness == Brightness.dark ? .16 : .055),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ];
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [brandLight, primary],
  );
}
