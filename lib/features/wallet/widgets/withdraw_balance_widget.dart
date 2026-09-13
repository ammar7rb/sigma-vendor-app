import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_edit_dialog_widget.dart';

class WithdrawBalanceWidget extends StatelessWidget {
  final Future<void> Function()? onChanged;
  const WithdrawBalanceWidget({super.key, this.onChanged});
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletController>();
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.account_balance_outlined),
          label: Text(getTranslated('withdraw', context) ?? ''),
          onPressed: wallet.availableBalance <= 0
              ? null
              : () async {
                  await wallet.getWithdrawMethods(context);
                  if (!context.mounted) return;
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CustomEditDialogWidget(
                          totalEarning: wallet.availableBalance));
                  if (!context.mounted) return;
                  await wallet.getSellerBalance(context);
                  await onChanged?.call();
                },
        ));
  }
}
