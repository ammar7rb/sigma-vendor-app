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
  bool renewing = false;
  bool autoRenewalAvailable = false;
  bool autoRenewalEnabled = false;
  String? error;
  String? transitionEndsAt;
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
        autoRenewalAvailable = data['auto_renewal_available'] == true;
        autoRenewalEnabled = data['auto_renewal_enabled'] == true;
        transitionEndsAt = data['transition_ends_at']?.toString();
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = summary?['active'] as Map?;
    final pending = summary?['pending'] as Map?;
    final scheduled = summary?['scheduled'] as List? ?? [];
    final plans = overview?.packages ?? <SellerPackagePlan>[];
    SellerPackagePlan? activePlan;
    for (final plan in plans) {
      if (plan.id == active?['package_id']) activePlan = plan;
    }
    final highestPrice = plans.fold<double>(
        0, (highest, plan) => plan.packagePrice > highest ? plan.packagePrice : highest);
    final onHighest = activePlan != null &&
        activePlan.packagePrice >= highestPrice &&
        highestPrice > 0;
    String actionFor(SellerPackagePlan plan) {
      if (active?['package_id'] == plan.id) {
        return label('تجديد الآن', 'Renew now');
      }
      if (active == null) return label('اشترك الآن', 'Subscribe now');
      if (onHighest) return label('اشترك', 'Subscribe');
      final activeLimit = activePlan?.productLimit ?? 0;
      final higher = activeLimit > 0 && plan.productLimit > 0
          ? plan.productLimit > activeLimit
          : plan.packagePrice > (activePlan?.packagePrice ?? 0);
      return higher
          ? label('ترقية', 'Upgrade')
          : label('تغيير الباقة', 'Change package');
    }
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
                  if (active == null)
                    _panel(label('الباقة المجانية', 'Free package'),
                        label('أنت على الباقة المجانية', 'You are on the free package')),
                  if (active != null)
                    _panel(
                        '${active['package_name']}',
                        '${label('موعد انتهاء الاشتراك', 'Subscription expires')}: ${active['expires_at'] ?? '—'}'),
                  if (active != null && autoRenewalEnabled)
                    _panel(label('التجديد التلقائي', 'Automatic renewal'),
                        label('التجديد التلقائي مفعّل. لإلغائه تواصل مع الإدارة.',
                            'Automatic renewal is on. Contact administration to cancel it.')),
                  if (active != null && autoRenewalAvailable && !autoRenewalEnabled)
                    FilledButton(
                        onPressed: renewing ? null : () => enableAutoRenewal(active),
                        child: Text(renewing
                            ? label('جارٍ التفعيل', 'Enabling')
                            : label('تفعيل التجديد التلقائي', 'Enable automatic renewal'))),
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
                      actionLabel: actionFor(plan),
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

  Future<void> enableAutoRenewal(Map active) async {
    SellerPackagePlan? plan;
    for (final item in overview?.packages ?? <SellerPackagePlan>[]) {
      if (item.id == active['package_id']) plan = item;
    }
    final price = plan?.packagePrice ??
        double.tryParse('${active['paid_package_price']}') ??
        0;
    if (price <= 0) {
      setState(() => error = label('تعذر قراءة سعر الباقة الحالية',
          'The current package price is unavailable'));
      return;
    }
    setState(() => renewing = true);
    try {
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/packages/auto-renewal', data: {
        'subscription_id': active['id'],
        'expected_price': price,
      });
      if (mounted) await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => renewing = false);
    }
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
