import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/bank_info/screens/bank_editing_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerBankInfoScreen extends StatefulWidget {
  const SellerBankInfoScreen({super.key});

  @override
  State<SellerBankInfoScreen> createState() => _SellerBankInfoScreenState();
}

class _SellerBankInfoScreenState extends State<SellerBankInfoScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<BankInfoController>().getBankInfo(context);
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: getTranslated('bank_info', context), isBackButtonExist: true),
      body: Consumer<BankInfoController>(builder: (context, bank, _) {
        final info = bank.bankInfo;
        if (loading && info == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (info == null) {
          return Center(
              child: Padding(
                  padding: AppDesign.pagePadding,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.account_balance_outlined,
                        size: 54, color: AppDesign.primary),
                    const SizedBox(height: 12),
                    Text(
                        getTranslated('bank_info_load_failed', context) ??
                            'Unable to load bank information',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label:
                            Text(getTranslated('retry', context) ?? 'Retry')),
                  ])));
        }

        return ListView(padding: AppDesign.pagePadding, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
                border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: .14))),
            child: Row(children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.account_balance_outlined,
                      color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        getTranslated('vendor_bank_account', context) ??
                            'Settlement bank account',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(getTranslated('vendor_bank_info_hint', context) ?? '',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor)),
                  ])),
            ]),
          ),
          const SizedBox(height: 14),
          _BankCard(children: [
            _row(context, 'holder_name', info.holderName),
            _row(context, 'bank_name', info.bankName),
            _row(context, 'branch_name', info.branch),
            _row(context, 'account_no', _masked(info.accountNo)),
          ]),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BankEditingScreen(sellerModel: info)));
              await _load();
            },
            icon: const Icon(Icons.edit_outlined),
            label:
                Text(getTranslated('edit_info', context) ?? 'Edit information'),
          ),
        ]);
      }),
    );
  }

  Widget _row(BuildContext context, String key, String? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(children: [
          Expanded(
              child: Text(getTranslated(key, context) ?? key,
                  style: TextStyle(color: Theme.of(context).hintColor))),
          const SizedBox(width: 14),
          Flexible(
              child: Text(
                  (value == null || value.trim().isEmpty)
                      ? (getTranslated('not_added_yet', context) ?? '-')
                      : value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
        ]),
      );

  String? _masked(String? value) {
    if (value == null || value.length < 5) return value;
    return '${'•' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}

class _BankCard extends StatelessWidget {
  final List<Widget> children;
  const _BankCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: AppDesign.softShadow(Theme.of(context).brightness)),
        child: Column(children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) const Divider(height: 1)
          ]
        ]),
      );
}
