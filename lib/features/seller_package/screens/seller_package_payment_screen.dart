import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_balance_funding_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/seller_package/controllers/seller_package_controller.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/widgets/transfer_account_details.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class SellerPackagePaymentScreen extends StatefulWidget {
  final SellerPackagePlan plan;
  final SellerPackageOverviewModel overview;
  const SellerPackagePaymentScreen(
      {super.key, required this.plan, required this.overview});
  @override
  State<SellerPackagePaymentScreen> createState() => _PackagePaymentState();
}

class _PackagePaymentState extends State<SellerPackagePaymentScreen> {
  final String requestKey = withdrawalRequestKey();
  bool loading = false;
  String? error;
  double? balance;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r =
          await VendorWorkspace.instance.client.get('/api/v3/seller/balance');
      if (mounted)
        setState(() => balance =
            double.tryParse('${r.data['financial_summary']['operating']}'));
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    }
  }

  Future<void> purchase() async {
    setState(() => loading = true);
    try {
      await VendorWorkspace.instance.client
          .post(AppConstants.sellerPackagePayUri, data: {
        'package_id': widget.plan.id,
        'payment_method': 'operating_balance',
        'payment_platform': 'vendor_app',
        'request_key': requestKey
      });
      if (!mounted) return;
      await context.read<SellerPackageController>().getOverview();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: VendorFinanceAppBar(title: financeText(context, 'ads_manager')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _PackageAmountCard(plan: widget.plan),
        const SizedBox(height: 24),
        Text(financeText(context, 'payments_balance_hint')),
        const SizedBox(height: 12),
        Text(
            '${financeText(context, 'payments_balance')}: ${balance == null ? '—' : financeMoney(context, balance)}'),
        if (error != null)
          Text(error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: loading ||
                    balance == null ||
                    balance! < widget.plan.packagePrice
                ? null
                : purchase,
            child: Text(financeText(context,
                loading ? 'loading' : 'purchase_from_payments_balance'))),
        TextButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SellerBalanceFundingScreen(
                          walletTarget: 'operating')));
              if (mounted) load();
            },
            child: Text(financeText(context, 'fund_purchase_balance')))
      ]));
}

class SellerPackageOfflinePaymentScreen extends StatefulWidget {
  final SellerPackagePlan plan;
  final SellerOfflinePaymentMethod method;

  const SellerPackageOfflinePaymentScreen(
      {super.key, required this.plan, required this.method});

  @override
  State<SellerPackageOfflinePaymentScreen> createState() =>
      _SellerPackageOfflinePaymentScreenState();
}

class _SellerPackageOfflinePaymentScreenState
    extends State<SellerPackageOfflinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final Map<String, TextEditingController> _informationControllers = {};
  XFile? _paymentProof;

  @override
  void initState() {
    super.initState();
    for (final field in _textInformationFields) {
      _informationControllers[field.inputName] = TextEditingController();
    }
  }

  List<SellerOfflineMethodField> get _textInformationFields =>
      widget.method.methodInformations
          .where((field) =>
              field.inputName.isNotEmpty &&
              !_isProofField(field) &&
              field.inputName != 'sender_name' &&
              field.inputName != 'sender_wallet_or_phone')
          .toList();

  @override
  void dispose() {
    _noteController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    for (final controller in _informationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBarWidget(title: getTranslated('manual_transfer', context)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                _PackageAmountCard(plan: widget.plan),
                if (widget.method.methodFields.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(getTranslated('transfer_details', context) ?? '',
                      style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TransferAccountDetails(fields: widget.method.methodFields),
                ],
                Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Text(
                      getTranslated('package_transfer_steps', context) ?? ''),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                TextFormField(
                  controller: _senderNameController,
                  maxLength: 100,
                  decoration: InputDecoration(
                      counterText: '',
                      labelText:
                          '${getTranslated('transfer_sender_full_name', context) ?? ''} *',
                      border: const OutlineInputBorder()),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? (getTranslated('field_is_required', context) ?? '')
                      : null,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                TextFormField(
                  controller: _senderPhoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 30,
                  decoration: InputDecoration(
                      counterText: '',
                      labelText:
                          '${getTranslated('transfer_sender_number', context) ?? ''} *',
                      border: const OutlineInputBorder()),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? (getTranslated('field_is_required', context) ?? '')
                      : null,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                ..._textInformationFields.map((field) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault),
                      child: TextFormField(
                        controller: _informationControllers[field.inputName],
                        decoration: InputDecoration(
                          labelText:
                              '${_fieldTitle(field)}${field.isRequired ? ' *' : ''}',
                          hintText: field.placeholder,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => field.isRequired &&
                                (value == null || value.trim().isEmpty)
                            ? (getTranslated('field_is_required', context) ??
                                '')
                            : null,
                      ),
                    )),
                OutlinedButton.icon(
                  onPressed: _pickProof,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(_paymentProof == null
                      ? (getTranslated('upload_payment_screenshot', context) ??
                          '')
                      : _paymentProof!.name),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                      labelText: getTranslated('payment_note', context),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Consumer<SellerPackageController>(
                    builder: (context, controller, _) {
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isSubmittingPayment ? null : _submit,
                      icon: controller.isSubmittingPayment
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(controller.isSubmittingPayment
                          ? (getTranslated('submitting', context) ?? '')
                          : (getTranslated('submit_for_review', context) ??
                              '')),
                    ),
                  );
                }),
              ]),
        ),
      ),
    );
  }

  Future<void> _pickProof() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null && mounted) {
      // The backend requires a multipart image in payment_proof, not text typed in a field.
      setState(() => _paymentProof = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paymentProof == null) {
      showCustomSnackBarWidget(
          getTranslated('payment_screenshot_required', context) ?? '', context,
          sanckBarType: SnackBarType.error);
      return;
    }

    final information = <String, String>{
      'sender_name': _senderNameController.text.trim(),
      'sender_wallet_or_phone': _senderPhoneController.text.trim(),
      for (final entry in _informationControllers.entries)
        entry.key: entry.value.text.trim(),
    };
    final submitted =
        await Provider.of<SellerPackageController>(context, listen: false)
            .submitOfflinePackagePayment(
      packageId: widget.plan.id,
      methodId: widget.method.id,
      methodInformations: information,
      paymentProof: _paymentProof!,
      paymentNote: _noteController.text.trim(),
    );
    if (submitted && mounted) {
      showCustomSnackBarWidget(
          getTranslated('payment_submitted_admin_review', context) ?? '',
          context,
          isError: false);
      Navigator.pop(context);
    }
  }

  bool _isProofField(SellerOfflineMethodField field) {
    final text = '${field.inputName} ${field.placeholder}'.toLowerCase();
    return text.contains('screenshot') ||
        text.contains('image') ||
        text.contains('receipt') ||
        text.contains('proof');
  }

  String _fieldTitle(SellerOfflineMethodField field) {
    return field.inputName.replaceAll('_', ' ').trim();
  }
}

class _PackageAmountCard extends StatelessWidget {
  final SellerPackagePlan plan;

  const _PackageAmountCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: .25)),
      ),
      child: Row(children: [
        const Icon(Icons.inventory_2_outlined),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(child: Text(plan.name, style: titilliumSemiBold)),
        Text(plan.packagePrice.toStringAsFixed(2),
            style:
                titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ]),
    );
  }
}
