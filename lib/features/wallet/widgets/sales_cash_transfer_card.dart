import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

/// Moves settled sales into the cash (operating) balance using the server quote.
class SalesCashTransferCard extends StatefulWidget {
  final double availableDisplay;
  final VoidCallback onDone;
  const SalesCashTransferCard(
      {super.key, required this.availableDisplay, required this.onDone});

  @override
  State<SalesCashTransferCard> createState() => _SalesCashTransferCardState();
}

class _SalesCashTransferCardState extends State<SalesCashTransferCard> {
  final amount = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  bool get arabic => Localizations.localeOf(context).languageCode == 'ar';
  String t(String ar, String en) => arabic ? ar : en;

  Future<void> review() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0 || value > widget.availableDisplay) {
      setState(() => error = t('أدخل مبلغًا ضمن الرصيد المتاح',
          'Enter an amount within the available balance'));
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await VendorWorkspace.instance.client.get(
          '/api/v3/seller/balance/transfer-quote',
          queryParameters: {'amount': value.toStringAsFixed(2)});
      final data = Map<String, dynamic>.from(response.data as Map);
      final quote = Map<String, dynamic>.from(data['quote'] as Map);
      final display = Map<String, dynamic>.from(data['display'] as Map? ?? {});
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                  title: Text(t('تأكيد التحويل', 'Confirm transfer')),
                  content: Text(
                      '${t('المبلغ', 'Amount')}: ${display['amount'] ?? value}\n'
                      '${t('الرسوم', 'Fee')}: ${display['fee'] ?? quote['fee']}\n'
                      '${t('الصافي إلى الكاش', 'Net to cash')}: ${display['net'] ?? quote['net']}'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(t('إلغاء', 'Cancel'))),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(t('تحويل', 'Transfer')))
                  ]));
      if (confirmed != true || !mounted) return;
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/balance/transfer', data: {
        'amount': value.toStringAsFixed(2),
        'request_key': withdrawalRequestKey(),
        'quoted_amount': quote['amount'],
        'currency_code': data['currency_code'],
        'fee_type': quote['fee_type'],
        'fee_value': quote['fee_value'],
        'fee': quote['fee'],
      });
      if (!mounted) return;
      amount.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t('تم تحويل الحصيلة إلى رصيد الكاش',
              'Sales were transferred to the cash balance'))));
      widget.onDone();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t('تحويل حصيلة المبيعات إلى الكاش',
                    'Transfer sales to cash')),
                const SizedBox(height: 6),
                Text(t('يُخصم رسم تحدده الإدارة من المبلغ المحوّل.',
                    'An administration fee is deducted from the transfer.')),
                const SizedBox(height: 12),
                TextField(
                    controller: amount,
                    enabled: !busy,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: t('المبلغ', 'Amount'))),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))
                ],
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: busy || widget.availableDisplay <= 0
                        ? null
                        : review,
                    child: Text(busy
                        ? t('جارٍ الحساب', 'Calculating')
                        : t('مراجعة الرسوم والتحويل', 'Review the fee and transfer')))
              ])));
}
