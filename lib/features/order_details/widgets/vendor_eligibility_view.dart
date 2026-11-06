import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';

class VendorEligibilityLockCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback? onRefresh;
  const VendorEligibilityLockCard(
      {super.key, required this.summary, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final total = (summary['restricted_amount'] as num? ?? 0).toDouble();
    final at = DateTime.tryParse('${summary['forwarded_at']}');
    Future<void> packages() async {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SellerPackageScreen()));
      onRefresh?.call();
    }

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(Icons.lock_outline, color: Color(0xFFB42318)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            summary['pending_on_vendor_side'] == true
                                ? 'طلبات معلقة من جهة التاجر'
                                : 'تفاصيل تنفيذ مقيدة',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    const Badge(
                        backgroundColor: Color(0xFFB42318), label: Text('!'))
                  ]),
                  const SizedBox(height: 16),
                  Text(summary['details_locked'] == true
                      ? 'إجمالي طلب التنفيذ المستحق لك'
                      : 'إجمالي الجزء المقيد فقط'),
                  Text('${total.toStringAsFixed(2)} ج.م',
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (at != null)
                    Text(
                        'تحويل الإدارة: ${DateFormat('yyyy/MM/dd HH:mm').format(at.toLocal())}'),
                  const SizedBox(height: 16),
                  ClipRect(
                      child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: const ExcludeSemantics(
                              child: IgnorePointer(
                                  child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                          'تفاصيل المنتجات والتنفيذ\nـــــــــــــــــــــــــــــــــــ',
                                          textAlign: TextAlign.center)))))),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('عرض التفاصيل'),
                      onPressed: () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                                  title: const Text('برجاء اختيار إحدى الباقات',
                                      textDirection: TextDirection.rtl),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('إغلاق')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          packages();
                                        },
                                        child: const Text('اختيار باقة')),
                                  ]))),
                  FilledButton(
                      onPressed: packages, child: const Text('اختيار باقة')),
                  const Text(
                      'يظل الطلب محفوظًا دون إلغاء تلقائي أو غرامة بسبب القفل.',
                      textAlign: TextAlign.center),
                ],
              )),
        ));
  }
}

class VendorEligibilityView extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onRefresh;
  const VendorEligibilityView(
      {super.key, required this.order, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final summary = Map<String, dynamic>.from(order['fulfillment_eligibility']);
    final lines = order['order_details'] as List? ?? [];
    return Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text('طلب #${order['id']}',
                        style: Theme.of(context).textTheme.titleLarge)),
                VendorEligibilityLockCard(
                    summary: summary, onRefresh: onRefresh),
                if (summary['partially_locked'] == true) ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(spacing: 12, runSpacing: 8, children: [
                        for (final stage in const {
                          'confirmed': 'استلام الطلب',
                          'processing': 'جاري التجهيز',
                          'out_for_delivery': 'جاري الشحن',
                          'delivered': 'تم التسليم'
                        }.entries)
                          Chip(
                              avatar: Icon(
                                  order['order_status'] == stage.key
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 18),
                              label: Text(stage.value)),
                      ])),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                          'الجزء المتاح: ${(summary['accessible_amount'] as num).toStringAsFixed(2)} ج.م',
                          style: Theme.of(context).textTheme.titleLarge)),
                  for (final line in lines)
                    Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(
                                '${line['product_details']?['name'] ?? ''}'),
                            subtitle: Text(
                                'الكمية: ${line['qty']} — سعر التوريد: ${line['price']} ج.م'))),
                  if (order['shipping_address_data'] is Map)
                    Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('بيانات تسليم الجزء المتاح',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${order['shipping_address_data']['contact_person_name'] ?? ''}'),
                                  Text(
                                      '${order['shipping_address_data']['phone'] ?? ''}'),
                                  Text(
                                      '${order['shipping_address_data']['address'] ?? ''}'),
                                ]))),
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                          'الجزء المقيد منفصل عن المنتجات المتاحة أعلاه.')),
                ],
              ]),
        ));
  }
}
