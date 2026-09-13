import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionWinnerWidget extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback? onMessageTap;
  final bool? isAdmin;

  const AuctionWinnerWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.onMessageTap,
    this.isAdmin
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeMedium,
      ),
      child: Row(
        children: [
          ClipOval(child: CustomImageWidget(image: avatarUrl ?? "", placeholder: Images.personIcon, height: 50, width: 50)),
          const SizedBox(width: Dimensions.paddingSizeMedium),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                  style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                SizedBox(height: Dimensions.paddingSizeSmall),

                Text((isAdmin ?? false) ? getTranslated('admin', context) ?? "" : getTranslated('auction_winner', context) ?? "",
                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault,),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onMessageTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal:  Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Image.asset(Images.chat, height: Dimensions.iconSizeMedium, color: Theme.of(context).cardColor),
            ),
          ),
        ],
      ),
    );
  }
}