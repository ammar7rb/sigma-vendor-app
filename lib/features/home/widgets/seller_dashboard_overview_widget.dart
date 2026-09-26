import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_balance_funding_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerDashboardOverviewWidget extends StatelessWidget {
  const SellerDashboardOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(builder: (context, wallet, _) {
      final data = wallet.dashboardOverview;
      if (data == null) return const SizedBox.shrink();
      final sales =
          Map<String, dynamic>.from(data['sales'] as Map? ?? const {});
      final products =
          Map<String, dynamic>.from(data['products'] as Map? ?? const {});
      final balances =
          Map<String, dynamic>.from(data['balances'] as Map? ?? const {});
      final insuranceWallet = Map<String, dynamic>.from(
          data['insurance_wallet'] as Map? ?? const {});
      final dueRows = List<Map<String, dynamic>>.from(
          (data['due_rows'] as List? ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map)));
      final shippingDueTotal = double.tryParse(
              '${balances['shipping_due_total']}') ??
          dueRows.fold<double>(
              0,
              (total, row) =>
                  total + (double.tryParse('${row['shipping_amount']}') ?? 0));
      final insuranceAvailable =
          double.tryParse('${balances['order_insurance_credit']}') ?? 0;
      final insuranceTotal = insuranceAvailable +
          (double.tryParse('${insuranceWallet['locked_amount']}') ?? 0) +
          (double.tryParse('${insuranceWallet['under_review_amount']}') ?? 0);
      final withdrawable = double.tryParse('${balances['available']}') ?? 0;
      final purchaseBalance = double.tryParse('${balances['operating']}') ?? 0;
      final walletTotal = withdrawable + purchaseBalance + insuranceAvailable;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final actionColor =
          isDark ? AppDesign.brandLight : Theme.of(context).primaryColor;

      void openFinance(String section) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SellerFinanceScreen(initialSection: section)));

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            boxShadow: AppDesign.softShadow(Theme.of(context).brightness)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(Icons.dashboard_customize_outlined,
                    color: actionColor)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    getTranslated('seller_dashboard_overview', context) ??
                        'Seller overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color))),
          ]),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: columns == 4 ? 164 : 178,
              children: [
                _Metric(
                    icon: Icons.check_circle_outline,
                    label: getTranslated('active_products', context) ??
                        'Active products',
                    value: (products['active'] ?? 0).toString(),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductListMenuScreen()))),
                _Metric(
                    icon: Icons.pending_actions_outlined,
                    label: getTranslated('seller_pending_products', context) ??
                        'Pending products',
                    value: '${products['under_review'] ?? 0}',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductListMenuScreen()))),
                _Metric(
                    icon: Icons.receipt_long_outlined,
                    label: getTranslated('review_orders', context) ?? 'Orders',
                    value: '${sales['orders_count'] ?? 0}',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OrderScreen(fromHome: true)))),
                _Metric(
                    icon: Icons.account_balance_wallet_outlined,
                    label: getTranslated('seller_wallet_total', context) ??
                        'Total wallet balance',
                    value: PriceConverter.convertPrice(context, walletTotal),
                    onTap: () => openFinance('balance')),
                _Metric(
                    icon: Icons.shopping_bag_outlined,
                    label: getTranslated(
                            'seller_purchase_balance_total', context) ??
                        'Total purchase balance',
                    value:
                        PriceConverter.convertPrice(context, purchaseBalance),
                    onTap: () => openFinance('balance')),
                _Metric(
                    icon: Icons.payments_outlined,
                    label:
                        getTranslated('total_sales', context) ?? 'Total sales',
                    value: PriceConverter.convertPrice(context,
                        double.tryParse('${sales['total_amount']}') ?? 0),
                    onTap: () => openFinance('orders')),
                _Metric(
                    icon: Icons.account_balance_outlined,
                    label:
                        getTranslated('seller_withdrawable_balance', context) ??
                            'Available to withdraw',
                    value: PriceConverter.convertPrice(context, withdrawable),
                    onTap: () => openFinance('balance')),
                _Metric(
                    icon: Icons.hourglass_top_rounded,
                    label: getTranslated('seller_due_balance_total', context) ??
                        'Total due balance',
                    value: PriceConverter.convertPrice(
                        context,
                        double.tryParse(
                                '${balances['pending_from_platform']}') ??
                            0),
                    onTap: () => openFinance('orders')),
                _Metric(
                    icon: Icons.shield_outlined,
                    label: getTranslated(
                            'seller_insurance_balance_total', context) ??
                        'Total insurance balance',
                    value: PriceConverter.convertPrice(context, insuranceTotal),
                    onTap: () => openFinance('insurance')),
                _Metric(
                    icon: Icons.local_shipping_outlined,
                    label:
                        getTranslated('seller_shipping_due_total', context) ??
                            'Total shipping due',
                    value:
                        PriceConverter.convertPrice(context, shippingDueTotal),
                    onTap: () => openFinance('shipping')),
              ],
            );
          }),
          if (dueRows.isNotEmpty) ...[
            const Divider(height: 24),
            Text(getTranslated('finance_order_dues', context) ??
                'Nearest due dates'),
            ...dueRows.take(3).map((row) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      '${row['order_reference'] ?? ''} | ${PriceConverter.convertPrice(context, double.tryParse('${row['sales_amount']}') ?? 0)}'),
                  subtitle:
                      Text(getTranslated('finance_due_notice', context) ?? ''),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WalletScreen())),
                )),
          ],
          const SizedBox(height: 14),
          OutlinedButtonTheme(
            data: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: actionColor,
                side: BorderSide(color: actionColor),
                backgroundColor:
                    isDark ? actionColor.withValues(alpha: .08) : null,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700
                  ? 3
                  : constraints.maxWidth >= 500
                      ? 2
                      : 1;
              final itemWidth =
                  (constraints.maxWidth - 8 * (columns - 1)) / columns;
              Widget item(Widget child) =>
                  SizedBox(width: itemWidth, height: 58, child: child);
              return Wrap(spacing: 8, runSpacing: 8, children: [
                item(OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SellerBalanceFundingScreen(
                                  walletTarget: 'operating')));
                      await wallet.getSellerDashboardOverview();
                    },
                    icon: const Icon(Icons.add_card),
                    label: Text(
                        getTranslated('fund_purchase_balance', context) ??
                            'Fund purchase balance'))),
                item(OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SellerBalanceFundingScreen(
                                  walletTarget: 'insurance')));
                      await wallet.getSellerDashboardOverview();
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: Text(
                        getTranslated('fund_insurance_balance', context) ??
                            'Fund insurance balance'))),
                item(OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SellerPackageScreen())),
                    icon: const Icon(Icons.campaign),
                    label: Text(
                        getTranslated('advertising_packages', context) ??
                            'Advertising packages'))),
                item(OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderScreen(fromHome: true))),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                        getTranslated('review_orders', context) ?? 'Orders'))),
                item(OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WalletScreen())),
                    icon: const Icon(Icons.shield_outlined),
                    label: Text(getTranslated('finance_my_wallet', context) ??
                        'Insurance & shipping'))),
                item(FilledButton.icon(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AddProductTabView(fromHome: true))),
                    icon: const Icon(Icons.add_box_outlined),
                    label: Text(getTranslated('add_product', context) ??
                        'Add product'))),
              ]);
            }),
          ),
        ]),
      );
    });
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isDark ? AppDesign.brandLight : Theme.of(context).primaryColor;
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 104),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? .18 : .12),
                      borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, size: 19, color: accent)),
              const SizedBox(height: 8),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: Theme.of(context).hintColor)),
              if (onTap != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Text(getTranslated('view_records', context) ?? 'View records',
                      style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: accent),
                ])
              ]
            ])));
  }
}
