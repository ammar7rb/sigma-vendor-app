import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_extra_ads_screen.dart';
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
  List<Map<String, dynamic>> slots = [];
  List<Map<String, dynamic>> products = [];
  bool loading = true;
  bool saving = false;
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
      final spaces = await client.get('/api/v3/seller/packages/slots');
      if (!mounted) return;
      setState(() {
        overview = SellerPackageOverviewModel.fromJson(data);
        summary = Map<String, dynamic>.from(data['subscription'] as Map);
        transitionEndsAt = data['transition_ends_at']?.toString();
        slots = (spaces.data['slots'] as List)
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        products = (spaces.data['products'] as List)
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> assign(Map<String, dynamic> slot, int? productId) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final response = await VendorWorkspace.instance.client.post(
          '/api/v3/seller/packages/slots/${slot['id']}',
          data: {'product_id': productId});
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.data['message']}')));
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = summary?['active'] as Map?;
    final pending = summary?['pending'] as Map?;
    final scheduled = summary?['scheduled'] as List? ?? [];
    return Scaffold(
        appBar: VendorFinanceAppBar(
            title: label(
                'الباقات ومساحات الإعلانات', 'Packages and advertising slots')),
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
                  Text(label(
                      'كل مساحة مدتها 30 يومًا من بداية الاشتراك. تغيير المنتج لا يمددها. الأسعار نهائية والتجديد يدوي.',
                      'Every slot lasts 30 days from subscription start. Replacing a product keeps its expiry. Prices are final; renewal is manual.')),
                  const SizedBox(height: 16),
                  if (active != null)
                    _panel('${active['package_name']}',
                        '${active['product_limit']} ${label('مساحة — حتى', 'slots — until')} ${active['expires_at']}')
                  else
                    _panel(
                        label('لا يوجد اشتراك سارٍ', 'No active subscription'),
                        label(
                            'اشترك لنشر المنتجات واستقبال طلبات جديدة. يمكنك إكمال الطلبات القائمة. للبائعين الحاليين مهلة انتقالية 7 أيام من الإطلاق.',
                            'Subscribe to publish products and receive new orders. Existing orders can still be completed. Existing vendors have a seven-day transition period.')),
                  if (pending != null)
                    _panel(label('طلب دفع قيد المتابعة', 'Pending payment'),
                        '${pending['package_name']} — ${pending['status']}'),
                  for (final next in scheduled)
                    _panel(label('الدورة القادمة مدفوعة', 'Next cycle is paid'),
                        '${next['package_name']} — ${label('تبدأ', 'starts')} ${next['starts_at']}'),
                  const SizedBox(height: 12),
                  if (active == null && transitionEndsAt != null)
                    Text(
                        '${label('نهاية مهلة البائعين الحاليين بتوقيت القاهرة:', 'Existing vendors transition ends (Cairo):')} $transitionEndsAt'),
                  if (overview != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: OutlinedButton.icon(
                            icon: const Icon(Icons.add_business_outlined),
                            label: Text(label('شراء ومتابعة المساحات الإضافية',
                                'Buy and track extra slots')),
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SellerExtraAdsScreen(
                                          subscription: active == null
                                              ? null
                                              : Map<String, dynamic>.from(
                                                  active),
                                          overview: overview!)));
                              if (mounted) await load();
                            })),
                  Text(label('الباقات المتاحة', 'Available packages'),
                      style: Theme.of(context).textTheme.titleLarge),
                  for (final plan
                      in overview?.packages ?? <SellerPackagePlan>[])
                    Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plan.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  Text(
                                      '${plan.productLimit} ${label('مساحة • 30 يومًا', 'slots • 30 days')}'),
                                  Text(financeMoney(context, plan.packagePrice),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                      onPressed:
                                          summary?['pending_review'] == true
                                              ? null
                                              : () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              SellerPackagePaymentScreen(
                                                                  plan: plan,
                                                                  overview:
                                                                      overview!)));
                                                  if (mounted) await load();
                                                },
                                      child: Text(label(
                                          'شراء أو تجديد', 'Buy or renew'))),
                                ]))),
                  const SizedBox(height: 16),
                  Text(label('مساحاتي', 'My slots'),
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(label(
                      'المنتج البديل يخضع لمراجعة الإدارة. عند تخفيض الباقة اختر المنتجات التي ستستمر.',
                      'Replacement products require admin review. When downgrading, choose which products continue.')),
                  if (slots.isEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(label(
                            'لا توجد مساحات سارية.', 'No current slots.'))),
                  for (final slot in slots)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${label('المساحة', 'Slot')} ${slot['position']}'),
                                  if (slot['editable'] == false)
                                    Text(label('مجمدة حتى تجديد الاشتراك',
                                        'Frozen until renewal')),
                                  Text(
                                      '${label('حتى', 'Until')} ${slot['expires_at']}'),
                                  if (slot['product'] is Map)
                                    Text(
                                        '${slot['product']['name']} — ${slot['product']['request_status'] == 1 ? label('معتمد', 'Approved') : label('بانتظار المراجعة', 'Awaiting review')}'),
                                  DropdownButtonFormField<int>(
                                      key: ValueKey(
                                          '${slot['id']}-${slot['product_id']}'),
                                      initialValue: products.any((p) =>
                                              p['id'] == slot['product_id'])
                                          ? slot['product_id'] as int?
                                          : null,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                          labelText: label('المنتج المرتبط',
                                              'Assigned product')),
                                      items: [
                                        DropdownMenuItem<int>(
                                            value: null,
                                            child: Text(label('إفراغ المساحة',
                                                'Empty slot'))),
                                        ...products.map((p) =>
                                            DropdownMenuItem<int>(
                                                value: p['id'] as int,
                                                child: Text('${p['name']}',
                                                    overflow:
                                                        TextOverflow.ellipsis)))
                                      ],
                                      onChanged:
                                          saving || slot['editable'] == false
                                              ? null
                                              : (id) => assign(slot, id)),
                                ]))),
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
