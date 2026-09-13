import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class NoteWidget extends StatelessWidget {
  final String note;

  const NoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingEye),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              children: [
                TextSpan(
                  text: getTranslated('rejected_note', context) ?? "",
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                TextSpan(
                  text: note,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
