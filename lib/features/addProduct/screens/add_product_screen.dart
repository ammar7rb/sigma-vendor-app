import 'dart:io';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/common/controller/tutorial_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/edt_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/product_general_info_data_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/ai/widgets/ai_generator_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/digital_product_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/select_category_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/title_and_description_widget.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  final AddProductModel? addProduct;
  final EditProductModel? editProduct;
  final bool fromHome;
  final Function(int) onTabChanged;
  const AddProductScreen(
      {super.key,
      this.product,
      this.addProduct,
      this.editProduct,
      this.fromHome = false,
      required this.onTabChanged});
  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;

  int? length;
  late bool _update;
  int cat = 0, subCat = 0, subSubCat = 0, unit = 0, brand = 0;
  String? unitValue = '';
  List<String> titleList = [];
  List<String> descriptionList = [];
  List<String> authors = [];
  List<String> publishingHouses = [];
  final List<String> deliveryTypeList = ['ready_after_sell', 'ready_product'];
  FocusNode _publishingFocus = FocusNode();
  FocusNode _authorFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  double optionHeight = 0;
  late List<int?> brandIds;
  final TextEditingController _brandNameController = TextEditingController();

  Future<void> _load() async {
    Provider.of<CategoryController>(context, listen: false).resetCategory();
    String languageCode =
        Provider.of<LocalizationController>(context, listen: false)
                    .locale
                    .countryCode ==
                'US'
            ? 'en'
            : Provider.of<LocalizationController>(context, listen: false)
                .locale
                .countryCode!
                .toLowerCase();
    Provider.of<AddProductTaxController>(Get.context!, listen: false)
        .getTaxVatList();
    await Provider.of<SplashController>(Get.context!, listen: false)
        .getColorList();
    await Provider.of<VariationController>(Get.context!, listen: false)
        .getAttributeList(Get.context!, widget.product, languageCode);
    await Provider.of<CategoryController>(Get.context!, listen: false)
        .getCategoryList(Get.context!, widget.product, languageCode);
    await Provider.of<ProductController>(Get.context!, listen: false)
        .getBrandList(Get.context!, languageCode);
    if (_update && widget.product?.brandId == null) {
      Provider.of<ProductController>(Get.context!, listen: false)
          .setBrandIndex(1, false);
    } else if (!_update) {
      Provider.of<ProductController>(Get.context!, listen: false)
          .setBrandIndex(0, false);
    }
  }

  ProductGeneralInfoData getCurrentFormData() {
    CategoryController categoryController =
        Provider.of<CategoryController>(context, listen: false);
    ProductController productController =
        Provider.of<ProductController>(context, listen: false);
    AddProductController resProvider =
        Provider.of<AddProductController>(context, listen: false);

    final selectedBrandIndex = productController.brandIndex;
    final selectedBrandId = selectedBrandIndex != null &&
            selectedBrandIndex >= 0 &&
            selectedBrandIndex < brandIds.length
        ? brandIds[selectedBrandIndex]
        : null;

    return ProductGeneralInfoData(
      categoryId: categoryController.categoryIndex != 0
          ? categoryController
              .categoryList![categoryController.categoryIndex! - 1].id
              .toString()
          : '-1',
      subCategoryId: categoryController.subCategoryIndex != 0
          ? categoryController
              .subCategoryList![categoryController.subCategoryIndex! - 1].id
              .toString()
          : "-1",
      subSubCategoryId: "-1",
      brandId: selectedBrandId != null && selectedBrandId > 0
          ? selectedBrandId.toString()
          : null,
      brandName: _brandNameController.text.trim().isEmpty
          ? null
          : _brandNameController.text.trim(),
      unit: (resProvider.unitValue != null && resProvider.unitValue!.isNotEmpty)
          ? resProvider.unitValue
          : unitValue,
      product: widget.product,
      addProduct: widget.addProduct,
      title: resProvider.titleControllerList[0].text.trim(),
      description: resProvider.descriptionControllerList[0].text.trim(),
    );
  }

  @override
  void initState() {
    super.initState();
    _update = widget.product != null;

    AddProductController addProductController =
        Provider.of<AddProductController>(context, listen: false);
    addProductController.initializeProductSpecifications(widget.product);

    Provider.of<AddProductImageController>(context, listen: false)
        .colorImageObject = [];
    Provider.of<AddProductImageController>(context, listen: false)
        .productReturnImageList = [];

    // Seller product copy is entered in Arabic only. The backend translation
    // payload is preserved for compatibility, while the seller sees one clear
    // source-of-truth field instead of duplicated language tabs.
    _tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    _tabController?.addListener(() {});

    Provider.of<CategoryController>(context, listen: false).removeCategory();
    Provider.of<AddProductController>(context, listen: false)
        .setSelectedPageIndex(0, isUpdate: false);

    length = 1;
    Provider.of<VariationController>(context, listen: false).initColorCode();
    if (widget.product != null) {
      unitValue = widget.product!.unit;
      unitValue = widget.product!.unit;
      Provider.of<AddProductController>(context, listen: false)
          .productCode
          .text = widget.product!.code ?? '123456';
      Provider.of<AddProductController>(context, listen: false)
          .getEditProduct(context, widget.product!.id);
      Provider.of<AddProductController>(context, listen: false)
          .setValueForUnit(widget.product!.unit.toString());
      Provider.of<AddProductController>(context, listen: false)
          .setProductTypeIndex(0, false);
      Provider.of<DigitalProductController>(context, listen: false)
          .setDigitalProductTypeIndex(
              widget.product!.digitalProductType == "ready_after_sell" ? 0 : 1,
              false);
      // Digital products are not exposed by the seller flow.
      Provider.of<SplashController>(context, listen: false).getColorList();
      _loadData();
      addProductController.youtubeLinkController.text =
          widget.product?.videoUrl ?? '';
    } else {
      Provider.of<AddProductController>(context, listen: false)
          .productCode
          .text = _generateSKU();
      Provider.of<AddProductController>(context, listen: false)
          .setValueForUnit('select_unit');
      Provider.of<VariationController>(context, listen: false)
          .setCurrentStock('1');
      Provider.of<AddProductController>(context, listen: false)
          .getTitleAndDescriptionList(
              Provider.of<SplashController>(context, listen: false)
                  .configModel!
                  .languageList!,
              null);
      Provider.of<AddProductController>(context, listen: false)
          .emptyDigitalProductData();
      Provider.of<AddProductImageController>(context, listen: false)
          .removeProductImage();
    }

    _load();

    if (Provider.of<DigitalProductController>(context, listen: false)
        .authorsList!
        .isNotEmpty) {
      for (var author
          in Provider.of<DigitalProductController>(context, listen: false)
              .authorsList!) {
        authors.add(author.name!);
      }
    }

    if (Provider.of<DigitalProductController>(context, listen: false)
        .publishingHouseList!
        .isNotEmpty) {
      for (var author
          in Provider.of<DigitalProductController>(context, listen: false)
              .publishingHouseList!) {
        publishingHouses.add(author.name!);
      }
    }
    Provider.of<AiController>(Get.context!, listen: false)
        .setRequestType(false, willUpdate: false);
    Provider.of<TutorialController>(Get.context!, listen: false)
        .setVisibility(false, isUpdate: false);

    if (Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.isAiFeatureActive ==
        1) {
      Provider.of<AiController>(Get.context!, listen: false)
          .generateLimitCheck();
    }
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _publishingFocus.dispose();
    _authorFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    String languageCode =
        Provider.of<LocalizationController>(context, listen: false)
                    .locale
                    .countryCode ==
                'US'
            ? 'en'
            : Provider.of<LocalizationController>(context, listen: false)
                .locale
                .countryCode!
                .toLowerCase();

    await Provider.of<VariationController>(context, listen: false)
        .getAttributeList(context, widget.product, languageCode);
    Provider.of<VariationController>(Get.context!, listen: false)
        .generateVariantTypes(Get.context!, widget.product);
    _callGetImages();
  }

  Future<void> _callGetImages() async {
    Future.delayed(const Duration(milliseconds: 800), () async {
      Provider.of<AddProductImageController>(Get.context!, listen: false)
          .getProductImage(widget.product!.id.toString(),
              isStorePreviousImage: true, isUpdate: true);
    });
  }

  Future<void> _selectProductDate(
      TextEditingController controller, bool expiry) async {
    final now = DateTime.now();
    final existing = DateTime.tryParse(controller.text);
    final selected = await showDatePicker(
      context: context,
      initialDate:
          existing ?? (expiry ? now.add(const Duration(days: 1)) : now),
      firstDate:
          expiry ? DateTime(now.year, now.month, now.day + 1) : DateTime(2000),
      lastDate: DateTime(now.year + 30),
    );
    if (selected != null) {
      controller.text =
          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  bool get wantKeepAlive => true;

  int addColor = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      floatingActionButton: (Provider.of<SplashController>(context,
                      listen: false)
                  .configModel
                  ?.isAiFeatureActive ==
              1)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
                child:
                    CustomAssetImageWidget(Images.useAi, height: 56, width: 56),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).cardColor,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return AiGeneratorBottomSheet(
                        languageList: Provider.of<SplashController>(context,
                                listen: false)
                            .configModel
                            ?.languageList,
                        tabController: _tabController,
                        nameControllerList: Provider.of<AddProductController>(
                                context,
                                listen: false)
                            .titleControllerList,
                        descriptionControllerList:
                            Provider.of<AddProductController>(context,
                                    listen: false)
                                .descriptionControllerList,
                      );
                    },
                  );
                },
              ),
            )
          : null,
      body: Consumer<VariationController>(
          builder: (context, variationController, child) {
        return Consumer<AddProductController>(
          builder: (context, resProvider, child) {
            return widget.product != null && resProvider.editProduct == null ||
                    variationController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : length != null
                    ? Consumer<SplashController>(
                        builder: (context, splashController, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Consumer<AiController>(
                                          builder: (context, aiController, _) {
                                        return AddProductSectionWidget(
                                          title: getTranslated(
                                              'basic_info', context)!,
                                          subTitle: getTranslated(
                                              'here_you_can_setup_the_product',
                                              context)!,
                                          isAiGenerating:
                                              (aiController.titleLoading ||
                                                  aiController.descLoading),
                                          childrens: [
                                            Container(
                                              margin: const EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault),
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: Dimensions
                                                            .paddingSizeSmall),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          top: Dimensions
                                                              .paddingSizeMedium,
                                                          left: Dimensions
                                                              .paddingEye,
                                                          bottom: Dimensions
                                                              .paddingEye),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: TabBar(
                                                          indicatorSize:
                                                              TabBarIndicatorSize
                                                                  .tab,
                                                          tabAlignment:
                                                              TabAlignment
                                                                  .start,
                                                          isScrollable: true,
                                                          dividerColor:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                          controller:
                                                              _tabController,
                                                          indicatorColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          indicatorWeight: 12,
                                                          labelColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          indicator:
                                                              UnderlineTabIndicator(
                                                            borderSide: BorderSide(
                                                                width: 2.0,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                            insets: EdgeInsets
                                                                .zero, // no inset — covers full tab
                                                          ),
                                                          indicatorPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0),
                                                          unselectedLabelStyle:
                                                              robotoRegular
                                                                  .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                          ),
                                                          labelStyle: robotoBold
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor,
                                                          ),
                                                          tabs:
                                                              _generateTabChildren(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: 235,
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            _tabController!,
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return TabBarView(
                                                              controller:
                                                                  _tabController,
                                                              children: _generateTabPage(
                                                                  resProvider,
                                                                  _tabController));
                                                        },
                                                      )),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .paddingSizeLarge),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                          getTranslated(
                                                              'upload_thumbnail',
                                                              context)!,
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color)),
                                                      SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Text(
                                                        '*',
                                                        style: robotoBold.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error,
                                                            fontSize: Dimensions
                                                                .fontSizeDefault),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                            'seller_product_main_image',
                                                            context) ??
                                                        '',
                                                    style:
                                                        robotoRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Consumer<
                                                          AddProductImageController>(
                                                      builder: (context,
                                                          addProductImageController,
                                                          child) {
                                                    return DottedBorder(
                                                      options:
                                                          RoundedRectDottedBorderOptions(
                                                        dashPattern: const [
                                                          4,
                                                          5
                                                        ],
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                        radius: const Radius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall),
                                                            ),
                                                            child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Stack(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            0),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(0),
                                                                          child: addProductImageController.selectedLogoFile != null
                                                                              ? Image.file(
                                                                                  File(addProductImageController.selectedLogoFile!.path),
                                                                                  width: double.infinity,
                                                                                  height: 150,
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : widget.product != null
                                                                                  ? FadeInImage.assetNetwork(
                                                                                      placeholder: Images.placeholderImage,
                                                                                      image: widget.product!.thumbnailFullUrl?.path ?? '',
                                                                                      height: 150,
                                                                                      width: double.infinity,
                                                                                      fit: BoxFit.cover,
                                                                                      imageErrorBuilder: (c, o, s) => const SizedBox(height: 150, width: 150),
                                                                                    )
                                                                                  : const SizedBox(height: 150, width: 150),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            top: 0,
                                                            left: 0,
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              onTap: () => addProductImageController.pickImage(
                                                                  true,
                                                                  false,
                                                                  false,
                                                                  null,
                                                                  isAddProduct:
                                                                      widget.product ==
                                                                          null),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .paddingSizeSmall),
                                                                ),
                                                                child: (addProductImageController.selectedLogoFile ==
                                                                            null &&
                                                                        (widget.product?.thumbnailFullUrl?.path ==
                                                                                null ||
                                                                            widget.product!.thumbnailFullUrl?.path ==
                                                                                ''))
                                                                    ? Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CustomAssetImageWidget(
                                                                              Images.addImageIcon,
                                                                              height: 30,
                                                                              width: 30,
                                                                              color: Theme.of(context).hintColor.withValues(alpha: .7)),
                                                                          Text(
                                                                              getTranslated('click_to_add', context)!,
                                                                              style: robotoRegular.copyWith(
                                                                                color: Theme.of(context).hintColor.withValues(alpha: .7),
                                                                              ))
                                                                        ],
                                                                      )
                                                                    : const SizedBox
                                                                        .shrink(),
                                                              ),
                                                            ),
                                                          ),
                                                          if (addProductImageController
                                                                      .selectedLogoFile !=
                                                                  null ||
                                                              (widget
                                                                      .product
                                                                      ?.thumbnailFullUrl
                                                                      ?.path
                                                                      ?.isNotEmpty ??
                                                                  false))
                                                            Positioned(
                                                                right: 10,
                                                                top: 10,
                                                                child: SizedBox(
                                                                  width: 25,
                                                                  height: 25,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      addProductImageController.pickImage(
                                                                          true,
                                                                          false,
                                                                          false,
                                                                          null,
                                                                          isAddProduct:
                                                                              widget.product == null);
                                                                    },
                                                                    child:
                                                                        const Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        CustomAssetImageWidget(
                                                                            Images
                                                                                .editImageIcon,
                                                                            height:
                                                                                25,
                                                                            width:
                                                                                25),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Center(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: DefaultTextStyle
                                                                .of(context)
                                                            .style
                                                            .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                            ),
                                                        children: <InlineSpan>[
                                                          TextSpan(
                                                              text: getTranslated(
                                                                      'jpg_png_less_then_1_mb',
                                                                      context) ??
                                                                  ''),
                                                          TextSpan(
                                                            text: getTranslated(
                                                                    'ratio_1_1',
                                                                    context) ??
                                                                '',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor),
                                                          ),
                                                        ],
                                                      ),
                                                      textAlign:
                                                          TextAlign.justify,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeDefault),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      Consumer<AiController>(builder:
                                          (context, aiController, child) {
                                        return AddProductSectionWidget(
                                          title: getTranslated(
                                              'general_setup', context)!,
                                          subTitle: getTranslated(
                                              'here_you_can_set_up_the_foundational_details',
                                              context)!,
                                          isAiGenerating: (aiController
                                              .generalSetupLoading),
                                          aiWidget: Consumer<AiController>(
                                              builder: (context, aiController,
                                                  child) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (resProvider
                                                        .titleControllerList[
                                                            _tabController
                                                                    ?.index ??
                                                                0]
                                                        .text
                                                        .isEmpty) {
                                                      showCustomSnackBarWidget(
                                                          '${getTranslated('product_name_required', context)}',
                                                          context);
                                                    } else if (resProvider
                                                        .descriptionControllerList[
                                                            _tabController
                                                                    ?.index ??
                                                                0]
                                                        .text
                                                        .isEmpty) {
                                                      showCustomSnackBarWidget(
                                                          '${getTranslated('product_description_required', context)}',
                                                          context);
                                                    } else {
                                                      resProvider
                                                          .generateAndSetOtherData(
                                                        title: resProvider
                                                            .titleControllerList[
                                                                _tabController
                                                                        ?.index ??
                                                                    0]
                                                            .text
                                                            .trim(),
                                                        description: resProvider
                                                            .descriptionControllerList[
                                                                _tabController
                                                                        ?.index ??
                                                                    0]
                                                            .text
                                                            .trim(),
                                                        langCode: Provider.of<
                                                                        SplashController>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .configModel
                                                                ?.languageList?[
                                                                    _tabController
                                                                            ?.index ??
                                                                        0]
                                                                .code ??
                                                            'en',
                                                      );
                                                    }
                                                  },
                                                  child: !aiController
                                                          .generalSetupLoading
                                                      ? Icon(Icons.auto_awesome,
                                                          color: Colors.blue)
                                                      : Shimmer.fromColors(
                                                          baseColor:
                                                              Theme.of(context)
                                                                  .hintColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.18),
                                                          highlightColor:
                                                              Theme.of(context)
                                                                  .hintColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.06),
                                                          child: Row(children: [
                                                            Icon(
                                                                Icons
                                                                    .auto_awesome,
                                                                color: Colors
                                                                    .blue),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            Text(
                                                                getTranslated(
                                                                        'generating',
                                                                        context) ??
                                                                    '',
                                                                style: robotoBold
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .blue)),
                                                          ]),
                                                        ),
                                                ),
                                              ],
                                            );
                                          }),
                                          childrens: <Widget>[
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeMedium),
                                              child: SelectCategoryWidget(
                                                  product: widget.product),
                                            ),
                                            Provider.of<SplashController>(
                                                                context,
                                                                listen: false)
                                                            .configModel
                                                            ?.brandSetting ==
                                                        "1" &&
                                                    resProvider
                                                            .productTypeIndex !=
                                                        1
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeMedium),
                                                    child: Column(
                                                      children: [
                                                        Consumer<
                                                                ProductController>(
                                                            builder: (context,
                                                                productController,
                                                                _) {
                                                          brandIds = [];
                                                          brandIds.add(-1);
                                                          brandIds.add(0);
                                                          if (productController
                                                                  .brandList !=
                                                              null) {
                                                            for (int index = 0;
                                                                index <
                                                                    productController
                                                                        .brandList!
                                                                        .length;
                                                                index++) {
                                                              brandIds.add(
                                                                  productController
                                                                      .brandList![
                                                                          index]
                                                                      .id);
                                                            }
                                                            if (_update &&
                                                                widget.product!
                                                                        .brandId !=
                                                                    null) {
                                                              if (brand == 0) {
                                                                productController.setBrandIndex(
                                                                    brandIds.indexOf(widget
                                                                        .product!
                                                                        .brandId),
                                                                    false);
                                                                brand++;
                                                              }
                                                            }
                                                          }

                                                          return DropdownDecoratorWidget(
                                                            child:
                                                                DropdownButton<
                                                                    int>(
                                                              value:
                                                                  productController
                                                                      .brandIndex,
                                                              icon: const Icon(Icons
                                                                  .keyboard_arrow_down_outlined),
                                                              borderRadius: const BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      Dimensions
                                                                          .paddingEye)),
                                                              items: brandIds
                                                                  .map((int?
                                                                      value) {
                                                                return DropdownMenuItem<
                                                                    int>(
                                                                  value: brandIds
                                                                      .indexOf(
                                                                          value),
                                                                  child: Text(
                                                                    value == 0
                                                                        ? getTranslated(
                                                                            'no_brand',
                                                                            context)!
                                                                        : value ==
                                                                                -1
                                                                            ? getTranslated('select_brand',
                                                                                context)!
                                                                            : productController.brandList![(brandIds.indexOf(value) - 2)].name!,
                                                                    style: robotoMedium.copyWith(
                                                                        color: value ==
                                                                                -1
                                                                            ? Theme.of(context).hintColor
                                                                            : null),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged:
                                                                  (int? value) {
                                                                productController
                                                                    .setBrandIndex(
                                                                        value,
                                                                        true);
                                                                // resProvider.changeBrandSelectedIndex(value);
                                                              },
                                                              isExpanded: true,
                                                              underline:
                                                                  const SizedBox(),
                                                            ),
                                                          );
                                                        }),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeSmall),
                                                        CustomTextFieldWidget(
                                                          controller:
                                                              _brandNameController,
                                                          formProduct: true,
                                                          border: true,
                                                          textInputType:
                                                              TextInputType
                                                                  .text,
                                                          hintText: getTranslated(
                                                              'enter_brand_name_if_not_listed',
                                                              context),
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Text(
                                                            getTranslated(
                                                                    'choose_an_existing_brand_or_enter_a_new_name',
                                                                    context) ??
                                                                '',
                                                            style: robotoRegular.copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeMedium),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            resProvider.productTypeIndex == 0
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeMedium),
                                                    child: Column(
                                                      children: [
                                                        DropdownDecoratorWidget(
                                                          title:
                                                              'seller_product_measurement_unit_optional',
                                                          isRequired: false,
                                                          child: DropdownButton<
                                                              String>(
                                                            icon: const Icon(Icons
                                                                .keyboard_arrow_down_outlined),
                                                            borderRadius: const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .paddingEye)),
                                                            hint: (resProvider
                                                                            .unitValue ==
                                                                        null ||
                                                                    resProvider
                                                                            .unitValue ==
                                                                        'select_unit' ||
                                                                    resProvider
                                                                            .unitValue ==
                                                                        'null')
                                                                ? Text(
                                                                    getTranslated(
                                                                        'select_unit',
                                                                        context)!,
                                                                    style: robotoMedium.copyWith(
                                                                        color: Theme.of(context)
                                                                            .hintColor))
                                                                : Text(
                                                                    resProvider
                                                                        .unitValue!,
                                                                    style: robotoMedium
                                                                        .copyWith(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.color,
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeExtraLarge,
                                                                    )),
                                                            items: Provider.of<
                                                                        SplashController>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .configModel!
                                                                .unit!
                                                                .map((String
                                                                    value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Text(
                                                                    value,
                                                                    style:
                                                                        robotoMedium),
                                                              );
                                                            }).toList(),
                                                            onChanged: (val) {
                                                              unitValue = val;
                                                              setState(
                                                                () {
                                                                  resProvider
                                                                      .setValueForUnit(
                                                                          val);
                                                                },
                                                              );
                                                            },
                                                            isExpanded: true,
                                                            underline:
                                                                const SizedBox(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            Padding(
                                              padding: const EdgeInsets
                                                  .fromLTRB(
                                                  Dimensions.paddingSizeMedium,
                                                  Dimensions.paddingSizeMedium,
                                                  Dimensions.paddingSizeMedium,
                                                  0),
                                              child: Row(children: [
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () => _selectProductDate(
                                                      resProvider
                                                          .productionDateController,
                                                      false),
                                                  child: IgnorePointer(
                                                      child: CustomTextFieldWidget(
                                                          formProduct: true,
                                                          required: true,
                                                          border: true,
                                                          readOnly: true,
                                                          controller: resProvider
                                                              .productionDateController,
                                                          hintText: getTranslated(
                                                              'production_date',
                                                              context)!)),
                                                )),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () => _selectProductDate(
                                                      resProvider
                                                          .expiryDateController,
                                                      true),
                                                  child: IgnorePointer(
                                                      child: CustomTextFieldWidget(
                                                          formProduct: true,
                                                          required: true,
                                                          border: true,
                                                          readOnly: true,
                                                          controller: resProvider
                                                              .expiryDateController,
                                                          hintText:
                                                              getTranslated(
                                                                  'expiry_date',
                                                                  context)!)),
                                                )),
                                              ]),
                                            ),
                                            resProvider.productTypeIndex == 0
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        Dimensions
                                                            .paddingSizeMedium,
                                                        Dimensions
                                                            .paddingSizeMedium,
                                                        Dimensions
                                                            .paddingSizeMedium,
                                                        0),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              getTranslated(
                                                                  'seller_product_sale_unit_and_measurements',
                                                                  context)!,
                                                              style: robotoBold.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall),
                                                          DropdownDecoratorWidget(
                                                            title:
                                                                'seller_product_sale_unit_type',
                                                            isRequired: true,
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              value: resProvider
                                                                  .saleUnitType,
                                                              isExpanded: true,
                                                              underline:
                                                                  const SizedBox(),
                                                              items: [
                                                                'piece',
                                                                'package'
                                                              ]
                                                                  .map((value) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: Text(getTranslated(
                                                                            'seller_product_sale_unit_$value',
                                                                            context)!),
                                                                      ))
                                                                  .toList(),
                                                              selectedItemBuilder: (context) => [
                                                                'piece',
                                                                'package'
                                                              ]
                                                                  .map((value) =>
                                                                      Text(getTranslated(
                                                                          'seller_product_sale_unit_$value',
                                                                          context)!))
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                if (value !=
                                                                    null)
                                                                  resProvider
                                                                      .setSaleUnitType(
                                                                          value);
                                                              },
                                                            ),
                                                          ),
                                                          if (resProvider
                                                                  .saleUnitType ==
                                                              'package') ...[
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),
                                                            CustomTextFieldWidget(
                                                              formProduct: true,
                                                              required: true,
                                                              border: true,
                                                              controller:
                                                                  resProvider
                                                                      .piecesPerUnitController,
                                                              textInputType:
                                                                  TextInputType
                                                                      .number,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              hintText:
                                                                  getTranslated(
                                                                      'seller_product_pieces_per_unit',
                                                                      context)!,
                                                            ),
                                                          ],
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall),
                                                          Text(
                                                              getTranslated(
                                                                  'seller_product_optional_dimensions',
                                                                  context)!,
                                                              style: robotoRegular.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall),
                                                          Row(children: [
                                                            Expanded(
                                                                child: CustomTextFieldWidget(
                                                                    formProduct:
                                                                        true,
                                                                    border:
                                                                        true,
                                                                    controller:
                                                                        resProvider
                                                                            .lengthController,
                                                                    textInputType:
                                                                        TextInputType
                                                                            .number,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    hintText: getTranslated(
                                                                        'seller_product_length',
                                                                        context)!)),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                            Expanded(
                                                                child: CustomTextFieldWidget(
                                                                    formProduct:
                                                                        true,
                                                                    border:
                                                                        true,
                                                                    controller:
                                                                        resProvider
                                                                            .widthController,
                                                                    textInputType:
                                                                        TextInputType
                                                                            .number,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    hintText: getTranslated(
                                                                        'seller_product_width',
                                                                        context)!)),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                            Expanded(
                                                                child: CustomTextFieldWidget(
                                                                    formProduct:
                                                                        true,
                                                                    border:
                                                                        true,
                                                                    controller:
                                                                        resProvider
                                                                            .heightController,
                                                                    textInputType:
                                                                        TextInputType
                                                                            .number,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    hintText: getTranslated(
                                                                        'seller_product_height',
                                                                        context)!)),
                                                          ]),
                                                          DropdownDecoratorWidget(
                                                            title:
                                                                'seller_product_dimension_unit',
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              value: resProvider
                                                                  .dimensionUnit,
                                                              isExpanded: true,
                                                              underline:
                                                                  const SizedBox(),
                                                              items: const [
                                                                'cm',
                                                                'm'
                                                              ]
                                                                  .map((value) => DropdownMenuItem<
                                                                          String>(
                                                                      value:
                                                                          value,
                                                                      child: Text(
                                                                          value)))
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                if (value !=
                                                                    null)
                                                                  resProvider
                                                                      .setDimensionUnit(
                                                                          value);
                                                              },
                                                            ),
                                                          ),
                                                          Row(children: [
                                                            Expanded(
                                                                child: CustomTextFieldWidget(
                                                                    formProduct:
                                                                        true,
                                                                    border:
                                                                        true,
                                                                    controller:
                                                                        resProvider
                                                                            .weightController,
                                                                    textInputType:
                                                                        TextInputType
                                                                            .number,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    hintText: getTranslated(
                                                                        'seller_product_weight',
                                                                        context)!)),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                            Expanded(
                                                                child:
                                                                    DropdownDecoratorWidget(
                                                              title:
                                                                  'seller_product_weight_unit',
                                                              child:
                                                                  DropdownButton<
                                                                      String>(
                                                                value: resProvider
                                                                    .weightUnit,
                                                                isExpanded:
                                                                    true,
                                                                underline:
                                                                    const SizedBox(),
                                                                items: const [
                                                                  'g',
                                                                  'kg'
                                                                ]
                                                                    .map((value) => DropdownMenuItem<
                                                                            String>(
                                                                        value:
                                                                            value,
                                                                        child: Text(
                                                                            value)))
                                                                    .toList(),
                                                                onChanged:
                                                                    (value) {
                                                                  if (value !=
                                                                      null)
                                                                    resProvider
                                                                        .setWeightUnit(
                                                                            value);
                                                                },
                                                              ),
                                                            )),
                                                          ]),
                                                        ]),
                                                  )
                                                : const SizedBox(),
                                            false &&
                                                    Provider.of<SplashController>(
                                                                context,
                                                                listen: false)
                                                            .configModel!
                                                            .digitalProductSetting ==
                                                        "1"
                                                ? DigitalProductWidget(
                                                    resProvider: resProvider,
                                                    product: widget.product)
                                                : const SizedBox(),
                                            Consumer<DigitalProductController>(
                                                builder: (context,
                                                    digitalProductController,
                                                    child) {
                                              return Column(
                                                children: [
                                                  //Author
                                                  resProvider.productTypeIndex ==
                                                          1
                                                      ? Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeMedium,
                                                              vertical: Dimensions
                                                                  .paddingSizeSmall),
                                                          child: Autocomplete<
                                                              String>(
                                                            optionsBuilder:
                                                                (TextEditingValue
                                                                    value) {
                                                              if (value.text
                                                                  .isEmpty) {
                                                                return const Iterable<
                                                                    String>.empty();
                                                              } else {
                                                                return authors.where((author) => author
                                                                    .toLowerCase()
                                                                    .contains(value
                                                                        .text
                                                                        .toLowerCase()));
                                                              }
                                                            },
                                                            fieldViewBuilder:
                                                                (context,
                                                                    controller,
                                                                    node,
                                                                    onComplete) {
                                                              _authorFocus =
                                                                  node;
                                                              if (!node
                                                                  .hasFocus) {
                                                                _authorFocus
                                                                    .unfocus();
                                                              } else {
                                                                _authorFocus
                                                                    .requestFocus();
                                                              }
                                                              return TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                controller:
                                                                    controller,
                                                                focusNode: node,
                                                                onEditingComplete:
                                                                    onComplete,
                                                                onSubmitted:
                                                                    (value) {
                                                                  if (digitalProductController
                                                                      .selectedAuthors!
                                                                      .isEmpty) {
                                                                    _scrollController.jumpTo(
                                                                        _scrollController.offset +
                                                                            20);
                                                                  }
                                                                  digitalProductController
                                                                      .addAuthor(
                                                                          value);
                                                                  // controller.text = '';
                                                                },
                                                                onChanged: (value) =>
                                                                    _onChangeOptionHeight(
                                                                        value,
                                                                        authors),
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          Dimensions
                                                                              .paddingSize,
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeMedium),
                                                                  hintText: getTranslated(
                                                                      'author_creator_artist',
                                                                      context),
                                                                  hintStyle: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor),
                                                                  labelText: getTranslated(
                                                                      'author_creator_artist',
                                                                      context),
                                                                  labelStyle: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.color),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Theme.of(context)
                                                                              .primaryColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide: BorderSide(
                                                                          color: Theme.of(context)
                                                                              .primaryColor
                                                                              .withValues(alpha: .25),
                                                                          width: .75)),
                                                                ),
                                                              );
                                                            },
                                                            displayStringForOption:
                                                                (value) =>
                                                                    value,
                                                            onSelected:
                                                                (String value) {
                                                              // resProvider.addAuthor(value);
                                                            },
                                                            optionsViewBuilder: (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                              return Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child:
                                                                    Container(
                                                                  height: (keyboardHeight ==
                                                                              0 &&
                                                                          (_authorFocus
                                                                              .hasFocus))
                                                                      ? 155
                                                                      : 250,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8.0), // Add padding to the right
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.9, // Adjust the width if needed
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusDefault),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.grey[Provider.of<ThemeController>(context).darkTheme
                                                                              ? 800
                                                                              : 200]!,
                                                                          spreadRadius:
                                                                              0.5,
                                                                          blurRadius:
                                                                              0.3)
                                                                    ],
                                                                  ),
                                                                  child: ListView
                                                                      .builder(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    itemCount:
                                                                        options
                                                                            .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      final String
                                                                          option =
                                                                          options
                                                                              .elementAt(index);
                                                                      return InkWell(
                                                                        onTap:
                                                                            () {
                                                                          onSelected(
                                                                              option);
                                                                        },
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            final bool
                                                                                highlight =
                                                                                AutocompleteHighlightedOption.of(context) == index;
                                                                            if (highlight) {
                                                                              SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                                                                                Scrollable.ensureVisible(context, alignment: 0.5);
                                                                              }, debugLabel: 'AutocompleteOptions.ensureVisible');
                                                                            }
                                                                            return Container(
                                                                              color: highlight ? Theme.of(context).focusColor : null,
                                                                              padding: const EdgeInsets.all(16.0),
                                                                              child: Text(option),
                                                                            );
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : const SizedBox(),

                                                  if (resProvider
                                                              .productTypeIndex ==
                                                          1 &&
                                                      digitalProductController
                                                          .selectedAuthors!
                                                          .isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeMedium),
                                                      child: SizedBox(
                                                        height: (resProvider
                                                                        .productTypeIndex ==
                                                                    1 &&
                                                                digitalProductController
                                                                    .selectedAuthors!
                                                                    .isNotEmpty)
                                                            ? 40
                                                            : 0,
                                                        child: (digitalProductController
                                                                .selectedAuthors!
                                                                .isNotEmpty)
                                                            ? ListView.builder(
                                                                itemCount:
                                                                    digitalProductController
                                                                        .selectedAuthors!
                                                                        .length,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .all(
                                                                        Dimensions
                                                                            .paddingSizeVeryTiny),
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              Dimensions.paddingSizeMedium),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              Dimensions.paddingSizeSmall),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .primaryColor
                                                                            .withValues(alpha: .20),
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                      ),
                                                                      child: Row(
                                                                          children: [
                                                                            Consumer<SplashController>(builder: (ctx,
                                                                                colorP,
                                                                                child) {
                                                                              return Text(
                                                                                digitalProductController.selectedAuthors![index],
                                                                                style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                              );
                                                                            }),
                                                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              onTap: () {
                                                                                digitalProductController.removeAuthor(index);
                                                                              },
                                                                              child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : const SizedBox(),
                                                      ),
                                                    ),

                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),

                                                  ///Publishing
                                                  resProvider.productTypeIndex ==
                                                          1
                                                      ? Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeMedium,
                                                              vertical: Dimensions
                                                                  .paddingSizeSmall),
                                                          child: Autocomplete<
                                                              String>(
                                                            optionsBuilder:
                                                                (TextEditingValue
                                                                    value) {
                                                              if (value.text
                                                                  .isEmpty) {
                                                                return const Iterable<
                                                                    String>.empty();
                                                              } else {
                                                                return publishingHouses.where((author) => author
                                                                    .toLowerCase()
                                                                    .contains(value
                                                                        .text
                                                                        .toLowerCase()));
                                                              }
                                                            },
                                                            fieldViewBuilder:
                                                                (context,
                                                                    controller,
                                                                    node,
                                                                    onComplete) {
                                                              _publishingFocus =
                                                                  node;
                                                              if (!node
                                                                  .hasFocus) {
                                                                _publishingFocus
                                                                    .unfocus();
                                                              } else {
                                                                _publishingFocus
                                                                    .requestFocus();
                                                              }
                                                              return TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                controller:
                                                                    controller,
                                                                focusNode: node,
                                                                onEditingComplete:
                                                                    onComplete,
                                                                onSubmitted:
                                                                    (value) {
                                                                  if (digitalProductController
                                                                      .selectedPublishingHouse!
                                                                      .isEmpty) {
                                                                    _scrollController.jumpTo(
                                                                        _scrollController.offset +
                                                                            20);
                                                                  }
                                                                  digitalProductController
                                                                      .addPublishingHouse(
                                                                          value);
                                                                },
                                                                onChanged: (value) =>
                                                                    _onChangeOptionHeight(
                                                                        value,
                                                                        publishingHouses),
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText: getTranslated(
                                                                      'publishing_house',
                                                                      context),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          Dimensions
                                                                              .paddingSize,
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeMedium),
                                                                  hintStyle: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor),
                                                                  labelText: getTranslated(
                                                                      'publishing_house',
                                                                      context),
                                                                  labelStyle: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.color),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Theme.of(context).primaryColor)),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide: BorderSide(
                                                                          color: Theme.of(context)
                                                                              .primaryColor
                                                                              .withValues(alpha: .25),
                                                                          width: .75)),
                                                                ),
                                                              );
                                                            },
                                                            displayStringForOption:
                                                                (value) =>
                                                                    value,
                                                            onSelected:
                                                                (String value) {
                                                              // resProvider.addAuthor(value);
                                                            },
                                                            optionsViewBuilder: (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                              return Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8.0), // Add padding to the right
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.9, //
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusDefault),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.grey[Provider.of<ThemeController>(context).darkTheme
                                                                              ? 800
                                                                              : 200]!,
                                                                          spreadRadius:
                                                                              0.5,
                                                                          blurRadius:
                                                                              0.3)
                                                                    ],
                                                                  ),

                                                                  // Adjust the width if needed
                                                                  child: ListView
                                                                      .builder(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    itemCount:
                                                                        options
                                                                            .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      final String
                                                                          option =
                                                                          options
                                                                              .elementAt(index);
                                                                      return InkWell(
                                                                        onTap:
                                                                            () {
                                                                          onSelected(
                                                                              option);
                                                                        },
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            final bool
                                                                                highlight =
                                                                                AutocompleteHighlightedOption.of(context) == index;
                                                                            if (highlight) {
                                                                              SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                                                                                Scrollable.ensureVisible(context, alignment: 0.5);
                                                                              }, debugLabel: 'AutocompleteOptions.ensureVisible');
                                                                            }
                                                                            return Container(
                                                                              color: highlight ? Theme.of(context).focusColor : null,
                                                                              padding: const EdgeInsets.all(16.0),
                                                                              child: Text(option),
                                                                            );
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : const SizedBox(),

                                                  if (resProvider
                                                              .productTypeIndex ==
                                                          1 &&
                                                      digitalProductController
                                                          .selectedPublishingHouse!
                                                          .isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeMedium),
                                                      child: SizedBox(
                                                        height: (resProvider
                                                                        .productTypeIndex ==
                                                                    1 &&
                                                                digitalProductController
                                                                    .selectedPublishingHouse!
                                                                    .isNotEmpty)
                                                            ? 40
                                                            : 0,
                                                        child: (digitalProductController
                                                                .selectedPublishingHouse!
                                                                .isNotEmpty)
                                                            ? ListView.builder(
                                                                itemCount:
                                                                    digitalProductController
                                                                        .selectedPublishingHouse!
                                                                        .length,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .all(
                                                                        Dimensions
                                                                            .paddingSizeVeryTiny),
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              Dimensions.paddingSizeMedium),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              Dimensions.paddingSizeSmall),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .primaryColor
                                                                            .withValues(alpha: .20),
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                      ),
                                                                      child: Row(
                                                                          children: [
                                                                            Consumer<SplashController>(builder: (ctx,
                                                                                colorP,
                                                                                child) {
                                                                              return Text(
                                                                                digitalProductController.selectedPublishingHouse![index],
                                                                                style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                              );
                                                                            }),
                                                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              onTap: () {
                                                                                digitalProductController.removePublishingHouse(index);
                                                                              },
                                                                              child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : const SizedBox(),
                                                      ),
                                                    ),
                                                  //End Author Publishing

                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),

                                                  resProvider.productTypeIndex ==
                                                          1
                                                      ? Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeMedium),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                DropdownDecoratorWidget(
                                                                  title:
                                                                      'delivery_type',
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_outlined),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.paddingEye)),
                                                                    value: digitalProductController.digitalProductTypeIndex ==
                                                                            0
                                                                        ? 'ready_after_sell'
                                                                        : 'ready_product',
                                                                    items: deliveryTypeList
                                                                        .map((String
                                                                            value) {
                                                                      return DropdownMenuItem<
                                                                              String>(
                                                                          value:
                                                                              value,
                                                                          child: Text(
                                                                              getTranslated(value, context)!,
                                                                              style: robotoMedium));
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (value) {
                                                                      digitalProductController.setDigitalProductTypeIndex(
                                                                          value == 'ready_after_sell'
                                                                              ? 0
                                                                              : 1,
                                                                          true);
                                                                    },
                                                                    isExpanded:
                                                                        true,
                                                                    underline:
                                                                        const SizedBox(),
                                                                  ),
                                                                ),
                                                              ]),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              );
                                            }),
                                            const SizedBox(height: 15),
                                          ],
                                        );
                                      }),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      AddProductSectionWidget(
                                        title: getTranslated(
                                            'additional_product_images',
                                            context)!,
                                        subTitle: getTranslated(
                                            'upload_any_additional_images_for',
                                            context)!,
                                        childrens: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault,
                                                vertical: Dimensions
                                                    .paddingSizeSmall),
                                            child: Consumer<
                                                    AddProductImageController>(
                                                builder: (context,
                                                    imageController, _) {
                                              final existingCount = _update
                                                  ? (widget.product
                                                          ?.imagesFullUrl
                                                          ?.where((image) =>
                                                              image.path
                                                                  ?.isNotEmpty ??
                                                              false)
                                                          .length ??
                                                      0)
                                                  : 0;
                                              final colorCount = imageController
                                                  .imagesWithColor
                                                  .where((image) =>
                                                      image.image != null)
                                                  .length;
                                              final count = existingCount +
                                                  imageController
                                                      .withoutColor.length +
                                                  colorCount;
                                              final isComplete = count >= 5;
                                              return Row(children: [
                                                Icon(
                                                    isComplete
                                                        ? Icons
                                                            .check_circle_outline
                                                        : Icons
                                                            .photo_library_outlined,
                                                    color: isComplete
                                                        ? Colors.green
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .error),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                Text(
                                                    '${getTranslated('seller_product_images_count', context)}: $count/5',
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: isComplete
                                                                ? Colors.green
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error)),
                                              ]);
                                            }),
                                          ),
                                          if (_update)
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeDefault,
                                                  vertical: Dimensions
                                                      .paddingSizeSmall),
                                              child:
                                                  Consumer<VariationController>(
                                                      builder: (context,
                                                          variationController,
                                                          _) {
                                                return Consumer<
                                                        AddProductImageController>(
                                                    builder: (context,
                                                        addProductImageController,
                                                        _) {
                                                  return GridView.builder(
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              childAspectRatio:
                                                                  1,
                                                              crossAxisCount: 2,
                                                              crossAxisSpacing:
                                                                  10,
                                                              mainAxisSpacing:
                                                                  10),
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          addProductImageController
                                                              .imagesWithoutColor
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              index) {
                                                        return Stack(children: [
                                                          DottedBorder(
                                                            options:
                                                                RoundedRectDottedBorderOptions(
                                                              dashPattern: const [
                                                                4,
                                                                5
                                                              ],
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                              radius:
                                                                  const Radius
                                                                      .circular(
                                                                      15),
                                                            ),
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                              child: ClipRRect(
                                                                borderRadius: const BorderRadius
                                                                    .all(
                                                                    Radius.circular(
                                                                        Dimensions
                                                                            .paddingSizeSmall)),
                                                                child:
                                                                    CustomImageWidget(
                                                                  image: addProductImageController
                                                                          .imagesWithoutColor[
                                                                      index],
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.3,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.3,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                              top: 5,
                                                              right: 5,
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                onTap: () =>
                                                                    addProductImageController
                                                                        .deleteProductImage(
                                                                  '${widget.product?.id}',
                                                                  _getFilenameFromFullImagePath(
                                                                      addProductImageController
                                                                              .imagesWithoutColor[
                                                                          index]),
                                                                  null,
                                                                ),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Theme.of(context)
                                                                            .hintColor
                                                                            .withValues(alpha: .25),
                                                                        blurRadius:
                                                                            1,
                                                                        spreadRadius:
                                                                            1,
                                                                        offset: const Offset(
                                                                            0,
                                                                            0),
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.paddingSizeDefault)),
                                                                  ),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete_forever_rounded,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        ]);
                                                      });
                                                });
                                              }),
                                            ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault,
                                                vertical: Dimensions
                                                    .paddingSizeSmall),
                                            child: Consumer<
                                                    AddProductImageController>(
                                                builder: (context,
                                                    addProductImageController,
                                                    child) {
                                              return GridView.builder(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                  ),
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      addProductImageController
                                                              .withoutColor
                                                              .length +
                                                          1,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          index) {
                                                    return index ==
                                                            addProductImageController
                                                                .withoutColor
                                                                .length
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              final existingCount = _update
                                                                  ? (widget
                                                                          .product
                                                                          ?.imagesFullUrl
                                                                          ?.where((image) =>
                                                                              image.path?.isNotEmpty ??
                                                                              false)
                                                                          .length ??
                                                                      0)
                                                                  : 0;
                                                              final colorImageCount =
                                                                  addProductImageController
                                                                      .imagesWithColor
                                                                      .where((image) =>
                                                                          image
                                                                              .image !=
                                                                          null)
                                                                      .length;
                                                              addProductImageController
                                                                  .pickAdditionalImages(
                                                                existingCount:
                                                                    existingCount,
                                                                colorImageCount:
                                                                    colorImageCount,
                                                              );
                                                            },
                                                            child: Stack(
                                                              children: [
                                                                DottedBorder(
                                                                  options:
                                                                      RoundedRectDottedBorderOptions(
                                                                    dashPattern: const [
                                                                      4,
                                                                      5
                                                                    ],
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                    radius: const Radius
                                                                        .circular(
                                                                        15),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.paddingSizeSmall),
                                                                    child: Image
                                                                        .asset(
                                                                      Images
                                                                          .placeholderImage,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .highlightColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  top: 0,
                                                                  left: 0,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CustomAssetImageWidget(
                                                                              Images.addImageIcon,
                                                                              height: 30,
                                                                              width: 30,
                                                                              color: Theme.of(context).hintColor.withValues(alpha: .7)),
                                                                          const SizedBox(
                                                                              height: Dimensions.paddingSizeSmall),
                                                                          Text(
                                                                              getTranslated('click_to_add', context)!,
                                                                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineMedium?.color))
                                                                        ]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Stack(
                                                            children: [
                                                              DottedBorder(
                                                                options:
                                                                    RoundedRectDottedBorderOptions(
                                                                  dashPattern: const [
                                                                    4,
                                                                    5
                                                                  ],
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                  radius: const Radius
                                                                      .circular(
                                                                      15),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.paddingSizeSmall)),
                                                                    child: Image
                                                                        .file(
                                                                      File(addProductImageController
                                                                          .withoutColor[
                                                                              index]
                                                                          .image!
                                                                          .path),
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 5,
                                                                right: 5,
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap: () => addProductImageController
                                                                      .removeImage(
                                                                          index,
                                                                          false),
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color: Theme.of(context).hintColor.withValues(alpha: .25),
                                                                                blurRadius: 1,
                                                                                spreadRadius: 1,
                                                                                offset: const Offset(0, 0))
                                                                          ],
                                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
                                                                      child: const Padding(
                                                                          padding: EdgeInsets.all(4.0),
                                                                          child: Icon(
                                                                            Icons.delete_forever_rounded,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                25,
                                                                          ))),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                  });
                                            }),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      if (false)
                                        AddProductSectionWidget(
                                          title: getTranslated(
                                              'product_video_link', context)!,
                                          subTitle: getTranslated(
                                              'add_the_youtube_video_link_here',
                                              context)!,
                                          childrens: <Widget>[
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeSmall),
                                              child: CustomTextFieldWidget(
                                                border: true,
                                                maxLine: 1,
                                                textInputType:
                                                    TextInputType.text,
                                                controller: resProvider
                                                    .youtubeLinkController,
                                                textInputAction:
                                                    TextInputAction.done,
                                                hintText: getTranslated(
                                                    'youtube_video_link',
                                                    context)!,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault),
                                          ],
                                        ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                    ]),
                              ),
                            )),
                            SizedBox(height: optionHeight),
                            Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: (keyboardHeight > 0 &&
                                        (_publishingFocus.hasFocus ||
                                            _authorFocus.hasFocus))
                                    ? Colors.transparent
                                    : Theme.of(context).cardColor,
                                boxShadow: (keyboardHeight > 0 &&
                                        (_publishingFocus.hasFocus ||
                                            _authorFocus.hasFocus))
                                    ? null
                                    : [
                                        BoxShadow(
                                            color: Colors.grey[
                                                Provider.of<ThemeController>(
                                                            context)
                                                        .darkTheme
                                                    ? 800
                                                    : 200]!,
                                            spreadRadius: 0.5,
                                            blurRadius: 0.3)
                                      ],
                              ),
                              child:
                                  (keyboardHeight > 0 &&
                                          (_publishingFocus.hasFocus ||
                                              _authorFocus.hasFocus))
                                      ? const SizedBox()
                                      : Consumer<AddProductController>(
                                          builder: (context, resProvider, _) {
                                          return !resProvider.isLoading
                                              ? SizedBox(
                                                  height: 50,
                                                  child: Consumer<
                                                          CategoryController>(
                                                      builder: (context,
                                                          categoryController,
                                                          _) {
                                                    return Consumer<
                                                            AiController>(
                                                        builder: (context,
                                                            aiController, _) {
                                                      return InkWell(
                                                        onTap: categoryController
                                                                    .categoryList ==
                                                                null
                                                            ? null
                                                            : () {
                                                                AddProductImageController
                                                                    addProductImageController =
                                                                    Provider.of<
                                                                            AddProductImageController>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                CategoryController
                                                                    categoryControllerr =
                                                                    Provider.of<
                                                                            CategoryController>(
                                                                        context,
                                                                        listen:
                                                                            false);

                                                                // bool isProductImageNull = false;
                                                                //
                                                                // final productController = Provider.of<ProductController>(context,listen: false);
                                                                // final categoryController = Provider.of<CategoryController>(context,listen: false);
                                                                //
                                                                // bool haveBlankTitle = false;
                                                                // bool haveBlankDes = false;
                                                                // if(resProvider.titleControllerList.isNotEmpty) {
                                                                //   if( resProvider.titleControllerList[0].text.isEmpty){
                                                                //     haveBlankTitle = true;
                                                                //   }
                                                                // }
                                                                //
                                                                // if(resProvider.descriptionControllerList.isNotEmpty) {
                                                                //   if(resProvider.descriptionControllerList[0].text.isEmpty) {
                                                                //     haveBlankDes = true;
                                                                //   }
                                                                // }
                                                                //
                                                                // if(_update && (widget.product!.imagesFullUrl != null && widget.product!.imagesFullUrl!.isNotEmpty)) {
                                                                //   for(ImageFullUrl image in widget.product!.imagesFullUrl!) {
                                                                //     if(image.path == null || image.path == '') {
                                                                //       isProductImageNull = true;
                                                                //       break;
                                                                //     }
                                                                //   }
                                                                // }
                                                                //
                                                                // if(haveBlankTitle){
                                                                //   showCustomSnackBarWidget(getTranslated('please_input_all_title',context),context, sanckBarType: SnackBarType.warning);
                                                                // }else if(haveBlankDes){
                                                                //   showCustomSnackBarWidget(getTranslated('please_input_all_des',context),context,  sanckBarType: SnackBarType.warning);
                                                                // }
                                                                // else if (categoryController.categoryIndex == 0 || categoryController.categoryIndex == -1) {
                                                                //   showCustomSnackBarWidget(getTranslated('select_a_category',context),context,  sanckBarType: SnackBarType.warning);
                                                                // }
                                                                // else if ((resProvider.unitValue == 'select_unit' || resProvider.unitValue == null) &&  resProvider.productTypeIndex == 0) {
                                                                //   showCustomSnackBarWidget(getTranslated('select_a_unit',context),context,  sanckBarType: SnackBarType.warning);
                                                                // }
                                                                // else if (resProvider.productCode.text == '' || resProvider.productCode.text.isEmpty) {
                                                                //   showCustomSnackBarWidget(getTranslated('product_code_is_required',context),context,  sanckBarType: SnackBarType.warning);
                                                                // }
                                                                // else if (resProvider.productCode.text.length < 6 || resProvider.productCode.text == '000000') {
                                                                //   showCustomSnackBarWidget(getTranslated('product_code_minimum_6_digit',context),context,  sanckBarType: SnackBarType.warning);
                                                                // } else if ((!_update && addProductImageController.selectedLogoFile == null) || (_update && (addProductImageController.selectedLogoFile == null  && (widget.product?.thumbnailFullUrl?.path == null || widget.product?.thumbnailFullUrl?.path == ''))) ) {
                                                                //   showCustomSnackBarWidget(getTranslated('upload_thumbnail_image',context),context, sanckBarType: SnackBarType.warning);
                                                                // } else if (!_update && addProductImageController.imagesWithColor.length + addProductImageController.withoutColor.length == 0  || (_update && addProductImageController.imagesWithColor.length + addProductImageController.withoutColor.length == 0 && ((widget.product!.imagesFullUrl != null && widget.product!.imagesFullUrl!.isEmpty) || isProductImageNull))) {
                                                                //   showCustomSnackBarWidget(getTranslated('upload_product_image',context),context, sanckBarType: SnackBarType.warning);
                                                                // }

                                                                bool isValidate = resProvider.validateGeneralInfo(
                                                                    context,
                                                                    categoryController:
                                                                        categoryControllerr,
                                                                    imageController:
                                                                        addProductImageController,
                                                                    existingProduct:
                                                                        widget
                                                                            .product,
                                                                    youtubeLink:
                                                                        resProvider
                                                                            .youtubeLinkController
                                                                            .text);

                                                                if (isValidate) {
                                                                  for (TextEditingController textEditingController
                                                                      in resProvider
                                                                          .titleControllerList) {
                                                                    titleList.add(
                                                                        textEditingController
                                                                            .text
                                                                            .trim());
                                                                  }

                                                                  //  print('----UnitValue--->>${resProvider.unitValue}---');
                                                                  // if(resProvider.productTypeIndex == 1 &&resProvider.digitalProductTypeIndex == 1 &&
                                                                  //     resProvider.selectedFileForImport != null ) {
                                                                  //   resProvider.uploadDigitalProduct(Provider.of<AuthController>(context,listen: false).getUserToken());
                                                                  // }
                                                                  resProvider.setSelectedPageIndex(
                                                                      1,
                                                                      isUpdate:
                                                                          true);

                                                                  widget
                                                                      .onTabChanged(
                                                                          1);
                                                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductNextScreen(
                                                                  //   categoryId: categoryController.categoryList![categoryController.categoryIndex!-1].id.toString(),
                                                                  //   subCategoryId: categoryController.subCategoryIndex != 0? categoryController.subCategoryList![categoryController.subCategoryIndex!-1].id.toString(): "-1",
                                                                  //   subSubCategoryId:(categoryController.subSubCategoryIndex != 0 && categoryController.subSubCategoryIndex! != -1) ? categoryController.subSubCategoryList![categoryController.subSubCategoryIndex!-1].id.toString():"-1",
                                                                  //   brandId: Provider.of<SplashController>(Get.context!, listen: false).configModel!.brandSetting == "1" && resProvider.productTypeIndex != 1 ? brandIds[productController.brandIndex!].toString() : null,
                                                                  //   unit: (resProvider.unitValue != null && resProvider.unitValue!.isNotEmpty) ? resProvider.unitValue :  unitValue,
                                                                  //   product: widget.product, addProduct: widget.addProduct,
                                                                  //   title: resProvider.titleControllerList[0].text.trim(),
                                                                  //   description: resProvider.descriptionControllerList[0].text.trim(),
                                                                  // )));
                                                                }
                                                              },
                                                        child: aiController
                                                                .addProductSetupLoading
                                                            ? Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: 40,
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        Dimensions
                                                                            .paddingSizeDefault),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.30),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            Text(
                                                                      getTranslated(
                                                                              'ai_is_generating_product_details',
                                                                              context) ??
                                                                          '',
                                                                      style: robotoMedium.copyWith(
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyLarge
                                                                              ?.color,
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                                      maxLines:
                                                                          2,
                                                                    )),
                                                                    SizedBox(
                                                                        width: Dimensions
                                                                            .paddingSizeExtraSmall),
                                                                    Shimmer
                                                                        .fromColors(
                                                                      baseColor: Theme.of(
                                                                              context)
                                                                          .hintColor
                                                                          .withValues(
                                                                              alpha: 0.18),
                                                                      highlightColor: Theme.of(
                                                                              context)
                                                                          .hintColor
                                                                          .withValues(
                                                                              alpha: 0.06),
                                                                      child: Row(
                                                                          children: [
                                                                            Icon(Icons.auto_awesome,
                                                                                color: Theme.of(context).primaryColor),
                                                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                            Text(getTranslated('generating', context) ?? '',
                                                                                style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                                                          ]),
                                                                    ),
                                                                  ],
                                                                ))
                                                            : Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: categoryController
                                                                              .categoryList ==
                                                                          null
                                                                      ? Theme.of(
                                                                              context)
                                                                          .hintColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall),
                                                                ),
                                                                child: Center(
                                                                    child: Text(
                                                                  getTranslated(
                                                                      'next',
                                                                      context)!,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeLarge),
                                                                )),
                                                              ),
                                                      );
                                                    });
                                                  }),
                                                )
                                              : const SizedBox();
                                        }),
                            )
                          ],
                        );
                      })
                    : const SizedBox();
          },
        );
      }),
    );
  }

  String _generateSKU() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String sku = '';

    for (int i = 0; i < 6; i++) {
      sku += chars[random.nextInt(chars.length)];
    }
    return sku;
  }

  List<Widget> _generateTabChildren() {
    return [
      Text(getTranslated('arabic', context) ?? 'العربية',
          style: robotoBold.copyWith())
    ];
  }

  List<Widget> _generateTabPage(
      AddProductController resProvider, TabController? tabIndex) {
    return [
      TitleAndDescriptionWidget(
          resProvider: resProvider, index: 0, langCode: 'ar')
    ];
  }

  void _onChangeOptionHeight(String value, List<String> list) {
    setState(() {
      if (value.isEmpty) {
        optionHeight = 0;
      } else {
        final int items = list
            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
            .length;
        optionHeight = items * 10;

        if (optionHeight > 300) {
          optionHeight = 300;
        }
      }
    });
  }

  String _getFilenameFromFullImagePath(String url) {
    final regex = RegExp(r'([^/]+)$');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
