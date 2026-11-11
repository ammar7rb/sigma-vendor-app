import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerPackagePlanCard extends StatelessWidget {
  final SellerPackagePlan plan;
  final bool current;
  final bool selected;
  final String? actionLabel;
  final VoidCallback? onSubscribe;
  const SellerPackagePlanCard(
      {super.key,
      required this.plan,
      this.current = false,
      this.selected = false,
      this.actionLabel,
      this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    String label(String arabic, String english) => ar ? arabic : english;
    final unit = ar
        ? {'days': 'يوم', 'months': 'شهر', 'years': 'سنة'}[plan.durationUnit] ??
            plan.durationUnit
        : plan.durationUnit;
    final duration = plan.durationUnit == 'lifetime'
        ? label('مدى الحياة', 'Lifetime')
        : '${plan.durationValue} $unit';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: current ? const Color(0xFFF8FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: current || selected
                  ? const Color(0xFF1A428A)
                  : const Color(0xFFDCE4F0),
              width: current ? 2 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
        if (current || selected)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  current
                      ? label('الباقة الحالية', 'Current package')
                      : label('الباقة المختارة', 'Selected package'),
                  style: const TextStyle(
                      color: Color(0xFF1A428A), fontWeight: FontWeight.w700))),
        if (plan.description.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(plan.description)),
        const SizedBox(height: 24),
        Text(financeMoney(context, plan.packagePrice),
            style: Theme.of(context).textTheme.headlineMedium),
        Text(label('سعر الباقة', 'Package price')),
        const SizedBox(height: 20),
        const Divider(),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
                '${label('عدد الإعلانات', 'Advertisements')}: ${plan.productLimit > 0 ? plan.productLimit : label('حسب الباقة', 'As listed')} ${plan.productLimit > 0 ? label('إعلانات', 'ads') : ''}')),
        Text('${label('مدة الاشتراك', 'Subscription duration')}: $duration'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: onSubscribe,
            child: Text(actionLabel ??
                (current
                    ? label('تجديد الآن', 'Renew now')
                    : label('اشترك الآن', 'Subscribe now')))),
      ]),
    );
  }
}
