import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ProductSeoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final XFile? image;
  final String? existingImageUrl;
  final VoidCallback? onImagePick;
  final VoidCallback? onImageRemove;
  final VoidCallback? onRemoveExistingImage;
  final bool isAiGenerating;
  final VoidCallback? onAiTap;

  const ProductSeoWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.image,
    this.existingImageUrl,
    this.onImagePick,
    this.onImageRemove,
    this.onRemoveExistingImage,
    this.isAiGenerating = false,
    this.onAiTap,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, -6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('product_seo', context) ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1 && onAiTap != null)
                  InkWell(
                    onTap: onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(
                        Icons.auto_awesome,
                        size: Dimensions.iconSizeMedium,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('product_seo_description', context) ?? '',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextFieldWidget(
                    controller: nameController,
                    hintText: getTranslated('meta_title', context) ?? "",
                    border: true,
                    borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextFieldWidget(
                      controller: descriptionController,
                      hintText: getTranslated('description', context) ?? "",
                      border: true,
                      borderColor: Theme.of(context).primaryColor.withValues(alpha: .25)
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated('meta_image', context) ?? "",
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                            children: <InlineSpan>[
                              TextSpan(text: _imageHintText(context)),
                              TextSpan(
                                text: getTranslated('ratio_1_1', context) ?? '',
                                style: TextStyle(color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        // Show local selected file if present
                        if (image != null)
                          ImagePreview(file: image!, onRemove: onImageRemove)
                        else if ((existingImageUrl ?? '').isNotEmpty)
                          // Show existing remote image when no local file selected
                          RemoteImagePreview(url: existingImageUrl!, onRemoveExisting: onRemoveExistingImage, onReplace: onImagePick)
                        else
                          AddImageZone(onTap: onImagePick),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  ),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImageWidget(
                Images.addImageIcon,
                height: 30,
                width: 30,
                color: Theme.of(context).hintColor.withValues(alpha: .7),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                getTranslated('click_to_add', context) ?? "",
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final XFile file;
  final VoidCallback? onRemove;

  const ImagePreview({
    super.key, 
    required this.file,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image.file(
            File(file.path),
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Theme.of(context).cardColor),
            ),
          ),
        ),
      ],
    );
  }
}

class RemoteImagePreview extends StatelessWidget {
  final String url;
  final VoidCallback? onRemoveExisting;
  final VoidCallback? onReplace;

  const RemoteImagePreview({super.key, required this.url, this.onRemoveExisting, this.onReplace});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image.network(
            url,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 150,
              color: Theme.of(context).hintColor.withValues(alpha: 0.10),
              child: Center(child: Text(getTranslated('image_not_available', context) ?? 'Image not available')),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              if (onReplace != null)
                GestureDetector(
                  onTap: onReplace,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                    child: Icon(Icons.edit, size: 16, color: Theme.of(context).cardColor),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemoveExisting,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
                  child: Icon(Icons.delete, size: 16, color: Theme.of(context).cardColor),
                ),
              ),
            ],
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