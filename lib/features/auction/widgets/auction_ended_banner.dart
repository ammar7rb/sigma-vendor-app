import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionEndedBanner extends StatelessWidget {
  final String? title;
  final String? message;

  const AuctionEndedBanner({super.key, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      color: theme.cardColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraLarge,
          vertical: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha:0.1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Text(title ?? getTranslated('auction_ended_item_not_sold', context) ?? "",
              textAlign: TextAlign.center,
              style: titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            Text(message ?? getTranslated('update_details_and_create_auction_again', context) ?? "",
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: theme.textTheme.bodyLarge!.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}