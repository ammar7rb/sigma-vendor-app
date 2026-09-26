import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_type_button_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class CompletedOrderWidget extends StatelessWidget {
  final Function? callback;
  const CompletedOrderWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankInfoController>(
        builder: (context, bankInfoController, child) {
      return bankInfoController.businessAnalyticsFilterData == null
          ? CompletedOrdersShimmer(
              isDarkMode: Provider.of<ThemeController>(context).darkTheme)
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
                boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeExtraSmall,
                        Dimensions.paddingSizeDefault,
                        0),
                    child: Text(getTranslated('completed_orders', context)!,
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Dimensions.fontSizeLarge)),
                  ),
                  Consumer<BankInfoController>(
                    builder: (context, bankInfoController, child) => SizedBox(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          OrderTypeButtonWidget(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            icon: Images.delivered,
                            text: getTranslated('delivered', context),
                            index: 3,
                            numberOfOrder: bankInfoController
                                .businessAnalyticsFilterData?.delivered,
                            callback: callback,
                          ),
                          OrderTypeButtonWidget(
                            showBorder: false,
                            color: Theme.of(context).colorScheme.error,
                            icon: Images.cancelled,
                            text: getTranslated('cancelled', context),
                            index: 6,
                            numberOfOrder: bankInfoController
                                .businessAnalyticsFilterData?.canceled,
                            callback: callback,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ),
            );
    });
  }
}

class CompletedOrdersShimmer extends StatelessWidget {
  final bool isDarkMode;
  const CompletedOrdersShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    final baseColor = Theme.of(context).hintColor.withValues(alpha: 0.18);
    final highlightColor = Theme.of(context).hintColor.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            spreadRadius: -3,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(height: 14, width: 160, color: shimmerColor),
            ),
            const SizedBox(height: 12),

            // Shimmer list
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (_, __) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 70,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
