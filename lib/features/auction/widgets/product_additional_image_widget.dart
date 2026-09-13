import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class ProductAdditionalImageWidget extends StatelessWidget {
  final List<XFile> images;
  final List<String>? existingImages; // new
  final VoidCallback? onAddTap;
  final void Function(int index)? onRemoveTap; // local image removal
  final void Function(int index)? onRemoveExistingTap; // existing image removal
  final bool isAiGenerating;

  const ProductAdditionalImageWidget({
    super.key,
    required this.images,
    this.existingImages,
    this.onAddTap,
    this.onRemoveTap,
    this.onRemoveExistingTap,
    this.isAiGenerating = false,
  });

  String _imageHintText(BuildContext context) {
    final maxSize = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.systemImageFileUploadMaxSize ??
        2;
    final template = getTranslated('jpg_png_less_then_x_mb', context) ?? '';
    return template.replaceAll('{size}', '$maxSize');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(
              getTranslated('product_additional_image', context) ?? '',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraLarge),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
                children: [
                  TextSpan(text: _imageHintText(context)),
                  TextSpan(text: getTranslated('ratio_1_1', context) ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // If no existing and no new images -> show add zone
                  (existingImages == null || existingImages!.isEmpty) && images.isEmpty
                    ? AddImageZone(onTap: onAddTap)
                    : ImageGrid(
                      images: images,
                      existingImages: existingImages ?? [],
                      onAddTap: onAddTap,
                      onRemoveTap: onRemoveTap,
                      onRemoveExistingTap: onRemoveExistingTap,
                    ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddImageZone extends StatelessWidget {
  final VoidCallback? onTap;
  const AddImageZone({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [4, 5],
          color: Theme.of(context).hintColor,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30, color: Theme.of(context).hintColor.withValues(alpha: .7)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(getTranslated('click_to_add', context) ?? "",
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: .7))),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<XFile> images;
  final List<String> existingImages; // new
  final VoidCallback? onAddTap;
  final void Function(int index)? onRemoveTap; // local
  final void Function(int index)? onRemoveExistingTap; // existing

  const ImageGrid({super.key, required this.images, required this.existingImages, this.onAddTap, this.onRemoveTap, this.onRemoveExistingTap});

  @override
  Widget build(BuildContext context) {
    // We'll render existing images first, then local images, and finally the add button
    final totalExisting = existingImages.length;
    final totalLocal = images.length;

    return Wrap(
      spacing: Dimensions.paddingSizeSmall,
      runSpacing: Dimensions.paddingSizeSmall,
      children: [
        // Existing network images
        ...List.generate(totalExisting, (index) => NetworkImageTile(
          url: existingImages[index],
          onRemove: () => onRemoveExistingTap?.call(index),
        )),

        // Picked local images
        ...List.generate(totalLocal, (index) => FileImageTile(
          file: images[index],
          onRemove: () => onRemoveTap?.call(index),
        )),

        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .4)),
              color: Theme.of(context).hintColor.withValues(alpha: .05),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Theme.of(context).hintColor.withValues(alpha: .7), size: 24),
                const SizedBox(height: 2),
                Text(getTranslated('add', context) ?? 'Add',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withValues(alpha: .7))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NetworkImageTile extends StatelessWidget {
  final String url;
  final VoidCallback? onRemove;
  const NetworkImageTile({super.key, required this.url, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c,s,e) => Container(
            width: 80, height: 80, color: Theme.of(context).hintColor.withValues(alpha: .05),
            child: Icon(Icons.broken_image, color: Theme.of(context).hintColor),
          )),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class FileImageTile extends StatelessWidget {
  final XFile file;
  final VoidCallback? onRemove;
  const FileImageTile({super.key, required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image.file(File(file.path), width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                child: Container(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}