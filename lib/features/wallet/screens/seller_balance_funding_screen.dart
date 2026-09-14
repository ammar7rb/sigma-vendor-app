import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/funding_amount.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

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
          title: Text(tr(widget.walletTarget == 'insurance'
              ? 'fund_insurance_balance'
              : 'fund_purchase_balance'))),
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
                            title: Text(tr(widget.walletTarget == 'insurance'
                                ? 'order_insurance_credit'
                                : 'seller_purchase_balance_total')),
                            subtitle: Text(PriceConverter.convertPrice(
                                context,
                                balance.summary[
                                        widget.walletTarget == 'insurance'
                                            ? 'order_insurance_credit'
                                            : 'operating'] ??
                                    0)))),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(tr('finance_balance_notice'))),
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
                    Row(children: [
                      Expanded(
                          child: _PaymentChoiceCard(
                              icon: Icons.account_balance_wallet_outlined,
                              title: tr('electronic_wallet_payment'),
                              subtitle: tr('electronic_wallet_payment_hint'),
                              selected: channel == 'wallet',
                              onTap: disabled
                                  ? null
                                  : () => setState(() => channel = 'wallet'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _PaymentChoiceCard(
                              icon: Icons.account_balance_rounded,
                              title: tr('instapay_payment'),
                              subtitle: tr('instapay_payment_hint'),
                              selected: channel == 'instapay',
                              onTap: disabled
                                  ? null
                                  : () =>
                                      setState(() => channel = 'instapay'))),
                    ]),
                    const SizedBox(height: 16),
                    if (!balance.offlinePaymentAvailable ||
                        balance.offlinePaymentMethods.isEmpty)
                      Text(tr('transfer_service_unavailable'))
                    else if (channel == null)
                      Text(tr('select_transfer_channel'))
                    else if (method != null) ...[
                      _TransferChannelHeader(
                        title: tr(channel == 'wallet'
                            ? 'electronic_wallet_payment'
                            : 'instapay_payment'),
                        subtitle: tr('transfer_using_admin_details'),
                      ),
                      for (final field in method.methodFields)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SelectableText(
                                '${_fieldLabel(field.inputName)}: ${field.inputData}')),
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
                                  labelText: '${tr('sender_name')} *',
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
                                      '${tr('sender_phone_or_account')} *',
                                  border: const OutlineInputBorder()),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? tr('required')
                                  : null)),
                      for (final field in method.methodInformations.where((f) =>
                          f.inputName.isNotEmpty &&
                          f.inputName != 'payment_screenshot' &&
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
        final success = await wallet.submitOfflineBalancePayment(
            amount: amount.text.trim(),
            methodId: method.id,
            methodInformations: {
              'sender_name':
                  information['${method.id}:sender_name']?.text.trim() ?? '',
              'sender_wallet_or_phone':
                  information['${method.id}:sender_wallet_or_phone']
                          ?.text
                          .trim() ??
                      '',
              for (final f in method.methodInformations
                  .where((f) => f.inputName != 'payment_screenshot'))
                f.inputName:
                    information['${method.id}:${f.inputName}']?.text.trim() ??
                        ''
            },
            paymentProof: proof!,
            paymentNote: note.text.trim(),
            walletTarget: widget.walletTarget);
        if (success && mounted) {
          showCustomSnackBarWidget(tr('deposit_submitted_review'), context,
              isError: false);
          Navigator.pop(context);
        }
      }
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(tr('finance_submit_failed'), context);
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  SellerOfflinePaymentMethod? _methodForChannel(
      SellerBalanceModel balance, String? selectedChannel) {
    if (selectedChannel == null || balance.offlinePaymentMethods.isEmpty)
      return null;
    final methods = balance.offlinePaymentMethods;
    bool matches(SellerOfflinePaymentMethod method, String needle) {
      final searchable =
          '${method.methodName} ${method.methodFields.map((field) => '${field.inputName} ${field.inputData}').join(' ')}'
              .toLowerCase();
      return searchable.contains(needle);
    }

    if (selectedChannel == 'instapay') {
      return methods
              .where((method) =>
                  matches(method, 'insta') || matches(method, 'انستا'))
              .firstOrNull ??
          (methods.length > 1 ? methods[1] : methods.first);
    }
    return methods
            .where((method) =>
                matches(method, 'wallet') || matches(method, 'محفظ'))
            .firstOrNull ??
        methods.first;
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
                  ? Theme.of(context).primaryColor
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
                Icon(icon, color: Theme.of(context).primaryColor),
                const Spacer(),
                Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected
                        ? Theme.of(context).primaryColor
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
