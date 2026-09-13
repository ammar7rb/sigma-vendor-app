import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_type_button_head_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class OngoingOrderWidget extends StatelessWidget {
  final Function? callback;
  const OngoingOrderWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankInfoController>(
      builder: (context, bankInfoController, child) {
        return bankInfoController.businessAnalyticsFilterData == null
            ? BusinessAnalyticsShimmer(
                isDarkMode: Provider.of<ThemeController>(context).darkTheme)
            : Container(
                padding: const EdgeInsets.all(16),
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
                      padding: EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(getTranslated('business_analytics', context)!,
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.w800)),
                          const Expanded(
                              child: SizedBox(
                            width: Dimensions.paddingSizeExtraLarge,
                          )),
                          Container(
                            height: 40,
                            width: 120,
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                  width: .7,
                                  color: Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: .3)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButton<String>(
                              iconEnabledColor: Theme.of(context).primaryColor,
                              value: bankInfoController.analyticsIndex == 0
                                  ? 'overall'
                                  : bankInfoController.analyticsIndex == 1
                                      ? 'today'
                                      : bankInfoController.analyticsIndex == 2
                                          ? 'this_week'
                                          : bankInfoController.analyticsIndex ==
                                                  3
                                              ? 'this_month'
                                              : 'this_year',
                              items: <String>[
                                'overall',
                                'today',
                                'this_week',
                                'this_month',
                                'this_year'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(getTranslated(value, context)!,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                bankInfoController.setAnalyticsFilterName(
                                    context, value, true);
                                bankInfoController.setAnalyticsFilterType(
                                    value == 'overall'
                                        ? 0
                                        : value == 'today'
                                            ? 1
                                            : value == 'this_week'
                                                ? 2
                                                : value == 'this_month'
                                                    ? 3
                                                    : 4,
                                    true);
                              },
                              isExpanded: true,
                              underline: const SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Consumer<BankInfoController>(
                      builder: (context, bankInfoController, child) =>
                          GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount:
                            MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.18,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          OrderTypeButtonHeadWidget(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withValues(alpha: 0.15),
                            circleColor: Theme.of(context).colorScheme.tertiary,
                            image: Images.packagingOrdersCardIcon,
                            text: getTranslated('processing', context),
                            index: 2,
                            numberOfOrder: bankInfoController
                                    .businessAnalyticsFilterData?.processing ??
                                0,
                            callback: callback,
                            subText: getTranslated('orders', context),
                          ),
                          OrderTypeButtonHeadWidget(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer
                                .withValues(alpha: 0.15),
                            circleColor: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            image: Images.confirmOrderCardIcon,
                            text: getTranslated('confirmed', context),
                            index: 7,
                            subText: getTranslated('orders', context),
                            numberOfOrder: bankInfoController
                                    .businessAnalyticsFilterData?.confirmed ??
                                0,
                            callback: callback,
                          ),
                          OrderTypeButtonHeadWidget(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer
                                .withValues(alpha: 0.15),
                            circleColor: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            image: Images.delivered,
                            text: getTranslated('delivered', context),
                            index: 3,
                            subText: getTranslated('orders', context),
                            numberOfOrder: bankInfoController
                                    .businessAnalyticsFilterData?.delivered ??
                                0,
                            callback: callback,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              );
      },
    );
  }
}

class BusinessAnalyticsShimmer extends StatelessWidget {
  final bool isDarkMode;
  const BusinessAnalyticsShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    final baseColor = Theme.of(context).hintColor.withValues(alpha: 0.18);
    final highlightColor = Theme.of(context).hintColor.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.only(top: 12), // Dimensions.paddingSizeSmall
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
            // Header Row (Icon + Title + Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 36, height: 36, color: shimmerColor),
                  const SizedBox(width: 12),
                  Container(height: 14, width: 140, color: shimmerColor),
                  const Spacer(),
                  Container(height: 50, width: 120, color: shimmerColor),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 7),
              child: Container(height: 14, width: 120, color: shimmerColor),
            ),

            // Grid Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1 / 0.65,
                children: List.generate(4, (_) {
                  return Container(
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
