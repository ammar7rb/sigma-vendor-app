import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_title_description_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class BasicSetupWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isAiGenerating;
  final String langCode;
  final XFile? thumbnailFile;
  final String? existingThumbnailUrl; // new
  final VoidCallback? onThumbnailTap;
  final VoidCallback? onThumbnailRemove;
  final VoidCallback? onClearExistingThumbnail; // new

  // New parameters for language-wise support
  final List<TextEditingController>? titleControllerList;
  final List<TextEditingController>? descriptionControllerList;
  final TabController? tabController;

  const BasicSetupWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.isAiGenerating = false,
    this.langCode = 'en',
    this.thumbnailFile,
    this.existingThumbnailUrl,
    this.onThumbnailTap,
    this.onThumbnailRemove,
    this.onClearExistingThumbnail,
    this.titleControllerList,
    this.descriptionControllerList,
    this.tabController,
  });

  @override
  State<BasicSetupWidget> createState() => _BasicSetupWidgetState();
}

class _BasicSetupWidgetState extends State<BasicSetupWidget>  with SingleTickerProviderStateMixin {

  String _imageHintText(BuildContext context) {
    final maxSize = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.systemImageFileUploadMaxSize ??
        2;
    final template = getTranslated('jpg_png_less_then_x_mb', context) ?? '';
    return template.replaceAll('{size}', '$maxSize');
  }

  void _onTitleAiTap(AuctionAiController aiController) {
    if (widget.nameController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    aiController.generateAuctionTitle(
      title: widget.nameController.text.trim(),
      nameController: widget.nameController,
      langCode: widget.langCode,
    );
  }

  void _onDescriptionAiTap(AuctionAiController aiController) {
    if (widget.nameController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    aiController.generateAuctionDescription(
      title: widget.nameController.text.trim(),
      descriptionController: widget.descriptionController,
      langCode: widget.langCode,
    );
  }

  List<Widget> _generateTabChildren() {
    List<Widget> tabs = [];
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    for (int index = 0; index < languages.length; index++) {
      final rawName = languages[index].name ?? 'Language';
      final name = rawName.isEmpty ? rawName : '${rawName[0].toUpperCase()}${rawName.substring(1)}';
      tabs.add(Text(name, style: robotoBold.copyWith()));
    }
    return tabs;
  }

  List<Widget> _generateTabPage(TabController? tabController) {
    List<Widget> tabView = [];
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    final titleList = widget.titleControllerList ?? [];
    final descList = widget.descriptionControllerList ?? [];

    for (int index = 0; index < languages.length; index++) {
      tabView.add(
        AuctionTitleDescriptionWidget(
          titleControllerList: titleList,
          descriptionControllerList: descList,
          index: index,
          langCode: languages[tabController?.index ?? 0].code ?? 'en',
        ),
      );
    }
    return tabView;
  }

  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;
    final bool isMultiLanguage = widget.titleControllerList != null && widget.descriptionControllerList != null;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('basic_setup', context) ?? '',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('basic_setup_description', context) ?? '',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.paddingEye),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Multi-language TabBar and TabView
                  if (isMultiLanguage)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeMedium,
                                    left: Dimensions.paddingEye,
                                    bottom: Dimensions.paddingEye,
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: TabBar(
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      dividerColor: Theme.of(context).hintColor,
                                      controller: widget.tabController,
                                      indicatorColor: Theme.of(context).primaryColor,
                                      indicatorWeight: 12,
                                      labelColor: Theme.of(context).primaryColor,
                                      indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                                        insets: EdgeInsets.zero,
                                      ),
                                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                                      tabs: _generateTabChildren(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 235,
                                child: AnimatedBuilder(
                                  animation: widget.tabController ?? TabController(length: 1, vsync: this),
                                  builder: (BuildContext context, Widget? child) {
                                    return TabBarView(
                                      controller: widget.tabController,
                                      children: _generateTabPage(widget.tabController),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    )
                  // Single language input (fallback)
                  else
                    Container(
                      padding: EdgeInsets.all(Dimensions.paddingSizeOrder),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Consumer<AuctionAiController>(
                        builder: (context, aiController, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (aiEnabled)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AiIconButton(
                                    isLoading: aiController.titleLoading,
                                    onTap: () => _onTitleAiTap(aiController),
                                  ),
                                ),

                              CustomTextFieldWidget(
                                controller: widget.nameController,
                                hintText: getTranslated('product_name', context) ?? 'Type Product Name',
                                border: true,
                                borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                              ),
                              const SizedBox(height: Dimensions.paddingSize),

                              if (aiEnabled)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AiIconButton(
                                    isLoading: aiController.descLoading,
                                    onTap: () => _onDescriptionAiTap(aiController),
                                  ),
                                ),

                              CustomTextFieldWidget(
                                controller: widget.descriptionController,
                                hintText: getTranslated('product_description', context) ?? 'Description',
                                border: true,
                                borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                maxLine: 3,
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Row(children: [
                          Text(getTranslated('upload_thumbnail', context) ?? '',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '*',
                            style: robotoBold.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                            children: [
                              TextSpan(text: _imageHintText(context)),
                              TextSpan(
                                text: getTranslated('ratio_1_1', context) ?? '',
                                style: TextStyle(color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        widget.thumbnailFile != null
                            ? ThumbnailPreview(file: widget.thumbnailFile!, onRemove: widget.onThumbnailRemove)
                            : (widget.existingThumbnailUrl != null && widget.existingThumbnailUrl!.isNotEmpty)
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        child: Image.network(
                                          widget.existingThumbnailUrl!,
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, s, e) => ThumbnailPickerZone(onTap: widget.onThumbnailTap),
                                        ),
                                      ),
                                      Positioned(
                                        top: Dimensions.paddingSizeExtraSmall,
                                        right: Dimensions.paddingSizeExtraSmall,
                                        child: Row(children: [
                                          GestureDetector(
                                            onTap: widget.onClearExistingThumbnail,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.close, size: 16, color: Theme.of(context).cardColor),
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                          GestureDetector(
                                            onTap: widget.onThumbnailTap,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.edit, size: 16, color: Theme.of(context).cardColor),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  )
                                : ThumbnailPickerZone(onTap: widget.onThumbnailTap),

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

class AiIconButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const AiIconButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
        highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              getTranslated('generating', context) ?? 'Generating...',
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(Icons.auto_awesome, size: Dimensions.iconSizeMedium, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class ThumbnailPickerZone extends StatelessWidget {
  final VoidCallback? onTap;
  const ThumbnailPickerZone({super.key, this.onTap});

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

class ThumbnailPreview extends StatelessWidget {
  final XFile file;
  final VoidCallback? onRemove;
  const ThumbnailPreview({super.key, required this.file, this.onRemove});

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
          top: Dimensions.paddingSizeExtraSmall,
          right: Dimensions.paddingSizeExtraSmall,
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
