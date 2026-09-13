import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductVideoCardWidget extends StatelessWidget {
  final String linkLabel;
  final String videoUrl;
  final VoidCallback? onUrlTap;

  const ProductVideoCardWidget({
    super.key,
    required this.linkLabel,
    required this.videoUrl,
    this.onUrlTap,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('product_video', context) ?? "",
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          Text(linkLabel,
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: Theme.of(context).hintColor)
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          GestureDetector(
            onTap: onUrlTap ?? _launchUrl,
            child: Text(videoUrl,
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor)
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
