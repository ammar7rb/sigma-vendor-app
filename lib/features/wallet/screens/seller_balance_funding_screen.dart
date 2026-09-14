import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int? methodId;
  String? gateway;
  bool offline = true, loading = true, failed = false, sending = false;
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
    final method = balance?.offlinePaymentMethods
        .where((m) => m.id == methodId)
        .firstOrNull;
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _PaymentChoiceCard(
                              icon: Icons.account_balance_wallet_outlined,
                              title: tr('wallet_or_transfer'),
                              subtitle: tr('wallet_or_transfer_hint'),
                              selected: offline,
                              onTap: disabled
                                  ? null
                                  : () => setState(() => offline = true))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _PaymentChoiceCard(
                              icon: Icons.credit_card_rounded,
                              title: tr('visa_mastercard'),
                              subtitle: tr('secure_online_payment'),
                              selected: !offline,
                              onTap: disabled
                                  ? null
                                  : () => setState(() => offline = false))),
                    ]),
                    const SizedBox(height: 16),
                    if (offline) ...[
                      if (!balance.offlinePaymentAvailable ||
                          balance.offlinePaymentMethods.isEmpty)
                        Text(tr('no_offline_payment_method'))
                      else ...[
                        DropdownButtonFormField<int>(
                            initialValue: method?.id,
                            isExpanded: true,
                            decoration: InputDecoration(
                                labelText: tr('transfer_method'),
                                border: const OutlineInputBorder()),
                            items: balance.offlinePaymentMethods
                                .map((m) => DropdownMenuItem(
                                    value: m.id, child: Text(m.methodName)))
                                .toList(),
                            onChanged: disabled
                                ? null
                                : (id) => setState(() {
                                      methodId = id;
                                    }),
                            validator: (_) => method == null
                                ? tr('select_transfer_method')
                                : null),
                        if (method != null) ...[
                          for (final field in method.methodFields)
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: SelectableText(
                                    '${field.inputName}: ${field.inputData}')),
                          for (final field in method.methodInformations.where(
                              (f) =>
                                  f.inputName.isNotEmpty &&
                                  f.inputName != 'payment_screenshot'))
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextFormField(
                                    controller: information.putIfAbsent(
                                        '${method.id}:${field.inputName}',
                                        () => TextEditingController()),
                                    enabled: !disabled,
                                    decoration: InputDecoration(
                                        labelText:
                                            '${field.inputName}${field.isRequired ? ' *' : ''}',
                                        hintText: field.placeholder,
                                        border: const OutlineInputBorder()),
                                    validator: (value) => field.isRequired &&
                                            (value ?? '').trim().isEmpty
                                        ? tr('complete_transfer_information')
                                        : null)),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: disabled ? null : pickProof,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(
                                proof?.name ?? tr('upload_payment_proof'))),
                        TextFormField(
                            controller: note,
                            enabled: !disabled,
                            maxLines: 2,
                            maxLength: 1000,
                            decoration: InputDecoration(
                                labelText: tr('payment_note'),
                                border: const OutlineInputBorder())),
                      ],
                    ] else ...[
                      if (!balance.digitalPaymentAvailable ||
                          balance.paymentGateways.isEmpty)
                        Text(tr('no_digital_payment_method')),
                      for (final item in balance.paymentGateways)
                        Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                                leading: Icon(gateway == item.keyName
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off),
                                trailing: const Icon(Icons.credit_card_rounded),
                                title: Text(item.title),
                                onTap: disabled
                                    ? null
                                    : () => setState(() => gateway = item.keyName))),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: disabled ||
                                (offline
                                    ? !balance.offlinePaymentAvailable ||
                                        balance.offlinePaymentMethods.isEmpty
                                    : !balance.digitalPaymentAvailable ||
                                        balance.paymentGateways.isEmpty)
                            ? null
                            : () => submit(wallet, balance, method),
                        icon: disabled
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Icon(offline
                                ? Icons.send_outlined
                                : Icons.open_in_new),
                        label: Text(tr(offline
                            ? 'submit_admin_review'
                            : 'continue_to_payment'))),
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
    if (offline && proof == null) {
      showCustomSnackBarWidget(tr('payment_proof_required'), context);
      return;
    }
    if (!offline && !balance.paymentGateways.any((g) => g.keyName == gateway)) {
      showCustomSnackBarWidget(tr('select_payment_gateway'), context);
      return;
    }
    setState(() => sending = true);
    try {
      if (offline && method != null) {
        final success = await wallet.submitOfflineBalancePayment(
            amount: amount.text.trim(),
            methodId: method.id,
            methodInformations: {
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
      } else if (!offline) {
        final link = await wallet.payOperatingBalance(
            amount: amount.text.trim(),
            paymentMethod: gateway!,
            walletTarget: widget.walletTarget);
        if (link != null &&
            !await launchUrl(Uri.parse(link),
                mode: LaunchMode.externalApplication) &&
            mounted) {
          showCustomSnackBarWidget(tr('could_not_open_payment_page'), context);
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const Spacer(),
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
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
                  style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      );
}
