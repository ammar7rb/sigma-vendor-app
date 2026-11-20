import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/vendor_motion.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

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
          accent: const Color(0xFF7C4DFF),
          onTap: () => open('subscriptions')),
      _OverviewTile(
          icon: Icons.account_balance_wallet_outlined,
          label: tr('finance_my_wallet'),
          value: money('available'),
          details: [tr('phase5_wallet_hint')],
          action: tr('phase5_view_details'),
          accent: AppDesign.success,
          onTap: () => open('wallet')),
      _OverviewTile(
          icon: Icons.payments_outlined,
          label: tr('phase5_payments'),
          value: money('operating'),
          details: [tr('phase5_payments_hint')],
          action: tr('phase5_view_details'),
          accent: AppDesign.primary,
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
          accent: const Color(0xFF0288D1),
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
            for (final (index, card) in cards.indexed)
              SizedBox(
                  width: width,
                  child: FadeSlideIn(index: index, child: card))
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
  final Color accent;
  const _OverviewTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.details,
      required this.action,
      required this.onTap,
      this.accent = AppDesign.primary});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      onTap: onTap,
      pressedScale: .97,
      semanticLabel: '$label $value',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: dark ? .35 : .18)),
            boxShadow: AppDesign.softShadow(Theme.of(context).brightness)),
        child: Stack(children: [
          PositionedDirectional(
              top: -28,
              end: -28,
              child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: dark ? .14 : .07)))),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: AlignmentDirectional.topStart,
                                  end: AlignmentDirectional.bottomEnd,
                                  colors: [
                                    accent.withValues(alpha: .75),
                                    accent
                                  ]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: accent.withValues(alpha: .3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: Icon(icon, color: Colors.white, size: 25)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context).hintColor)),
                            const SizedBox(height: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(value,
                                  key: ValueKey(value),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                            ),
                          ])),
                    ]),
                    for (final detail in details)
                      Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(detail,
                              style: Theme.of(context).textTheme.bodySmall)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Text(action,
                          style: TextStyle(
                              color: accent, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 18,
                          color: accent,
                          textDirection: Directionality.of(context)),
                    ]),
                  ])),
        ]),
      ),
    );
  }
}
