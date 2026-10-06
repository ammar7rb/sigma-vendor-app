import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class ThemeController with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool get darkTheme => false;

  void toggleTheme() {
    // Vendor appearance stays light, including devices using dark mode.
    sharedPreferences?.setBool(AppConstants.theme, false);
  }

  void _loadCurrentTheme() async {
    await sharedPreferences?.setBool(AppConstants.theme, false);
  }
}
