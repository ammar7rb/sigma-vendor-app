import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production startup and dashboard do not depend on preview-only code',
      () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final dashboard =
        File('lib/features/dashboard/screens/dashboard_screen.dart')
            .readAsStringSync();
    final home = File('lib/features/home/screens/home_page_screen.dart')
        .readAsStringSync();
    expect(mainSource, contains('if (!kIsWeb)'));
    expect(dashboard, contains('HomePageScreen'));
    expect(dashboard, isNot(contains('SellerDashboardOverviewWidget')));
    expect(home, contains('SellerDashboardOverviewWidget'));
    expect(dashboard, isNot(contains('vendor-stage1-preview')));
    expect(home, isNot(contains('vendor-stage1-preview')));
  });

  test('shipping dispute action is last and uses warning styling', () {
    final source = File(
            'lib/features/order_details/widgets/seller_shipping_assignment_widget.dart')
        .readAsStringSync();
    final action = source.lastIndexOf("tr('shipping_due_support_action')");
    final history = source.indexOf("tr('seller_journey_proof_history')");
    expect(action, greaterThan(history));
    expect(source, contains('foregroundColor: AppDesign.warning'));
    expect(source, contains('width: double.infinity'));
  });

  test('seller due balance is named accurately across vendor surfaces', () {
    for (final path in [
      'lib/features/home/widgets/seller_dashboard_overview_widget.dart',
      'lib/features/wallet/screens/seller_finance_screen.dart',
      'lib/features/profile/screens/seller_profile_screen.dart',
    ]) {
      expect(File(path).readAsStringSync(), contains('seller_due_balance'));
    }
    final ar = jsonDecode(File('assets/language/ar.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(ar['seller_due_balance'], 'الرصيد المستحق');
  });

  test('phase previews remove order-detail floating action and shipping note',
      () {
    final phase3 =
        File('E:/xampp/htdocs/ba/public/vendor-stage1-preview/phase3.html')
            .readAsStringSync();
    final details = phase3.substring(
        phase3.indexOf('const details='), phase3.indexOf('const support='));
    expect(details, isNot(contains(r'${floating}')));
    expect(phase3, contains('اعتراض على الطلب أو تقديم بلاغ'));
    final phase6 =
        File('E:/xampp/htdocs/ba/public/vendor-stage1-preview/phase6.html')
            .readAsStringSync();
    expect(phase6, isNot(contains('إعدادات الشحن تدار من المنصة')));
    expect(phase6, contains('الرصيد المستحق'));
  });

  test('phase seven responsive breakpoints cover phone and tablet', () {
    final menu = File('lib/features/menu/widgets/vendor_menu_widget.dart')
        .readAsStringSync();
    final profile =
        File('lib/features/profile/screens/seller_profile_screen.dart')
            .readAsStringSync();
    expect(menu, contains('constraints.maxWidth >= 700'));
    expect(profile, contains('constraints.maxWidth >= 700'));
  });

  test('dashboard balance cards open their matching records', () {
    final dashboard =
        File('lib/features/home/widgets/seller_dashboard_overview_widget.dart')
            .readAsStringSync();
    final finance =
        File('lib/features/wallet/screens/seller_finance_screen.dart')
            .readAsStringSync();
    for (final key in [
      'seller_purchase_balance_total',
      'seller_due_balance_total',
      'seller_insurance_balance_total',
      'seller_shipping_due_total',
    ]) {
      expect(dashboard, contains(key));
    }
    for (final section in ['balance', 'orders', 'insurance', 'shipping']) {
      expect(dashboard, contains("openFinance('$section')"));
    }
    expect(finance, contains('initialSection'));
    expect(finance, contains("('balance', 'finance_purchase_records')"));
  });

  test('dashboard separates cumulative sales from due balances', () {
    final dashboard =
        File('lib/features/home/widgets/seller_dashboard_overview_widget.dart')
            .readAsStringSync();
    expect(dashboard, contains('seller_wallet_total'));
    expect(dashboard, contains("sales['total_amount']"));
    expect(dashboard, contains("balances['pending_from_platform']"));
    expect(dashboard.indexOf('seller_wallet_total'),
        lessThan(dashboard.indexOf('total_sales')));
  });

  test('purchase and insurance wallets have independent funding targets', () {
    final funding =
        File('lib/features/wallet/screens/seller_balance_funding_screen.dart')
            .readAsStringSync();
    final dashboard =
        File('lib/features/home/widgets/seller_dashboard_overview_widget.dart')
            .readAsStringSync();
    final repository =
        File('lib/features/wallet/domain/repositories/wallet_repository.dart')
            .readAsStringSync();
    expect(dashboard, contains("walletTarget: 'insurance'"));
    expect(funding, contains('walletTarget: widget.walletTarget'));
    expect(repository, contains("'wallet_target': walletTarget"));
  });

  test('finance records expose shipping and insurance availability dates', () {
    final finance =
        File('lib/features/wallet/screens/seller_finance_screen.dart')
            .readAsStringSync();
    expect(finance, contains("row['shipping_due_at']"));
    expect(finance, contains("row['seller_insurance_reuse_at']"));
  });

  test('home header exposes language switch beside notifications', () {
    final home = File('lib/features/home/screens/home_page_screen.dart')
        .readAsStringSync();
    expect(home, contains('PopupMenuButton<int>'));
    expect(home, contains('Icons.translate_rounded'));
    expect(home.indexOf('Icons.translate_rounded'),
        lessThan(home.indexOf('CupertinoIcons.bell')));
  });

  test('vendor navigation uses unified vector icons', () {
    final dashboard =
        File('lib/features/dashboard/screens/dashboard_screen.dart')
            .readAsStringSync();
    expect(dashboard, contains('Icons.home_outlined'));
    expect(dashboard, contains('Icons.receipt_long_outlined'));
    expect(dashboard, isNot(contains('child: Image.asset(icon')));
  });
}
