import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/product_details_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

void _showImagePreview(BuildContext context, List<String> urls, int startIndex) {
  final size = MediaQuery.sizeOf(context);
  final double itemWidth = size.width * 0.8;
  final controller = ScrollController(initialScrollOffset: startIndex * itemWidth);
  showDialog(
    context: context,
    builder: (_) => ListView.builder(
      controller: controller,
      itemCount: urls.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (ctx, i) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: size.height * 0.4,
          width: urls.length == 1 ? size.width * 0.8 : size.width * 0.7,
          child: ImagePreviewDesign(imagePath: urls[i]),
        ),
      ),
    ),
  );
}

class AuctionProductCardWidget extends StatelessWidget {
  final String title;
  final double startingPrice;
  final double entryFee;
  final List<String> imageUrls;

  const AuctionProductCardWidget({
    super.key,
    required this.title,
    required this.startingPrice,
    required this.entryFee,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final mainImage = imageUrls.isNotEmpty ? imageUrls[0] : null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSize),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: mainImage != null
                ? () => _showImagePreview(context, imageUrls, 0)
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.paddingEye),
              child: CustomImageWidget(image: mainImage ?? "", width: 90, height: 90, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSize),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                PriceRow(
                  label: getTranslated('starting_price', context) ?? "",
                  amount: startingPrice,
                  amountColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: Dimensions.paddingSizeVeryTiny),

                PriceRow(
                  label: getTranslated('entry_fee', context) ?? "",
                  amount: entryFee,
                  amountColor: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(imageUrls.length > 1)
                  ThumbnailRow(
                    imageUrls: imageUrls.sublist(1),
                    onTap: (i) => _showImagePreview(context, imageUrls, i + 1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThumbnailRow extends StatelessWidget {
  final List<String> imageUrls;
  final void Function(int index)? onTap;

  const ThumbnailRow({super.key, required this.imageUrls, this.onTap});

  @override
  Widget build(BuildContext context) {
    const maxVisible = 4;
    final totalImages = imageUrls.length;
    final displayThumbnails = imageUrls.length > maxVisible ? imageUrls.sublist(0, maxVisible) : imageUrls;

    return Row(
      children: List.generate(displayThumbnails.length, (index) {
        final url = displayThumbnails[index];
        final isLastSlotWithExtra = index == maxVisible - 1 && totalImages > maxVisible;

        return Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSeven),
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(index) : null,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSeven),
                  child: CustomImageWidget(image: url, width: 40, height: 40, fit: BoxFit.cover),
                ),
                if (isLastSlotWithExtra)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.6),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSeven),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${totalImages - maxVisible + 1}',
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color amountColor;

  const PriceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label  ',
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)

        ),
        Text('\$ ${amount.toStringAsFixed(2)}',
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w700, color: amountColor)
        ),
      ],
    );
  }
}