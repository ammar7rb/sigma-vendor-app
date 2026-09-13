import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vendor menu hides removed legacy modules and exposes core tools', () {
    final menu = File('lib/features/menu/widgets/vendor_menu_widget.dart')
        .readAsStringSync();
    expect(menu, isNot(contains('ShopScreen')));
    expect(menu, isNot(contains('ClearanceSaleScreen')));
    expect(menu, isNot(contains('VatManagementScreen')));
    expect(menu, isNot(contains('RestockListScreen')));
    expect(menu, contains('WalletScreen'));
    expect(menu, contains('SellerBankInfoScreen'));
    expect(menu, contains('RefundScreen'));
    expect(menu, contains("'refund_requests'"));
  });

  test('bottom navigation has three destinations and refund lives in menu', () {
    final dashboard =
        File('lib/features/dashboard/screens/dashboard_screen.dart')
            .readAsStringSync();
    expect(dashboard, contains('List.generate(3'));
    expect(dashboard, isNot(contains('RefundScreen')));
    expect(dashboard, isNot(contains('Icons.assignment_return_outlined')));
  });

  test('refund details hide customer and delivery-person information', () {
    final details =
        File('lib/features/refund/widgets/refund_details_widget.dart')
            .readAsStringSync();
    expect(details, isNot(contains('CustomerInfoWidget')));
    expect(details, isNot(contains('DeliveryManInfoWidget')));
    expect(details, isNot(contains('Customer not found')));
  });

  test('seller profile exposes products orders wallet insurance and bank', () {
    final profile =
        File('lib/features/profile/screens/seller_profile_screen.dart')
            .readAsStringSync();
    for (final value in [
      'ProductListMenuScreen',
      'OrderScreen',
      'WalletScreen',
      "balances['order_insurance_credit']",
      'SellerBankInfoScreen'
    ]) {
      expect(profile, contains(value));
    }
  });

  test('vendor settings have language and theme but no shipping selector', () {
    final settings = File('lib/features/settings/screens/setting_screen.dart')
        .readAsStringSync();
    expect(settings, contains('ChooseLanguageScreen'));
    expect(settings, contains('ThemeChangerWidget'));
    expect(settings, isNot(contains('ChooseShippingDialogWidget')));
  });

  test('only Arabic and English languages remain', () {
    final constants = File('lib/utill/app_constants.dart').readAsStringSync();
    expect(
        RegExp(r'LanguageModel\(')
            .allMatches(constants.substring(
                constants.indexOf('static List<LanguageModel> languages')))
            .take(5)
            .length,
        greaterThanOrEqualTo(2));
    expect(constants, isNot(contains("languageCode: 'hi'")));
    expect(constants, isNot(contains("languageCode: 'bn'")));
    expect(constants, isNot(contains("languageCode: 'es'")));
  });

  test('bank information handles loading and null response safely', () {
    final bank =
        File('lib/features/bank_info/screens/seller_bank_info_screen.dart')
            .readAsStringSync();
    expect(bank, contains('if (loading && info == null)'));
    expect(bank, contains('if (info == null)'));
    expect(bank, contains('getBankInfo(context)'));
  });

  test('Arabic and English translation files stay valid', () {
    for (final path in ['assets/language/ar.json', 'assets/language/en.json']) {
      expect(jsonDecode(File(path).readAsStringSync()),
          isA<Map<String, dynamic>>());
    }
  });
}
