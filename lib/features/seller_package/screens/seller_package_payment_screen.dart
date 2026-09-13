import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/seller_package/controllers/seller_package_controller.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerPackagePaymentScreen extends StatelessWidget {
  final SellerPackagePlan plan;
  final SellerPackageOverviewModel overview;

  const SellerPackagePaymentScreen({super.key, required this.plan, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('package_payment', context)),
      body: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
        _PackageAmountCard(plan: plan),
        if (overview.operatingBalancePaymentAvailable) ...[
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _PaymentMethodTile(
            icon: Icons.account_balance_wallet_outlined,
            title: getTranslated('pay_from_operating_balance', context) ?? '',
            subtitle: '${getTranslated('available', context) ?? ''}: ${overview.operatingBalance.toStringAsFixed(2)}',
            onTap: () => _payFromOperatingBalance(context),
          ),
        ],
        if (overview.digitalPaymentAvailable && overview.paymentGateways.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(getTranslated('pay_online', context) ?? '', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...overview.paymentGateways.map((gateway) => _PaymentMethodTile(
            icon: Icons.credit_card_outlined,
            title: gateway.title,
            onTap: () => _startDigitalPayment(context, gateway),
          )),
        ],
        if (overview.offlinePaymentAvailable && overview.offlinePaymentMethods.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(getTranslated('manual_transfer', context) ?? '', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...overview.offlinePaymentMethods.map((method) => _PaymentMethodTile(
            icon: Icons.account_balance_outlined,
            title: method.methodName,
            subtitle: getTranslated('submit_proof_for_admin_review', context),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SellerPackageOfflinePaymentScreen(plan: plan, method: method),
            )),
          )),
        ],
        if ((!overview.digitalPaymentAvailable || overview.paymentGateways.isEmpty) &&
            (!overview.offlinePaymentAvailable || overview.offlinePaymentMethods.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: Center(child: Text(getTranslated('no_payment_method_available', context) ?? '')),
          ),
      ]),
    );
  }

  Future<void> _payFromOperatingBalance(BuildContext context) async {
    final controller = Provider.of<SellerPackageController>(context, listen: false);
    final paid = await controller.payPackageFromOperatingBalance(packageId: plan.id);
    if (paid && context.mounted) {
      showCustomSnackBarWidget(getTranslated('package_payment_completed_from_balance', context) ?? '', context, isError: false, sanckBarType: SnackBarType.success);
      Navigator.pop(context);
    }
  }

  Future<void> _startDigitalPayment(BuildContext context, SellerPaymentGateway gateway) async {
    final controller = Provider.of<SellerPackageController>(context, listen: false);
    final redirectLink = await controller.payPackage(packageId: plan.id, paymentMethod: gateway.keyName);
    if (redirectLink == null || redirectLink.isEmpty) return;

    // Digital gateways own the secure payment page; the app only opens the redirect returned by the backend.
    final launched = await launchUrl(Uri.parse(redirectLink), mode: LaunchMode.externalApplication);
    if (launched) {
      // The backend creates a pending subscription before redirecting, so refresh the visible state immediately.
      await controller.getOverview();
    }
    if (!launched && context.mounted) {
      showCustomSnackBarWidget(getTranslated('could_not_open_payment_page', context) ?? '', context, sanckBarType: SnackBarType.error);
    }
  }
}

class SellerPackageOfflinePaymentScreen extends StatefulWidget {
  final SellerPackagePlan plan;
  final SellerOfflinePaymentMethod method;

  const SellerPackageOfflinePaymentScreen({super.key, required this.plan, required this.method});

  @override
  State<SellerPackageOfflinePaymentScreen> createState() => _SellerPackageOfflinePaymentScreenState();
}

class _SellerPackageOfflinePaymentScreenState extends State<SellerPackageOfflinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final Map<String, TextEditingController> _informationControllers = {};
  XFile? _paymentProof;

  @override
  void initState() {
    super.initState();
    for (final field in _textInformationFields) {
      _informationControllers[field.inputName] = TextEditingController();
    }
  }

  List<SellerOfflineMethodField> get _textInformationFields => widget.method.methodInformations
      .where((field) => field.inputName.isNotEmpty && !_isProofField(field))
      .toList();

  @override
  void dispose() {
    _noteController.dispose();
    for (final controller in _informationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('manual_transfer', context)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
            _PackageAmountCard(plan: widget.plan),
            if (widget.method.methodFields.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(getTranslated('transfer_details', context) ?? '', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...widget.method.methodFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                child: Text('${_fieldTitle(field)}: ${field.inputData}', style: titilliumRegular),
              )),
            ],
            const SizedBox(height: Dimensions.paddingSizeLarge),
            ..._textInformationFields.map((field) => Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
              child: TextFormField(
                controller: _informationControllers[field.inputName],
                decoration: InputDecoration(
                  labelText: '${_fieldTitle(field)}${field.isRequired ? ' *' : ''}',
                  hintText: field.placeholder,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => field.isRequired && (value == null || value.trim().isEmpty)
                    ? (getTranslated('field_is_required', context) ?? '') : null,
              ),
            )),
            OutlinedButton.icon(
              onPressed: _pickProof,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(_paymentProof == null ? (getTranslated('upload_payment_screenshot', context) ?? '') : _paymentProof!.name),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(labelText: getTranslated('payment_note', context), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Consumer<SellerPackageController>(builder: (context, controller, _) {
              return SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmittingPayment ? null : _submit,
                  icon: controller.isSubmittingPayment
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(controller.isSubmittingPayment
                      ? (getTranslated('submitting', context) ?? '')
                      : (getTranslated('submit_for_review', context) ?? '')),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickProof() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null && mounted) {
      // The backend requires a multipart image in payment_proof, not text typed in a field.
      setState(() => _paymentProof = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paymentProof == null) {
      showCustomSnackBarWidget(getTranslated('payment_screenshot_required', context) ?? '', context, sanckBarType: SnackBarType.error);
      return;
    }

    final information = <String, String>{
      for (final entry in _informationControllers.entries) entry.key: entry.value.text.trim(),
    };
    final submitted = await Provider.of<SellerPackageController>(context, listen: false).submitOfflinePackagePayment(
      packageId: widget.plan.id,
      methodId: widget.method.id,
      methodInformations: information,
      paymentProof: _paymentProof!,
      paymentNote: _noteController.text.trim(),
    );
    if (submitted && mounted) {
      showCustomSnackBarWidget(getTranslated('payment_submitted_admin_review', context) ?? '', context, isError: false);
      Navigator.pop(context);
    }
  }

  bool _isProofField(SellerOfflineMethodField field) {
    final text = '${field.inputName} ${field.placeholder}'.toLowerCase();
    return text.contains('screenshot') || text.contains('image') || text.contains('receipt') || text.contains('proof');
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
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
      ),
      child: Row(children: [
        const Icon(Icons.inventory_2_outlined),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(child: Text(plan.name, style: titilliumSemiBold)),
        Text(plan.packagePrice.toStringAsFixed(2), style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ]),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _PaymentMethodTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon), title: Text(title, style: titilliumSemiBold),
        subtitle: subtitle == null ? null : Text(subtitle!, style: titilliumRegular),
        trailing: const Icon(Icons.chevron_right), onTap: onTap,
      ),
    );
  }
}
