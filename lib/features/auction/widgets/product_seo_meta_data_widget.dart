import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';


class ProductSeoMetaDataWidget extends StatelessWidget {
  final String seoTitle;
  final String metaDescription;
  final String? imageUrl;

  const ProductSeoMetaDataWidget({
    super.key,
    required this.seoTitle,
    required this.metaDescription,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated('product_seo_metadata', context) ?? "",
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          Divider(color: Theme.of(context).cardColor, thickness: 1, height: 1),

          if(seoTitle.isNotEmpty)...[
            Text(seoTitle,
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
            ),
            const SizedBox(height: Dimensions.paddingEye),
          ],


          if(metaDescription.isNotEmpty)...[
            Text(metaDescription, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!)),
            const SizedBox(height: Dimensions.paddingSizeMedium),
          ],


          if(imageUrl != null && imageUrl!.isNotEmpty)...[
            MetaThumbnail(imageUrl: imageUrl ?? ""),
          ]

        ],
      ),
    );
  }
}

class MetaThumbnail extends StatelessWidget {
  final String imageUrl;

  const MetaThumbnail({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.paddingEye),
      child: CustomImageWidget(image: imageUrl, width: 72, height: 72, fit: BoxFit.cover),
    );
  }
}
