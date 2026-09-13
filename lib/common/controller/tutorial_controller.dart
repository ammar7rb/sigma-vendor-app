import 'package:flutter/foundation.dart';

class TutorialController extends ChangeNotifier {
  bool _isVisible = true;
  bool get isVisible => _isVisible;

  void setVisibility(bool isVisible, {bool isUpdate = true}) {
    _isVisible = isVisible;
    if(isUpdate) {
      notifyListeners();
    }
  }
}