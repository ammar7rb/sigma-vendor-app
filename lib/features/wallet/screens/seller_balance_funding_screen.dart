import 'package:dio/dio.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_navigation_actions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/widgets/transfer_account_details.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/funding_amount.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerBalanceFundingScreen extends StatefulWidget {
  final String walletTarget;
  const SellerBalanceFundingScreen({
    super.key,
    this.walletTarget = 'operating',
  });
  @override
  State<SellerBalanceFundingScreen> createState() =>
      _SellerBalanceFundingScreenState();
}

class _SellerBalanceFundingScreenState extends State<SellerBalanceFundingScreen>
    with WidgetsBindingObserver {
  final amount = TextEditingController(), note = TextEditingController();
  final transferReference = TextEditingController(),
      extraQuantity = TextEditingController(text: '1');
  String requestKey = withdrawalRequestKey();
  String purchaseKind = 'none';
  int? packageId;
  Map<String, dynamic>? fundingOptions;
  String? fundingError;
  String label(String ar, String en) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  List<Map<String, dynamic>> get plans =>
      (fundingOptions?['packages'] as List? ?? [])
          .map((p) => Map<String, dynamic>.from(p as Map))
          .toList();
  Map<String, dynamic>? get selectedPlan =>
      plans.where((p) => p['id'] == packageId).firstOrNull;
  final form = GlobalKey<FormState>();
  final Map<String, TextEditingController> information = {};
  XFile? proof;
  String? channel;
  bool loading = true, failed = false, sending = false;
  String tr(String key) => getTranslated(key, context) ?? key;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => reload());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    transferReference.dispose();
    extraQuantity.dispose();
    amount.dispose();
    note.dispose();
    for (final controller in information.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !sending) reload();
  }

  Future<void> reload() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      failed = false;
    });
    final success =
        await context.read<WalletController>().getSellerBalance(context);
    try {
      final response = await VendorWorkspace.instance.client
          .get('/api/v3/seller/balance/funding-intents');
      if (mounted) {
        setState(() {
          fundingOptions = Map<String, dynamic>.from(response.data as Map);
          packageId ??= plans.firstOrNull?['id'] as int?;
          fundingError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => fundingError = label(
            'تعذر تحميل اختيارات الشراء والسجل.',
            'Could not load purchase choices and history.'));
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
        failed = !success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletController>();
    final balance = wallet.sellerBalance;
    final method = balance == null ? null : _methodForChannel(balance, channel);
    final disabled = sending || wallet.isFunding;
    return Scaffold(
      appBar: AppBar(
          actions: const [VendorAddProductAction()],
          title: Text(tr('fund_purchase_balance'))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : failed || balance == null
              ? Center(
                  child: TextButton.icon(
                      onPressed: reload,
                      icon: const Icon(Icons.refresh),
                      label: Text(tr('finance_load_failed'))))
              : Form(
                  key: form,
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    Card(
                        child: ListTile(
                            leading: const Icon(
                                Icons.account_balance_wallet_outlined),
                            title: Text(tr('seller_purchase_balance_total')),
                            subtitle: Text(PriceConverter.convertPrice(
                                context, balance.summary['operating'] ?? 0)))),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(tr('finance_balance_notice'))),
                    ...purchaseControls(disabled),
                    TextFormField(
                        controller: transferReference,
                        enabled: !disabled,
                        maxLength: 191,
                        decoration: InputDecoration(
                            labelText: label(
                                'رقم عملية التحويل', 'Transfer reference'),
                            border: const OutlineInputBorder()),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? label('أدخل رقم التحويل.',
                                'Enter the transfer reference.')
                            : null),
                    TextFormField(
                        controller: amount,
                        enabled: !disabled,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                '${tr('enter_amount')} (${balance.fundingSettings['currency_code'] ?? ''})',
                            border: const OutlineInputBorder(),
                            helperText:
                                '${tr('finance_allowed_amount')}: ${balance.fundingSettings['min_amount']} - ${(double.tryParse('${balance.fundingSettings['max_amount']}') ?? 0) > 0 ? balance.fundingSettings['max_amount'] : '∞'}'),
                        validator: (value) {
                          final key = fundingAmountError(
                              value, balance.fundingSettings);
                          return key == null ? null : tr(key);
                        }),
                    const SizedBox(height: 16),
                    Text(tr('payment_method'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (context, constraints) {
                      final walletChoice = _PaymentChoiceCard(
                          icon: Icons.account_balance_wallet_outlined,
                          title: tr('electronic_wallet_payment'),
                          subtitle: tr('electronic_wallet_payment_hint'),
                          selected: channel == 'wallet',
                          onTap: disabled
                              ? null
                              : () => setState(() => channel = 'wallet'));
                      final instaPayChoice = _PaymentChoiceCard(
                          icon: Icons.account_balance_rounded,
                          title: tr('instapay_payment'),
                          subtitle: tr('instapay_payment_hint'),
                          selected: channel == 'instapay',
                          onTap: disabled
                              ? null
                              : () => setState(() => channel = 'instapay'));
                      if (constraints.maxWidth < 420) {
                        return Column(children: [
                          walletChoice,
                          const SizedBox(height: 10),
                          instaPayChoice,
                        ]);
                      }
                      return Row(children: [
                        Expanded(child: walletChoice),
                        const SizedBox(width: 10),
                        Expanded(child: instaPayChoice),
                      ]);
                    }),
                    const SizedBox(height: 16),
                    if (!balance.offlinePaymentAvailable ||
                        balance.offlinePaymentMethods.isEmpty)
                      Text(tr('transfer_service_unavailable'))
                    else if (channel == null)
                      Text(tr('select_transfer_channel'))
                    else if (method == null)
                      Text(tr('transfer_service_unavailable'))
                    else ...[
                      _TransferChannelHeader(
                        title: tr(channel == 'wallet'
                            ? 'electronic_wallet_payment'
                            : 'instapay_payment'),
                        subtitle: tr('balance_transfer_steps'),
                      ),
                      TransferAccountDetails(fields: method.methodFields),
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextFormField(
                              controller: information.putIfAbsent(
                                  '${method.id}:sender_name',
                                  () => TextEditingController()),
                              enabled: !disabled,
                              maxLength: 100,
                              decoration: InputDecoration(
                                  counterText: '',
                                  labelText:
                                      '${tr('transfer_sender_full_name')} *',
                                  border: const OutlineInputBorder()),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? tr('required')
                                  : null)),
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextFormField(
                              controller: information.putIfAbsent(
                                  '${method.id}:sender_wallet_or_phone',
                                  () => TextEditingController()),
                              enabled: !disabled,
                              keyboardType: TextInputType.phone,
                              maxLength: 30,
                              decoration: InputDecoration(
                                  counterText: '',
                                  labelText:
                                      '${tr('transfer_sender_number')} *',
                                  border: const OutlineInputBorder()),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? tr('required')
                                  : null)),
                      for (final field in method.methodInformations.where((f) =>
                          f.inputName.isNotEmpty &&
                          !const [
                            'payment_screenshot',
                            'transfer_reference',
                            'transaction_reference',
                            'transaction_id',
                            'reference_number',
                            'reference'
                          ].contains(f.inputName) &&
                          f.inputName != 'sender_name' &&
                          f.inputName != 'sender_wallet_or_phone'))
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextFormField(
                                controller: information.putIfAbsent(
                                    '${method.id}:${field.inputName}',
                                    () => TextEditingController()),
                                enabled: !disabled,
                                decoration: InputDecoration(
                                    labelText:
                                        '${_fieldLabel(field.inputName)}${field.isRequired ? ' *' : ''}',
                                    hintText: field.placeholder,
                                    border: const OutlineInputBorder()),
                                validator: (value) => field.isRequired &&
                                        (value ?? '').trim().isEmpty
                                    ? tr('complete_transfer_information')
                                    : null)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                          onPressed: disabled ? null : pickProof,
                          icon: const Icon(Icons.upload_file_outlined),
                          label:
                              Text(proof?.name ?? tr('upload_payment_proof'))),
                      TextFormField(
                          controller: note,
                          enabled: !disabled,
                          maxLines: 2,
                          maxLength: 1000,
                          decoration: InputDecoration(
                              labelText: tr('payment_note'),
                              border: const OutlineInputBorder())),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: disabled ||
                                method == null ||
                                !balance.offlinePaymentAvailable
                            ? null
                            : () => submit(wallet, balance, method),
                        icon: disabled
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send_outlined),
                        label: Text(tr('submit_admin_review'))),
                  ])),
    );
  }

  Future<void> pickProof() async {
    try {
      final picked = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked == null) return;
      if (await picked.length() > 5 * 1024 * 1024) {
        if (mounted) {
          showCustomSnackBarWidget(tr('finance_proof_limit'), context);
        }
      } else if (mounted) {
        setState(() => proof = picked);
      }
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(tr('finance_proof_failed'), context);
      }
    }
  }

  Future<void> submit(WalletController wallet, SellerBalanceModel balance,
      SellerOfflinePaymentMethod? method) async {
    if (sending || !form.currentState!.validate()) return;
    if (proof == null) {
      showCustomSnackBarWidget(tr('payment_proof_required'), context);
      return;
    }
    setState(() => sending = true);
    try {
      if (method != null) {
        final informationData = <String, String>{
          'sender_name':
              information['${method.id}:sender_name']?.text.trim() ?? '',
          'sender_wallet_or_phone':
              information['${method.id}:sender_wallet_or_phone']?.text.trim() ??
                  '',
          for (final f in method.methodInformations.where((f) =>
              !const [
                'payment_screenshot',
                'transfer_reference',
                'transaction_reference',
                'transaction_id',
                'reference_number',
                'reference'
              ].contains(f.inputName) &&
              f.inputName != 'sender_name' &&
              f.inputName != 'sender_wallet_or_phone'))
            f.inputName:
                information['${method.id}:${f.inputName}']?.text.trim() ?? ''
        };
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text(
                        label('تأكيد طلب الشحن', 'Confirm funding request')),
                    content: Text(
                        '${label('مبلغ الشحن', 'Funding amount')}: ${amount.text} EGP\n${purchaseKind == 'none' ? label('إضافة رصيد فقط', 'Credit balance only') : purchaseKind == 'package' ? '${selectedPlan?['name']} — ${selectedPlan?['package_price']} EGP' : '${extraQuantity.text} × ${fundingOptions?['extra_settings']['unit_price']} EGP'}'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(label('رجوع', 'Back'))),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(label('تأكيد', 'Confirm')))
                    ]));
        if (confirmed != true) return;
        final data = <String, dynamic>{
          'amount': amount.text.trim(),
          'method_id': method.id,
          'method_information': informationData,
          'transfer_reference': transferReference.text.trim(),
          'request_key': requestKey,
          'payment_note': note.text.trim(),
          'wallet_target': 'operating',
          'purchase_kind': purchaseKind,
          'payment_proof': MultipartFile.fromBytes(await proof!.readAsBytes(),
              filename: proof!.name)
        };
        if (purchaseKind == 'package') {
          data.addAll({
            'package_id': packageId,
            'expected_purchase_amount': selectedPlan?['package_price']
          });
        }
        if (purchaseKind == 'extra') {
          data.addAll({
            'subscription_id': fundingOptions?['subscription']['id'],
            'quantity': int.tryParse(extraQuantity.text),
            'expected_unit_price': fundingOptions?['extra_settings']
                ['unit_price']
          });
        }
        final response = await VendorWorkspace.instance.client.post(
            '/api/v3/seller/balance/offline-payment',
            data: FormData.fromMap(data));
        final success = response.statusCode == 200;
        if (success) await wallet.getSellerBalance();
        if (success && mounted) {
          showCustomSnackBarWidget(tr('deposit_submitted_review'), context,
              isError: false);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBarWidget(financeError(context, e), context);
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  List<Widget> purchaseControls(bool disabled) {
    final extras = fundingOptions?['extra_settings'] as Map?;
    final active = fundingOptions?['subscription'] as Map?;
    final intents = (fundingOptions?['intents']?['data'] as List? ?? []);
    return [
      if (fundingError != null)
        Text(fundingError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      DropdownButtonFormField<String>(
          initialValue: purchaseKind,
          isExpanded: true,
          decoration: InputDecoration(
              labelText: label('بعد اعتماد الشحن', 'After funding approval')),
          items: [
            DropdownMenuItem(
                value: 'none',
                child: Text(label('إضافة رصيد فقط', 'Credit balance only'))),
            if (plans.isNotEmpty)
              DropdownMenuItem(
                  value: 'package',
                  child: Text(label('شراء أو تجديد باقة أختارها',
                      'Buy or renew my selected plan'))),
            if (extras?['enabled'] == true && active != null)
              DropdownMenuItem(
                  value: 'extra',
                  child: Text(label('مساحات إضافية للدورة الحالية',
                      'Extra slots for the current cycle')))
          ],
          onChanged: disabled
              ? null
              : (value) => setState(() {
                    purchaseKind = value ?? 'none';
                    requestKey = withdrawalRequestKey();
                  })),
      if (purchaseKind == 'package') ...[
        DropdownButtonFormField<int>(
            initialValue: packageId,
            isExpanded: true,
            decoration: InputDecoration(
                labelText:
                    label('الباقة والسعر المثبت', 'Plan and fixed price')),
            items: plans
                .map((p) => DropdownMenuItem(
                    value: p['id'] as int,
                    child: Text('${p['name']} — ${p['package_price']} EGP')))
                .toList(),
            onChanged: disabled
                ? null
                : (value) => setState(() {
                      packageId = value;
                      requestKey = withdrawalRequestKey();
                    })),
        Text(label(
            'السعر والشروط محفوظة وقت الطلب. يبدأ التجديد بعد الدورات المدفوعة الحالية.',
            'Price and terms are fixed at submission. Renewal starts after all paid cycles.')),
      ],
      if (purchaseKind == 'extra') ...[
        TextFormField(
            controller: extraQuantity,
            enabled: !disabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText:
                    label('عدد المساحات الإضافية', 'Extra slot quantity')),
            validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                ? label(
                    'أدخل عددًا صحيحًا موجبًا.', 'Enter a positive quantity.')
                : null),
        Text(
            '${label('سعر المساحة', 'Unit price')}: ${extras?['unit_price']} EGP — ${label('تنتهي', 'Expires')}: ${active?['expires_at']}'),
        Text(label(
            'إذا انتهى الاشتراك قبل اعتماد التحويل، يبقى المبلغ معلقًا لتسوية يدوية دون رصيد أو مساحات.',
            'If the subscription expires before approval, the transfer stays pending for manual settlement without balance credit or slots.')),
      ],
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label(
              'الزيادة تبقى في رصيد المدفوعات. عند نقص الرصيد اضغط إعادة المحاولة بعد استكماله؛ لا تجديد دوري تلقائي.',
              'Surplus stays in operating. If funds are short, top up and press Retry; no recurring automatic renewal.'))),
      for (final raw in intents.take(5))
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${raw['deposit_id']} — ${raw['purchase_amount']} EGP'),
              Text(
                  '${raw['message'] ?? label('بانتظار اعتماد الشحن', 'Awaiting funding approval')}'),
              if (['insufficient_balance', 'action_required']
                  .contains(raw['status']))
                TextButton(
                    onPressed: disabled
                        ? null
                        : () async {
                            setState(() => sending = true);
                            try {
                              await VendorWorkspace.instance.client.post(
                                  '/api/v3/seller/balance/funding-intents/${raw['id']}/retry');
                              await reload();
                            } catch (e) {
                              if (mounted) {
                                showCustomSnackBarWidget(
                                    financeError(context, e), context);
                              }
                            } finally {
                              if (mounted) setState(() => sending = false);
                            }
                          },
                    child:
                        Text(label('إعادة محاولة الشراء', 'Retry purchase'))),
            ])),
    ];
  }

  SellerOfflinePaymentMethod? _methodForChannel(
      SellerBalanceModel balance, String? selectedChannel) {
    if (selectedChannel == null || balance.offlinePaymentMethods.isEmpty) {
      return null;
    }
    return transferMethodForChannel(
        balance.offlinePaymentMethods, selectedChannel);
  }

  String _fieldLabel(String inputName) => tr(inputName);
}

class _TransferChannelHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TransferChannelHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
        ]),
      );
}

class _PaymentChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  const _PaymentChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? Theme.of(context).primaryColor.withValues(alpha: .09)
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
              color: selected
                  ? AppDesign.foregroundAccent(Theme.of(context).brightness)
                  : Theme.of(context).dividerColor,
              width: selected ? 1.6 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon,
                    color: AppDesign.foregroundAccent(
                        Theme.of(context).brightness)),
                const Spacer(),
                Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected
                        ? AppDesign.foregroundAccent(
                            Theme.of(context).brightness)
                        : Theme.of(context).hintColor),
              ]),
              const SizedBox(height: 12),
              Text(title,
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      );
}
