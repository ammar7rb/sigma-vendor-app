import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class StockViolationScreen extends StatefulWidget {
  const StockViolationScreen({super.key});

  @override
  State<StockViolationScreen> createState() => _StockViolationScreenState();
}

class _StockViolationScreenState extends State<StockViolationScreen> {
  String _languageCode(BuildContext context) {
    final locale = Provider.of<LocalizationController>(context, listen: false).locale;
    if (locale.languageCode == 'en') return 'en';
    if (locale.languageCode == 'ar') return 'sa';
    return locale.languageCode;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProductController>(context, listen: false).getStockViolations(_languageCode(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('stock_violation_history', context)),
      body: Consumer<ProductController>(builder: (context, controller, _) {
        if (controller.stockViolations == null && controller.isStockViolationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final violations = controller.stockViolations ?? [];
        return RefreshIndicator(
          onRefresh: () => controller.getStockViolations(_languageCode(context)),
          child: violations.isEmpty
              ? ListView(children: const [SizedBox(height: 160), NoDataScreen()])
              : ListView.separated(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: violations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (_, index) {
                    final violation = violations[index];
                    final isPenalty = violation.decision == 'penalty';
                    final alert = violation.alertType == 'out_of_stock'
                        ? getTranslated('out_of_stock_alert', context)
                        : getTranslated('low_stock_alert', context);
                    return Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: (isPenalty ? Colors.red : Colors.orange).withValues(alpha: .35)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(isPenalty ? Icons.gpp_maybe_outlined : Icons.warning_amber_rounded, color: isPenalty ? Colors.red : Colors.orange),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Text(violation.product?.name ?? getTranslated('product_was_deleted', context)!, style: titilliumSemiBold)),
                          Text(isPenalty ? getTranslated('manual_penalty', context)! : getTranslated('manual_warning', context)!, style: titilliumSemiBold.copyWith(color: isPenalty ? Colors.red : Colors.orange)),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(alert ?? '', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(violation.reason, style: titilliumRegular),
                        if (violation.policyReference?.isNotEmpty ?? false) ...[
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text('${getTranslated('policy_reference', context)}: ${violation.policyReference}', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
                        ],
                        if (violation.penaltyAmount != null) ...[
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text('${getTranslated('amount', context)}: ${violation.penaltyAmount!.toStringAsFixed(2)}', style: titilliumSemiBold.copyWith(color: Colors.red)),
                        ],
                        if (violation.decidedAt != null) ...[
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(violation.decidedAt!, style: titilliumRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                        ],
                      ]),
                    );
                  },
                ),
        );
      }),
    );
  }
}
