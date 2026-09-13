import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_general_setup_model.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_media_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_ai_generator_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_product_video_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_shipping_return_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/basic_setup_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_title_description_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/general_setup_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/product_additional_image_widget.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';

class AddAuctionProductScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final AuctionProduct? auctionProduct;
  const AddAuctionProductScreen({super.key, this.onNext, this.auctionProduct});

  @override
  AddAuctionProductScreenState createState() => AddAuctionProductScreenState();
}

class AddAuctionProductScreenState extends State<AddAuctionProductScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  TabController? _tabController;

  late List<TextEditingController> titleControllerList;
  late List<TextEditingController> descriptionControllerList;

  final TextEditingController shippingFeeController = TextEditingController();
  final TextEditingController returnPolicyController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  final TextEditingController itemConditionController = TextEditingController();


  String? selectedProductType = 'Physical';
  String? selectedCategory;
  String? selectedBrand;

  final List<String> productTypeList = ['Physical'];

  bool _brandsLoaded = false;
  bool _categoriesLoaded = false;

  VideoUploadType _videoUploadType = VideoUploadType.link;
  VideoUploadType get videoUploadType => _videoUploadType;


  String? selectedItemCondition;

  final Map<String, String> itemConditionMap = {
    "New": "NEW",
    "Like_New": "LIKE_NEW",
    "Excellent": "EXCELLENT",
    "Good": "GOOD",
    "Fair": "FAIR"
  };

  // Image-driven auto-fill: when the user generates from an image, the
  // AuctionAiController fills general setup + shipping in the background. This
  // screen is already built (it's the open tab), so it can't use a lazy
  // initState check like the Auction Info / SEO tabs — instead it listens to
  // the controller and applies each result once.
  AuctionAiController? _aiController;
  bool _imageGeneralSetupApplied = false;
  bool _imageShippingApplied = false;

  @override
  void initState() {
    super.initState();

    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    _tabController = TabController(
      length: languages.isNotEmpty ? languages.length : 1,
      initialIndex: 0,
      vsync: this,
    );

    titleControllerList = List.generate(languages.length, (index) => TextEditingController());
    descriptionControllerList = List.generate(languages.length, (index) => TextEditingController());

    if (widget.auctionProduct != null) {
      if (titleControllerList.isNotEmpty) titleControllerList[0].text = widget.auctionProduct!.name ?? '';
      if (descriptionControllerList.isNotEmpty) descriptionControllerList[0].text = widget.auctionProduct!.details ?? '';
      if (widget.auctionProduct!.translations != null && widget.auctionProduct!.translations!.isNotEmpty) {
        for (var t in widget.auctionProduct!.translations!) {
          final idx = languages.indexWhere((lan) => lan.code == (t.locale ?? ''));
          if (idx >= 0 && idx < titleControllerList.length && t.key == 'name') {
            titleControllerList[idx].text = t.value ?? titleControllerList[idx].text;
          }
          if (idx >= 0 && idx < descriptionControllerList.length && t.key == 'description') {
            descriptionControllerList[idx].text = t.value ?? descriptionControllerList[idx].text;
          }
        }
      }

      shippingFeeController.text = widget.auctionProduct!.shippingFee?.toString() ?? '';
      returnPolicyController.text = widget.auctionProduct!.returnPolicy ?? '';

      videoLinkController.text = widget.auctionProduct!.youtubeVideoUrl ??
          widget.auctionProduct!.videoUrl ?? '';

      if (widget.auctionProduct!.videoProvider == 'custom_video') {
        _videoUploadType = VideoUploadType.file;
      } else {
        _videoUploadType = VideoUploadType.link;
      }

      selectedProductType = (widget.auctionProduct!.productType != null && widget.auctionProduct!.productType!.isNotEmpty)
          ? (widget.auctionProduct!.productType!.toLowerCase() == 'physical' ? 'Physical' : widget.auctionProduct!.productType)
          : selectedProductType;

      String? serverValue = widget.auctionProduct!.itemCondition;
      if (serverValue != null) {
        String? itemConditionKey;
        if (itemConditionMap.containsKey(serverValue)) {
          itemConditionKey = serverValue;
        } else {
          final entry = itemConditionMap.entries.firstWhere(
            (e) => e.value == serverValue,
            orElse: () => const MapEntry('', ''),
          );
          if (entry.key.isNotEmpty) {
            itemConditionKey = entry.key;
          } else {
            final normalized = serverValue.replaceAll(' ', '_');
            if (itemConditionMap.containsKey(normalized)) {
              itemConditionKey = normalized;
            }
          }
        }
        selectedItemCondition = itemConditionKey;
      }

    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AddAuctionProductMediaController>(context, listen: false)
          .loadFromAuctionProduct(widget.auctionProduct, isUpdate: true);
    });

    _aiController = Provider.of<AuctionAiController>(context, listen: false);
    _aiController!.setRequestType(false, willUpdate: false);
    _aiController!.addListener(_applyImageDrivenSetup);

    if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1) {
      Provider.of<AuctionAiController>(context, listen: false).generateLimitCheck();
    }
    Provider.of<AddProductTaxController>(context, listen: false).getTaxVatList();

    if (widget.auctionProduct?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuctionProductController>(context, listen: false)
            .getAuctionProductForEdit(widget.auctionProduct!.id!).then((_) => _populateTranslationControllers());
      });
    }
  }

  void _populateTranslationControllers() {
    if (!mounted) return;
    final product = Provider.of<AuctionProductController>(context, listen: false).auctionProductForEdit;
    if (product?.translations == null || product!.translations!.isEmpty) return;
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    setState(() {
      for (var t in product.translations!) {
        final idx = languages.indexWhere((lan) => lan.code == (t.locale ?? ''));
        if (idx >= 0 && idx < titleControllerList.length && t.key == 'name') {
          titleControllerList[idx].text = t.value ?? '';
        }
        if (idx >= 0 && idx < descriptionControllerList.length && t.key == 'description') {
          descriptionControllerList[idx].text = t.value ?? '';
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localizationController = Provider.of<LocalizationController>(context, listen: false);
    final String languageCode = localizationController.locale.countryCode == 'US' ? 'en' : localizationController.locale.countryCode!.toLowerCase();

    if (!_brandsLoaded) {
      _brandsLoaded = true;
      Provider.of<ProductController>(context, listen: false).getBrandList(context, languageCode);
    }
    if (!_categoriesLoaded) {
      _categoriesLoaded = true;
      Provider.of<CategoryController>(context, listen: false).getCategoryList(context, null, languageCode);
    }

    if (widget.auctionProduct != null) {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      if (categoryController.categoryList != null && widget.auctionProduct!.category != null) {
        final matched = categoryController.categoryList!.where((c) => c.id == widget.auctionProduct!.category?.id).firstOrNull;
        if (matched != null) selectedCategory = matched.name;
      }

      final productController = Provider.of<ProductController>(context, listen: false);
      if (productController.brandList != null && widget.auctionProduct!.brand != null) {
        final matched = productController.brandList!.where((b) => b.id == widget.auctionProduct!.brand?.id).firstOrNull;
        if (matched != null) selectedBrand = matched.name;
      }
    }
  }

  // Applies image-driven general setup + shipping to this screen's local state.
  // Triggered by AuctionAiController notifications; each result is applied once.
  void _applyImageDrivenSetup() {
    if (!mounted) return;
    final ai = _aiController;
    if (ai == null || !ai.requestTypeImage) return;

    if (!_imageGeneralSetupApplied && ai.generalSetupModel != null) {
      _imageGeneralSetupApplied = true;
      _applyGeneralSetupModel(ai.generalSetupModel);
    }
    if (!_imageShippingApplied && ai.shippingSetupModel != null) {
      _imageShippingApplied = true;
      _applyShippingResult();
    }
  }

  @override
  void dispose() {
    _aiController?.removeListener(_applyImageDrivenSetup);
    _tabController?.dispose();
    for (var controller in titleControllerList) {
      controller.dispose();
    }
    for (var controller in descriptionControllerList) {
      controller.dispose();
    }
    shippingFeeController.dispose();
    returnPolicyController.dispose();
    videoLinkController.dispose();
    itemConditionController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final imageController = Provider.of<AddAuctionProductMediaController>(context);
    final productController = Provider.of<ProductController>(context);
    final categoryController = Provider.of<CategoryController>(context);

    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;

    final List<String> brandNames = productController.brandList?.map((b) => b.name ?? '').where((name) => name.isNotEmpty).toList() ?? [];
    final List<String> categoryNames = categoryController.categoryList?.map((c) => c.name ?? '').where((name) => name.isNotEmpty).toList() ?? [];

    // Select only the loading flags this screen actually uses. Watching the
    // whole controller (via Consumer) made every notifyListeners() — including
    // image picking from the AI sheet — rebuild this entire form even while it
    // is covered by the AI modals, which froze low-RAM devices. A Selector
    // rebuilds only when one of these flags changes, not when pickedLogo does.
    return Selector<AuctionAiController, ({bool basic, bool general, bool shipping, bool desc})>(
      selector: (_, c) => (
        basic: c.auctionBasicSetupLoading,
        general: c.generalSetupLoading,
        shipping: c.shippingSetupLoading,
        desc: c.descLoading,
      ),
      builder: (context, aiFlags, _) {
        final bool anyAiLoading = aiFlags.basic || aiFlags.general || aiFlags.shipping || aiFlags.desc;
        return Scaffold(
          floatingActionButton: aiEnabled
              ? Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
              onPressed: _openAiBottomSheet,
              child: CustomAssetImageWidget(
                Images.useAi,
                height: 56,
                width: 56,
              ),
            ),
          ) : null,

          body: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      BasicSetupWidget(
                        nameController: titleControllerList.isNotEmpty ? titleControllerList[_tabController?.index ?? 0] : TextEditingController(),
                        descriptionController: descriptionControllerList.isNotEmpty ? descriptionControllerList[_tabController?.index ?? 0] : TextEditingController(),
                        langCode: _currentLangCode,
                        isAiGenerating: aiFlags.basic || aiFlags.desc,
                        thumbnailFile: imageController.thumbnailFile,
                        existingThumbnailUrl: imageController.existingThumbnailUrl,
                        onThumbnailTap: () => imageController.pickThumbnail(),
                        onThumbnailRemove: () => imageController.removeThumbnail(),
                        onClearExistingThumbnail: () => imageController.clearExistingThumbnail(),
                        titleControllerList: titleControllerList,
                        descriptionControllerList: descriptionControllerList,
                        tabController: _tabController,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      GeneralSetupWidget(
                        onAiTap: aiEnabled ? _onGeneralSetupAiTap : null,
                        isAiGenerating: aiFlags.general,
                        productType: selectedProductType,
                        productTypeList: productTypeList,
                        onProductTypeChanged: (val) => setState(() => selectedProductType = val),
                        category: selectedCategory,
                        categoryList: categoryNames,
                        onCategoryChanged: (val) => setState(() => selectedCategory = val),
                        brand: selectedBrand,
                        brandList: brandNames,
                        onBrandChanged: (val) => setState(() => selectedBrand = val),
                        itemConditionController: itemConditionController,
                        itemCondition: selectedItemCondition,
                        itemConditionList: itemConditionMap.keys.toList(),
                        onItemConditionChanged: (val) => setState(() {
                          selectedItemCondition = val;
                        }),

                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      AuctionShippingReturnWidget(
                        shippingFeeController: shippingFeeController,
                        returnPolicyController: returnPolicyController,
                        isAiGenerating: aiFlags.shipping,
                        onAiTap: aiEnabled ? _onShippingAiTap : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ProductAdditionalImageWidget(
                        images: imageController.productImages,
                        existingImages: imageController.existingImageUrls,
                        onAddTap: () => imageController.pickProductImage(),
                        onRemoveTap: (index) => imageController.removeProductImage(index),
                        onRemoveExistingTap: (index) => imageController.removeExistingImageAt(index),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      AuctionProductVideoWidget(
                        videoLinkController: videoLinkController,
                        initialType: _videoUploadType,
                        pickedMediaFile: imageController.pickedMediaFile,
                        isPickingMedia: imageController.isPickingMedia,
                        onFileTap: () => imageController.pickSingleMedia(),
                        onFileRemove: () => imageController.removeMediaFile(),
                        onTypeChanged: (type) => setState(() => _videoUploadType = type),
                        existingVideoFilename: imageController.existingCustomVideoFilename,
                        onExistingVideoRemove: () => imageController.clearExistingCustomVideo(),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                  ),
                ),
              ),

              Consumer<ThemeController>(
                builder: (context, themeController, _) {
                  return Container(
                    padding:
                    const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[
                          themeController.darkTheme ? 800 : 200]!,
                          spreadRadius: 0.5,
                          blurRadius: 0.3,
                        ),
                      ],
                    ),
                    child: anyAiLoading ? Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              getTranslated('ai_is_generating_product_details', context) ?? 'AI is generating product details…',
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          ShimmerGeneratingLabel(context: context),
                        ],
                      ),
                    ) : SizedBox(
                      height: 50,
                      child: InkWell(
                        onTap: widget.onNext,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                          child: Center(
                            child: Text(getTranslated('next', context) ?? 'Next',
                              style: titilliumBold.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String get _currentLangCode {
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    if (languages.isEmpty) return 'en';
    final index = _tabController?.index ?? 0;
    return languages[index].code ?? 'en';
  }

  void _openAiBottomSheet() {
    // Re-arm one-shot application so a fresh image generation re-applies general
    // setup + shipping even if a previous run already did.
    _imageGeneralSetupApplied = false;
    _imageShippingApplied = false;

    final splashController = Provider.of<SplashController>(context, listen: false);

    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: AuctionAiGeneratorBottomSheet(
            languageList: splashController.configModel?.languageList,
            tabController: _tabController,
            nameControllerList: titleControllerList,
            descriptionControllerList: descriptionControllerList,
            onImageAutoFillApply: _applyImageAutoFillResults,
          ),
        );
      },
    );
  }

  void _applyImageAutoFillResults() {
    if (!mounted) return;
    _applyGeneralSetupResult();
    _applyShippingResult();
  }

  void _onShippingAiTap() {
    if (titleControllerList[_tabController?.index ?? 0].text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    if (descriptionControllerList[_tabController?.index ?? 0].text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context);
      return;
    }

    Provider.of<AuctionAiController>(context, listen: false).generateShippingPolicySetup(
      title: titleControllerList[_tabController?.index ?? 0].text.trim(),
      description: descriptionControllerList[_tabController?.index ?? 0].text.trim(),
      langCode: _currentLangCode,
    ).then((_) => _applyShippingResult());
  }

  void _applyShippingResult() {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final data = aiController.shippingSetupModel?.data?.auctionAiShippingData;
    if (data == null) return;

    if (data.shippingFee != null) {
      shippingFeeController.text = data.shippingFee.toString();
    }
    if (data.returnPolicy != null && data.returnPolicy!.isNotEmpty) {
      returnPolicyController.text = data.returnPolicy!;
    }
  }

  void _onGeneralSetupAiTap() {
    if (titleControllerList[_tabController?.index ?? 0].text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    if (descriptionControllerList[_tabController?.index ?? 0].text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context);
      return;
    }

    Provider.of<AuctionAiController>(context, listen: false).generateGeneralSetup(
      title: titleControllerList[_tabController?.index ?? 0].text.trim(),
      description: descriptionControllerList[_tabController?.index ?? 0].text.trim(),
      langCode: _currentLangCode,
    ).then((_) => _applyGeneralSetupResult());
  }

  void _applyGeneralSetupResult() {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final model = aiController.generalSetupModel;
    if (model == null) return;

    _applyGeneralSetupModel(model);
  }

  void _applyGeneralSetupModel(AuctionGeneralSetupModel? model) {
    if (model == null) return;
    setState(() {
      if (model.auctionGeneralSetupModel?.data?.productType != null) {
        final suggested = model.auctionGeneralSetupModel?.data?.productType == 'physical' ? 'Physical' : model.auctionGeneralSetupModel?.data?.productType == 'digital' ? 'Digital' : null;
        if (suggested != null && productTypeList.contains(suggested)) {
          selectedProductType = suggested;
        }
      }

      final categoryController = Provider.of<CategoryController>(context, listen: false);
      if (model.auctionGeneralSetupModel?.data?.categoryId != null && categoryController.categoryList != null) {
        final matchedCategory = categoryController.categoryList!.where((c) => c.id.toString() == model.auctionGeneralSetupModel?.data?.categoryId.toString()).firstOrNull;
        if (matchedCategory != null) {
          selectedCategory = matchedCategory.name;
        }
      }

      final productController = Provider.of<ProductController>(context, listen: false);
      if (model.auctionGeneralSetupModel?.data?.brandId != null && productController.brandList != null) {
        final matchedBrand = productController.brandList!.where((b) => b.id == model.auctionGeneralSetupModel?.data?.brandId).firstOrNull;
        if (matchedBrand != null) {
          selectedBrand = matchedBrand.name;
        }
      }

      if (model.auctionGeneralSetupModel?.data?.itemCondition != null) {
        String aiValue = model.auctionGeneralSetupModel!.data!.itemCondition!;
        String? itemConditionKey;

        if (itemConditionMap.containsKey(aiValue)) {
          itemConditionKey = aiValue;
        } else {
          final entry = itemConditionMap.entries.firstWhere(
            (e) => e.value == aiValue,
            orElse: () => const MapEntry('', ''),
          );
          if (entry.key.isNotEmpty) itemConditionKey = entry.key;
        }
        if (itemConditionKey != null) selectedItemCondition = itemConditionKey;
      }

    });
  }

}

class ShimmerGeneratingLabel extends StatelessWidget {
  final BuildContext context;
  const ShimmerGeneratingLabel({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Row(mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            getTranslated('generating', context) ?? 'Generating…',
            style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  final Widget child;
  const ShimmerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShimmerFromColors(
      baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
      highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
      child: child,
    );
  }
}

class ShimmerFromColors extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerFromColors({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
