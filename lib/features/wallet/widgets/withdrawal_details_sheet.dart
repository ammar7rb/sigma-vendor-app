import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Status text for a sales withdrawal: pending, approved and awaiting the
/// transfer, transferred, or rejected.
String withdrawalStatusLabel(BuildContext context, Map row) {
  String tr(String key) => getTranslated(key, context) ?? key;
  if (row['approved'] == 0 && row['reviewed_at'] != null) {
    return tr('withdrawal_status_reviewed');
  }
  return tr('withdrawal_status_${row['approved']}');
}

Future<void> showWithdrawalDetailsSheet(BuildContext context, Map row,
    {required String Function(dynamic) money}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _WithdrawalDetailsSheet(row: row, money: money));
}

class _WithdrawalDetailsSheet extends StatefulWidget {
  final Map row;
  final String Function(dynamic) money;
  const _WithdrawalDetailsSheet({required this.row, required this.money});

  @override
  State<_WithdrawalDetailsSheet> createState() =>
      _WithdrawalDetailsSheetState();
}

class _WithdrawalDetailsSheetState extends State<_WithdrawalDetailsSheet> {
  Uint8List? proof;
  bool loading = false, proofIsPdf = false;
  String? error;

  String tr(String key) => getTranslated(key, context) ?? key;

  Future<void> loadProof() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await VendorWorkspace.instance.client.dio!.get<List<int>>(
          '/api/v3/seller/balance/withdrawals/${widget.row['id']}/proof',
          options: Options(responseType: ResponseType.bytes));
      final type = response.headers.value('content-type') ?? '';
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) setState(() => error = tr('transfer_proof_unavailable'));
        return;
      }
      if (!mounted) return;
      setState(() {
        proofIsPdf = type.contains('pdf');
        proof = Uint8List.fromList(bytes);
      });
    } catch (_) {
      if (mounted) setState(() => error = tr('transfer_proof_unavailable'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final method = row['withdrawal_method_fields'] is Map
        ? row['withdrawal_method_fields']['method_name']
        : null;
    final rows = <(String, String)>[
      (tr('withdrawal_amount'), widget.money(row['amount'])),
      (tr('withdrawal_status_label'), withdrawalStatusLabel(context, row)),
      if (method != null) (tr('withdrawal_method_label'), '$method'),
      if ((row['payout_reference'] ?? '').toString().isNotEmpty)
        (tr('transfer_reference'), '${row['payout_reference']}'),
      if ((row['transaction_note'] ?? '').toString().isNotEmpty)
        (tr('note'), '${row['transaction_note']}'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr('withdrawal_details'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                for (final item in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(item.$1,
                                  style: TextStyle(
                                      color: Theme.of(context).hintColor))),
                          const SizedBox(width: 12),
                          Flexible(
                              child: Text(item.$2,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))),
                        ]),
                  ),
                if (row['has_payout_proof'] == true) ...[
                  const SizedBox(height: 12),
                  if (proof == null)
                    OutlinedButton.icon(
                        onPressed: loading ? null : loadProof,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.receipt_long_outlined),
                        label: Text(tr('view_transfer_proof')))
                  else if (proofIsPdf)
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * .5,
                      child: SfPdfViewer.memory(proof!),
                    )
                  else
                    ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: InteractiveViewer(
                            child: Image.memory(proof!, fit: BoxFit.contain))),
                ],
                if (error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
              ]),
        ),
      ),
    );
  }
}
