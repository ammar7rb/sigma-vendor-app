import 'dart:ui';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';
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
  final bool embedded;
  const SellerPackagePaymentScreen(
      {super.key,
      required this.plan,
      required this.overview,
      this.embedded = false});
  @override
  State<SellerPackagePaymentScreen> createState() => _PackagePaymentState();
}

class _PackagePaymentState extends State<SellerPackagePaymentScreen> {
  final String requestKey = withdrawalRequestKey();
  bool loading = false;
  String? error;
  double? balance;
  String? channel;
  SellerOfflinePaymentMethod? selectedMethod;
  String tr(String ar, String en) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r =
          await VendorWorkspace.instance.client.get('/api/v3/seller/balance');
      if (mounted) {
        setState(() => balance =
            double.tryParse('${r.data['financial_summary']['operating']}'));
      }
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    }
  }

  Future<void> purchase() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await VendorWorkspace.instance.client
          .post(AppConstants.sellerPackagePayUri, data: {
        'package_id': widget.plan.id,
        'expected_package_price': widget.plan.packagePrice,
        'payment_method': 'operating_balance',
        'payment_platform': 'vendor_app',
        'request_key': requestKey
      });
      await VendorWorkspace.instance.refresh();
      if (!mounted) return;
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openTransfer(SellerOfflinePaymentMethod method) async {
    if (widget.embedded) {
      Navigator.pop(context, method);
      return;
    }
    final submitted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => SellerPackageOfflinePaymentScreen(
                plan: widget.plan, method: method)));
    if (submitted == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final methods = widget.overview.offlinePaymentMethods
        .where((m) => m.paymentChannel == channel)
        .toList();
    final body = ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            Expanded(
                child: Text(
                    channel == 'balance'
                        ? tr('تأكيد الدفع', 'Confirm payment')
                        : tr('اختر طريقة الدفع', 'Choose payment method'),
                    style: Theme.of(context).textTheme.titleLarge)),
            if (channel != null)
              Flexible(
                  child: TextButton.icon(
                      onPressed: loading
                          ? null
                          : () => setState(() {
                                channel = null;
                                selectedMethod = null;
                              }),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(
                          tr('تغيير طريقة الدفع', 'Change payment method')))),
            IconButton(
                tooltip: tr('إغلاق', 'Close'),
                onPressed: loading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 12),
          _PackageAmountCard(plan: widget.plan),
          const SizedBox(height: 20),
          if (channel == null)
            for (final entry in {
              'balance': tr('الدفع من خلال المحفظة', 'Pay through wallet'),
              'instapay': tr('إنستا باي', 'InstaPay'),
              'wallet': tr('محفظة إلكترونية', 'Electronic wallet')
            }.entries)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Builder(builder: (context) {
                    final enabled = entry.key == 'balance' ||
                        (widget.overview.offlinePaymentAvailable &&
                            widget.overview.offlinePaymentMethods
                                .any((m) => m.paymentChannel == entry.key));
                    return Semantics(
                        selected: channel == entry.key,
                        child: ListTile(
                          enabled: enabled && !loading,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: channel == entry.key
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).dividerColor)),
                          selected: channel == entry.key,
                          selectedTileColor: const Color(0xFFEDF2FB),
                          leading: entry.key == 'instapay'
                              ? Image.asset(
                                  'assets/images/withdrawal/instapay.png',
                                  width: 48,
                                  height: 32,
                                  fit: BoxFit.cover)
                              : const Icon(
                                  Icons.account_balance_wallet_outlined),
                          title: Text(entry.value),
                          subtitle: enabled
                              ? null
                              : Text(tr(
                                  'غير متاحة حاليًا', 'Currently unavailable')),
                          trailing: Icon(channel == entry.key
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                          onTap: () {
                            final matches = widget
                                .overview.offlinePaymentMethods
                                .where((m) => m.paymentChannel == entry.key)
                                .toList();
                            if (entry.key != 'balance' && matches.length == 1) {
                              openTransfer(matches.first);
                              return;
                            }
                            setState(() {
                              channel = entry.key;
                              selectedMethod = null;
                            });
                          },
                        ));
                  })),
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (channel == 'balance') ...[
            const SizedBox(height: 12),
            _PaymentBalanceReceipt(
                balance: balance, price: widget.plan.packagePrice),
            if (balance != null && balance! < widget.plan.packagePrice)
              Text(tr('رصيد المدفوعات غير كافٍ. اختر طريقة أخرى أو أضف رصيدًا.',
                  'Insufficient payments balance. Choose another method or add funds.')),
            const SizedBox(height: 16),
          ],
          if (channel != null &&
              channel != 'balance' &&
              methods.isNotEmpty) ...[
            _TransferMethodHeader(instapay: channel == 'instapay'),
            if (methods.length > 1)
              DropdownButtonFormField<int>(
                initialValue: selectedMethod?.id ?? methods.first.id,
                decoration: InputDecoration(
                    labelText: tr('حساب التحويل', 'Transfer account')),
                items: methods
                    .map((m) => DropdownMenuItem(
                        value: m.id, child: Text(m.methodName)))
                    .toList(),
                onChanged: loading
                    ? null
                    : (id) => setState(() =>
                        selectedMethod = methods.firstWhere((m) => m.id == id)),
              ),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: loading
                    ? null
                    : () => openTransfer(selectedMethod ?? methods.first),
                child: Text(tr('متابعة الدفع', 'Continue payment'))),
          ],
        ]);
    final content = SizedBox(
        height: channel == 'balance'
            ? (MediaQuery.sizeOf(context).height * .78 -
                    MediaQuery.viewInsetsOf(context).bottom)
                .clamp(200.0, 740.0)
            : null,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: body),
          if (channel == 'balance')
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (balance != null &&
                        balance! >= widget.plan.packagePrice) ...[
                      const Divider(),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            Expanded(
                                child: Text(tr('الرصيد بعد الدفع',
                                    'Balance after payment'))),
                            const SizedBox(width: 12),
                            Text(
                                financeMoney(context,
                                    balance! - widget.plan.packagePrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A428A)))
                          ])),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          onPressed: loading ||
                                  balance == null ||
                                  balance! < widget.plan.packagePrice
                              ? null
                              : purchase,
                          child: Text(loading
                              ? tr('جارٍ الدفع…', 'Paying…')
                              : tr('ادفع الآن', 'Pay now'))),
                    )
                  ]),
            ),
        ]));
    return PopScope(
        canPop: !loading,
        child: widget.embedded
            ? content
            : Scaffold(
                appBar: VendorFinanceAppBar(title: tr('الدفع', 'Payment')),
                body: content));
  }
}

Future<void> showSellerPackagePaymentDialog(BuildContext context,
    {required SellerPackagePlan plan,
    required SellerPackageOverviewModel overview}) async {
  final result = await showGeneralDialog<Object>(
    context: context,
    barrierDismissible: false,
    barrierLabel: Localizations.localeOf(context).languageCode == 'ar'
        ? 'الدفع'
        : 'Payment',
    barrierColor: Colors.black.withValues(alpha: .45),
    pageBuilder: (context, animation, secondaryAnimation) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.sizeOf(context).height * .86 -
                  MediaQuery.viewInsetsOf(context).bottom),
          child: SellerPackagePaymentScreen(
              plan: plan, overview: overview, embedded: true),
        ),
      ),
    ),
  );
  if (result is SellerOfflinePaymentMethod && context.mounted) {
    await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                SellerPackageOfflinePaymentScreen(plan: plan, method: result)));
  }
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
  final _transferReference = TextEditingController();
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
              !const [
                'transfer_reference',
                'transaction_reference',
                'transaction_id',
                'reference_number',
                'reference'
              ].contains(field.inputName) &&
              !_isProofField(field) &&
              field.inputName != 'sender_name' &&
              field.inputName != 'sender_wallet_or_phone')
          .toList();

  @override
  void dispose() {
    _transferReference.dispose();
    _noteController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    for (final controller in _informationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get instapay => widget.method.paymentChannel == 'instapay';
  String text(String ar, String en) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  InputDecoration fieldDecoration(String label,
          {String? hint, IconData? icon}) =>
      InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          prefixIcon: icon == null ? null : Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: instapay
              ? text('الدفع عبر إنستا باي', 'Pay with InstaPay')
              : text('الدفع بمحفظة إلكترونية', 'Pay with electronic wallet')),
      body: SafeArea(
          child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _TransferMethodHeader(instapay: instapay),
                  const SizedBox(height: 20),
                  _PackageAmountCard(plan: widget.plan),
                  if (widget.method.methodFields.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(text('بيانات المستلم', 'Recipient details'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TransferAccountDetails(fields: widget.method.methodFields),
                  ],
                  const SizedBox(height: 24),
                  Text(text('بيانات التحويل', 'Transfer details'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderNameController,
                    maxLength: 100,
                    decoration: fieldDecoration(
                            text('اسم صاحب الحساب المُرسِل',
                                'Sender account holder name'),
                            icon: Icons.person_outline)
                        .copyWith(counterText: ''),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? (getTranslated('field_is_required', context) ?? '')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderPhoneController,
                    keyboardType: instapay
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLength: instapay ? 191 : 30,
                    decoration: fieldDecoration(
                            instapay
                                ? text('حساب إنستا باي أو رقم الهاتف المُرسِل',
                                    'Sender InstaPay address or phone')
                                : text('رقم المحفظة المُرسِلة',
                                    'Sender wallet number'),
                            icon: instapay
                                ? Icons.alternate_email
                                : Icons.phone_android)
                        .copyWith(counterText: ''),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? (getTranslated('field_is_required', context) ?? '')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _transferReference,
                    maxLength: 191,
                    decoration: fieldDecoration(
                            instapay
                                ? text('رقم العملية في إنستا باي',
                                    'InstaPay transaction reference')
                                : text('رقم عملية المحفظة',
                                    'Wallet transaction reference'),
                            hint: text('كما يظهر في إيصال التحويل',
                                'As shown on the transfer receipt'),
                            icon: Icons.receipt_long_outlined)
                        .copyWith(counterText: ''),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? (getTranslated('field_is_required', context) ?? '')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ..._textInformationFields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _informationControllers[field.inputName],
                        decoration: fieldDecoration(
                            '${_fieldTitle(field)}${field.isRequired ? ' *' : ''}',
                            hint: field.placeholder),
                        validator: (v) => field.isRequired &&
                                (v == null || v.trim().isEmpty)
                            ? (getTranslated('field_is_required', context) ??
                                '')
                            : null,
                      ))),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Theme.of(context).dividerColor)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 32, color: Color(0xFF1A428A)),
                          const SizedBox(height: 12),
                          Text(text('إثبات التحويل', 'Transfer receipt'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                              text(
                                  'أرفق صورة واضحة لعملية التحويل، حتى 5 ميجابايت.',
                                  'Attach a clear transfer receipt, up to 5 MB.'),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                              onPressed: _pickProof,
                              icon: Icon(_paymentProof == null
                                  ? Icons.upload_file_outlined
                                  : Icons.check_circle_outline),
                              label: Text(
                                  _paymentProof == null
                                      ? text('اختيار صورة التحويل',
                                          'Choose receipt image')
                                      : _paymentProof!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      maxLength: 1000,
                      decoration: fieldDecoration(
                          text('ملاحظة (اختياري)', 'Note (optional)'))),
                  const SizedBox(height: 20),
                  Consumer<SellerPackageController>(
                      builder: (context, controller, _) => SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed:
                                controller.isSubmittingPayment ? null : _submit,
                            icon: controller.isSubmittingPayment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.check_circle_outline),
                            label: Text(controller.isSubmittingPayment
                                ? text('جارٍ الإرسال…', 'Submitting…')
                                : text('تأكيد الدفع', 'Confirm payment')),
                          ))),
                  const SizedBox(height: 20),
                ],
              ))),
    );
  }

  Future<void> _pickProof() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null && await picked.length() > 5 * 1024 * 1024) {
      if (mounted) {
        showCustomSnackBarWidget(
            text('الصورة أكبر من 5 ميجابايت. اختر صورة أصغر.',
                'The image exceeds 5 MB. Choose a smaller image.'),
            context,
            sanckBarType: SnackBarType.error);
      }
      return;
    }
    if (picked != null && mounted) {
      // The backend requires a multipart image in payment_proof, not text typed in a field.
      setState(() => _paymentProof = picked);
    }
  }

  Future<void> _submit() async {
    if (context.read<SellerPackageController>().isSubmittingPayment) return;
    if (!_formKey.currentState!.validate()) return;
    if (_paymentProof == null) {
      showCustomSnackBarWidget(
          getTranslated('payment_screenshot_required', context) ?? '', context,
          sanckBarType: SnackBarType.error);
      return;
    }

    final information = <String, String>{
      'transfer_reference': _transferReference.text.trim(),
      'sender_name': _senderNameController.text.trim(),
      'sender_wallet_or_phone': _senderPhoneController.text.trim(),
      for (final entry in _informationControllers.entries)
        entry.key: entry.value.text.trim(),
    };
    final submitted =
        await Provider.of<SellerPackageController>(context, listen: false)
            .submitOfflinePackagePayment(
      packageId: widget.plan.id,
      expectedPrice: widget.plan.packagePrice,
      methodId: widget.method.id,
      methodInformations: information,
      paymentProof: _paymentProof!,
      paymentNote: _noteController.text.trim(),
    );
    if (submitted && mounted) {
      showCustomSnackBarWidget(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'المعاملة قيد المراجعة.'
              : 'Transaction under review.',
          context,
          isError: false);
      Navigator.pop(context, true);
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
        Text(financeMoney(context, plan.packagePrice),
            style:
                titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ]),
    );
  }
}

class _TransferMethodHeader extends StatelessWidget {
  final bool instapay;
  const _TransferMethodHeader({required this.instapay});
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (instapay)
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/withdrawal/instapay.png',
                width: 80, height: 48, fit: BoxFit.cover))
      else
        Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: const Color(0xFFE7F5ED),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.phone_android_outlined,
                color: Color(0xFF11613D), size: 30)),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            instapay
                ? (ar ? 'التحويل عبر إنستا باي' : 'InstaPay transfer')
                : (ar
                    ? 'التحويل من محفظة إلكترونية'
                    : 'Electronic wallet transfer'),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
            instapay
                ? (ar
                    ? 'حوّل مبلغ الباقة إلى حساب إنستا باي الموضح، ثم أرفق إثبات العملية.'
                    : 'Transfer the package amount to the InstaPay account below, then attach your receipt.')
                : (ar
                    ? 'حوّل مبلغ الباقة إلى رقم المحفظة الموضح، ثم أرفق إثبات العملية.'
                    : 'Transfer the package amount to the wallet number below, then attach your receipt.'),
            style: Theme.of(context).textTheme.bodyMedium),
      ])),
    ]);
  }
}

class _PaymentBalanceReceipt extends StatelessWidget {
  final double? balance;
  final double price;
  const _PaymentBalanceReceipt({required this.balance, required this.price});
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    Widget line(String label, String value, {bool total = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: total ? const Color(0xFF1A428A) : null)))
        ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 8),
      const Icon(Icons.account_balance_wallet_outlined,
          size: 40, color: Color(0xFF1A428A)),
      const SizedBox(height: 12),
      Text(ar ? 'الدفع من خلال المحفظة' : 'Pay from your payments wallet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
          ar
              ? 'راجع المبلغ ثم أكّد الدفع. يتم تأكيد العملية تلقائيًا.'
              : 'Review the amount and confirm. Payment is confirmed automatically.',
          textAlign: TextAlign.center),
      const SizedBox(height: 16),
      line(ar ? 'رصيد المدفوعات الحالي' : 'Current payments balance',
          balance == null ? '—' : financeMoney(context, balance)),
      line(ar ? 'مبلغ الاشتراك' : 'Subscription amount',
          financeMoney(context, price)),
    ]);
  }
}
