import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_withdrawal_methods_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_balance_funding_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerFinanceScreen extends StatefulWidget {
  final bool fromNotification;
  final String initialSection;
  const SellerFinanceScreen(
      {super.key,
      this.fromNotification = false,
      this.initialSection = 'balance'});
  @override
  State<SellerFinanceScreen> createState() => _SellerFinanceState();
}

class _SellerFinanceState extends State<SellerFinanceScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? data;
  String? error;
  bool loading = false, submitting = false;
  int securityPage = 1,
      withdrawalsPage = 1,
      transactionsPage = 1,
      depositsPage = 1;
  int? methodId;
  final amount = TextEditingController();
  String requestKey = withdrawalRequestKey();
  String tr(String key) => financeText(context, key);
  String money(dynamic v) => financeMoney(context, v);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    amount.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load();
  }

  Future<void> load() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      final r = await VendorWorkspace.instance.client
          .get('/api/v3/seller/balance', queryParameters: {
        'transactions_page': transactionsPage,
        'deposits_page': depositsPage,
        'security_page': securityPage,
        'withdrawals_page': withdrawalsPage
      });
      if (mounted)
        setState(() {
          data = Map<String, dynamic>.from(r.data);
          error = null;
          final methods = data!['withdrawal_methods'] as List? ?? [];
          if (!methods.any((m) => m['id'] == methodId)) methodId = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> fund(String target) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SellerBalanceFundingScreen(walletTarget: target)));
    if (mounted) load();
  }

  Future<void> withdraw() async {
    final value = double.tryParse(amount.text);
    final available = double.tryParse(PriceConverter.convertPriceWithoutSymbol(
            context,
            double.tryParse('${data?['financial_summary']?['available']}') ??
                0)) ??
        0;
    if (methodId == null ||
        value == null ||
        !value.isFinite ||
        value <= 0 ||
        value > available) {
      setState(() => error = tr('invalid_withdraw_request'));
      return;
    }
    setState(() => submitting = true);
    try {
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/balance/withdraw', data: {
        'saved_method_id': methodId,
        'amount': value,
        'request_key': requestKey
      });
      if (!mounted) return;
      amount.clear();
      requestKey = withdrawalRequestKey();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('withdraw_request_submitted'))));
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> cancel(Map row) async {
    if (submitting) return;
    setState(() => submitting = true);
    try {
      await VendorWorkspace.instance.client.dio!.delete(
          '/api/v3/seller/close-withdraw-request',
          data: {'id': row['id']});
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Widget pager(
          Map records, int page, VoidCallback previous, VoidCallback next) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(
            onPressed: !loading && page > 1 ? previous : null,
            child: Text(tr('previous'))),
        Text('$page / ${records['last_page'] ?? 1}'),
        TextButton(
            onPressed:
                !loading && page < (records['last_page'] ?? 1) ? next : null,
            child: Text(tr('next')))
      ]);
  @override
  Widget build(BuildContext context) {
    final summary = data?['financial_summary'] as Map? ?? {};
    final transactions = data?['transactions'] as Map? ?? {};
    final security = data?['security_deposits'] as Map? ?? {};
    final totals = security['summary'] as Map? ?? {};
    final records = security['records'] as Map? ?? {};
    final deposits = data?['deposits'] as Map? ?? {};
    final withdrawals = data?['withdrawals'] as Map? ?? {};
    final methods = data?['withdrawal_methods'] as List? ?? [];
    return Scaffold(
        appBar: VendorFinanceAppBar(title: tr('finance_my_wallet')),
        body: loading && data == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (error != null)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(error!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error))),
                              if (data != null) ...[
                                FinancePanel(
                                    title: tr('available_balance'),
                                    amount: money(summary['available']),
                                    hint: tr('available_balance_hint'),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          DropdownButtonFormField<int>(
                                              initialValue: methodId,
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                  labelText: tr(
                                                      'selected_withdrawal_method')),
                                              items: methods
                                                  .map((m) => DropdownMenuItem<
                                                          int>(
                                                      value: m['id'],
                                                      child: Text(
                                                          '${m['method_name']}',
                                                          overflow: TextOverflow
                                                              .ellipsis)))
                                                  .toList(),
                                              onChanged: submitting
                                                  ? null
                                                  : (v) => setState(
                                                      () => methodId = v)),
                                          const SizedBox(height: 12),
                                          TextField(
                                              controller: amount,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              decoration: InputDecoration(
                                                  labelText:
                                                      tr('withdrawal_amount'))),
                                          const SizedBox(height: 16),
                                          FilledButton(
                                              onPressed: submitting ||
                                                      methods.isEmpty ||
                                                      (double.tryParse(
                                                                  '${summary['available']}') ??
                                                              0) <=
                                                          0
                                                  ? null
                                                  : withdraw,
                                              child: submitting
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2))
                                                  : Text(tr(
                                                      'submit_withdrawal_request'))),
                                          TextButton(
                                              onPressed: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const VendorWithdrawalMethodsScreen()));
                                                if (mounted) load();
                                              },
                                              child: Text(tr(
                                                  'manage_withdrawal_methods'))),
                                          Text(
                                              '${tr('pending_withdrawal_amount')}: ${money(summary['pending_withdraw'])}')
                                        ])),
                                const SizedBox(height: 16),
                                FinancePanel(
                                    title: tr('payments_balance'),
                                    amount: money(summary['operating']),
                                    hint: tr('payments_balance_hint'),
                                    child: OutlinedButton(
                                        onPressed: () => fund('operating'),
                                        child:
                                            Text(tr('fund_purchase_balance')))),
                                const SizedBox(height: 16),
                                FinancePanel(
                                    title: tr('security_deposit_balance'),
                                    amount: money(
                                        summary['order_insurance_credit']),
                                    hint: tr('unused_security_balance_hint'),
                                    child: OutlinedButton(
                                        onPressed: () => fund('insurance'),
                                        child: Text(
                                            tr('fund_insurance_balance')))),
                                const SizedBox(height: 28),
                                Text(tr('paid_security_deposits'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                Text(
                                    '${tr('total_security_deposits_paid')}: ${money(totals['total_paid'])}'),
                                Text(
                                    '${tr('nearest_return_date')}: ${financeDate(context, totals['next_return_at'])}'),
                                Text(
                                    '${tr('due_on_nearest_date')}: ${money(totals['next_return_amount'])}'),
                                Text(tr('security_returns_hint')),
                                const SizedBox(height: 16),
                                for (final row in records['data'] as List? ?? [])
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: FinancePanel(
                                          title: '${row['reference']}',
                                          amount: money(row['amount']),
                                          hint:
                                              '${financeDate(context, row['return_at'])} · ${tr('deposit_${row['status']}')}',
                                          child: row['invoice_number'] != null
                                              ? TextButton.icon(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              VendorInvoiceDocumentScreen(
                                                                  order:
                                                                      '${row['order_reference']}'))),
                                                  icon: const Icon(
                                                      Icons.receipt_long_outlined),
                                                  label: Text('${tr('view_invoice')} #${row['invoice_number']}'))
                                              : null)),
                                if ((records['data'] as List? ?? []).isEmpty)
                                  Text(tr('no_data_found')),
                                pager(records, securityPage, () {
                                  securityPage--;
                                  load();
                                }, () {
                                  securityPage++;
                                  load();
                                }),
                                const SizedBox(height: 28),
                                Text(tr('wallet_transactions'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                for (final row
                                    in transactions['data'] as List? ?? [])
                                  Card(
                                      child: ListTile(
                                    title: Text(
                                        '${tr(row['direction'] == 'credit' ? 'wallet_credit' : 'wallet_debit')}: ${money(row['amount'])}'),
                                    subtitle: Text('WLT-${row['id']} · ${tr({
                                          'available': 'available_balance',
                                          'operating': 'payments_balance',
                                          'order_insurance_credit':
                                              'security_deposit_balance'
                                        }[row['bucket']] ?? 'balance')}\n${financeDate(context, row['created_at'])}'),
                                    isThreeLine: true,
                                  )),
                                if ((transactions['data'] as List? ?? [])
                                    .isEmpty)
                                  Text(tr('no_data_found')),
                                pager(transactions, transactionsPage, () {
                                  transactionsPage--;
                                  load();
                                }, () {
                                  transactionsPage++;
                                  load();
                                }),
                                const SizedBox(height: 28),
                                Text(tr('deposit_history'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                for (final row
                                    in deposits['data'] as List? ?? [])
                                  Card(
                                      child: ListTile(
                                    title: Text(
                                        '${row['amount']} ${row['currency_code']}'),
                                    subtitle: Text(
                                        '${tr('funding_status_${row['status']}')} · ${tr(row['metadata']?['wallet_target'] == 'insurance' ? 'security_deposit_balance' : 'payments_balance')}\n${row['transaction_reference'] ?? row['payment_request_id'] ?? '—'} · ${financeDate(context, row['created_at'])}${row['rejection_reason'] == null ? '' : '\n${row['rejection_reason']}'}'),
                                    isThreeLine: true,
                                  )),
                                if ((deposits['data'] as List? ?? []).isEmpty)
                                  Text(tr('no_data_found')),
                                pager(deposits, depositsPage, () {
                                  depositsPage--;
                                  load();
                                }, () {
                                  depositsPage++;
                                  load();
                                }),
                                const SizedBox(height: 28),
                                Text(tr('finance_withdraw_history'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                for (final row
                                    in withdrawals['data'] as List? ?? [])
                                  Card(
                                      child: ListTile(
                                          title: Text(money(row['amount'])),
                                          subtitle: Text(
                                              '${row['withdrawal_method_fields']?['method_name'] ?? ''}\n${tr('withdrawal_status_${row['approved']}')} · ${financeDate(context, row['created_at'])}'),
                                          isThreeLine: true,
                                          trailing: row['approved'] == 0
                                              ? TextButton(
                                                  onPressed: submitting
                                                      ? null
                                                      : () => cancel(row),
                                                  child: Text(tr('cancel')))
                                              : null)),
                                if ((withdrawals['data'] as List? ?? [])
                                    .isEmpty)
                                  Text(tr('no_data_found')),
                                pager(withdrawals, withdrawalsPage, () {
                                  withdrawalsPage--;
                                  load();
                                }, () {
                                  withdrawalsPage++;
                                  load();
                                })
                              ]
                            ])))));
  }
}
