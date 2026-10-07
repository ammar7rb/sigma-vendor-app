import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/vendor_invoices_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class SellerDashboardOverviewWidget extends StatelessWidget {
  const SellerDashboardOverviewWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      Consumer<WalletController>(builder: (context, wallet, child) {
        final data = wallet.dashboardOverview;
        if (data == null) return const SizedBox.shrink();
        final sales = data['sales'] as Map? ?? {};
        final products = data['products'] as Map? ?? {};
        String tr(String key) => getTranslated(key, context) ?? key;
        void open(Widget screen) =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('store_overview'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(spacing: 24, runSpacing: 16, children: [
                            for (final item in [
                              ('orders', sales['orders_count']),
                              ('products', products['total']),
                              ('sold_units', sales['sold_units'])
                            ])
                              SizedBox(
                                  width: 120,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(tr(item.$1)),
                                        const SizedBox(height: 8),
                                        Text('${item.$2 ?? 0}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall)
                                      ]))
                          ]))),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                      onPressed: () => open(const ProductListMenuScreen()),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: Text(tr('manage_products'))),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    OutlinedButton(
                        onPressed: () => open(const SellerFinanceScreen()),
                        child: Text(tr('finance_my_wallet'))),
                    OutlinedButton(
                        onPressed: () => open(const VendorInvoicesScreen()),
                        child: Text(tr('vendor_invoices'))),
                    OutlinedButton(
                        onPressed: () => open(const SellerPackageScreen()),
                        child: Text(tr('ads_manager')))
                  ])
                ]));
      });
}
