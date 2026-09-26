import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/bank_info/screens/seller_bank_info_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/profile_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/theme_changer_widget.dart';
import 'package:sixvalley_vendor_app/features/settings/screens/setting_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const SellerProfileScreen({super.key, this.showBackButton = true});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = context.read<ProfileController>();
      if (profile.userInfoModel == null) await profile.getSellerInfo();
      if (mounted) {
        await context.read<WalletController>().getSellerDashboardOverview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          isBackButtonExist: widget.showBackButton,
          title: getTranslated('my_profile', context)),
      body: Consumer2<ProfileController, WalletController>(
          builder: (context, profile, wallet, _) {
        final seller = profile.userInfoModel;
        if (seller == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final overview = wallet.dashboardOverview ?? const <String, dynamic>{};
        final balances =
            Map<String, dynamic>.from(overview['balances'] as Map? ?? const {});
        final products =
            Map<String, dynamic>.from(overview['products'] as Map? ?? const {});

        return RefreshIndicator(
          onRefresh: () async {
            await profile.getSellerInfo();
            await wallet.getSellerDashboardOverview();
          },
          child: ListView(padding: AppDesign.pagePadding, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: AppDesign.brandGradient,
                  borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
                  boxShadow:
                      AppDesign.softShadow(Theme.of(context).brightness)),
              child: Row(children: [
                Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                      child: CustomImageWidget(
                          image: seller.imageFullUrl?.path ?? '',
                          fit: BoxFit.cover)),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${seller.fName ?? ''} ${seller.lName ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(seller.email ?? seller.phone ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .84),
                              fontSize: 12)),
                      const SizedBox(height: 9),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen())),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .17),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                getTranslated('edit_profile', context) ??
                                    'Edit profile',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700))),
                      ),
                    ])),
              ]),
            ),
            const SizedBox(height: 16),
            Text(
                getTranslated('vendor_account_summary', context) ??
                    'Account summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _SummaryCard(
                      icon: Icons.inventory_2_outlined,
                      label: getTranslated('products', context) ?? 'Products',
                      value: '${products['total'] ?? seller.productCount ?? 0}',
                      onTap: () => _open(const ProductListMenuScreen())),
                  _SummaryCard(
                      icon: Icons.receipt_long_outlined,
                      label: getTranslated('orders', context) ?? 'Orders',
                      value: '${seller.ordersCount ?? 0}',
                      onTap: () => _open(const OrderScreen(fromHome: true))),
                  _SummaryCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: getTranslated('seller_due_balance', context) ??
                          'Due balance',
                      value: _money(balances['available']),
                      onTap: () => _open(const WalletScreen())),
                  _SummaryCard(
                      icon: Icons.shield_outlined,
                      label: getTranslated('order_insurance_credit', context) ??
                          'Insurance',
                      value: _money(balances['order_insurance_credit']),
                      onTap: () => _open(const WalletScreen())),
                ],
              );
            }),
            const SizedBox(height: 16),
            _ActionCard(
                icon: Icons.account_balance_outlined,
                title:
                    getTranslated('bank_info', context) ?? 'Bank information',
                subtitle: getTranslated('vendor_bank_info_hint', context) ?? '',
                onTap: () => _open(const SellerBankInfoScreen())),
            const SizedBox(height: 10),
            _ActionCard(
                icon: Icons.settings_outlined,
                title: getTranslated('settings', context) ?? 'Settings',
                subtitle: getTranslated('vendor_settings_hint', context) ?? '',
                onTap: () => _open(const SettingsScreen())),
            const SizedBox(height: 10),
            const ThemeChangerWidget(),
            const SizedBox(height: 18),
          ]),
        );
      }),
    );
  }

  String _money(dynamic value) => PriceConverter.convertPrice(
      context, double.tryParse('${value ?? 0}') ?? 0);
  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SummaryCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon,
                            size: 20,
                            color: AppDesign.foregroundAccent(Theme.of(context).brightness))),
                    const Spacer(),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).hintColor)),
                  ])),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon,
                  color: AppDesign.foregroundAccent(Theme.of(context).brightness))),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: subtitle.isEmpty
              ? null
              : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
