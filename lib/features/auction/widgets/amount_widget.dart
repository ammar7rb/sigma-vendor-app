import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AmountWidget extends StatelessWidget {
  final double amount;
  final VoidCallback onPayNow;
  final String buttonText;
  final String label;

  const AmountWidget({
    super.key,
    required this.amount,
    required this.onPayNow,
    required this.buttonText,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSize),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeMedium),
      ),
      child: Row(
        children: [
          CustomAssetImageWidget(Images.auctionWallet, width: 48, height: 48, fit: BoxFit.contain),
          const SizedBox(width: Dimensions.paddingSize),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount.toStringAsFixed(2),
                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeMaxLarge, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: Dimensions.paddingSizeOrder),

                Row(
                  children: [
                    Text(label,
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    JustTheTooltip(
                      content: Padding(
                        padding: EdgeInsets.all(Dimensions.paddingEye),
                        child: Text( getTranslated("amount_payable_tooltip", context) ?? "",
                          style: titilliumRegular.copyWith(color: Theme.of(context).cardColor),
                        ),
                      ),
                      child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: onPayNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeMedium),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
            ),
            child: Text(buttonText,
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)
            ),
          ),
        ],
      ),
    );
  }
}