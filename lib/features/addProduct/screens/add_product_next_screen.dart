import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/attribute_view_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/product_general_info_data_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/color_variation_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/digital_product_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/upload_preview_file_widget.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
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
import '../../auth/controllers/auth_controller.dart';

class AddProductNextScreen extends StatefulWidget {
  final ValueChanged<bool>? isSelected;
  final Product? product;
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandId;
  final String? brandName;
  final AddProductModel? addProduct;
  final String? unit;
  final String? title;
  final String? description;
  final Function(int) onTabChanged;

  const AddProductNextScreen(
      {super.key,
      this.isSelected,
      required this.product,
      required this.addProduct,
      this.categoryId,
      this.subCategoryId,
      this.subSubCategoryId,
      this.brandId,
      this.brandName,
      this.unit,
      this.title,
      this.description,
      required this.onTabChanged});

  @override
  AddProductNextScreenState createState() => AddProductNextScreenState();
}

class AddProductNextScreenState extends State<AddProductNextScreen>
    with AutomaticKeepAliveClientMixin {
  bool isSelected = false;
  final FocusNode _unitPriceNode = FocusNode();
  final FocusNode _totalQuantityNode = FocusNode();
  final FocusNode _minimumOrderQuantityNode = FocusNode();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _colorVariationController =
      TextEditingController();

  final digitalProductController =
      Provider.of<DigitalProductController>(Get.context!, listen: false);
  final resProvider =
      Provider.of<AddProductController>(Get.context!, listen: false);

  AutoCompleteTextField? searchTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;
  late bool _update;
  Product? _product;
  String? thumbnailImage = '', metaImage = '';
  List<String?>? productImage = [];
  int counter = 0, total = 0;
  int addColor = 0;
  int cat = 0, subCat = 0, subSubCat = 0, unit = 0, brand = 0;

  List<String> taxModelList = ['include', 'exclude'];

  Future<void> _load() async {
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
  }

  @override
  void dispose() {
    _colorVariationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<AddProductImageController>(context, listen: false)
        .colorImageObject = [];
    Provider.of<AddProductImageController>(context, listen: false)
        .productReturnImageList = [];
    _product = widget.product;
    _update = widget.product != null;
    _taxController.text = '0';
    _discountController.text = '0';
    resProvider.shippingCostController.text = '0';
    resProvider.minimumOrderQuantityController.text = '1';
    _loadData();
    if (_update) {
      _asyncMethod();
      resProvider.unitPriceController.text =
          PriceConverter.convertPriceWithoutSymbol(
              context, _product!.unitPrice);
      _taxController.text = _product!.tax.toString();
      Provider.of<VariationController>(context, listen: false)
          .setCurrentStock(_product!.currentStock.toString());
      // Admin three-step shipping replaces the legacy per-product shipping amount.
      resProvider.shippingCostController.text = '0';
      resProvider.minimumOrderQuantityController.text =
          _product!.minimumOrderQty.toString();
      Provider.of<AddProductController>(context, listen: false)
          .setDiscountTypeIndex(
              _product!.discountType == 'percent' ? 0 : 1, false);
      _discountController.text = _product!.discountType == 'percent'
          ? _product!.discount.toString()
          : PriceConverter.convertPriceWithoutSymbol(
              context, _product!.discount);
      thumbnailImage = _product!.thumbnail;
      metaImage = _product!.metaImage;
      productImage = _product!.images;
      Provider.of<AddProductController>(context, listen: false)
          .setTaxTypeIndex(_product!.taxModel == 'include' ? 0 : 1, false);
      Provider.of<AddProductTaxController>(Get.context!, listen: false)
          .setProductVatTax(_product?.taxVats);
      if ((widget.product?.variation != null &&
              widget.product!.variation!.isNotEmpty) ||
          (widget.product?.digitalVariation != null &&
              widget.product!.digitalVariation!.isNotEmpty) ||
          (widget.product!.colors != null &&
              widget.product!.colors!.isNotEmpty)) {
        Provider.of<AddProductController>(context, listen: false)
            .setIsAttributeActive(true, notify: false);
      }
    } else {
      VariationController variationController =
          Provider.of<VariationController>(Get.context!, listen: false);

      _product = Product();
      resProvider.unitPriceController.text = '0';
      resProvider.discountController.text = '0';
      _discountController.text = '0';
      variationController.totalQuantityController.text = '1';
      resProvider.minimumOrderQuantityController.text = '1';
      resProvider.shippingCostController.text = '0';
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadData() async {
    await _load();
    if (Provider.of<AiController>(Get.context!, listen: false)
        .requestTypeImage) {
      Provider.of<AiController>(Get.context!, listen: false)
          .setNextProductNextScreen(true);

      await Future.delayed(const Duration(milliseconds: 500));

      await Provider.of<AiController>(Get.context!, listen: false)
          .generatePricing(
              title: widget.title ?? '',
              langCode: widget.description ?? '',
              uniPriceController: resProvider.unitPriceController,
              discountController: _discountController,
              stockQuantityController:
                  Provider.of<VariationController>(Get.context!, listen: false)
                      .totalQuantityController,
              minQuantityController: resProvider.minimumOrderQuantityController,
              shippingCostController: resProvider.shippingCostController);

      await Provider.of<AiController>(Get.context!, listen: false)
          .generateVariationSetup(
              title: widget.title ?? '',
              description: widget.description ?? '',
              product: widget.product);
      Provider.of<AiController>(Get.context!, listen: false)
          .setNextProductNextScreen(false);
      showCustomSnackBarWidget(
          getTranslated('tap_next_to_automatically_generate', Get.context!),
          Get.context!,
          sanckBarType: SnackBarType.warning);
    }
  }

  Future<void> _asyncMethod() async {
    Future.delayed(const Duration(milliseconds: 800), () async {
      Provider.of<AddProductImageController>(Get.context!, listen: false)
          .getProductImage(widget.product!.id.toString(),
              isStorePreviousImage: true);
    });
  }

  ProductCombinedData getCurrentFormData() {
    final resProvider =
        Provider.of<AddProductController>(context, listen: false);
    final categoryController =
        Provider.of<CategoryController>(context, listen: false);
    final String titleValue = resProvider.titleControllerList[0].text.trim();
    final String descriptionValue =
        resProvider.descriptionControllerList[0].text.trim();
    String unitPrice = resProvider.unitPriceController.text.trim();
    String currentStock =
        Provider.of<VariationController>(context, listen: false)
            .totalQuantityController
            .text
            .trim();
    List<int?> taxIds =
        Provider.of<AddProductTaxController>(Get.context!, listen: false)
            .selectedTaxList
            .map((tax) => tax.id)
            .toList();
    // Sigma pricing does not allow seller-side discounts. Promotions are
    // controlled centrally, so the legacy API field remains neutral.
    const String discount = '0';
    // Keep legacy form data neutral; server-side checkout calculates the real shipping price.
    String shipping = '0';

    return ProductCombinedData(
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
      brandId: widget.brandId,
      brandName: widget.brandName,
      unit: (resProvider.unitValue != null && resProvider.unitValue!.isNotEmpty)
          ? resProvider.unitValue
          : widget.unit,
      title: titleValue,
      description: descriptionValue,
      product: widget.product,
      addProduct: widget.addProduct,
      unitPrice: unitPrice,
      discount: discount,
      currentStock: currentStock,
      minimumOrderQuantity: resProvider.minimumOrderQuantityController.text,
      tax: taxIds,
      shippingCost: shipping,
      isSelected: widget.isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeController themeProvider =
        Provider.of<ThemeController>(context, listen: false);

    final ConfigModel? configModel =
        Provider.of<SplashController>(Get.context!, listen: false).configModel;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        Provider.of<AddProductController>(context, listen: false)
            .setSelectedPageIndex(0, isUpdate: true);
      },
      child: Scaffold(
        // appBar: CustomAppBarWidget(title:  widget.product != null ?
        // getTranslated('update_product', context) :
        // getTranslated('add_product', context),
        // onBackPressed: () {
        //   Navigator.pop(context);
        //   Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(0, isUpdate: true);
        //   },

        body: Container(
          decoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall),
          child: Consumer<VariationController>(
              builder: (context, variationController, child) {
            return Consumer<AddProductController>(
              builder: (context, resProvider, child) {
                List<int> brandIds = [];
                List<String> digitalVariation = [
                  'Audio',
                  'Video',
                  'Document',
                  'Software'
                ];
                List<int> colors = [];
                brandIds.add(0);

                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Consumer<CategoryController>(
                            builder: (context, categoryController, child) {
                          return SingleChildScrollView(
                            child:
                                (variationController.attributeList != null &&
                                        variationController
                                            .attributeList!.isNotEmpty &&
                                        categoryController.categoryList !=
                                            null &&
                                        Provider.of<SplashController>(context,
                                                    listen: false)
                                                .colorList !=
                                            null)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Consumer<AiController>(builder:
                                                (context, aiController, child) {
                                              return AddProductSectionWidget(
                                                isAiGenerating:
                                                    aiController.pricingLoading,
                                                title: getTranslated(
                                                    'pricing_and_others',
                                                    context)!,
                                                subTitle: getTranslated(
                                                    'here_you_can_setup_the_price',
                                                    context)!,
                                                aiWidget:
                                                    Consumer<AiController>(
                                                        builder: (context,
                                                            aiController,
                                                            child) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (widget.title ==
                                                              null) {
                                                            showCustomSnackBarWidget(
                                                                '${getTranslated('product_name_required', context)}',
                                                                context);
                                                          } else if (widget
                                                                  .description ==
                                                              null) {
                                                            showCustomSnackBarWidget(
                                                                '${getTranslated('product_description_required', context)}',
                                                                context);
                                                          } else {
                                                            aiController.generatePricing(
                                                                title: widget
                                                                        .title ??
                                                                    '',
                                                                langCode: widget
                                                                        .description ??
                                                                    '',
                                                                uniPriceController:
                                                                    resProvider
                                                                        .unitPriceController,
                                                                discountController:
                                                                    _discountController,
                                                                stockQuantityController:
                                                                    variationController
                                                                        .totalQuantityController,
                                                                minQuantityController:
                                                                    resProvider
                                                                        .minimumOrderQuantityController,
                                                                shippingCostController:
                                                                    resProvider
                                                                        .shippingCostController);
                                                          }
                                                        },
                                                        child: !aiController
                                                                .pricingLoading
                                                            ? Icon(
                                                                Icons
                                                                    .auto_awesome,
                                                                color:
                                                                    Colors.blue)
                                                            : Shimmer
                                                                .fromColors(
                                                                baseColor: Theme.of(
                                                                        context)
                                                                    .hintColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.18),
                                                                highlightColor: Theme.of(
                                                                        context)
                                                                    .hintColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.06),
                                                                child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .auto_awesome,
                                                                          color:
                                                                              Colors.blue),
                                                                      const SizedBox(
                                                                          width:
                                                                              Dimensions.paddingSizeExtraSmall),
                                                                      Text(
                                                                          getTranslated('generating', context) ??
                                                                              '',
                                                                          style:
                                                                              robotoBold.copyWith(color: Colors.blue)),
                                                                    ]),
                                                              ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                                childrens: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeMedium),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeLarge),
                                                        CustomTextFieldWidget(
                                                          border: true,
                                                          controller: resProvider
                                                              .unitPriceController,
                                                          focusNode:
                                                              _unitPriceNode,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                          textInputType:
                                                              TextInputType
                                                                  .number,
                                                          isAmount: true,
                                                          hintText:
                                                              getTranslated(
                                                            resProvider.saleUnitType ==
                                                                    'package'
                                                                ? 'seller_product_package_price'
                                                                : 'seller_product_individual_price',
                                                            context,
                                                          )!,
                                                          formProduct: true,
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeLarge),

                                                        if (configModel
                                                                    ?.systemTaxType ==
                                                                'product_wise' &&
                                                            configModel
                                                                    ?.systemTaxIncludeStatus ==
                                                                0)
                                                          Consumer<
                                                                  AddProductTaxController>(
                                                              builder: (context,
                                                                  addProductTaxController,
                                                                  child) {
                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                DropdownDecoratorWidget(
                                                                  child: DropdownButton<
                                                                      TaxVatModel>(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_outlined),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.paddingEye)),
                                                                    hint: Text(
                                                                        getTranslated(
                                                                            'select_tax_rate',
                                                                            context)!,
                                                                        style: robotoRegular
                                                                            .copyWith(
                                                                          color: themeProvider.darkTheme
                                                                              ? Theme.of(context).textTheme.bodyLarge?.color
                                                                              : Theme.of(context).hintColor,
                                                                        )),
                                                                    items: addProductTaxController
                                                                        .taxVatList
                                                                        .map((TaxVatModel?
                                                                            value) {
                                                                      bool
                                                                          isSelected =
                                                                          addProductTaxController
                                                                              .isSelected(value!);
                                                                      return DropdownMenuItem<
                                                                          TaxVatModel>(
                                                                        enabled:
                                                                            !isSelected,
                                                                        value:
                                                                            value,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text('${value.name} ${value.id != 0 ? '(${value.taxRate}%)' : ''}'),
                                                                            if (isSelected)
                                                                              Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (TaxVatModel?
                                                                            value) {
                                                                      if (value
                                                                              ?.id ==
                                                                          0) {
                                                                        for (TaxVatModel taxVatModel
                                                                            in addProductTaxController.taxVatList) {
                                                                          if (taxVatModel.id != 0 &&
                                                                              !addProductTaxController.isSelected(taxVatModel)) {
                                                                            addProductTaxController.addToSelectedTaxList(taxVatModel);
                                                                          }
                                                                        }
                                                                        return;
                                                                      } else {
                                                                        addProductTaxController
                                                                            .addToSelectedTaxList(value!);
                                                                      }
                                                                    },
                                                                    isExpanded:
                                                                        true,
                                                                    underline:
                                                                        const SizedBox(),
                                                                  ),
                                                                ),
                                                                !addProductTaxController
                                                                        .selectedTaxList
                                                                        .isNotEmpty
                                                                    ? const SizedBox(
                                                                        height: Dimensions
                                                                            .paddingSizeSmall)
                                                                    : const SizedBox
                                                                        .shrink(),
                                                                addProductTaxController
                                                                        .selectedTaxList
                                                                        .isNotEmpty
                                                                    ? SizedBox(
                                                                        height: addProductTaxController.selectedTaxList.isNotEmpty
                                                                            ? 40
                                                                            : 0,
                                                                        child: ListView
                                                                            .builder(
                                                                          itemCount: addProductTaxController
                                                                              .selectedTaxList
                                                                              .length,
                                                                          scrollDirection:
                                                                              Axis.horizontal,
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                                              child: Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                                                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                                                decoration: BoxDecoration(
                                                                                  color: Theme.of(context).primaryColor.withValues(alpha: .20),
                                                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                                ),
                                                                                child: Row(children: [
                                                                                  Consumer<SplashController>(builder: (ctx, colorP, child) {
                                                                                    return Text(
                                                                                      '${addProductTaxController.selectedTaxList[index].name} (${addProductTaxController.selectedTaxList[index].taxRate}%)',
                                                                                      style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                                    );
                                                                                  }),
                                                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    onTap: () {
                                                                                      addProductTaxController.removeToSelectedTaxList(addProductTaxController.selectedTaxList[index], index);
                                                                                    },
                                                                                    child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                                  ),
                                                                                ]),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      )
                                                                    : const SizedBox(),
                                                                addProductTaxController
                                                                        .selectedTaxList
                                                                        .isNotEmpty
                                                                    ? const SizedBox(
                                                                        height:
                                                                            Dimensions.paddingSizeSmall)
                                                                    : const SizedBox(),
                                                              ],
                                                            );
                                                          }),

                                                        ///Stock Quantity
                                                        Consumer<
                                                                VariationController>(
                                                            builder: (context,
                                                                variationController,
                                                                child) {
                                                          return Column(
                                                            children: [
                                                              resProvider.productTypeIndex ==
                                                                      0
                                                                  ? CustomTextFieldWidget(
                                                                      idDate: variationController
                                                                          .variantTypeList
                                                                          .isNotEmpty,
                                                                      border:
                                                                          true,
                                                                      textInputType:
                                                                          TextInputType
                                                                              .number,
                                                                      focusNode:
                                                                          _totalQuantityNode,
                                                                      controller:
                                                                          variationController
                                                                              .totalQuantityController,
                                                                      textInputAction:
                                                                          TextInputAction
                                                                              .next,
                                                                      isAmount:
                                                                          true,
                                                                      hintText: getTranslated(
                                                                          'current_stock',
                                                                          context)!,
                                                                      formProduct:
                                                                          true,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              resProvider.productTypeIndex ==
                                                                      0
                                                                  ? const SizedBox(
                                                                      height: Dimensions
                                                                          .iconSizeExtraLarge)
                                                                  : const SizedBox
                                                                      .shrink(),
                                                            ],
                                                          );
                                                        }),

                                                        ///Min order quantity
                                                        CustomTextFieldWidget(
                                                          border: true,
                                                          textInputType:
                                                              TextInputType
                                                                  .number,
                                                          focusNode:
                                                              _minimumOrderQuantityNode,
                                                          controller: resProvider
                                                              .minimumOrderQuantityController,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          isAmount: true,
                                                          hintText: getTranslated(
                                                              'minimum_order_quantity',
                                                              context)!,
                                                          formProduct: true,
                                                        ),

                                                        // Shipping price and quantity rules are configured by admin at checkout.
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                            SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault),
                                            Consumer<AiController>(builder:
                                                (context, aiController, child) {
                                              return AddProductSectionWidget(
                                                isAiGenerating: aiController
                                                    .variationLoading,
                                                title: getTranslated(
                                                    'variations', context)!,
                                                subTitle: getTranslated(
                                                    'enable_and_manage_different_variations',
                                                    context)!,
                                                aiWidget: InkWell(
                                                  onTap: () {
                                                    if (widget.title == null) {
                                                      showCustomSnackBarWidget(
                                                          '${getTranslated('product_name_required', context)}',
                                                          context);
                                                    } else if (widget
                                                            .description ==
                                                        null) {
                                                      showCustomSnackBarWidget(
                                                          '${getTranslated('product_description_required', context)}',
                                                          context);
                                                    } else {
                                                      aiController
                                                          .generateVariationSetup(
                                                              title: widget
                                                                      .title ??
                                                                  '',
                                                              description: widget
                                                                      .description ??
                                                                  '',
                                                              product: widget
                                                                  .product);
                                                    }
                                                  },
                                                  child: !aiController
                                                          .variationLoading
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
                                                button: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: Dimensions
                                                          .paddingSizeDefault),
                                                  child: FlutterSwitch(
                                                    width: 40.0,
                                                    height: 20.0,
                                                    toggleSize: 20.0,
                                                    value: resProvider
                                                        .isAttributeActive,
                                                    borderRadius: 20.0,
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    padding: 1.0,
                                                    onToggle: (bool isActive) =>
                                                        resProvider
                                                            .setIsAttributeActive(
                                                                isActive,
                                                                notify: true),
                                                  ),
                                                ),
                                                childrens: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: Dimensions
                                                          .paddingSizeMedium,
                                                      right: Dimensions
                                                          .paddingSizeMedium,
                                                      top: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .centerStart,
                                                      child: Text(
                                                        getTranslated(
                                                                'seller_product_variation_help',
                                                                context) ??
                                                            '',
                                                        style: robotoRegular
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (!resProvider
                                                      .isAttributeActive)
                                                    SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeSmall),
                                                  resProvider.productTypeIndex ==
                                                              0 &&
                                                          resProvider
                                                              .isAttributeActive
                                                      ? Column(children: [
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeDefault),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeMedium),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.05)),
                                                              padding: EdgeInsets
                                                                  .all(Dimensions
                                                                      .paddingSizeSmall),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            getTranslated('color',
                                                                                context)!,
                                                                            style:
                                                                                robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                                          Text(
                                                                            getTranslated('here_you_setup_color_wise_variations',
                                                                                context)!,
                                                                            style:
                                                                                robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      )),
                                                                      const SizedBox(
                                                                          width:
                                                                              Dimensions.paddingSizeSmall),
                                                                      FlutterSwitch(
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            20.0,
                                                                        toggleSize:
                                                                            20.0,
                                                                        value: variationController
                                                                            .attributeList![0]
                                                                            .active,
                                                                        borderRadius:
                                                                            20.0,
                                                                        activeColor:
                                                                            Theme.of(context).primaryColor,
                                                                        padding:
                                                                            1.0,
                                                                        onToggle: (bool isActive) => variationController.toggleAttribute(
                                                                            context,
                                                                            0,
                                                                            widget.product),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Consumer<
                                                                          AiController>(
                                                                      builder: (context,
                                                                          aiController,
                                                                          child) {
                                                                    TextEditingController?
                                                                        _autoController;
                                                                    FocusNode?
                                                                        _autoFocusNode;

                                                                    return Column(
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                Dimensions.paddingSizeSmall),
                                                                        variationController.attributeList![0].active
                                                                            ? Consumer<SplashController>(builder: (ctx, colorProvider, child) {
                                                                                if (colorProvider.colorList != null) {
                                                                                  for (int index = 0; index < colorProvider.colorList!.length; index++) {
                                                                                    colors.add(index);
                                                                                  }
                                                                                }
                                                                                return Autocomplete<int>(
                                                                                  optionsBuilder: (TextEditingValue value) {
                                                                                    if (value.text.isEmpty) {
                                                                                      return _getColorSuggestionsIndexList(
                                                                                        colors: colors,
                                                                                        colorList: colorProvider.colorList,
                                                                                        savedColorVariationList: variationController.attributeList?.first.variants ?? [],
                                                                                        pattern: '',
                                                                                      );
                                                                                    } else {
                                                                                      return _getColorSuggestionsIndexList(
                                                                                        colors: colors,
                                                                                        colorList: colorProvider.colorList,
                                                                                        savedColorVariationList: variationController.attributeList?.first.variants ?? [],
                                                                                        pattern: value.text,
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                  optionsViewBuilder: (context, Function(int) onSelected, Iterable<int> options) {
                                                                                    return Align(
                                                                                      alignment: Alignment.topLeft,
                                                                                      child: Material(
                                                                                        elevation: 4.0,
                                                                                        color: Theme.of(context).cardColor,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                                                        ),
                                                                                        child: SizedBox(
                                                                                          width: MediaQuery.of(context).size.width - (Dimensions.paddingSizeDefault * 2),
                                                                                          height: 250,
                                                                                          child: ListView.builder(
                                                                                            padding: EdgeInsets.zero,
                                                                                            itemCount: options.length,
                                                                                            itemBuilder: (BuildContext context, int index) {
                                                                                              final int optionIndex = options.elementAt(index);
                                                                                              final colorItem = colorProvider.colorList![optionIndex];

                                                                                              String hexString = colorItem.code!.replaceAll('#', '');
                                                                                              Color itemColor = Color(int.parse("0xFF$hexString"));

                                                                                              return InkWell(
                                                                                                onTap: () {
                                                                                                  onSelected(optionIndex);
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        width: 20,
                                                                                                        height: 20,
                                                                                                        decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2))),
                                                                                                      ),
                                                                                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          colorItem.name!,
                                                                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  fieldViewBuilder: (context, controller, node, onComplete) {
                                                                                    _autoController ??= controller;
                                                                                    _autoFocusNode ??= node;
                                                                                    return Container(
                                                                                      height: 50,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Theme.of(context).cardColor,
                                                                                        border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .50)),
                                                                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                                                      ),
                                                                                      child: TextField(
                                                                                        controller: controller,
                                                                                        focusNode: node,
                                                                                        onEditingComplete: onComplete,
                                                                                        onTap: () {
                                                                                          if (controller.text.isEmpty) {
                                                                                            controller.text = controller.text;
                                                                                          }
                                                                                        },
                                                                                        decoration: InputDecoration(
                                                                                          hintText: getTranslated('type_color_name', context),
                                                                                          hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                                                                          border: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                                                            borderSide: BorderSide.none,
                                                                                          ),
                                                                                          suffixIcon: Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  displayStringForOption: (value) => colorProvider.colorList![value].name!,
                                                                                  onSelected: (int value) {
                                                                                    variationController.addVariant(context, 0, colorProvider.colorList![value].name, widget.product, true);
                                                                                    variationController.addColorCode(colorProvider.colorList![value].code);

                                                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                                      _autoFocusNode?.unfocus();
                                                                                    });
                                                                                  },
                                                                                );
                                                                              })
                                                                            : const SizedBox(),
                                                                        SizedBox(
                                                                            height: (variationController.attributeList![0].variants.isNotEmpty)
                                                                                ? Dimensions.paddingSizeSmall
                                                                                : 0),
                                                                        if (variationController.attributeList?[0].active ??
                                                                            false)
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 0),
                                                                            child: variationController.attributeList![0].variants.isNotEmpty
                                                                                ? Wrap(
                                                                                    spacing: Dimensions.paddingSizeSmall,
                                                                                    runSpacing: Dimensions.paddingSizeSmall,
                                                                                    children: List.generate(
                                                                                      variationController.attributeList![0].variants.length,
                                                                                      (index) {
                                                                                        String hexString = '';
                                                                                        if (variationController.colorCodeList.isNotEmpty && variationController.colorCodeList.length > index) {
                                                                                          hexString = variationController.colorCodeList[index]!.replaceAll('#', '');
                                                                                        }
                                                                                        Color itemColor = Color(int.parse("0xFF$hexString"));
                                                                                        return Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                                                                                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 15,
                                                                                                height: 15,
                                                                                                decoration: BoxDecoration(
                                                                                                  color: itemColor,
                                                                                                  shape: BoxShape.circle,
                                                                                                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                                              Consumer<SplashController>(builder: (ctx, colorP, child) {
                                                                                                return Text(
                                                                                                  variationController.attributeList![0].variants[index]!,
                                                                                                  style: robotoRegular.copyWith(
                                                                                                    fontSize: Dimensions.fontSizeDefault,
                                                                                                    color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                                                                                                  ),
                                                                                                );
                                                                                              }),
                                                                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                                              InkWell(
                                                                                                splashColor: Colors.transparent,
                                                                                                onTap: () {
                                                                                                  variationController.removeVariant(context, 0, index, widget.product);
                                                                                                  variationController.removeColorCode(index);
                                                                                                },
                                                                                                child: Icon(
                                                                                                  Icons.close,
                                                                                                  size: 15,
                                                                                                  color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  )
                                                                                : const SizedBox(),
                                                                          ),
                                                                        const SizedBox(
                                                                            height:
                                                                                Dimensions.paddingSizeSmall),
                                                                      ],
                                                                    );
                                                                  }),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeDefault),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeMedium),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.05)),
                                                              padding: EdgeInsets
                                                                  .all(Dimensions
                                                                      .paddingSizeSmall),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            getTranslated('other_attributes',
                                                                                context)!,
                                                                            style:
                                                                                robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            getTranslated('here_you_can_setup_the_product_attribute',
                                                                                context)!,
                                                                            style:
                                                                                robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      )),
                                                                    ],
                                                                  ),
                                                                  AttributeViewWidget(
                                                                      product:
                                                                          widget
                                                                              .product,
                                                                      colorOn: variationController
                                                                          .attributeList![
                                                                              0]
                                                                          .active),
                                                                  SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeDefault),
                                                        ])
                                                      : const SizedBox(),
                                                  SizedBox(
                                                      height: resProvider
                                                                  .productTypeIndex ==
                                                              0
                                                          ? 0
                                                          : Dimensions
                                                              .paddingSizeDefault),
                                                  resProvider.productTypeIndex ==
                                                              1 &&
                                                          resProvider
                                                              .isAttributeActive
                                                      ? Consumer<
                                                              DigitalProductController>(
                                                          builder: (context,
                                                              digitalProductController,
                                                              _) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .all(Dimensions
                                                                    .paddingSizeSmall),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.05)),
                                                              padding: EdgeInsets
                                                                  .all(Dimensions
                                                                      .paddingSizeSmall),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        getTranslated(
                                                                            'select_file_type',
                                                                            context)!,
                                                                        style: robotoBold.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(context).textTheme.bodyLarge?.color),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),

                                                                      Text(
                                                                        getTranslated(
                                                                            'select_at_least_one_file_type_to_work',
                                                                            context)!,
                                                                        style: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall,
                                                                            color: Theme.of(context).textTheme.headlineLarge?.color),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              Dimensions.paddingSizeSmall),

                                                                      DropdownDecoratorWidget(
                                                                        child: DropdownButton<
                                                                            String>(
                                                                          icon:
                                                                              const Icon(Icons.keyboard_arrow_down_outlined),
                                                                          borderRadius: const BorderRadius
                                                                              .all(
                                                                              Radius.circular(Dimensions.paddingEye)),
                                                                          hint: Text(
                                                                              getTranslated('select_file_type', context)!,
                                                                              style: robotoRegular.copyWith(color: themeProvider.darkTheme ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraLarge)),
                                                                          items:
                                                                              digitalVariation.map((String? value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Text(value!),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged:
                                                                              (String? value) {
                                                                            if (digitalProductController.selectedDigitalVariation.contains(value)) {
                                                                              showCustomSnackBarWidget(getTranslated('filetype_already_exists', context), context, sanckBarType: SnackBarType.warning);
                                                                            } else {
                                                                              digitalProductController.addDigitalProductVariation(value!);
                                                                            }
                                                                          },
                                                                          isExpanded:
                                                                              true,
                                                                          underline:
                                                                              const SizedBox(),
                                                                        ),
                                                                      ),

                                                                      !digitalProductController
                                                                              .selectedDigitalVariation
                                                                              .isNotEmpty
                                                                          ? const SizedBox(
                                                                              height: Dimensions.paddingSizeSmall)
                                                                          : const SizedBox.shrink(),

                                                                      digitalProductController
                                                                              .selectedDigitalVariation
                                                                              .isNotEmpty
                                                                          ? SizedBox(
                                                                              height: digitalProductController.selectedDigitalVariation.isNotEmpty ? 30 : 0,
                                                                              child: ListView.builder(
                                                                                itemCount: digitalProductController.selectedDigitalVariation.length,
                                                                                scrollDirection: Axis.horizontal,
                                                                                itemBuilder: (context, index) {
                                                                                  return Container(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Theme.of(context).hintColor.withValues(alpha: .20),
                                                                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                                    ),
                                                                                    child: Row(children: [
                                                                                      Consumer<SplashController>(builder: (ctx, colorP, child) {
                                                                                        return Text(
                                                                                          digitalProductController.selectedDigitalVariation[index],
                                                                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!),
                                                                                        );
                                                                                      }),
                                                                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                      InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        onTap: () {
                                                                                          digitalProductController.removeDigitalVariant(context, index);
                                                                                        },
                                                                                        child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                                      ),
                                                                                    ]),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),
                                                                      digitalProductController
                                                                              .selectedDigitalVariation
                                                                              .isNotEmpty
                                                                          ? const SizedBox(
                                                                              height: Dimensions.paddingSizeSmall)
                                                                          : const SizedBox(),

                                                                      ///Digital variation
                                                                      Consumer<DigitalProductController>(builder:
                                                                          (context,
                                                                              digitalProductController,
                                                                              _) {
                                                                        return ListView
                                                                            .builder(
                                                                          itemCount: digitalProductController
                                                                              .selectedDigitalVariation
                                                                              .length,
                                                                          shrinkWrap:
                                                                              true,
                                                                          physics:
                                                                              const NeverScrollableScrollPhysics(),
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  digitalProductController.selectedDigitalVariation[index],
                                                                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: CustomTextFieldWidget(
                                                                                        formProduct: true,
                                                                                        required: true,
                                                                                        border: true,
                                                                                        controller: digitalProductController.extentionControllerList[index],
                                                                                        textInputAction: TextInputAction.done,
                                                                                        textInputType: TextInputType.text,
                                                                                        isAmount: false,
                                                                                        hintText: '${digitalProductController.selectedDigitalVariation[index]} ${getTranslated('extension', context)!}',
                                                                                        onFieldSubmit: (String value) {
                                                                                          if (digitalProductController.digitalVariationExtantion[index].contains(value)) {
                                                                                            showCustomSnackBarWidget(getTranslated('extension_already_exists', context), context, sanckBarType: SnackBarType.warning);
                                                                                          } else if (value.trim() != '') {
                                                                                            digitalProductController.addExtension(index, value);
                                                                                          }
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        if (digitalProductController.digitalVariationExtantion[index].contains(digitalProductController.extentionControllerList[index].text)) {
                                                                                          showCustomSnackBarWidget(getTranslated('extension_already_exists', context), context, sanckBarType: SnackBarType.warning);
                                                                                        } else if (digitalProductController.extentionControllerList[index].text.trim() != '') {
                                                                                          digitalProductController.addExtension(index, digitalProductController.extentionControllerList[index].text);
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        height: 50,
                                                                                        width: 50,
                                                                                        padding: EdgeInsets.all(Dimensions.paddingSizeMedium),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Theme.of(context).primaryColor,
                                                                                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                                                        ),
                                                                                        child: SizedBox(height: 20, width: 20, child: CustomAssetImageWidget(Images.addAttribuiteIcon)),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                digitalProductController.digitalVariationExtantion[index].isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                                                                                digitalProductController.digitalVariationExtantion[index].isNotEmpty
                                                                                    ? SizedBox(
                                                                                        height: digitalProductController.digitalVariationExtantion[index].isNotEmpty ? 30 : 0,
                                                                                        child: ListView.builder(
                                                                                          itemCount: digitalProductController.digitalVariationExtantion[index].length,
                                                                                          scrollDirection: Axis.horizontal,
                                                                                          itemBuilder: (context, i) {
                                                                                            return Padding(
                                                                                              padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                                                              child: Container(
                                                                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                                                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Theme.of(context).hintColor.withValues(alpha: .20),
                                                                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                                                ),
                                                                                                child: Row(children: [
                                                                                                  Consumer<SplashController>(builder: (ctx, colorP, child) {
                                                                                                    return Text(
                                                                                                      digitalProductController.digitalVariationExtantion[index][i],
                                                                                                      style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                                                    );
                                                                                                  }),
                                                                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                  InkWell(
                                                                                                    splashColor: Colors.transparent,
                                                                                                    onTap: () {
                                                                                                      digitalProductController.removeExtension(index, i);
                                                                                                    },
                                                                                                    child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                                                  ),
                                                                                                ]),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      )
                                                                                    : const SizedBox(),
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall)
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      }),
                                                                    ]),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                      : SizedBox(),
                                                ],
                                              );
                                            }),
                                            variationController
                                                    .variantTypeList.isNotEmpty
                                                ? SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault)
                                                : const SizedBox(),
                                            variationController
                                                    .variantTypeList.isNotEmpty
                                                ? AttributePricingWidget(
                                                    product: widget.product,
                                                    colorOn: variationController
                                                        .attributeList![0]
                                                        .active)
                                                : const SizedBox(),
                                            if (variationController
                                                    .attributeList![0].active &&
                                                variationController
                                                    .attributeList![0]
                                                    .variants
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                            if (variationController
                                                    .attributeList![0].active &&
                                                variationController
                                                    .attributeList![0]
                                                    .variants
                                                    .isNotEmpty)
                                              ColorVariationImageWidget(
                                                  product: widget.product),
                                            if (variationController
                                                    .attributeList![0].active &&
                                                variationController
                                                    .attributeList![0]
                                                    .variants
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                            resProvider.productTypeIndex == 1 &&
                                                    resProvider
                                                        .isAttributeActive
                                                ? Consumer<
                                                        DigitalProductController>(
                                                    builder: (context,
                                                        digitalProductController,
                                                        _) {
                                                    return Column(
                                                      children: [
                                                        digitalProductController
                                                                .shouldShowUploadFile()
                                                            ? SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeDefault)
                                                            : SizedBox(),
                                                        digitalProductController
                                                                .shouldShowUploadFile()
                                                            ? AddProductSectionWidget(
                                                                title: getTranslated(
                                                                    'variation_wise_file_upload',
                                                                    context)!,
                                                                childrens: [
                                                                  ListView
                                                                      .builder(
                                                                    itemCount: digitalProductController
                                                                        .selectedDigitalVariation
                                                                        .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return ListView
                                                                          .builder(
                                                                        itemCount: digitalProductController
                                                                            .variationFileList[index]
                                                                            .length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemBuilder:
                                                                            (context,
                                                                                i) {
                                                                          return Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: (i % 2 == 0) ? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha: 0.03),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text('${digitalProductController.selectedDigitalVariation[index]}-${digitalProductController.digitalVariationExtantion[index][i]} ${getTranslated('file', context)!}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                                                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                  Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: Column(
                                                                                        children: [
                                                                                          CustomTextFieldWidget(
                                                                                            border: true,
                                                                                            controller: digitalProductController.variationFileList[index][i].priceController,
                                                                                            textInputAction: TextInputAction.done,
                                                                                            textInputType: TextInputType.number,
                                                                                            isAmount: false,
                                                                                            hintText: getTranslated('price_s', context)!,
                                                                                            onFieldSubmit: (String value) {
                                                                                              if (value.trim() != '') {
                                                                                                // resProvider.addExtension(index, value);
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                          const SizedBox(height: Dimensions.paddingSizeMedium),
                                                                                          CustomTextFieldWidget(
                                                                                            border: true,
                                                                                            controller: digitalProductController.variationFileList[index][i].skuController,
                                                                                            textInputAction: TextInputAction.done,
                                                                                            textInputType: TextInputType.text,
                                                                                            isAmount: false,
                                                                                            hintText: getTranslated('sku', context)!,
                                                                                            onFieldSubmit: (String value) {
                                                                                              if (value.trim() != '') {
                                                                                                // resProvider.addExtension(index, value);
                                                                                              }
                                                                                            },
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: Dimensions.paddingSizeMedium,
                                                                                    ),
                                                                                    Provider.of<DigitalProductController>(context, listen: false).digitalProductTypeIndex == 1
                                                                                        ? Expanded(
                                                                                            flex: 1,
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                                                                                color: Theme.of(context).highlightColor,
                                                                                              ),
                                                                                              child: DottedBorder(
                                                                                                options: RoundedRectDottedBorderOptions(
                                                                                                  dashPattern: const [4, 5],
                                                                                                  color: digitalProductController.variationFileList[index][i].fileName == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                                                                                                  radius: const Radius.circular(Dimensions.paddingEye),
                                                                                                ),
                                                                                                child: InkWell(
                                                                                                  onTap: () {
                                                                                                    digitalProductController.pickFileForDigitalProduct(index, i);
                                                                                                  },
                                                                                                  child: Container(
                                                                                                    height: Dimensions.uploadFile,
                                                                                                    width: double.infinity,
                                                                                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Theme.of(context).highlightColor,
                                                                                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                                                                                    ),
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: digitalProductController.variationFileList[index][i].fileName == null ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                                                                                                      children: digitalProductController.variationFileList[index][i].fileName == null
                                                                                                          ? [
                                                                                                              Image.asset(Images.uploadIcon, height: 32, width: 32),
                                                                                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                              Text(getTranslated('file_upload', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                                                                                                            ]
                                                                                                          : [
                                                                                                              Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                children: [
                                                                                                                  digitalProductController.isDigitalVariationLoading[index][i]
                                                                                                                      ? const SizedBox(height: 30, width: 30, child: CircularProgressIndicator())
                                                                                                                      : InkWell(
                                                                                                                          onTap: () {
                                                                                                                            if (_update) {
                                                                                                                              digitalProductController.deleteDigitalVariationFile(_product!.id!, index, i);
                                                                                                                            } else {
                                                                                                                              digitalProductController.removeFileForDigitalProduct(index, i);
                                                                                                                            }
                                                                                                                          },
                                                                                                                          child: Image.asset(Images.digitalPreviewDeleteIcon, height: 20, width: 20)),
                                                                                                                ],
                                                                                                              ),
                                                                                                              const SizedBox(
                                                                                                                height: Dimensions.paddingSizeExtraSmall,
                                                                                                              ),

                                                                                                              SizedBox(width: 20, child: Image.asset(Images.digitalPreviewFileIcon)),
                                                                                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                                                                              Expanded(child: Text(digitalProductController.variationFileList[index][i].fileName ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis)),
                                                                                                              //deleteIcon
                                                                                                            ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ))
                                                                                        : const SizedBox.shrink(),
                                                                                  ]),
                                                                                  Provider.of<DigitalProductController>(context, listen: false).digitalProductTypeIndex == 1 ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox(),
                                                      ],
                                                    );
                                                  })
                                                : const SizedBox(),
                                            Consumer<DigitalProductController>(
                                                builder: (context,
                                                    digitalProductController,
                                                    _) {
                                              return Provider.of<SplashController>(
                                                                  context,
                                                                  listen: false)
                                                              .configModel!
                                                              .digitalProductSetting ==
                                                          "1" &&
                                                      digitalProductController
                                                          .selectedDigitalVariation
                                                          .isEmpty
                                                  ? DigitalProductWidget(
                                                      resProvider: resProvider,
                                                      product: widget.product,
                                                      fromAddProductNextScreen:
                                                          true)
                                                  : SizedBox();
                                            }),
                                            if (resProvider.productTypeIndex ==
                                                    0 &&
                                                !(Provider.of<SplashController>(
                                                                context,
                                                                listen: false)
                                                            .configModel!
                                                            .digitalProductSetting ==
                                                        "1" &&
                                                    digitalProductController
                                                        .selectedDigitalVariation
                                                        .isEmpty))
                                              SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                            if (resProvider.productTypeIndex ==
                                                1)
                                              UploadPreviewFileWidget(
                                                  product: widget.product),
                                          ])
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 300.0),
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                          );
                        }),
                      ),
                      Consumer<AiController>(
                          builder: (context, aiController, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[
                                      Provider.of<ThemeController>(context)
                                              .darkTheme
                                          ? 800
                                          : 200]!,
                                  spreadRadius: 0.5,
                                  blurRadius: 0.3)
                            ],
                          ),
                          height: 80,
                          child: aiController.addProductNextScreenLoading
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.30),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        getTranslated(
                                                'ai_is_generating_product_details',
                                                context) ??
                                            '',
                                        style: robotoMedium.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            fontSize: Dimensions.fontSizeSmall),
                                        maxLines: 2,
                                      )),
                                      SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .hintColor
                                            .withValues(alpha: 0.18),
                                        highlightColor: Theme.of(context)
                                            .hintColor
                                            .withValues(alpha: 0.06),
                                        child: Row(children: [
                                          Icon(Icons.auto_awesome,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text(
                                              getTranslated(
                                                      'generating', context) ??
                                                  '',
                                              style: robotoBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                        ]),
                                      ),
                                    ],
                                  ))
                              : Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        widget.onTabChanged(0);
                                        resProvider.setSelectedPageIndex(0,
                                            isUpdate: true);
                                      },
                                      child: CustomButtonWidget(
                                        isColor: true,
                                        btnTxt:
                                            '${getTranslated('go_back', context)}',
                                        backgroundColor: Theme.of(context)
                                            .hintColor
                                            .withValues(alpha: .6),
                                        buttonHeight: 55,
                                      ),
                                    )),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Expanded(child:
                                        Consumer<VariationController>(builder:
                                            (context, variationController, _) {
                                      return Consumer<AiController>(
                                          builder: (context, aiController, _) {
                                        return Consumer<AddProductController>(
                                            builder: (context, resProvider, _) {
                                          return resProvider.isLoading
                                              ? const Center(
                                                  child: SizedBox(
                                                      height: 35,
                                                      width: 35,
                                                      child:
                                                          CircularProgressIndicator()))
                                              : CustomButtonWidget(
                                                  btnTxt: getTranslated(
                                                      'next', context),
                                                  buttonHeight: 55,
                                                  onTap: () {
                                                    final digitalProductController =
                                                        Provider.of<
                                                                DigitalProductController>(
                                                            Get.context!,
                                                            listen: false);

                                                    final variationController =
                                                        Provider.of<
                                                                VariationController>(
                                                            context,
                                                            listen: false);
                                                    final taxController = Provider
                                                        .of<AddProductTaxController>(
                                                            context,
                                                            listen: false);
                                                    final imageController = Provider
                                                        .of<AddProductImageController>(
                                                            context,
                                                            listen: false);
                                                    final configModel = Provider
                                                            .of<SplashController>(
                                                                context,
                                                                listen: false)
                                                        .configModel;

                                                    bool isValid = resProvider
                                                        .validateVariations(
                                                      context,
                                                      digitalProductController:
                                                          digitalProductController,
                                                      variationController:
                                                          variationController,
                                                      taxController:
                                                          taxController,
                                                      imageController:
                                                          imageController,
                                                      configModel: configModel,

                                                      unitPrice: resProvider
                                                          .unitPriceController
                                                          .text
                                                          .trim(),
                                                      currentStock:
                                                          variationController
                                                              .totalQuantityController
                                                              .text
                                                              .trim(),
                                                      orderQuantity: resProvider
                                                          .minimumOrderQuantityController
                                                          .text
                                                          .trim(),
                                                      // Do not submit a seller-defined shipping amount with the product.
                                                      shippingCost: '0',
                                                      isUpdate:
                                                          widget.product !=
                                                              null,
                                                    );

                                                    // for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                    //   if(digitalProductController.digitalVariationExtantion[index].isEmpty) {
                                                    //     digitalProductVariationEmpty = true;
                                                    //     break;
                                                    //   }
                                                    // }
                                                    //
                                                    // for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                    //   for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                    //     if(digitalProductController.variationFileList[index][i].fileName == null) {
                                                    //       isFileEmpty = true;
                                                    //       break;
                                                    //     }
                                                    //   }
                                                    // }
                                                    //
                                                    // for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                    //   for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                    //     if(digitalProductController.variationFileList[index][i].priceController?.text.trim() == ''){
                                                    //       isPriceEmpty = true;
                                                    //       break;
                                                    //     }
                                                    //   }
                                                    // }
                                                    //
                                                    // for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                    //   for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                    //     if(digitalProductController.variationFileList[index][i].skuController?.text.trim() == ''){
                                                    //       isSKUEmpty = true;
                                                    //       break;
                                                    //     }
                                                    //   }
                                                    // }
                                                    //
                                                    // for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                    //   for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                    //     if(digitalProductController.variationFileList[index][i].fileName == null){
                                                    //       isTitleEmpty = true;
                                                    //       break;
                                                    //     }
                                                    //   }
                                                    // }
                                                    //
                                                    // String unitPrice =resProvider.unitPriceController.text.trim();
                                                    // String currentStock = Provider.of<VariationController>(context,listen: false).totalQuantityController.text.trim();
                                                    // String orderQuantity = resProvider.minimumOrderQuantityController.text.trim();
                                                    // List<int?> taxIds = Provider.of<AddProductTaxController>(Get.context!, listen: false).selectedTaxList.map((tax) => tax.id).toList();
                                                    // String discount = _discountController.text.trim();
                                                    // String shipping = resProvider.shippingCostController.text.trim();
                                                    // bool haveBlankVariant = false;
                                                    // bool blankVariantPrice = false;
                                                    // bool blankVariantQuantity = false;
                                                    // bool isColorImageEmpty = false;
                                                    // AddProductImageController addProductImageController =  Provider.of<AddProductImageController>(context, listen: false);
                                                    //
                                                    //
                                                    // for (AttributeModel attr in variationController.attributeList!) {
                                                    //
                                                    //   if (attr.active && attr.variants.isEmpty) {
                                                    //     haveBlankVariant = true;
                                                    //     break;
                                                    //   }
                                                    // }
                                                    //
                                                    // for (VariantTypeModel variantType in variationController.variantTypeList) {
                                                    //   if (variantType.controller.text.isEmpty) {
                                                    //     blankVariantPrice = true;
                                                    //     break;
                                                    //   }
                                                    // }
                                                    //
                                                    // for (VariantTypeModel variantType in variationController.variantTypeList) {
                                                    //   if (variantType.qtyController.text.isEmpty) {
                                                    //     blankVariantQuantity = true;
                                                    //     break;
                                                    //   }
                                                    // }
                                                    //
                                                    // if(addProductImageController.imagesWithColor.isNotEmpty) {
                                                    //   for (int i=0; i<addProductImageController.imagesWithColor.length; i++) {
                                                    //     if (!_update && addProductImageController.imagesWithColor[i].image == null && !isColorImageEmpty) {
                                                    //       isColorImageEmpty = true;
                                                    //     } else if (_update && addProductImageController.imagesWithColor[i].colorImage?.imageName == null && !isColorImageEmpty){
                                                    //       isColorImageEmpty = true;
                                                    //     }
                                                    //   }
                                                    // }
                                                    //
                                                    //
                                                    //
                                                    //
                                                    // if (unitPrice.isEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_unit_price', context),context,  sanckBarType: SnackBarType.warning);
                                                    // }
                                                    // // else if (resProvider.taxTypeIndex == -1) {
                                                    // //   showCustomSnackBarWidget(getTranslated('select_tax_model', context),context,  sanckBarType: SnackBarType.warning);
                                                    // // }
                                                    //
                                                    // else if (currentStock.isEmpty &&  resProvider.productTypeIndex == 0) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_total_quantity', context),context,  sanckBarType: SnackBarType.warning);
                                                    // }
                                                    // else if (orderQuantity.isEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_minimum_order_quantity', context),context,  sanckBarType: SnackBarType.warning);
                                                    // }
                                                    // else if (haveBlankVariant) {
                                                    //   showCustomSnackBarWidget(getTranslated('add_at_least_one_variant_for_every_attribute',context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if (blankVariantPrice) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_price_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                                                    // }else if (blankVariantQuantity) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_quantity_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if (resProvider.productTypeIndex == 0 && resProvider.shippingCostController.text.isEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('enter_shipping_cost', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(_update && resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 && isFileEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('digital_product_file_empty', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(!_update && resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 && isFileEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('digital_product_file_empty', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(resProvider.productTypeIndex == 1 && isPriceEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('digital_product_price_empty', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(resProvider.productTypeIndex == 1 && isSKUEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('digital_product_sku_empty', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(resProvider.productTypeIndex == 1 && digitalProductVariationEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('digital_product_variation_empty', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if (!_update && (resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 &&
                                                    //     digitalProductController.selectedFileForImport == null) && digitalProductController.selectedDigitalVariation.isEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('please_choose_digital_product',context),context,  sanckBarType: SnackBarType.warning);
                                                    // }  else if(configModel?.systemTaxType == 'product_wise' && configModel?.systemTaxIncludeStatus == 0 && Provider.of<AddProductTaxController>(Get.context!,listen: false).selectedTaxList.isEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('please_add_your_product_tax', context),context,  sanckBarType: SnackBarType.warning);
                                                    // } else if(!_update && variationController.attributeList![0].active && variationController.attributeList![0].variants.isNotEmpty && isColorImageEmpty) {
                                                    //   showCustomSnackBarWidget(getTranslated('upload_product_color_image',context),context, sanckBarType: SnackBarType.warning);
                                                    // }

                                                    if (isValid) {
                                                      if (resProvider
                                                                  .productTypeIndex ==
                                                              1 &&
                                                          digitalProductController
                                                                  .digitalProductTypeIndex ==
                                                              1 &&
                                                          digitalProductController
                                                                  .selectedFileForImport !=
                                                              null &&
                                                          digitalProductController
                                                              .selectedDigitalVariation
                                                              .isEmpty) {
                                                        digitalProductController
                                                            .uploadDigitalProduct(
                                                                Provider.of<AuthController>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .getUserToken());
                                                      }
                                                      resProvider
                                                          .setSelectedPageIndex(
                                                              2,
                                                              isUpdate: true);
                                                      widget.onTabChanged(2);

                                                      // Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductSeoScreen(
                                                      //   unitPrice: unitPrice,
                                                      //   tax: taxIds,
                                                      //   unit: widget.unit,
                                                      //   categoryId: widget.categoryId,
                                                      //   subCategoryId: widget.subCategoryId,
                                                      //   subSubCategoryId: widget.subSubCategoryId,
                                                      //   brandyId: widget.brandId,
                                                      //   discount: discount,
                                                      //   currentStock: currentStock,
                                                      //   minimumOrderQuantity: orderQuantity,
                                                      //   shippingCost: shipping,
                                                      //   product: widget.product, addProduct: widget.addProduct,
                                                      //   title: widget.title,
                                                      //   description: widget.description,
                                                      // )));
                                                    }
                                                  },
                                                );
                                        });
                                      });
                                    })),
                                  ],
                                ),
                        );
                      })
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Iterable<int> _getColorSuggestionsIndexList({
    required List<int> colors,
    required List<ColorList>? colorList,
    required List<String?> savedColorVariationList,
    required String pattern,
  }) {
    return colors.where((colorIndex) =>
        colorList![colorIndex]
            .name!
            .toLowerCase()
            .contains(pattern.toLowerCase()) &&
        !(savedColorVariationList.contains(colorList[colorIndex].name)));
  }
}
