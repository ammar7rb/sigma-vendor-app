import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CategoryButtonWidget extends StatelessWidget {
  final String? text;
  final int index;
  final int? categoryId;
  const CategoryButtonWidget({super.key, required this.text, required this.index, this.categoryId});

  @override
  Widget build(BuildContext context) {
    final displayText = text != null && text!.length > 15
      ? '${text!.substring(0, 15)}...'
      : text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
         Provider.of<RestockController>(context, listen: false).setIndex(index, categoryId);
         Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
        },
        child: Consumer<RestockController>(builder: (context, order, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: order.categoryIndex == index ? Theme.of(context).primaryColor : Provider.of<ThemeController>(context).darkTheme ?
              ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
            ),
            child: Text(displayText ?? '', style: order.categoryIndex == index ? titilliumBold.copyWith(color: order.categoryIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color):
            robotoRegular.copyWith(color: order.categoryIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
          );
        },
        ),
      ),
    );
  }
}