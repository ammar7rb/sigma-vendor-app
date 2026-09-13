import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AmountDueCard extends StatelessWidget {
  final String price;
  final String title;
  final String description;
  final String? buttonText;
  final Function? onTap;
  final bool? showButton;

  const AmountDueCard({
    super.key,
    required this.price,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
    this.showButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: ThemeShadow.getShadow(context),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .tertiaryContainer
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: robotoBold.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              price,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverlarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              description,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.headlineLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            if (showButton!)
              InkWell(
                onTap: () => onTap!(),
                child: Container(
                  height: Dimensions.paddingSizeButton,
                  width: 150,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Center(
                    child: Text(
                      buttonText!,
                      style: titilliumBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
