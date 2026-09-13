import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart' show FlutterSwitch;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum MetaImagePreview {
  large('2', 'Large'),
  medium('1', 'Medium'),
  small('0', 'Small');

  const MetaImagePreview(this.value, this.label);

  /// API value submitted to the server.
  final String value;

  /// Display label shown in the dropdown.
  final String label;

  static MetaImagePreview fromValue(String? value) =>
      MetaImagePreview.values.firstWhere(
        (e) => e.value == value,
        orElse: () => MetaImagePreview.large,
      );
}

class SeoSetupWidget extends StatelessWidget {
  final VoidCallback? onAiTap;
  final bool isAiGenerating;

  // Dynamic meta fields / callbacks
  final String? metaIndex; // 'index' or 'noindex'
  final ValueChanged<String?>? onMetaIndexChanged;

  final bool metaNoFollow;
  final ValueChanged<bool?>? onMetaNoFollowChanged;

  final bool metaNoArchive;
  final ValueChanged<bool?>? onMetaNoArchiveChanged;

  final bool metaNoImageIndex;
  final ValueChanged<bool?>? onMetaNoImageIndexChanged;

  final bool metaNoSnippet;
  final ValueChanged<bool?>? onMetaNoSnippetChanged;

  final bool metaMaxSnippet;
  final ValueChanged<bool>? onMetaMaxSnippetChanged;
  final TextEditingController? metaMaxSnippetValueController;

  final bool metaMaxVideoPreview;
  final ValueChanged<bool>? onMetaMaxVideoPreviewChanged;
  final TextEditingController? metaMaxVideoPreviewValueController;

  final bool metaMaxImagePreview;
  final ValueChanged<bool>? onMetaMaxImagePreviewChanged;
  final String? metaMaxImagePreviewValue;
  final ValueChanged<String?>? onMetaMaxImagePreviewValueChanged;

  const SeoSetupWidget({
    super.key,
    this.onAiTap,
    this.isAiGenerating = false,
    this.metaIndex,
    this.onMetaIndexChanged,
    this.metaNoFollow = false,
    this.onMetaNoFollowChanged,
    this.metaNoArchive = false,
    this.onMetaNoArchiveChanged,
    this.metaNoImageIndex = false,
    this.onMetaNoImageIndexChanged,
    this.metaNoSnippet = false,
    this.onMetaNoSnippetChanged,
    this.metaMaxSnippet = false,
    this.onMetaMaxSnippetChanged,
    this.metaMaxSnippetValueController,
    this.metaMaxVideoPreview = false,
    this.onMetaMaxVideoPreviewChanged,
    this.metaMaxVideoPreviewValueController,
    this.metaMaxImagePreview = false,
    this.onMetaMaxImagePreviewChanged,
    this.metaMaxImagePreviewValue,
    this.onMetaMaxImagePreviewValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;
    final String safeMetaIndex = (metaIndex == 'noindex') ? 'noindex' : 'index';
    final String safeMetaMaxImagePreviewValue = MetaImagePreview.fromValue(metaMaxImagePreviewValue).value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getTranslated('other_seo_setup', context) ?? '',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (aiEnabled && onAiTap != null)
                  Consumer<AuctionAiController>(
                    builder: (context, aiController, _) {
                      if (aiController.metaSeoLoading) {
                        return Shimmer.fromColors(
                          baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                          highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                          child: Row(mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.blue),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                getTranslated('generating', context) ?? 'Generating...',
                                style: robotoBold.copyWith(color: Colors.blue),
                              ),
                            ],
                          ),
                        );
                      }
                      return InkWell(
                        onTap: onAiTap,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: Dimensions.iconSizeMedium,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('seo_setup_description', context) ?? '',
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
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                RadioGroup<String>(
                  groupValue: safeMetaIndex,
                  onChanged: (v) => onMetaIndexChanged?.call(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'index',
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Flexible(
                                child: Text(getTranslated('index', context) ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: safeMetaIndex != 'index' ?
                                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color) :
                                  robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor)
                                )
                              ),

                            ],
                          ),
                        ),

                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'noindex',
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Flexible(
                                child: Text(getTranslated('no_index', context) ?? '', maxLines: 1,
                                  style : safeMetaIndex != 'noindex' ?
                                    robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).textTheme.bodyLarge?.color) :
                                    robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).primaryColor),
                                overflow: TextOverflow.ellipsis)
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MetaSeoItem(
                              title: getTranslated('no_follow', context) ?? '',
                              value: metaNoFollow,
                              callback: onMetaNoFollowChanged,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: MetaSeoItem(
                              title: getTranslated('no_archive', context) ?? '',
                              value: metaNoArchive,
                              callback: onMetaNoArchiveChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        children: [
                          Expanded(
                            child: MetaSeoItem(
                              title: getTranslated('no_image_index', context) ?? '',
                              value: metaNoImageIndex,
                              callback: onMetaNoImageIndexChanged,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Expanded(
                            child: MetaSeoItem(
                              title: getTranslated('no_snippet', context) ?? '',
                              value: metaNoSnippet,
                              callback: onMetaNoSnippetChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                SeoToggleSection(
                  title: getTranslated('max_snippet', context) ?? '',
                  subtitle: getTranslated('maximum_characters_for', context) ?? '',
                  switchValue: metaMaxSnippet,
                  onSwitchToggle: (val) => onMetaMaxSnippetChanged?.call(val),
                  child: CustomTextFieldWidget(
                    textInputType: TextInputType.number,
                    controller: metaMaxSnippetValueController,
                    border: true,
                    hintText: getTranslated('input_snippet_value', context) ?? '',
                    onChanged: (value) => metaMaxSnippetValueController?.text = value,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                SeoToggleSection(
                  title: getTranslated('max_video_preview', context) ?? '',
                  subtitle: getTranslated('maximum_seconds_for_the_video', context) ?? '',
                  switchValue: metaMaxVideoPreview,
                  onSwitchToggle: (val) => onMetaMaxVideoPreviewChanged?.call(val),
                  child: CustomTextFieldWidget(
                    textInputType: TextInputType.number,
                    controller: metaMaxVideoPreviewValueController,
                    border: true,
                    hintText: getTranslated('input_max_video_preview_value', context) ?? '',
                    onChanged: (value) => metaMaxVideoPreviewValueController?.text = value,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                SeoToggleSection(
                  title: getTranslated('max_image_preview', context) ?? '',
                  subtitle: getTranslated('determine_the_maximum_size_or', context) ?? '',
                  switchValue: metaMaxImagePreview,
                  onSwitchToggle: (val) => onMetaMaxImagePreviewChanged?.call(val),
                  child: DropdownDecoratorWidget(
                    child: DropdownButton<String>(
                      value: safeMetaMaxImagePreviewValue,
                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: MetaImagePreview.values
                          .map((e) => DropdownMenuItem(value: e.value,
                          child: Text(e.label, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
                      onChanged: onMetaMaxImagePreviewValueChanged,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeoToggleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onSwitchToggle;
  final Widget child;

  const SeoToggleSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      subtitle,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              FlutterSwitch(
                width: 35,
                height: 20,
                toggleSize: 20,
                value: switchValue,
                borderRadius: 20,
                activeColor: Theme.of(context).primaryColor,
                padding: 1,
                onToggle: onSwitchToggle,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          child,
        ],
      ),
    );
  }
}

class MetaSeoItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?>? callback;

  const MetaSeoItem({super.key, required this.title, required this.value, this.callback});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: callback),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Flexible(
          child: Text(
            title,
            style: !value ?
            robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color) :
            robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).primaryColor),
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
