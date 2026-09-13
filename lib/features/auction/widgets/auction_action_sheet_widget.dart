import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum AuctionDialogType { turnOff, turnOn, edit, delete, cancel }

Future<bool?> showAuctionDialog(BuildContext context, AuctionDialogType type) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AuctionConfirmDialog(type: type),
  );
}

class AuctionConfirmDialog extends StatelessWidget {
  final AuctionDialogType type;

  const AuctionConfirmDialog({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type, context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.close, size: 16, color: Theme.of(context).hintColor),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingEye),

            DialogIcon(config: config),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(config.title,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(config.subtitle,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: config.cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    isPrimary: false,
                  )
                ),
                const SizedBox(width: Dimensions.paddingSize),

                Expanded(
                  child: CustomButton(
                    label: config.confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                    isPrimary: true,
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DialogConfig _getConfig(AuctionDialogType type, BuildContext context) {
    switch (type) {
      case AuctionDialogType.turnOff:
        return DialogConfig(
          imagePath: Images.auctionOffIcon,
          title: getTranslated("auction_turn_off_title", context) ?? "",
          subtitle: getTranslated("auction_turn_off_subtitle", context) ?? "",
          cancelLabel: getTranslated("auction_turn_off_cancel", context) ?? "",
          confirmLabel: getTranslated("auction_turn_off_confirm", context) ?? "",
          confirmColor: Theme.of(context).primaryColor,
        );
      case AuctionDialogType.turnOn:
        return DialogConfig(
          imagePath: Images.auctionOnIcon,
          title: getTranslated("auction_turn_on_title", context) ?? "",
          subtitle: getTranslated("auction_turn_on_subtitle", context) ?? "",
          cancelLabel: getTranslated("auction_turn_on_cancel", context) ?? "",
          confirmLabel: getTranslated("auction_turn_on_confirm", context) ?? "",
          confirmColor: Theme.of(context).primaryColor,
        );
      case AuctionDialogType.edit:
        return DialogConfig(
          imagePath: Images.exclamation,
          title: getTranslated("auction_edit_title", context) ?? "",
          subtitle: getTranslated("auction_edit_subtitle", context) ?? "",
          cancelLabel: getTranslated("auction_edit_cancel", context) ?? "",
          confirmLabel: getTranslated("auction_edit_confirm", context) ?? "",
          confirmColor: Theme.of(context).primaryColor,
        );
      case AuctionDialogType.delete:
        return DialogConfig(
          imagePath: Images.deleteAuction,
          title: getTranslated("auction_delete_title", context) ?? "",
          subtitle: getTranslated("auction_delete_subtitle", context) ?? "",
          cancelLabel: getTranslated("auction_delete_cancel", context) ?? "",
          confirmLabel: getTranslated("auction_delete_confirm", context) ?? "",
          confirmColor: Theme.of(context).colorScheme.error,
        );
      case AuctionDialogType.cancel:
        return DialogConfig(
          imagePath: Images.exclamation,
          title: getTranslated("auction_cancel_title", context) ?? "",
          subtitle: getTranslated("auction_cancel_subtitle", context) ?? "",
          cancelLabel: getTranslated("auction_cancel_cancel", context) ?? "",
          confirmLabel: getTranslated("auction_cancel_confirm", context) ?? "",
          confirmColor: Theme.of(context).colorScheme.error,
        );
    }
  }
}

class DialogIcon extends StatelessWidget {
  final DialogConfig config;
  const DialogIcon({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return CustomAssetImageWidget(config.imagePath, width: 72, height: 72, fit: BoxFit.contain);
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isPrimary;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isPrimary ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.1);
    final Color fgColor = isPrimary ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return ElevatedButton(
      onPressed: isLoading ? () {} : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                strokeWidth: 2,
              ),
            )
          : Text(label,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.bold, color: fgColor),
            ),
    );
  }
}

class DialogConfig {
  final String imagePath;
  final String title;
  final String subtitle;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;

  const DialogConfig({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
  });
}