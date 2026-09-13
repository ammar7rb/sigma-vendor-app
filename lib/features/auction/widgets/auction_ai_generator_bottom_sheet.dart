import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_generate_title_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_image_analyze_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionAiGeneratorBottomSheet extends StatelessWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  final List<TextEditingController>? descriptionControllerList;
  final VoidCallback? onImageAutoFillApply;

  const AuctionAiGeneratorBottomSheet({
    super.key,
    this.languageList,
    this.tabController,
    this.nameControllerList,
    this.descriptionControllerList,
    this.onImageAutoFillApply,
  });

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: sheet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Consumer<AuctionAiController>(
        builder: (context, aiController, child) {
          return Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            const SizedBox(height: 20),

            CustomAssetImageWidget(Images.aiAssistance, height: 70, width: 70),
            const SizedBox(height: 10),

            Text(
              getTranslated('hi_there', context) ?? '',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              getTranslated('i_am_here_to_help_you', context) ?? '',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text(
                getTranslated('ai_assistance_description', context) ?? '',
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: CustomButtonWidget(
                btnTxt: getTranslated('upload_image', context) ?? '',
                borderColor: Colors.blue,
                textSize: Dimensions.fontSizeDefault,
                backgroundColor: Colors.transparent,
                textStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  _showSheet(
                    context,
                    AuctionImageAnalyzeBottomSheet(
                      languageList: languageList,
                      tabController: tabController,
                      nameControllerList: nameControllerList,
                      descriptionControllerList: descriptionControllerList,
                      onImageAutoFillApply: onImageAutoFillApply,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: CustomButtonWidget(
                borderColor: Colors.blue,
                btnTxt: getTranslated('generate_product_name', context) ?? '',
                textStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  _showSheet(
                    context,
                    AuctionGenerateTitleBottomSheet(
                      languageList: languageList,
                      tabController: tabController,
                      nameControllerList: nameControllerList,
                      descriptionControllerList: descriptionControllerList,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text(
                getTranslated('ai_may_make_mistakes', context) ?? '',
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        },
      ),
    );
  }
}
