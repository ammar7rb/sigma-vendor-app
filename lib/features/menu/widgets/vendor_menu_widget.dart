import 'package:sixvalley_vendor_app/features/profile/screens/vendor_account_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/vendor_invoices_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

/// Vendor menu matching the customer application's visual language. Legacy
/// shop, clearance, VAT and global-restock entry points are intentionally not
/// exposed here.
class MenuBottomSheetWidget extends StatelessWidget {
  const MenuBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDesign.radiusLarge))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(9)))),
            const SizedBox(height: 18),
            Text(getTranslated('vendor_menu', context) ?? 'Vendor menu',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(getTranslated('vendor_menu_hint', context) ?? '',
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 18),
            _section(context, 'vendor_business_tools', [
              _MenuEntry(Icons.person_outline, 'vendor_account',
                  () => _open(context, const VendorAccountScreen())),
              _MenuEntry(
                  Icons.account_balance_wallet_outlined,
                  'finance_my_wallet',
                  () => _open(context, const SellerFinanceScreen())),
              _MenuEntry(Icons.receipt_long_outlined, 'vendor_invoices',
                  () => _open(context, const VendorInvoicesScreen())),
              _MenuEntry(Icons.inventory_2_outlined, 'my_order',
                  () => _open(context, const OrderScreen())),
              _MenuEntry(
                  Icons.mail_outline,
                  'administration_messages',
                  () =>
                      _open(context, const VendorInboxScreen(messages: true))),
              _MenuEntry(Icons.notifications_outlined, 'notification',
                  () => _open(context, const VendorInboxScreen())),
              _MenuEntry(Icons.campaign_outlined, 'ads_manager',
                  () => _open(context, const SellerPackageScreen())),
            ]),
            const SizedBox(height: 14),
            ListTile(
              tileColor: AppDesign.danger.withValues(alpha: .07),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
              leading: const Icon(Icons.logout, color: AppDesign.danger),
              title: Text(getTranslated('logout', context) ?? 'Logout',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppDesign.danger)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                await showModalBottomSheet(
                    context: Get.context!,
                    builder: (_) => const SignOutConfirmationDialogWidget());
              },
            ),
            const SizedBox(height: 12),
            Center(
                child: Text(
                    '${getTranslated('app_version', context) ?? 'Version'} ${AppConstants.appVersion}',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).hintColor))),
          ]),
        ),
      ),
    );
  }

  Widget _section(
          BuildContext context, String titleKey, List<_MenuEntry> entries) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated(titleKey, context) ?? titleKey,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: columns == 3 ? 3 : 2.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (_, index) => _MenuTile(entry: entries[index]),
          );
        }),
      ]);

  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Future.microtask(() => Navigator.push(
        Get.context!, MaterialPageRoute(builder: (_) => screen)));
  }
}

class _MenuEntry {
  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;
  const _MenuEntry(this.icon, this.labelKey, this.onTap);
}

class _MenuTile extends StatelessWidget {
  final _MenuEntry entry;
  const _MenuTile({required this.entry});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          onTap: entry.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(entry.icon,
                      size: 20,
                      color: AppDesign.foregroundAccent(
                          Theme.of(context).brightness))),
              const SizedBox(width: 9),
              Expanded(
                  child: Text(
                      getTranslated(entry.labelKey, context) ?? entry.labelKey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      );
}
