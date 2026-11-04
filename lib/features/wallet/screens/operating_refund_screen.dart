import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class OperatingRefundScreen extends StatefulWidget {
  const OperatingRefundScreen({super.key});
  @override
  State<OperatingRefundScreen> createState() => _OperatingRefundState();
}

class _OperatingRefundState extends State<OperatingRefundScreen> {
  final amount = TextEditingController();
  Map? data;
  Map<String, dynamic>? pending;
  String? error;
  bool busy = false;
  String tr(String key) => financeText(context, key);

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final result = await VendorWorkspace.instance.client
          .get('/api/v3/seller/balance/operating-refunds');
      if (mounted) {
        setState(() {
          data = result.data as Map;
          error = null;
        });
      }
    } catch (exception) {
      if (mounted) setState(() => error = financeError(context, exception));
    }
  }

  Future<void> submit() async {
    if (busy || data == null) return;
    final value = double.tryParse(amount.text);
    if (pending == null && (value == null || value <= 0 || !value.isFinite)) {
      setState(() => error = tr('invalid_withdraw_request'));
      return;
    }
    pending ??= {
      'amount': amount.text,
      'request_key': withdrawalRequestKey(),
      'currency_code':
          context.read<SplashController>().myCurrency?.code ?? 'EGP',
    };
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/balance/operating-refunds', data: pending);
      pending = null;
      if (!mounted) return;
      amount.clear();
      await load();
    } catch (exception) {
      if (!mounted) return;
      final status =
          exception is DioException ? exception.response?.statusCode : null;
      if (status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        pending = null;
      }
      setState(() => error = financeError(context, exception));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: VendorFinanceAppBar(title: tr('operating_refund')),
        body: RefreshIndicator(
          onRefresh: load,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            if (error != null)
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (data == null)
              const LinearProgressIndicator()
            else ...[
              Text(tr('operating_refund_hint')),
              Text('${tr('payout_days_after_approval')}: ${data!['days']}'),
              TextField(
                controller: amount,
                enabled: !busy && pending == null,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText:
                        '${tr('amount')} (${context.watch<SplashController>().myCurrency?.code ?? 'EGP'}) *'),
              ),
              FilledButton(
                  onPressed: busy ? null : submit,
                  child: Text(tr(pending == null
                      ? 'request_operating_refund'
                      : 'retry_same_payout_request'))),
              const SizedBox(height: 24),
              for (final row
                  in (data!['requests'] as Map?)?['data'] as List? ?? [])
                ListTile(
                  title: Text(
                      '${row['transaction_number']} · ${financeMoney(context, row['amount'])}'),
                  subtitle: Text(
                      '${tr(row['approved'] == 0 && row['reviewed_at'] != null ? 'payout_approved_waiting' : 'withdrawal_status_${row['approved']}')}\n${tr('payout_due_date')}: ${financeDate(context, row['payout_due_at'])}'),
                ),
            ],
          ]),
        ),
      );
}
