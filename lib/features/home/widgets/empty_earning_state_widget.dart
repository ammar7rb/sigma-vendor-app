import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class EmptyEarningStateWidget extends StatelessWidget {
  const EmptyEarningStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeButton),
      alignment: Alignment.center,
      child: Column(children: [

        CustomAssetImageWidget(Images.emptyEarningIcon, height: 45, width: 45, color: Theme.of(context).disabledColor),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        
        Text(getTranslated('no_statistics_generated_yet', context)!, style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
            fontSize: Dimensions.fontSizeDefault,
        )),
      ]),
    );
  }
}
