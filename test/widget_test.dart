import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/helper/egypt_location_helper.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

void main() {
  test(
      'seller registration always exits loading and accepts current API errors',
      () {
    final controller =
        File('lib/features/auth/controllers/auth_controller.dart')
            .readAsStringSync();
    final screen = File('lib/features/auth/screens/registration_screen.dart')
        .readAsStringSync();

    expect(controller, contains('_registrationErrorMessage(response)'));
    expect(controller,
        contains("final message = data['message'] ?? data['error']"));
    expect(controller, contains('_isLoading = false;'));
    expect(controller, contains('policies is List'));
    expect(
        screen,
        contains(
            "final reference = '\${data['registration_reference'] ?? ''}'.trim()"));
    expect(screen, contains('.catchError((_)'));
    final repository =
        File('lib/features/auth/domain/repositories/auth_repository.dart')
            .readAsStringSync();
    expect(repository, isNot(contains('request.fields}')),
        reason: 'Registration must never log password-bearing form fields');
  });

  test('vendor profile exposes a logout action', () {
    final profile =
        File('lib/features/profile/widgets/theme_changer_widget.dart')
            .readAsStringSync();
    final logout = profile.indexOf("title: 'logout'");
    expect(logout, greaterThanOrEqualTo(0));
    expect(profile, contains('SignOutConfirmationDialogWidget()'));
  });

  test('vendor splash includes the same animated loading cue as customer app',
      () {
    final splash = File('lib/features/splash/screens/splash_screen.dart')
        .readAsStringSync();
    expect(splash, contains('LinearProgressIndicator'));
    expect(splash, contains('FadeTransition'));
  });

  test('vendor dashboard actions use seller flows without POS overlays', () {
    final dashboard =
        File('lib/features/dashboard/screens/dashboard_screen.dart')
            .readAsStringSync();
    final overview =
        File('lib/features/home/widgets/seller_dashboard_overview_widget.dart')
            .readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(dashboard, isNot(contains('PosScreen(fromMenu: true)')));
    expect(dashboard, isNot(contains('FloatingActionButton.extended')));
    expect(
        File('lib/features/profile/widgets/vendor_navigation_actions.dart')
            .readAsStringSync(),
        contains('AddProductTabView'));
    expect(overview, contains('const ProductListMenuScreen()'));
    expect(dashboard, contains('const OrderScreen()'));
    expect(
        File('lib/features/menu/widgets/vendor_menu_widget.dart')
            .readAsStringSync(),
        contains('VendorInvoicesScreen'));
    expect(overview, isNot(contains('VendorInvoicesScreen')));
    expect(mainSource, contains('if (_showSetupGuideOverlay() &&'));
    expect(mainSource, contains('bool _showSetupGuideOverlay() => false;'));
  });

  test('seller deposits expose responsive wallet and InstaPay channels', () {
    final funding =
        File('lib/features/wallet/screens/seller_balance_funding_screen.dart')
            .readAsStringSync();
    expect(funding, contains("channel == 'wallet'"));
    expect(funding, contains("channel == 'instapay'"));
    expect(funding, contains('constraints.maxWidth < 420'));
    expect(funding, contains('method.methodFields'));
    expect(funding, contains('/api/v3/seller/balance/offline-payment'));
    expect(funding, contains('request_key'));
    expect(funding, contains('transfer_reference'));
    expect(funding, contains('5 * 1024 * 1024'));
  });

  test('mobile environment and Egypt-only location contract are valid', () {
    expect(AppConstants.baseUrl, isNotEmpty);
    expect(
        EgyptLocationHelper.contains(const LatLng(30.0444, 31.2357)), isTrue);
    expect(
        EgyptLocationHelper.contains(const LatLng(23.5880, 58.3829)), isFalse);
    expect(EgyptLocationHelper.normalize(const LatLng(23.5880, 58.3829)),
        EgyptLocationHelper.center);
  });

  test('wallet presentation keeps financial tabs from the same payload', () {
    final balance = SellerBalanceModel.fromJson({
      'financial_summary': {'available': '100'},
      'financial_records': [],
      'financial_tabs': {
        'shipping': [
          {
            'bucket': 'available',
            'direction': 'credit',
            'amount': '20',
            'shipment_reference': 'SHP-1'
          },
        ],
      },
      'deposits': [],
      'settlements': {},
      'funding_settings': {},
    });

    expect(balance.summary['available'], 100);
    expect(
        balance.financialTabs['shipping']?.single.shipmentReference, 'SHP-1');
  });
}
