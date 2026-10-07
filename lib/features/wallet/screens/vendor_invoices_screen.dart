import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';

class VendorInvoicesScreen extends StatefulWidget {
  const VendorInvoicesScreen({super.key});
  @override
  State<VendorInvoicesScreen> createState() => _VendorInvoicesState();
}

class _VendorInvoicesState extends State<VendorInvoicesScreen> {
  Map<String, dynamic>? data;
  String? error;
  bool loading = true;
  int page = 1;
  String tr(String key) => financeText(context, key);
  String money(dynamic v) => financeMoney(context, v);
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final r = await VendorWorkspace.instance.client
          .get('/api/v3/seller/invoices', queryParameters: {'page': page});
      if (mounted)
        setState(() {
          data = Map<String, dynamic>.from(r.data);
          error = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void open(Map item) {
    final ref = '${item['order_reference']}';
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
                orderId: int.tryParse(ref),
                accessToken: int.tryParse(ref) == null ? ref : null)));
  }

  @override
  Widget build(BuildContext context) {
    final summary = data?['summary'] as Map? ?? {};
    final records = data?['records'] as Map? ?? {};
    return Scaffold(
        appBar: VendorFinanceAppBar(title: tr('vendor_invoices')),
        body: loading && data == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () {
                  page = 1;
                  return load();
                },
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(tr('sales_invoices_hint')),
                              if (error != null)
                                Text(error!,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              if (data != null) ...[
                                const SizedBox(height: 20),
                                FinancePanel(
                                    title: tr('total_invoice_receivables'),
                                    amount: money(summary['total_receivables']),
                                    hint:
                                        '${tr('already_settled')}: ${money(summary['settled_total'])}'),
                                const SizedBox(height: 12),
                                FinancePanel(
                                    title: tr('nearest_entitlement_date'),
                                    amount: financeDate(
                                        context, summary['next_due_at']),
                                    hint:
                                        '${tr('due_on_nearest_date')}: ${money(summary['next_due_amount'])}'),
                                const SizedBox(height: 24),
                                for (final raw in records['data'] as List? ?? [])
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: FinancePanel(
                                          title: raw['locked'] == true
                                              ? '***${raw['order_number_suffix']}'
                                              : '${tr('sales_invoice_number')} #${raw['invoice_number']}',
                                          amount: money(raw['locked'] == true
                                              ? raw['order_amount']
                                              : raw['receivable']),
                                          hint: raw['locked'] == true
                                              ? '${tr('security_deposit_required')}: ${money(raw['security_deposit_amount'])}'
                                              : '${financeDate(context, raw['due_at'])} · ${tr('settlement_${raw['status']}')}',
                                          child: OutlinedButton.icon(
                                              onPressed: () => open(raw),
                                              icon: Icon(raw['locked'] == true
                                                  ? Icons.lock_outline
                                                  : Icons
                                                      .receipt_long_outlined),
                                              label: Text(tr(
                                                  raw['locked'] == true ? 'pay_security_deposit' : 'view_order'))))),
                                if ((records['data'] as List? ?? []).isEmpty)
                                  Text(tr('no_data_found')),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                          onPressed: page > 1 && !loading
                                              ? () {
                                                  page--;
                                                  load();
                                                }
                                              : null,
                                          child: Text(tr('previous'))),
                                      Text(
                                          '$page / ${records['last_page'] ?? 1}'),
                                      TextButton(
                                          onPressed: page <
                                                      (records['last_page'] ??
                                                          1) &&
                                                  !loading
                                              ? () {
                                                  page++;
                                                  load();
                                                }
                                              : null,
                                          child: Text(tr('next')))
                                    ])
                              ]
                            ])))));
  }
}
