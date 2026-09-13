import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class GeneralSetupWidget extends StatefulWidget {
  final VoidCallback? onAiTap;
  final bool isAiGenerating;
  final String? productType;
  final List<String> productTypeList;
  final ValueChanged<String?> onProductTypeChanged;

  final String? category;
  final List<String> categoryList;
  final ValueChanged<String?> onCategoryChanged;

  final String? brand;
  final List<String> brandList;
  final ValueChanged<String?> onBrandChanged;
  final TextEditingController? itemConditionController;

  final String? itemCondition;
  final List<String> itemConditionList;
  final ValueChanged<String?> onItemConditionChanged;


  const GeneralSetupWidget({
    super.key,
    this.onAiTap,
    this.isAiGenerating = false,
    this.productType,
    this.productTypeList = const [],
    required this.onProductTypeChanged,
    this.category,
    this.categoryList = const [],
    required this.onCategoryChanged,
    this.brand,
    this.brandList = const [],
    required this.onBrandChanged,
    this.itemConditionController,
    this.itemCondition,
    this.itemConditionList = const [],
    required this.onItemConditionChanged,
  });

  @override
  State<GeneralSetupWidget> createState() => _GeneralSetupWidgetState();
}

class _GeneralSetupWidgetState extends State<GeneralSetupWidget> {

  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.fontSizeExtraLarge,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('general_setup', context) ?? '',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (aiEnabled && widget.onAiTap != null)
                  Consumer<AuctionAiController>(
                    builder: (context, aiController, _) {
                      if (aiController.generalSetupLoading) {
                        return Shimmer.fromColors(
                          baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                          highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.blue),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                getTranslated('generating', context) ?? 'Generating...',
                                style: robotoBold.copyWith(color: Colors.blue),
                              ),
                            ],
                          ),
                        );
                      }
                      return InkWell(
                        onTap: widget.onAiTap,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: Dimensions.iconSizeMedium,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('general_setup_description', context) ?? '',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('category', context) ?? '',
                    value: widget.category,
                    items: widget.categoryList,
                    onChanged: widget.onCategoryChanged,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('brand', context) ?? '',
                    value: widget.brand,
                    items: widget.brandList,
                    onChanged: widget.onBrandChanged,
                    isRequired: false,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('item_condition', context) ?? '',
                    value: widget.itemCondition,
                    items: widget.itemConditionList,
                    onChanged: widget.onItemConditionChanged,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                child: Container(color: Theme.of(context).cardColor),
              ),
            ),
          ),
      ],
    );
  }
}

class AuctionDropdownField extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool? isEnabled;
  final bool isRequired;

  const AuctionDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.isEnabled = true,
    this.value,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeMedium,
        vertical: Dimensions.paddingSizeVeryTiny,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: .75),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_outlined, size: Dimensions.iconSizeMedium),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        hint: Text(isRequired ? '$hintText *' : hintText, style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(getTranslated(item, context) ?? item, style: titilliumRegular),
          );
        }).toList(),
        onChanged: !isEnabled! ? null : onChanged,
      ),
    );
  }
}
