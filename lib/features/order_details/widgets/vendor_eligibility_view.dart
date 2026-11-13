import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';

class VendorEligibilityLockCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback? onRefresh;
  const VendorEligibilityLockCard(
      {super.key, required this.summary, this.onRefresh});

  static const _primary = Color(0xFF1A428A);
  static const _accent = Color(0xFF2F6FD6);

  Widget _bar(double width, {double height = 12}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: const Color(0xFFC9D8F0),
          borderRadius: BorderRadius.circular(6)));

  @override
  Widget build(BuildContext context) {
    final total = (summary['restricted_amount'] as num? ?? 0).toDouble();
    final fullyLocked = summary['details_locked'] == true;
    Future<void> packages() async {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SellerPackageScreen()));
      onRefresh?.call();
    }

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD6E2F5)),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEDF3FD), Colors.white])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                            colors: [_primary, _accent])),
                    child: const Icon(Icons.lock_outline, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          fullyLocked
                              ? 'عندك طلب جديد في انتظارك!'
                              : 'جزء من الطلب في انتظار الباقة',
                          style: const TextStyle(
                              color: _primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                          summary['pending_on_vendor_side'] == true
                              ? 'الطلب بانتظارك — اشترك في باقة لتبدأ التنفيذ.'
                              : 'اشترك في باقة وتفتح لك التفاصيل كاملة فورًا.',
                          style: const TextStyle(color: Color(0xFF5D6E87))),
                    ])),
              ]),
              const SizedBox(height: 14),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _accent)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            fullyLocked
                                ? 'إجمالي الطلب المستحق لك'
                                : 'إجمالي الجزء المخفي',
                            style: const TextStyle(color: Color(0xFF5D6E87))),
                        Text('${total.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                                color: _primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ])),
              const SizedBox(height: 14),
              ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(alignment: Alignment.center, children: [
                    ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: ExcludeSemantics(
                            child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(18),
                                child: Column(children: [
                                  for (final w in const [180.0, 220.0, 150.0])
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Row(children: [
                                          Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFC9D8F0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          const SizedBox(width: 12),
                                          _bar(w),
                                        ])),
                                  _bar(260),
                                  const SizedBox(height: 12),
                                  _bar(190),
                                ])))),
                    Container(
                        color: Colors.white.withValues(alpha: 0.45),
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        width: double.infinity,
                        child: const Column(children: [
                          CircleAvatar(
                              radius: 22,
                              backgroundColor: _primary,
                              child: Icon(Icons.lock, color: Colors.white)),
                          SizedBox(height: 8),
                          Text('التفاصيل مخفية',
                              style: TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          Text('المنتجات • بيانات العميل • عنوان التسليم',
                              style: TextStyle(color: Color(0xFF5D6E87))),
                        ])),
                  ])),
              const SizedBox(height: 14),
              for (final perk in const [
                'تفاصيل الطلب كاملة بمجرد تفعيل الباقة',
                'الفتح تلقائي — بدون أي خطوة إضافية',
                'أول 3 إعلانات مجانًا مع باقتك'
              ])
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      const Icon(Icons.check_circle,
                          size: 20, color: Color(0xFF16815C)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(perk)),
                    ])),
              const SizedBox(height: 12),
              SizedBox(
                  height: 48,
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: packages,
                      child: const Text('اشترك الآن وافتح الطلب',
                          style: TextStyle(fontWeight: FontWeight.w800)))),
              const SizedBox(height: 8),
              const Text('طلبك محفوظ ولا يُلغى بسبب القفل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF5D6E87))),
            ],
          ),
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
