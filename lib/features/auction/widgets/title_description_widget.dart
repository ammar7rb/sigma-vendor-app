import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class TitleDescriptionWidget extends StatefulWidget {
  final String description;
  final String? imageUrl;
  final int collapsedMaxLines;

  const TitleDescriptionWidget({
    super.key,
    required this.description,
    this.imageUrl,
    this.collapsedMaxLines = 4,
  });

  @override
  State<TitleDescriptionWidget> createState() => _TitleDescriptionWidgetState();
}

class _TitleDescriptionWidgetState extends State<TitleDescriptionWidget> {
  bool _isExpanded = false;

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
          children:[
            Text(getTranslated('description', context) ?? "",
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
            const SizedBox(height: Dimensions.paddingSizeMedium),
            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.30)),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            Text(widget.description,
                maxLines: _isExpanded ? null : widget.collapsedMaxLines,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!)
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            if (widget.imageUrl != null) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: _isExpanded ? 220 : 120,
                        width: double.infinity,
                        child: CustomImageWidget(image: widget.imageUrl!),
                      ),
                    ),
                  ),

                  if (!_isExpanded)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: .35),
                            ],
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: Dimensions.paddingSizeSmall,
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: SeeMoreButton(label: _isExpanded ? getTranslated('see_less', context) ?? "" : getTranslated('see_more', context) ?? "")
                    ),
                  ),
                ],
              ),
            ],
          ]
      ),
    );
  }
}

class SeeMoreButton extends StatelessWidget {
  final String label;

  const SeeMoreButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeOrder),
          border: Border.all(color: Theme.of(context).primaryColor, width: 1.2),
        ),
        child: Text(label,
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
        ),
      );
  }
}