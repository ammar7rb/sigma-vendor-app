import 'package:flutter/material.dart';

String debtMoney(dynamic value) => '${(double.tryParse('$value') ?? 0).toStringAsFixed(2)} ج.م';

class VendorDebtPanel extends StatelessWidget {
  final Map debt;
  final List deposits;
  const VendorDebtPanel({super.key, required this.debt, this.deposits = const []});

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Card(
    margin: const EdgeInsets.only(bottom: 20),
    child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('الديون وسدادها', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      Text('الدين القائم: ${debtMoney(debt['outstanding_debt'])}', style: const TextStyle(color: Color(0xFFB42318))),
      const SizedBox(height: 8),
      const Text('الإيداع المؤكد يسدد الدين الأقدم أولًا، ويضاف الباقي إلى رصيد المدفوعات. لا يخصم من مستحقات مبيعاتك.'),
      for (final charge in debt['charges'] as List? ?? []) ListTile(contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('${charge['reference']} — ${charge['kind'] == 'cancellation_penalty' ? 'غرامة إلغاء' : 'رسوم إعلان إضافي'}'),
        subtitle: Text('قيمة الرسم: ${debtMoney(charge['amount'])}\nالمتبقي: ${debtMoney(charge['outstanding'])}')),
      for (final deposit in deposits.where((row) => row is Map && row['debt_allocation'] is Map)) ExpansionTile(
        tilePadding: EdgeInsets.zero, title: Text('توزيع الإيداع DEP-${deposit['id']}'), children: [
          Align(alignment: Alignment.centerRight, child: DepositAllocationDetails(allocation: Map<String, dynamic>.from(deposit['debt_allocation']))),
        ]),
    ])),
  ));
}

class DepositAllocationDetails extends StatelessWidget {
  final Map<String, dynamic> allocation;
  const DepositAllocationDetails({super.key, required this.allocation});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('إجمالي الإيداع: ${debtMoney(allocation['gross_amount'])}'),
    Text('الدين المسدد: ${debtMoney(allocation['debt_recovered'])}'),
    Text('صافي المدفوعات المضاف: ${debtMoney(allocation['net_wallet_credit'])}'),
    Text('الدين المتبقي وقت التأكيد: ${debtMoney(allocation['remaining_debt'])}'),
    if (allocation['reversed_at'] != null) const Text('عُكس هذا الإيداع مع الاحتفاظ بالسجل.'),
    for (final reference in allocation['references'] as List? ?? []) Text('DEBT-${reference['charge_id']}: ${debtMoney(reference['amount'])}'),
  ]));
}

class VendorDebtDepositPreview extends StatelessWidget {
  final dynamic debt;
  final String grossInput;
  const VendorDebtDepositPreview({super.key, required this.debt, required this.grossInput});
  @override
  Widget build(BuildContext context) {
    final gross = (double.tryParse(grossInput) ?? 0).clamp(0, double.infinity);
    final outstanding = (double.tryParse('$debt') ?? 0).clamp(0, double.infinity);
    final recovered = gross < outstanding ? gross : outstanding;
    return Directionality(textDirection: TextDirection.rtl, child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('الدين القائم: ${debtMoney(outstanding)}'),
      Text('سداد دين متوقع: ${debtMoney(recovered)}'),
      Text('صافي مدفوعات متوقع: ${debtMoney(gross - recovered)}'),
      const Text('معاينة فقط؛ يعاد الحساب عند التأكيد. المبلغ المتاح للشراء هو الصافي بعد سداد الدين.'),
    ])));
  }
}
