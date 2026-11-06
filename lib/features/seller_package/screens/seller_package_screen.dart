import 'package:sixvalley_vendor_app/features/seller_package/widgets/seller_package_plan_card.dart';

import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_payment_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerPackageScreen extends StatefulWidget {
  const SellerPackageScreen({super.key});
  @override
  State<SellerPackageScreen> createState() => _SellerPackageScreenState();
}

class _SellerPackageScreenState extends State<SellerPackageScreen> {
  SellerPackageOverviewModel? overview;
  Map<String, dynamic>? summary;
  bool loading = true;
  String? error;
  String? transitionEndsAt;
  bool renewalAvailable = false;
  bool renewalEnabled = false;
  bool renewalConsent = false;
  bool renewalBusy = false;
  bool get arabic => Localizations.localeOf(context).languageCode == 'ar';
  String label(String ar, String en) => arabic ? ar : en;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final client = VendorWorkspace.instance.client;
      final response = await client.get('/api/v3/seller/packages');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        overview = SellerPackageOverviewModel.fromJson(data);
        summary = Map<String, dynamic>.from(data['subscription'] as Map);
        transitionEndsAt = data['transition_ends_at']?.toString();
        renewalAvailable = data['auto_renewal_available'] == true;
        renewalEnabled = data['auto_renewal_enabled'] == true;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> enableRenewal(Map active, SellerPackagePlan plan) async {
    if (renewalBusy || !renewalConsent) return;
    setState(() { renewalBusy = true; error = null; });
    try {
      await VendorWorkspace.instance.client.post('/api/v3/seller/packages/auto-renewal', data: {
        'subscription_id': active['id'], 'expected_price': plan.packagePrice,
      });
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => renewalBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = summary?['active'] as Map?;
    final pending = summary?['pending'] as Map?;
    final scheduled = summary?['scheduled'] as List? ?? [];
    final renewalPlans = (overview?.packages ?? <SellerPackagePlan>[]).where((p) => p.id == active?['package_id']);
    final renewalPlan = renewalPlans.isEmpty ? null : renewalPlans.first;
    final totalAds = num.tryParse('${active?['product_limit'] ?? ''}');
    final baseAds = num.tryParse('${active?['base_product_limit'] ?? ''}');
    final extras = totalAds == null || baseAds == null
        ? null
        : (totalAds > baseAds ? totalAds - baseAds : 0);
    return Scaffold(
        appBar:
            VendorFinanceAppBar(title: label('الاشتراكات', 'Subscriptions')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  if (error != null) ...[
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    TextButton(
                        onPressed: load,
                        child: Text(label('إعادة المحاولة', 'Retry')))
                  ],
                  if (active != null)
                    _panel(
                        '${active['package_name']}',
                        '${label('الإعلانات المتبقية', 'Remaining ads')}: ${active['remaining_product_limit'] ?? (active['product_publishing_unlimited'] == true ? label('غير محدودة', 'Unlimited') : '—')} • ${label('الإضافات', 'Extras')}: ${extras ?? '—'} • ${label('موعد انتهاء الاشتراك', 'Subscription expires')}: ${active['expires_at'] ?? '—'}'),
                  if (renewalAvailable && renewalEnabled)
                    _panel(label('التجديد التلقائي مفعل', 'Automatic renewal enabled'), label('لإلغائه تواصل مع الإدارة.', 'Contact administration to cancel.'))
                  else if (renewalAvailable && active != null && renewalPlan != null)
                    Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CheckboxListTile(contentPadding: EdgeInsets.zero, value: renewalConsent, onChanged: renewalBusy ? null : (value) => setState(() => renewalConsent = value == true), title: Text(label('تفعيل التجديد التلقائي', 'Enable automatic renewal')), subtitle: Text('${label('يخصم من الرصيد النقدي عند انتهاء الاشتراك', 'Charged from cash balance at expiry')}: ${financeMoney(context, renewalPlan.packagePrice)}')),
                      Text(label('يتوقف التجديد مع إشعار عند نقص الرصيد أو تغير السعر. لإلغائه تواصل مع الإدارة.', 'Renewal stops with a notification if funds are insufficient or the price changes. Contact administration to cancel.')),
                      FilledButton(onPressed: renewalConsent && !renewalBusy ? () => enableRenewal(active, renewalPlan) : null, child: Text(label('تأكيد التفعيل', 'Confirm'))),
                    ]))),
                  if (pending != null)
                    _panel(
                        summary?['pending_review'] == true ||
                                pending['status'] == 'pending_review'
                            ? label('المعاملة قيد المراجعة',
                                'Transaction under review')
                            : label('بانتظار إتمام الدفع', 'Awaiting payment'),
                        '${pending['package_name']}'),
                  for (final next in scheduled)
                    _panel(label('الدورة القادمة مدفوعة', 'Next cycle is paid'),
                        '${next['package_name']} — ${label('تبدأ', 'starts')} ${next['starts_at']}'),
                  const SizedBox(height: 12),
                  Text(label('الباقات المتاحة', 'Available packages'),
                      style: Theme.of(context).textTheme.titleLarge),
                  for (final plan
                      in overview?.packages ?? <SellerPackagePlan>[])
                    SellerPackagePlanCard(
                      plan: plan,
                      current: active?['package_id'] == plan.id,
                      selected: pending?['package_id'] == plan.id,
                      onSubscribe: summary?['pending_review'] == true
                          ? null
                          : () async {
                              await showSellerPackagePaymentDialog(context,
                                  plan: plan, overview: overview!);
                              if (mounted) await load();
                            },
                    ),
                ])));
  }

  Widget _panel(String title, String detail) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(detail),
          ])));
}
