import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_debt_panel.dart';

void main() {
  for (final width in [360.0, 768.0]) {
    testWidgets('debt and deposit receipt remain readable at $width', (tester) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: VendorDebtPanel(
        debt: {'outstanding_debt': '20', 'charges': [{'reference': 'DEBT-9', 'kind': 'additional_slot', 'amount': '80', 'outstanding': '20'}]},
        deposits: [{'id': 12, 'debt_allocation': {'gross_amount': '100', 'debt_recovered': '60', 'net_wallet_credit': '40', 'remaining_debt': '20', 'references': [{'charge_id': 9, 'amount': '60'}]}}, {'id': 11}],
      )))));
      expect(find.text('الدين القائم: 20.00 ج.م'), findsOneWidget);
      expect(find.text('توزيع الإيداع DEP-11'), findsNothing);
      await tester.tap(find.text('توزيع الإيداع DEP-12'));
      await tester.pumpAndSettle();
      expect(find.text('إجمالي الإيداع: 100.00 ج.م'), findsOneWidget);
      expect(find.text('الدين المسدد: 60.00 ج.م'), findsOneWidget);
      expect(find.text('صافي المدفوعات المضاف: 40.00 ج.م'), findsOneWidget);
      expect(find.text('DEBT-9: 60.00 ج.م'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('preview uses net spendable credit and never negative credit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VendorDebtDepositPreview(debt: '150', grossInput: '100'))));
    expect(find.text('سداد دين متوقع: 100.00 ج.م'), findsOneWidget);
    expect(find.text('صافي مدفوعات متوقع: 0.00 ج.م'), findsOneWidget);
  });
  testWidgets('reversed receipt retains its audit label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DepositAllocationDetails(allocation: {'reversed_at': '2026-11-06'}))));
    expect(find.text('عُكس هذا الإيداع مع الاحتفاظ بالسجل.'), findsOneWidget);
  });
}
