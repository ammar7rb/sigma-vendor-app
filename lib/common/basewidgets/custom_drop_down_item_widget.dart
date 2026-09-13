
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CustomDropDownItemWidget extends StatelessWidget {
  final String? title;
  final Widget? widget;
  final double? borderRadius;
  const CustomDropDownItemWidget({super.key, this.title, this.widget, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        title != null?
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Text(getTranslated(title, context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
        ):const SizedBox(),

        Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault,0),
          child: Container(height: 45,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 6),
              border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha:.5))
            ),
            alignment: Alignment.center,
            child: widget,
          ),),
        const SizedBox(height: Dimensions.paddingSizeMedium)
      ],),
    );
  }
}