import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

/// Shared by the profile and home. Content height follows text scaling.
class VendorAccountOverview extends StatelessWidget {
  const VendorAccountOverview({super.key});

  @override
  Widget build(BuildContext context) => Consumer<WalletController>(
      builder: (context, wallet, _) => VendorAccountOverviewContent(
          data: wallet.dashboardOverview?['account_overview'] as Map?,
          loading: wallet.overviewLoading,
          failed: wallet.overviewFailed,
          onRetry: wallet.getSellerDashboardOverview));
}

class VendorAccountOverviewContent extends StatelessWidget {
  final Map? data;
  final bool loading, failed;
  final VoidCallback onRetry;
  final void Function(String)? onNavigate;
  const VendorAccountOverviewContent(
      {super.key,
      this.data,
      this.loading = false,
      this.failed = false,
      required this.onRetry,
      this.onNavigate});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => getTranslated(key, context) ?? key;
    void open(String destination) {
      if (onNavigate != null) {
        onNavigate!(destination);
        return;
      }
      final Widget screen = switch (destination) {
        'subscriptions' => const SellerPackageScreen(),
        'spaces' => const ProductListMenuScreen(showAdvertisingSlots: true),
        'payments' => const SellerFinanceScreen(initialSection: 'operating'),
        _ => const SellerFinanceScreen(),
      };
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
          .then((_) {
        if (context.mounted) {
          context.read<WalletController>().getSellerDashboardOverview();
        }
      });
    }

    final subscription = data?['subscription'] as Map? ?? {};
    final balances = data?['balances'] as Map? ?? {};
    final capacity = data?['capacity'] as Map? ?? {};
    String count(String key) => '${capacity[key] ?? '—'}';
    String money(String bucket) => balances[bucket] is num
        ? PriceConverter.convertPrice(
            context, (balances[bucket] as num).toDouble())
        : '—';
    final expiry = DateTime.tryParse('${subscription['expires_at']}');
    final date = expiry == null
        ? null
        : MaterialLocalizations.of(context).formatMediumDate(expiry.toLocal());
    final cards = <Widget>[
      _OverviewTile(
          icon: Icons.workspace_premium_outlined,
          label: tr('phase5_current_package'),
          value: '${subscription['package_name'] ?? tr('phase5_no_package')}',
          details: [
            tr('phase5_status_${subscription['status'] ?? 'none'}'),
            if (date != null) '${tr('phase5_expires')} $date'
          ],
          action: tr(subscription['active'] == true
              ? 'vendor_subscriptions'
              : 'phase5_renew_package'),
          onTap: () => open('subscriptions')),
      _OverviewTile(
          icon: Icons.account_balance_wallet_outlined,
          label: tr('finance_my_wallet'),
          value: money('available'),
          details: [tr('phase5_wallet_hint')],
          action: tr('phase5_view_details'),
          onTap: () => open('wallet')),
      _OverviewTile(
          icon: Icons.payments_outlined,
          label: tr('phase5_payments'),
          value: money('operating'),
          details: [tr('phase5_payments_hint')],
          action: tr('phase5_view_details'),
          onTap: () => open('payments')),
      _OverviewTile(
          icon: Icons.grid_view_outlined,
          label: tr('phase5_spaces'),
          value:
              '\u2066${count('used')} / ${count('total')}\u2069 ${tr('phase5_used')}',
          details: [
            '${tr('phase5_available')}: ${count('available')} · ${tr('phase5_reserved')}: ${count('reserved')}',
            '${tr('phase5_included')}: ${count('included')} · ${tr('phase5_additional')}: ${count('additional')}'
          ],
          action: tr('phase5_manage_spaces'),
          onTap: () => open('spaces')),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (loading) ...[
        LinearProgressIndicator(semanticsLabel: tr('phase5_loading')),
        const SizedBox(height: 12)
      ],
      if (failed || (!loading && data == null)) ...[
        Text(tr(data == null ? 'phase5_load_failed' : 'phase5_stale'),
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
        Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
                onPressed: loading ? null : onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(tr('phase5_retry')))),
      ],
      if (data != null)
        LayoutBuilder(builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final columns = constraints.maxWidth >= 1100 && scale < 1.5
              ? 4
              : constraints.maxWidth >= 600 && scale < 1.5
                  ? 2
                  : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final card in cards) SizedBox(width: width, child: card)
          ]);
        }),
    ]);
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final String label, value, action;
  final List<String> details;
  final VoidCallback onTap;
  const _OverviewTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.details,
      required this.action,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(label,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Text(value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ])),
                const SizedBox(width: 16),
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: const Color(0xffedf2fb),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon,
                        color: Theme.of(context).colorScheme.primary)),
              ]),
              for (final detail in details)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(detail)),
              const SizedBox(height: 16),
              Text(action,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700)),
            ])),
      ));
}
