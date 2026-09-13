import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

extension PaymentMethodLabelExtension on String? {
  String toPaymentMethodLabel(BuildContext context) {
    return getTranslated(this ?? '', context) ?? this ?? '';
  }
}
