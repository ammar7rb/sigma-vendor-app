import 'dart:async';
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
          margin: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
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
                                : 'لديك طلب جديد بانتظارك',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    const Badge(
                        backgroundColor: Color(0xFFB42318), label: Text('!'))
                  ]),
                  const SizedBox(height: 16),
                  _LockedAmountHero(
                      label: summary['details_locked'] == true
                          ? 'إجمالي مستحقاتك من هذا الطلب'
                          : 'قيمة الجزء المقيد من الطلب',
                      amount: total,
                      dueAt: _earliestDue(summary)),
                  if (at != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                          'تحويل الإدارة: ${DateFormat('yyyy/MM/dd HH:mm').format(at.toLocal())}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
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
                  FilledButton.icon(
                      onPressed: packages,
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: const Text('اشترك الآن واقبل الطلب')),
                  const Text(
                      'يظل الطلب محفوظًا دون إلغاء تلقائي أو غرامة بسبب القفل.',
                      textAlign: TextAlign.center),
                ],
              )),
        ));
  }
}

DateTime? _earliestDue(Map<String, dynamic> summary) {
  DateTime? earliest;
  for (final portion in (summary['portions'] as List? ?? [])) {
    if (portion is! Map || portion['status'] != 'locked') continue;
    final due = DateTime.tryParse('${portion['pending_due_at']}');
    if (due != null && (earliest == null || due.isBefore(earliest))) earliest = due;
  }
  return earliest;
}

/// Large amount with the subscription prompt and the time left before the
/// order moves to pending orders.
class _LockedAmountHero extends StatefulWidget {
  final String label;
  final double amount;
  final DateTime? dueAt;
  const _LockedAmountHero(
      {required this.label, required this.amount, this.dueAt});

  @override
  State<_LockedAmountHero> createState() => _LockedAmountHeroState();
}

class _LockedAmountHeroState extends State<_LockedAmountHero> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.dueAt != null) {
      _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.dueAt?.toLocal().difference(DateTime.now());
    final countdown = left == null
        ? null
        : left.isNegative
            ? 'انتهت المهلة وتم تحويل الطلب إلى الطلبات المعلقة'
            : 'متبقٍ ${left.inHours} ساعة و${left.inMinutes.remainder(60)} دقيقة قبل تحويل الطلب إلى الطلبات المعلقة';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF59C9FA), Color(0xFF1A428A)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1A428A).withValues(alpha: .3),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widget.amount),
            duration: Duration(
                milliseconds:
                    MediaQuery.of(context).disableAnimations ? 0 : 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text('${v.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5)),
          ),
        ),
        const SizedBox(height: 10),
        const Text('اشترك في باقة لتقبل هذا الطلب وتُضاف مستحقاته إلى حسابك',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        if (countdown != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                  child: Text(countdown,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12.5))),
            ]),
          ),
        ],
      ]),
    );
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
