import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CustomSearchFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String prefix;
  final Function iconPressed;
  final Function(String text)? onSubmit;
  final Function? onChanged;
  final Function? filterAction;
  final bool isFilter;
  final bool showCloseIcon;
  const CustomSearchFieldWidget({super.key,
    required this.controller,
    required this.hint,
    required this.prefix,
    required this.iconPressed,
    this.onSubmit,
    this.onChanged,
    this.filterAction,
    this.isFilter = false,
    this.showCloseIcon = false,
  });

  @override
  State<CustomSearchFieldWidget> createState() => _CustomSearchFieldWidgetState();
}

class _CustomSearchFieldWidgetState extends State<CustomSearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: widget.controller,
            textInputAction: TextInputAction.search,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent, // Handled by Container
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 12),

              // The Search Button inside the field
              suffixIcon: InkWell(
                onTap: () => widget.iconPressed(),
                child: Container(
                  margin: const EdgeInsets.all(4), // Padding around the button inside the field
                  padding: const EdgeInsets.all(8), // Padding inside the button
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall), // Slightly smaller radius for inner button
                  ),
                  child: Icon(widget.showCloseIcon ? Icons.close : Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ),
            onSubmitted: widget.onSubmit,
            onChanged: widget.onChanged as void Function(String)?,
          ),
        ),
      ),


      widget.isFilter ? Padding(
        padding:  EdgeInsets.only(
          left :  Provider.of<LocalizationController>(context, listen: false).isLtr? Dimensions.paddingSizeSmall : 0,
          right :  Provider.of<LocalizationController>(context, listen: false).isLtr? 0 : Dimensions.paddingSizeSmall
        ),
        child: GestureDetector(
          onTap: widget.filterAction as void Function()?,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Solid blue background
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(Images.filterIcon, color: Colors.white), // Ensure icon is white
          ),
        ),
      ) : const SizedBox(),
    ],);
  }
}