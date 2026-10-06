import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('saved dark appearance cannot override light mode', () async {
    SharedPreferences.setMockInitialValues({AppConstants.theme: true});
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(sharedPreferences: preferences);
    expect(controller.darkTheme, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.getBool(AppConstants.theme), isFalse);
    controller.toggleTheme();
    expect(controller.darkTheme, isFalse);
  });
  test('session starts in Arabic despite saved English', () async {
    SharedPreferences.setMockInitialValues({AppConstants.languageCode: 'en', AppConstants.countryCode: 'US'});
    final preferences = await SharedPreferences.getInstance();
    final controller = LocalizationController(sharedPreferences: preferences);
    expect(controller.locale.languageCode, 'ar');
    expect(controller.isLtr, isFalse);
    expect(controller.getCurrentLanguage(), 'ar');
    await Future<void>.delayed(Duration.zero);
    expect(preferences.getString(AppConstants.languageCode), 'ar');
  });
}
