import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_account_overview.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class SellerDashboardOverviewWidget extends StatelessWidget {
  const SellerDashboardOverviewWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      Consumer<WalletController>(builder: (context, wallet, child) {
        final data = wallet.dashboardOverview;
        if (data == null) {
          return const Padding(
              padding: EdgeInsets.all(16), child: VendorAccountOverview());
        }
        final sales = data['sales'] as Map? ?? {};
        final capacity = data['account_overview']?['capacity'] as Map? ?? {};
        String tr(String key) => getTranslated(key, context) ?? key;
        void open(Widget screen) =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const VendorAccountOverview(),
                  const SizedBox(height: 24),
                  Text(tr('store_overview'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                      builder: (context, constraints) =>
                          Wrap(spacing: 12, runSpacing: 12, children: [
                            for (final item in [
                              (
                                'orders',
                                sales['received_orders_count'],
                                Icons.shopping_bag_outlined
                              ),
                              (
                                'phase5_spaces',
                                capacity['total'],
                                Icons.inventory_2_outlined
                              ),
                              (
                                'sold_units',
                                sales['sold_units'],
                                Icons.bar_chart_outlined
                              )
                            ])
                              SizedBox(
                                  width: constraints.maxWidth >= 600
                                      ? (constraints.maxWidth - 24) / 3
                                      : constraints.maxWidth,
                                  child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(children: [
                                            Icon(item.$3,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                size: 28),
                                            const SizedBox(width: 16),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(tr(item.$1)),
                                                  const SizedBox(height: 8),
                                                  Text('${item.$2 ?? 0}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium)
                                                ]))
                                          ]))))
                          ])),
                  const SizedBox(height: 20),
                  Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            Text(tr('grow_your_catalogue'),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(tr('grow_your_catalogue_hint'),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                                onPressed: () => open(
                                    const AddProductTabView(fromHome: true)),
                                icon: const Icon(Icons.add_box_outlined),
                                label: Text(tr('add_new_product')))
                          ]))),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                      onPressed: () => open(const ProductListMenuScreen()),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: Text(tr('phase5_manage_spaces'))),
                ]));
      });
}
