import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTitleDescriptionWidget extends StatefulWidget {
  final List<TextEditingController> titleControllerList;
  final List<TextEditingController> descriptionControllerList;
  final int index;
  final String langCode;

  const AuctionTitleDescriptionWidget({
    super.key,
    required this.titleControllerList,
    required this.descriptionControllerList,
    required this.index,
    required this.langCode,
  });

  @override
  State<AuctionTitleDescriptionWidget> createState() => _AuctionTitleDescriptionWidgetState();
}

class _AuctionTitleDescriptionWidgetState extends State<AuctionTitleDescriptionWidget> {
  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.iconSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI button for title
          if (aiEnabled)
            Consumer<AuctionAiController>(
              builder: (context, aiController, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.titleControllerList[widget.index].text.isEmpty) {
                          showCustomSnackBarWidget(
                            getTranslated('product_name_required', context) ?? 'Product name is required',
                            context,
                          );
                        } else {
                          aiController.generateAuctionTitle(
                            title: widget.titleControllerList[widget.index].text.trim(),
                            nameController: widget.titleControllerList[widget.index],
                            langCode: widget.langCode,
                          );
                        }
                      },
                      child: !aiController.titleLoading
                          ? Icon(Icons.auto_awesome, color: Colors.blue)
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                              highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.blue),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('generating', context) ?? 'Generating...',
                                    style: robotoBold.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Title input field
          CustomTextFieldWidget(
            controller: widget.titleControllerList[widget.index],
            hintText: getTranslated('product_name', context) ?? 'Type Product Name',
            border: true,
            borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // AI button for description
          if (aiEnabled)
            Consumer<AuctionAiController>(
              builder: (context, aiController, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.titleControllerList[widget.index].text.isEmpty) {
                          showCustomSnackBarWidget(
                            getTranslated('product_name_required', context) ?? 'Product name is required',
                            context,
                          );
                        } else {
                          aiController.generateAuctionDescription(
                            title: widget.titleControllerList[widget.index].text.trim(),
                            descriptionController: widget.descriptionControllerList[widget.index],
                            langCode: widget.langCode,
                          );
                        }
                      },
                      child: !aiController.descLoading
                          ? Icon(Icons.auto_awesome, color: Colors.blue)
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                              highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.blue),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('generating', context) ?? 'Generating...',
                                    style: robotoBold.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Description input field
          CustomTextFieldWidget(
            controller: widget.descriptionControllerList[widget.index],
            hintText: getTranslated('product_description', context) ?? 'Description',
            border: true,
            borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
            maxLine: 3,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
