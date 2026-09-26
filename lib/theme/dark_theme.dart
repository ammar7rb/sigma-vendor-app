import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';


Color _primaryColor = AppDesign.primary;
Color _secondaryColor = const Color(0xFFF58300);

ThemeData dark = ThemeData(
  fontFamily: 'Cairo',
  useMaterial3: true,
  primaryColor: _primaryColor,
  brightness: Brightness.dark,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  highlightColor: AppDesign.darkSurface,
  hintColor: const Color(0xFFAAB9CB),
  disabledColor: const Color(0xFF718198),
  cardColor: AppDesign.darkSurface,
  scaffoldBackgroundColor: AppDesign.darkBackground,
  dividerColor: const Color(0xFF24364D),
  cardTheme: CardThemeData(
    color: AppDesign.darkSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppDesign.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: Color(0xFF24364D))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: Color(0xFF24364D))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDesign.radiusMedium), borderSide: const BorderSide(color: AppDesign.brandLight, width: 1.5)),
    hintStyle: const TextStyle(color: Color(0xFFAAB9CB)),
    labelStyle: const TextStyle(color: Color(0xFFCBD6E3)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppDesign.brandLight),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppDesign.brandLight,
      side: const BorderSide(color: AppDesign.brandLight),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppDesign.darkSurface,
    indicatorColor: AppDesign.primary,
    iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? Colors.white : const Color(0xFF94A3B8))),
    labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
      color: states.contains(WidgetState.selected)
          ? const Color(0xFFE9EEF4)
          : const Color(0xFFB8C7D8),
    )),
  ),


  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE9EEF4)),  // Text color primary
    bodyMedium: TextStyle(color: Color(0xFFE9EEF4)), // Text color Secondary
    bodySmall: TextStyle(color: Color(0xFFB8C7D8)),
    headlineMedium: TextStyle(color: Color(0xFFB8C7D8)),
    headlineLarge : TextStyle(color: Color(0xFFDDE6F0)),
  ),


  colorScheme : ColorScheme.dark(
      primary: _primaryColor,  // Primary Color
      secondary: _secondaryColor,  // Secondary Color
      tertiary: const Color(0xFFFFBB38), // Warning Color
      tertiaryContainer: const Color(0xFF6C7A8E),
      onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
      primaryContainer: const Color(0xFF208458),
      secondaryContainer: const Color(0xFFF2F2F2),
      surface: AppDesign.darkSurface,
      outline: const Color(0xff5C8FFC), // Info Color / Pending color
      surfaceTint: const Color(0xff5C8FFC),
      onPrimary: const Color(0xFFF2F2F2),
      onSecondary: const Color(0xFFFC9926),
      error: const Color(0xFFFF4040), // Danger Color
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
