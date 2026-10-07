import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_navigation_actions.dart';

String financeText(BuildContext context, String key) =>
    getTranslated(key, context) ?? key;
String financeMoney(BuildContext context, dynamic value) =>
    PriceConverter.convertPrice(context, double.tryParse('$value') ?? 0);
String financeDate(BuildContext context, dynamic value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? '—'
      : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
          .format(date.toLocal());
}

String financeError(BuildContext context, Object error) {
  if (error is DioException && error.response?.data is Map) {
    final data = error.response!.data as Map;
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      return first is List ? '${first.first}' : '$first';
    }
    if (data['message'] != null) return '${data['message']}';
  }
  return financeText(context, 'vendor_save_error');
}

String withdrawalRequestKey() {
  final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final s = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

class FinancePanel extends StatelessWidget {
  final String title;
  final String? amount, hint;
  final Widget? child;
  final VoidCallback? onTap;
  const FinancePanel(
      {super.key,
      required this.title,
      this.amount,
      this.hint,
      this.child,
      this.onTap});
  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (amount != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(amount!,
                              style:
                                  Theme.of(context).textTheme.headlineSmall)),
                    if (hint != null)
                      Text(hint!, style: Theme.of(context).textTheme.bodySmall),
                    if (child != null) ...[const SizedBox(height: 16), child!]
                  ]))));
}

class VendorFinanceAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const VendorFinanceAppBar({super.key, required this.title});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: const [VendorAddProductAction()]);
}

class VendorInvoiceDocumentScreen extends StatefulWidget {
  final String order;
  const VendorInvoiceDocumentScreen({super.key, required this.order});
  @override
  State<VendorInvoiceDocumentScreen> createState() =>
      _VendorInvoiceDocumentState();
}

class _VendorInvoiceDocumentState extends State<VendorInvoiceDocumentScreen> {
  Uint8List? bytes;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r = await VendorWorkspace.instance.client.get(
          '/api/v3/seller/invoices/${widget.order}/document',
          options: Options(responseType: ResponseType.bytes));
      if (mounted)
        setState(
            () => bytes = Uint8List.fromList((r.data as List).cast<int>()));
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: VendorFinanceAppBar(title: financeText(context, 'invoice')),
      body: bytes != null
          ? SfPdfViewer.memory(bytes!)
          : error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(error!),
                  TextButton(
                      onPressed: load,
                      child: Text(financeText(context, 'retry')))
                ]))
              : const Center(child: CircularProgressIndicator()));
}
