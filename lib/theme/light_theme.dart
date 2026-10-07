import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

Color _primaryColor = AppDesign.primary;
Color _secondaryColor = AppDesign.primary;

ThemeData light = ThemeData(
  fontFamily: 'VendorCare',
  useMaterial3: true,
  primaryColor: _primaryColor,
  bottomSheetTheme:
      const BottomSheetThemeData(backgroundColor: Colors.transparent),
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: const Color(0xFF52627A),
  disabledColor: const Color(0xFF8290A2),
  canvasColor: const Color(0xFFFCFCFC),
  cardColor: const Color(0xFFFFFFFF),
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: AppDesign.lightBackground,
  dividerColor: const Color(0xFFDCE4F0),
  cardTheme: CardThemeData(
    color: AppDesign.lightSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppDesign.lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFDCE4F0))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFDCE4F0))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        borderSide: const BorderSide(color: AppDesign.primary, width: 1.5)),
    hintStyle: const TextStyle(color: Color(0xFF52627A)),
    labelStyle: const TextStyle(color: Color(0xFF475569)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppDesign.lightSurface,
    indicatorColor: AppDesign.primary,
    iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? Colors.white
            : const Color(0xFF64748B))),
    labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppDesign.primary
              : const Color(0xFF475569),
        )),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF172942)), // Text color primary
    bodyMedium: const TextStyle(color: Color(0xFF172942)),
    bodySmall: const TextStyle(color: Color(0xFF52627A)),
    headlineMedium: const TextStyle(color: Color(0xFF52627A)),
    headlineLarge: const TextStyle(color: Color(0xFF172942)),
  ),
  colorScheme: ColorScheme.light(
    primary: _primaryColor, // Primary Color
    secondary: _secondaryColor, // Secondary Color
    error: AppDesign.danger,
    tertiary: AppDesign.warning, // Warning Color
    tertiaryContainer: const Color(0xFFFFF4DC),
    onTertiaryContainer: AppDesign.success, // Success Color
    primaryContainer: const Color(0xFFEAF0FA),
    secondaryContainer: const Color(0xFFF4F7FB),
    surface: const Color(0xFFFFFFFF),
    surfaceTint: AppDesign.primary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    outline: const Color(0xFFDCE4F0), // Info Color / Pending color
  ),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
