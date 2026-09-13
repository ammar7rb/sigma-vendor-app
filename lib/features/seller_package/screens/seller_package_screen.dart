import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/seller_package/controllers/seller_package_controller.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_payment_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class SellerPackageScreen extends StatefulWidget {
  const SellerPackageScreen({super.key});

  @override
  State<SellerPackageScreen> createState() => _SellerPackageScreenState();
}

class _SellerPackageScreenState extends State<SellerPackageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = Provider.of<SellerPackageController>(context, listen: false);
      await controller.getOverview();
      final active = controller.overview?.subscription.active;
      if (active != null) await controller.getPerformance(active.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('advertising_packages', context) ?? 'Advertising packages'),
      body: Consumer<SellerPackageController>(
        builder: (context, controller, _) {
          final overview = controller.overview;
          if (overview == null) {
            return controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _EmptyState(onRefresh: controller.getOverview);
          }

          return RefreshIndicator(
            onRefresh: controller.getOverview,
            child: ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                _CurrentPackageCard(summary: overview.subscription),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(getTranslated('available_advertising_packages', context) ?? 'Available advertising packages', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                ...overview.packages.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: _PackagePlanCard(plan: plan, overview: overview),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CurrentPackageCard extends StatelessWidget {
  final SellerPackageSummary summary;

  const _CurrentPackageCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final subscription = summary.active;
    if (subscription == null) {
      final waiting = summary.pending;
      return _SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(waiting == null
              ? (getTranslated('no_active_package', context) ?? 'No active package')
              : (getTranslated('package_payment_under_review', context) ?? 'Package payment is under review'), style: titilliumSemiBold),
          if (waiting == null) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(getTranslated('choose_package_to_activate', context) ?? 'Choose a package below to renew or activate your subscription.', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
          ],
          if (waiting != null) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(waiting.packageName, style: titilliumRegular),
            Text('${getTranslated('payment_status', context) ?? 'Payment status'}: ${waiting.paymentStatus}', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
          ],
        ]),
      );
    }

    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.inventory_2_outlined),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Text(subscription.packageName, style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
          Text(subscription.paidPackagePrice.toStringAsFixed(2), style: titilliumSemiBold),
        ]),
        const Divider(height: Dimensions.paddingSizeLarge),
        _QuotaRow(icon: Icons.add_box_outlined, title: getTranslated('product_listings', context) ?? 'Product listings', value: subscription.remainingProductLimit),
        _QuotaRow(icon: Icons.search_outlined, title: getTranslated('search_promotions', context) ?? 'Search promotions', value: subscription.remainingSearchPromotionLimit),
        _QuotaRow(icon: Icons.home_outlined, title: getTranslated('homepage_promotions', context) ?? 'Homepage promotions', value: subscription.remainingHomepagePromotionLimit),
        _QuotaRow(icon: Icons.confirmation_number_outlined, title: getTranslated('coupons', context) ?? 'Coupons', value: subscription.remainingCouponLimit),
        Text(_durationText(context, subscription), style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        if (subscription.startedAt != null)
          Text('${getTranslated('started', context) ?? 'Started'}: ${_dateText(subscription.startedAt!)}', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        Text('${getTranslated('payment_status', context) ?? 'Payment status'}: ${subscription.paymentStatus}', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Consumer<SellerPackageController>(builder: (context, controller, _) {
          final performance = controller.performance;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (performance != null) Wrap(spacing: 12, runSpacing: 4, children: [
              Text('${getTranslated('search_impressions', context) ?? 'Impressions'}: ${performance.impressions}', style: titilliumRegular),
              Text('${getTranslated('product_visits', context) ?? 'Visits'}: ${performance.visits}', style: titilliumRegular),
              Text('${getTranslated('orders', context) ?? 'Orders'}: ${performance.orders}', style: titilliumRegular),
              Text('${getTranslated('sales_amount', context) ?? 'Sales'}: ${performance.salesAmount.toStringAsFixed(2)}', style: titilliumRegular),
            ]),
            if (!subscription.cancelAtPeriodEnd) TextButton.icon(
              onPressed: controller.isSubmittingPayment ? null : () => _requestCancellation(context, controller, subscription),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(getTranslated('cancel_package_no_refund', context) ?? 'Cancel package (no refund)'),
            ) else Text(getTranslated('cancellation_scheduled_for_period_end', context) ?? 'Cancellation scheduled for period end.', style: titilliumRegular.copyWith(color: Theme.of(context).colorScheme.error)),
          ]);
        }),
        if (subscription.expiresAt != null) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('${getTranslated('valid_until', context) ?? 'Valid until'}: ${_dateText(subscription.expiresAt!)}', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        ],
      ]),
    );
  }

  String _durationText(BuildContext context, SellerPackageSubscription subscription) {
    if (subscription.durationStatus == 'lifetime' || subscription.durationUnit == 'lifetime') return '${getTranslated('duration', context) ?? 'Duration'}: ${getTranslated('lifetime', context) ?? 'Lifetime'}';
    if (subscription.remainingDays != null) return '${getTranslated('remaining', context) ?? 'Remaining'}: ${subscription.remainingDays} ${getTranslated('days', context) ?? 'days'}';
    return '${getTranslated('duration', context) ?? 'Duration'}: ${subscription.durationValue} ${getTranslated(subscription.durationUnit, context) ?? subscription.durationUnit}';
  }

  String _dateText(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? value : parsed.toLocal().toString().split(' ').first;
  }

  Future<void> _requestCancellation(BuildContext context, SellerPackageController controller, SellerPackageSubscription subscription) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(getTranslated('cancel_package', context) ?? 'Cancel package'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(subscription.cancellationEffect == 'immediate'
            ? (getTranslated('package_cancel_immediate_no_refund', context) ?? 'Benefits stop immediately. No refund will be issued.')
            : (getTranslated('package_cancel_period_end_no_refund', context) ?? 'Benefits continue until the paid period ends. No refund will be issued.')),
        const SizedBox(height: 12),
        TextField(controller: reason, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: getTranslated('cancellation_reason', context) ?? 'Cancellation reason')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(getTranslated('back', context) ?? 'Back')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, reason.text.trim().length >= 3), child: Text(getTranslated('confirm_cancellation', context) ?? 'Confirm cancellation')),
      ],
    ));
    if (confirmed == true) await controller.cancelPackage(subscriptionId: subscription.id, reason: reason.text.trim());
    reason.dispose();
  }
}

class _PackagePlanCard extends StatelessWidget {
  final SellerPackagePlan plan;
  final SellerPackageOverviewModel overview;

  const _PackagePlanCard({required this.plan, required this.overview});

  @override
  Widget build(BuildContext context) {
    final canSelect = !overview.subscription.pendingReview;
    return InkWell(
      // Keep a pending offline request immutable until an admin approves or rejects it.
      onTap: canSelect ? () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => SellerPackagePaymentScreen(plan: plan, overview: overview),
      )) : null,
      borderRadius: BorderRadius.circular(8),
      child: _SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(plan.name, style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
          Text(plan.packagePrice.toStringAsFixed(2), style: titilliumSemiBold.copyWith(color: Theme.of(context).primaryColor)),
        ]),
        if (plan.description.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(plan.description, style: titilliumRegular),
        ],
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(spacing: Dimensions.paddingSizeDefault, runSpacing: Dimensions.paddingSizeExtraSmall, children: [
          _PlanFact(label: getTranslated('search', context) ?? 'Search', value: plan.searchPromotionLimit),
          _PlanFact(label: getTranslated('homepage', context) ?? 'Homepage', value: plan.homepagePromotionLimit),
          _PlanFact(label: getTranslated('coupons', context) ?? 'Coupons', value: plan.couponLimit),
          Text(_planDurationText(context, plan), style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        ]),
      ])),
    );
  }
}

String _planDurationText(BuildContext context, SellerPackagePlan plan) {
  if (plan.durationUnit == 'lifetime') return '${getTranslated('duration', context) ?? 'Duration'}: ${getTranslated('lifetime', context) ?? 'Lifetime'}';
  return '${getTranslated('duration', context) ?? 'Duration'}: ${plan.durationValue} ${getTranslated(plan.durationUnit, context) ?? plan.durationUnit}';
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
      ),
      child: child,
    );
  }
}

class _QuotaRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const _QuotaRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        Icon(icon, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(child: Text(title, style: titilliumRegular)),
        Text(value.toString(), style: titilliumSemiBold),
      ]),
    );
  }
}

class _PlanFact extends StatelessWidget {
  final String label;
  final int value;

  const _PlanFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor));
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: 'Retry',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
