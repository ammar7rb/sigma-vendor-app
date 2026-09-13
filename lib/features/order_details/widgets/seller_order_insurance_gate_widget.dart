import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:intl/intl.dart';
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
      return ListView(padding: const EdgeInsets.all(16), children: [
        Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
                side: BorderSide(color: Theme.of(context).dividerColor)),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.shield_outlined,
                                color: Theme.of(context).primaryColor)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                getTranslated(
                                        'seller_order_insurance', context) ??
                                    'Seller order insurance',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)))
                      ]),
                      const SizedBox(height: 12),
                      Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                              color: AppDesign.warning.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                              getTranslated(
                                      'seller_order_details_hidden_until_insurance_paid',
                                      context) ??
                                  'Order details remain hidden until insurance is paid.',
                              style: const TextStyle(height: 1.5))),
                      const Divider(height: 28),
                      _row(
                          context,
                          getTranslated('order_reference', context) ??
                              'Order reference',
                          insurance.orderReference),
                      _row(
                          context,
                          getTranslated('insurance_amount', context) ??
                              'Insurance amount',
                          PriceConverter.convertPrice(
                              context, insurance.amount)),
                      _row(
                          context,
                          getTranslated('payment_deadline', context) ??
                              'Payment deadline',
                          insurance.expiresAt == null
                              ? (getTranslated('finance_not_set', context) ??
                                  '')
                              : DateFormat.yMMMd(Localizations.localeOf(context)
                                      .languageCode)
                                  .format(DateTime.parse(insurance.expiresAt!)
                                      .toLocal())),
                      _row(
                          context,
                          getTranslated('status', context) ?? 'Status',
                          getTranslated(insurance.status, context) ??
                              insurance.status),
                      if (insurance.adminNote?.isNotEmpty == true)
                        _row(
                            context,
                            getTranslated('admin_note', context) ??
                                'Admin note',
                            insurance.adminNote!),
                      _row(
                          context,
                          getTranslated('order_insurance_credit', context) ??
                              '',
                          PriceConverter.convertPrice(
                              context, insurance.reusableInsuranceCredit)),
                      Text(getTranslated('finance_due_notice', context) ?? ''),
                      const SizedBox(height: 16),
                      if (insurance.status == 'pending_payment') ...[
                        if (envelope!.paymentOptions.reusableInsuranceCredit &&
                            insurance.reusableInsuranceCredit >=
                                insurance.amount)
                          _payButton(
                              context,
                              controller,
                              insurance,
                              'seller_order_insurance_credit',
                              'pay_from_reusable_insurance_credit'),
                        if (envelope.paymentOptions.digitalPayment)
                          ...envelope.paymentOptions.digitalGateways
                              .map((gateway) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: OutlinedButton(
                                    onPressed: controller.insuranceLoading
                                        ? null
                                        : () async {
                                            final redirect = await _pay(context,
                                                controller, gateway.id);
                                            if (redirect != null) {
                                              try {
                                                final opened = await launchUrl(
                                                    Uri.parse(redirect),
                                                    mode: LaunchMode
                                                        .externalApplication);
                                                if (!opened && context.mounted)
                                                  showCustomSnackBarWidget(
                                                      getTranslated(
                                                          'could_not_open_payment_page',
                                                          context),
                                                      context);
                                              } catch (_) {
                                                if (context.mounted)
                                                  showCustomSnackBarWidget(
                                                      getTranslated(
                                                          'could_not_open_payment_page',
                                                          context),
                                                      context);
                                              }
                                            }
                                          },
                                    child: Text(
                                        '${getTranslated('pay_with', context) ?? 'Pay with'} ${gateway.title}'),
                                  ))),
                        if (envelope.paymentOptions.offlinePayment &&
                            envelope.paymentOptions.offlineMethods.isNotEmpty)
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: OutlinedButton(
                                  onPressed: () => _offlineDialog(
                                      context,
                                      controller,
                                      envelope.paymentOptions.offlineMethods),
                                  child: Text(getTranslated(
                                          'offline_payment', context) ??
                                      'Offline payment'))),
                      ],
                      if (insurance.status == 'pending_review')
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(getTranslated(
                                    'offline_payment_waiting_for_admin_review',
                                    context) ??
                                'Payment is waiting for admin review.')),
                    ]))),
      ]);
    });
  }

  Widget _row(BuildContext context, String title, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(title)),
        Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600)))
      ]));

  Widget _payButton(BuildContext context, OrderDetailsController controller,
          SellerOrderInsuranceModel insurance, String method, String label) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                onPressed: controller.insuranceLoading
                    ? null
                    : () => _pay(context, controller, method),
                icon: const Icon(Icons.shield_outlined),
                label: Text(getTranslated(label, context) ?? label))),
      );

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
