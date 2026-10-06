import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/localization/models/language_model.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class LocalizationController extends ChangeNotifier {
  final SharedPreferences? sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    _loadCurrentLanguage();
  }

  int? _languageIndex;
  Locale _locale = const Locale('ar', 'SA');
  bool _isLtr = false;
  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  int? get languageIndex => _languageIndex;
  List<LanguageModel> _languages = [];
  List<LanguageModel> get languages => _languages;


  void setLanguage(Locale locale, int index) {
    _locale = locale;
    _languageIndex = index;
    if(_locale.languageCode == 'ar') {
      _isLtr = false;
    }else {
      _isLtr = true;
    }
    _saveLanguage(_locale);
    Provider.of<AuthController>(Get.context!, listen: false).setCurrentLanguage(locale.languageCode);
    notifyListeners();
  }

  Future<void> _loadCurrentLanguage() async {
    // Every new session starts in Arabic; the in-app language selector remains available.
    _locale = const Locale('ar', 'SA');
    for(int index=0; index<AppConstants.languages.length; index++) {
      if(AppConstants.languages[index].languageCode == _locale.languageCode) {
        _languageIndex = index;
        break;
      }
    }
    _isLtr = _locale.languageCode != 'ar';
    _languages = [];
    _languages.addAll(AppConstants.languages);
    await _saveLanguage(_locale);
    notifyListeners();
  }

  Future<void> _saveLanguage(Locale locale) async {
    await sharedPreferences!.setString(AppConstants.languageCode, locale.languageCode);
    await sharedPreferences!.setString(AppConstants.countryCode, locale.countryCode!);
  }

  String? getCurrentLanguage() {
    return _locale.languageCode;
  }


}