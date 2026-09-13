import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class CustomConfirmationDialogWidget extends StatelessWidget {
  final String? icon;
  final String title;
  final String description;
  final List<String>? highlightTexts;
  final String yesButtonText;
  final String noButtonText;
  final VoidCallback onYesPressed;
  final VoidCallback? onNoPressed;
  final bool isLoading;

  const CustomConfirmationDialogWidget({
    super.key,
    this.icon,
    required this.title,
    required this.description,
    this.highlightTexts,
    this.yesButtonText = 'Yes',
    this.noButtonText = 'No',
    required this.onYesPressed,
    this.onNoPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      insetPadding: const EdgeInsets.all(Dimensions.topSpace),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Stack(
          children: [
            // Close Button (Top Right) - Disabled during loading
            Positioned(
              right: Dimensions.paddingSizeSmall,
              top: Dimensions.paddingSizeSmall,
              child: GestureDetector(
                onTap: isLoading ? null : () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeOrder),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: Dimensions.iconSizeDefault,
                    color: isLoading
                        ? Theme.of(context).hintColor
                        : Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if (icon != null) ...[
                    CustomAssetImageWidget(
                      icon!,
                      height: Dimensions.heightWidth50,
                      width: Dimensions.heightWidth50,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSize),

                  RichDescriptionWidget(
                    description: description,
                    highlightTexts: highlightTexts,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeMedium),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : (onNoPressed ?? () => Navigator.pop(context)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                          child: Text(
                            noButtonText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : onYesPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).cardColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).cardColor,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            yesButtonText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class RichDescriptionWidget extends StatelessWidget {
  final String description;
  final List<String>? highlightTexts;
  final TextAlign textAlign;

  const RichDescriptionWidget({
    super.key,
    required this.description,
    this.highlightTexts,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    if (highlightTexts == null || highlightTexts!.isEmpty) {
      return Text(
        description,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: Dimensions.fontSizeDefault,
          height: 1.4,
          color: Theme.of(context).hintColor,
        ),
      );
    }

    List<TextSpan> spans = [];
    String remainingText = description;

    while (remainingText.isNotEmpty) {
      int firstIndex = -1;
      String currentHighlight = "";

      for (String highlight in highlightTexts!) {
        int index = remainingText.indexOf(highlight);
        if (index != -1 && (firstIndex == -1 || index < firstIndex)) {
          firstIndex = index;
          currentHighlight = highlight;
        }
      }

      if (firstIndex != -1) {
        if (firstIndex > 0) {
          spans.add(TextSpan(text: remainingText.substring(0, firstIndex)));
        }

        spans.add(TextSpan(
          text: currentHighlight,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color ?? Colors.black,
          ),
        ));
        remainingText = remainingText.substring(firstIndex + currentHighlight.length);
      } else {
        spans.add(TextSpan(text: remainingText));
        remainingText = "";
      }
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: Dimensions.fontSizeDefault,
          height: 1.4,
          fontFamily: 'Roboto',
          color: Theme.of(context).hintColor,
        ),
        children: spans,
      ),
    );
  }
}