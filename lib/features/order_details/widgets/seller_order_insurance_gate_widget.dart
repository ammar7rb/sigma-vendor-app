import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/seller_order_insurance_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerOrderInsuranceGateWidget extends StatelessWidget {
  final String orderId;
  const SellerOrderInsuranceGateWidget({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsController>(builder: (context, controller, _) {
      final envelope = controller.sellerOrderInsurance;
      final insurance = envelope?.insurance;
      if (controller.insuranceLoading || insurance == null)
        return const Center(child: CircularProgressIndicator());
      final lastThree = insurance.orderLastThreeDigits.padLeft(3, '0');
      return ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Icon(Icons.shield_outlined, size: 42, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(getTranslated('seller_order_insurance', context) ?? 'تأمين الطلب',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(getTranslated('seller_order_details_hidden_until_insurance_paid', context) ?? 'تفاصيل الطلب محجوبة حتى سداد التأمين',
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: insurance.status == 'pending_payment'
                    ? () => _showPaymentOptions(context, controller, envelope!, insurance)
                    : null,
                icon: const Icon(Icons.lock_open_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('${getTranslated('insurance_amount', context) ?? 'قيمة التأمين'}: ${PriceConverter.convertPrice(context, insurance.amount)}'),
                ),
              ),
              if (insurance.status == 'pending_review')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(getTranslated('offline_payment_waiting_for_admin_review', context) ?? 'الدفع قيد مراجعة الإدارة', textAlign: TextAlign.center),
                ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  Container(
                    height: 155,
                    padding: const EdgeInsets.all(20),
                    color: Theme.of(context).primaryColor.withValues(alpha: .08),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 170, height: 14, color: Theme.of(context).dividerColor),
                      const SizedBox(height: 18),
                      Container(width: 240, height: 14, color: Theme.of(context).dividerColor),
                      const SizedBox(height: 18),
                      Container(width: 130, height: 14, color: Theme.of(context).dividerColor),
                    ]),
                  ),
                  Positioned.fill(child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: ColoredBox(color: Theme.of(context).cardColor.withValues(alpha: .7)),
                  )),
                  Positioned.fill(child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('•••${lastThree.substring(lastThree.length - 3)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('${getTranslated('order_amount', context) ?? 'قيمة الطلب'}: ${PriceConverter.convertPrice(context, insurance.orderAmount)}'),
                    ],
                  ))),
                ]),
              ),
            ]),
          ),
        ),
      ]);
    });
  }

  void _showPaymentOptions(BuildContext context, OrderDetailsController controller,
      SellerOrderInsuranceEnvelope envelope, SellerOrderInsuranceModel insurance) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(getTranslated('choose_payment_method', sheetContext) ?? 'اختر طريقة دفع التأمين',
              style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          if (envelope.paymentOptions.reusableInsuranceCredit)
            OutlinedButton.icon(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text(getTranslated('pay_from_reusable_insurance_credit', sheetContext) ?? 'الدفع من رصيد التأمين'),
              onPressed: () async {
                if (insurance.reusableInsuranceCredit < insurance.amount) {
                  showCustomSnackBarWidget(
                    getTranslated('seller_insurance_balance_insufficient_action', sheetContext) ??
                        'رصيد التأمين لا يكفي لإتمام المعاملة. اختر طريقة أخرى أو أودع في رصيد التأمين.',
                    sheetContext,
                  );
                  return;
                }
                Navigator.pop(sheetContext);
                await _pay(context, controller, 'seller_order_insurance_credit');
              },
            ),
          for (final method in envelope.paymentOptions.offlineMethods)
            if (envelope.paymentOptions.offlinePayment)
              OutlinedButton.icon(
                icon: Icon(method.channel == 'instapay'
                    ? Icons.account_balance_outlined : Icons.phone_android_outlined),
                label: Text(method.channel == 'instapay'
                    ? '${getTranslated('instapay_payment', sheetContext) ?? 'إنستا باي'} · ${method.title}'
                    : '${getTranslated('electronic_wallet_payment', sheetContext) ?? 'محفظة إلكترونية'} · ${method.title}'),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _offlineDialog(context, controller, [method]);
                },
              ),
          if (envelope.paymentOptions.digitalPayment)
            for (final gateway in envelope.paymentOptions.digitalGateways)
              OutlinedButton.icon(
                icon: const Icon(Icons.credit_card_outlined),
                label: Text(gateway.title),
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  final redirect = await _pay(context, controller, gateway.id);
                  if (redirect == null) return;
                  try {
                    final opened = await launchUrl(Uri.parse(redirect), mode: LaunchMode.externalApplication);
                    if (!opened && context.mounted) {
                      showCustomSnackBarWidget(getTranslated('could_not_open_payment_page', context), context);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showCustomSnackBarWidget(getTranslated('could_not_open_payment_page', context), context);
                    }
                  }
                },
              ),
        ]),
      )),
    );
  }

  Future<String?> _pay(BuildContext context, OrderDetailsController controller,
      String method) async {
    try {
      return await controller.paySellerOrderInsurance(orderId, method);
    } catch (_) {
      if (context.mounted)
        showCustomSnackBarWidget(
            getTranslated('seller_journey_action_failed', context), context);
      return null;
    }
  }

  Future<void> _offlineDialog(
      BuildContext context,
      OrderDetailsController controller,
      List<InsurancePaymentMethod> methods) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            SellerInsuranceOfflineScreen(orderId: orderId, methods: methods)));
  }
}

class SellerInsuranceOfflineScreen extends StatefulWidget {
  final String orderId;
  final List<InsurancePaymentMethod> methods;
  const SellerInsuranceOfflineScreen(
      {super.key, required this.orderId, required this.methods});
  @override
  State<SellerInsuranceOfflineScreen> createState() =>
      _SellerInsuranceOfflineScreenState();
}

class _SellerInsuranceOfflineScreenState
    extends State<SellerInsuranceOfflineScreen> {
  final note = TextEditingController();
  XFile? proof;
  late String methodId = widget.methods.first.id;
  bool busy = false;
  String tr(String key) => getTranslated(key, context) ?? key;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.methods.firstWhere((m) => m.id == methodId);
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(tr('offline_payment'))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppDesign.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(tr('seller_journey_insurance_review_notice'),
                  style: const TextStyle(height: 1.5))),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              initialValue: methodId,
              isExpanded: true,
              items: widget.methods
                  .map((m) =>
                      DropdownMenuItem(value: m.id, child: Text(m.title)))
                  .toList(),
              onChanged:
                  busy ? null : (value) => setState(() => methodId = value!),
              decoration: InputDecoration(
                  labelText: tr('transfer_method'),
                  border: const OutlineInputBorder())),
          for (final field in method.fields)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SelectableText(
                    '${field['input_name'] ?? field['name'] ?? ''}: ${field['input_data'] ?? field['value'] ?? ''}')),
          const SizedBox(height: 16),
          TextField(
              controller: note,
              enabled: !busy,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                  labelText: tr('payment_note'),
                  border: const OutlineInputBorder())),
          OutlinedButton.icon(
              onPressed: busy ? null : pick,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(proof?.name ?? tr('select_payment_proof'))),
          const SizedBox(height: 8),
          SizedBox(
              height: 54,
              child: FilledButton(
                  onPressed: busy || proof == null ? null : submit,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(tr('submit_admin_review')))),
        ]));
  }

  Future<void> pick() async {
    try {
      final file = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (file == null) return;
      if (await file.length() > 5 * 1024 * 1024) {
        if (mounted)
          showCustomSnackBarWidget(tr('finance_proof_limit'), context);
        return;
      }
      if (mounted) setState(() => proof = file);
    } catch (_) {
      if (mounted)
        showCustomSnackBarWidget(tr('finance_proof_failed'), context);
    }
  }

  Future<void> submit() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final ok = await context
          .read<OrderDetailsController>()
          .submitSellerOrderInsuranceOffline(
              widget.orderId, methodId, proof!.path, note.text.trim());
      if (ok && mounted) {
        showCustomSnackBarWidget(
            tr('seller_journey_insurance_review_notice'), context,
            isError: false);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        showCustomSnackBarWidget(tr('seller_journey_action_failed'), context);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
