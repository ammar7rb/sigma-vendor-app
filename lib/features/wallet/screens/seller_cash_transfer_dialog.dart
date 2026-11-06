import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerCashTransferDialog extends StatefulWidget {
  final String requestKey;
  final String currencyCode;
  final int ownerId;
  const SellerCashTransferDialog(
      {super.key,
      required this.requestKey,
      required this.currencyCode,
      required this.ownerId});
  @override
  State<SellerCashTransferDialog> createState() =>
      _SellerCashTransferDialogState();
}

class _SellerCashTransferDialogState extends State<SellerCashTransferDialog> {
  final amount = TextEditingController();
  Map<String, dynamic>? quote;
  Map<String, dynamic>? display;
  String? error;
  bool busy = false;
  bool pending = false;
  bool restoring = true;
  bool storageFailed = false;
  String? restoredCurrency;
  String get storageKey => 'seller_cash_transfer_pending_${widget.ownerId}';
  String get effectiveCurrency => restoredCurrency ?? widget.currencyCode;
  String tr(String key) => financeText(context, key);
  @override
  void initState() {
    super.initState();
    restorePending();
  }

  Future<void> restorePending() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final stored = preferences.getString(storageKey);
      if (stored != null) {
        final saved = Map<String, dynamic>.from(jsonDecode(stored) as Map);
        amount.text = '${saved['amount']}';
        quote = Map<String, dynamic>.from(saved['quote'] as Map);
        display = Map<String, dynamic>.from(saved['display'] as Map);
        restoredCurrency = '${saved['currency']}';
        pending = true;
      }
    } catch (_) {
      if (mounted) {
        storageFailed = true;
        error = tr('sales_cash_transfer_storage_error');
      }
    } finally {
      if (mounted) setState(() => restoring = false);
    }
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> review() async {
    if (busy) return;
    final value = double.tryParse(amount.text.trim());
    if (value == null || !value.isFinite || value <= 0) {
      setState(() => error = tr('sales_cash_transfer_invalid_amount'));
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await VendorWorkspace.instance.client.get(
          '/api/v3/seller/balance/transfer-quote',
          queryParameters: {'amount': value});
      if (response.data['currency_code'] != widget.currencyCode) {
        throw StateError('currency_changed');
      }
      if (mounted) {
        setState(() {
          quote = Map<String, dynamic>.from(response.data['quote'] as Map);
          display = Map<String, dynamic>.from(response.data['display'] as Map);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> confirm() async {
    if (busy || quote == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      final previous = preferences.getString(storageKey);
      final saved = previous == null
          ? {
              'request_key': widget.requestKey,
              'amount': amount.text.trim(),
              'quote': quote,
              'display': display,
              'currency': effectiveCurrency,
            }
          : Map<String, dynamic>.from(jsonDecode(previous) as Map);
      if (previous == null) {
        final stored =
            await preferences.setString(storageKey, jsonEncode(saved));
        if (!stored) throw StateError('storage');
      }
      if (mounted) setState(() => pending = true);
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/balance/transfer', data: {
        'amount': double.parse(amount.text.trim()),
        'request_key': saved['request_key'],
        'quoted_amount': quote!['amount'],
        'currency_code': effectiveCurrency,
        'fee_type': quote!['fee_type'],
        'fee_value': quote!['fee_value'],
        'fee': quote!['fee'],
      });
      await preferences.remove(storageKey);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(tr(quote == null
            ? 'sales_cash_transfer_title'
            : 'sales_cash_transfer_confirm')),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(tr('sales_cash_transfer_hint')),
              const SizedBox(height: 12),
              if (quote == null)
                TextField(
                    controller: amount,
                    enabled: !busy,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: '${tr('amount')} ($effectiveCurrency)')),
              if (quote != null) ...[
                Text(
                    '${tr('amount')}: ${display!['amount']} $effectiveCurrency'),
                Text(
                    '${tr('sales_cash_transfer_fee')}: ${display!['fee']} $effectiveCurrency'),
                Text(
                    '${tr('sales_cash_transfer_net')}: ${display!['net']} $effectiveCurrency'),
                if (pending) Text(tr('sales_cash_transfer_pending_retry')),
              ],
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
            ])),
        actions: [
          TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: Text(tr('cancel'))),
          if (quote != null && !pending)
            TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                          quote = null;
                          error = null;
                        }),
                child: Text(tr('edit'))),
          FilledButton(
              onPressed:
                  busy || restoring || storageFailed || widget.ownerId <= 0
                      ? null
                      : quote == null
                          ? review
                          : confirm,
              child: Text(tr(busy
                  ? 'loading'
                  : quote == null
                      ? 'sales_cash_transfer_review'
                      : 'confirm'))),
        ],
      );
}
