import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';


Color _primaryColor = AppDesign.primary;
Color _secondaryColor = const Color(0xFFF58300);

ThemeData light = ThemeData(
  fontFamily: 'Cairo',
  useMaterial3: true,
  primaryColor: _primaryColor,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: const Color(0xFF637083),
  disabledColor:  const Color(0xFF8290A2),
  canvasColor: const Color(0xFFFCFCFC),
  cardColor: const Color(0xFFFFFFFF),
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: AppDesign.lightBackground,
  dividerColor: const Color(0xFFE2E8F0),
  cardTheme: CardThemeData(
    color: AppDesign.lightSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppDesign.lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: AppDesign.primary, width: 1.5)),
    hintStyle: const TextStyle(color: Color(0xFF637083)),
    labelStyle: const TextStyle(color: Color(0xFF475569)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppDesign.lightSurface,
    indicatorColor: AppDesign.primary,
    iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? Colors.white : const Color(0xFF64748B))),
    labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
      color: states.contains(WidgetState.selected)
          ? AppDesign.primary
          : const Color(0xFF475569),
    )),
  ),

  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF222324)),  // Text color primary
    bodyMedium: const TextStyle(color: Color(0xFF334155)),
    bodySmall: const TextStyle(color: Color(0xFF637083)),
    headlineMedium: const TextStyle(color: Color(0xFF637083)),
    headlineLarge : const TextStyle(color: Color(0xFF334155)),
  ),


  colorScheme: ColorScheme.light(
    primary:  _primaryColor,  // Primary Color
    secondary:  _secondaryColor,  // Secondary Color
    error: const Color(0xFFFF5A5A),
    tertiary:  const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFFADC9F3),
    onTertiaryContainer:  const Color(0xFF04BB7B), // Success Color
    primaryContainer: const Color(0xFF9AECC6),
    secondaryContainer: const Color(0xFFF2F2F2),
    surface: const Color(0xFFFFFFFF),
    surfaceTint: const Color(0xFF0087FF),
    onPrimary: Colors.white,
    onSecondary: const Color(0xFFFC9926),
    outline: const Color(0xff5C8FFC), // Info Color / Pending color
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
