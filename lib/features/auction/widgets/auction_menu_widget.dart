import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionCard extends StatelessWidget {
  final String title;
  final String? image;
  final IconData? icon;
  final int? count;
  final VoidCallback? onTap;

  const AuctionCard({
    super.key,
    required this.title,
    this.image,
    this.icon,
    this.count,
    this.onTap,
  }) : assert(image != null || icon != null, 'Either image or icon must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeMedium,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            icon != null
              ? Icon(icon, size: Dimensions.iconSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: 0.70))
              : CustomAssetImageWidget(image!, width: Dimensions.iconSizeLarge, height: Dimensions.iconSizeLarge),
            SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
