import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/image_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/meta_seo_widget.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AddProductSeoScreen extends StatefulWidget {
  final ValueChanged<bool>? isSelected;
  final Product? product;
  final String? unitPrice;
  final String? discount;
  final String? currentStock;
  final String? minimumOrderQuantity;
  final List<int?>? tax;
  final String? shippingCost;
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandyId;
  final String? brandName;
  final String? unit;
  final String? title;
  final String? description;
  final AddProductModel? addProduct;
  final Function(int) onTabChanged;

  const AddProductSeoScreen(
      {super.key,
      this.isSelected,
      required this.product,
      required this.addProduct,
      this.unitPrice,
      this.tax,
      this.discount,
      this.currentStock,
      this.shippingCost,
      this.categoryId,
      this.subCategoryId,
      this.subSubCategoryId,
      this.brandyId,
      this.brandName,
      this.unit,
      this.minimumOrderQuantity,
      this.title,
      this.description,
      required this.onTabChanged});

  @override
  AddProductSeoScreenState createState() => AddProductSeoScreenState();
}

class AddProductSeoScreenState extends State<AddProductSeoScreen>
    with AutomaticKeepAliveClientMixin {
  bool isSelected = false;
  final FocusNode _seoTitleNode = FocusNode();
  final FocusNode _seoDescriptionNode = FocusNode();
  final TextEditingController _seoTitleController = TextEditingController();
  final TextEditingController _seoDescriptionController =
      TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  AutoCompleteTextField? searchTextField;
  late double _distanceToField;
  TextfieldTagsController? _controller;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;
  late bool _update;
  Product? _product;
  AddProductModel? _addProduct;
  String? thumbnailImage = '', metaImage = '';
  int counter = 0, total = 0;
  int addColor = 0;
  List<String> tagList = [];
  final categoryController =
      Provider.of<CategoryController>(Get.context!, listen: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _update = widget.product != null;
    _addProduct = widget.addProduct;
    if (_update) {
      if (_product!.tags != null) {
        for (int i = 0; i < _product!.tags!.length; i++) {
          tagList.add(_product!.tags![i].tag!);
        }
      }
      _seoTitleController.text = _product!.metaSeoInfo != null
          ? _product!.metaSeoInfo?.metaTitle ?? ''
          : _product!.metaTitle ?? '';
      _seoDescriptionController.text = _product!.metaSeoInfo != null
          ? _product!.metaSeoInfo?.metaDescription ?? ''
          : _product!.metaDescription ?? '';
      thumbnailImage = _product!.thumbnail;
      metaImage = _product!.metaImage;
      _youtubeLinkController.text = _product?.videoUrl ?? '';

      if (_product?.imagesFullUrl != null) {
        List<Map<String, dynamic>>? productImages = [];
        for (int i = 0; i < _product!.imagesFullUrl!.length; i++) {
          productImages.add({
            "image_name": _product?.imagesFullUrl?[i].key ?? '',
            "storage": null,
          });
        }
        // Provider.of<AddProductController>(context,listen: false).productReturnImage = productImages;
      }
    } else {
      AddProductController addProductController =
          Provider.of<AddProductController>(context, listen: false);
      _seoTitleController.text =
          addProductController.titleControllerList[0].text;
      _product = Product();
      _addProduct = AddProductModel();
      Provider.of<AddProductController>(Get.context!, listen: false)
          .resetMetaSeoInfo();
    }
    _controller = TextfieldTagsController();

    if ((Provider.of<AiController>(context, listen: false)
                .generalSetupModel
                ?.data
                ?.searchTags ??
            [])
        .isNotEmpty) {
      for (int i = 0;
          i <
              (Provider.of<AiController>(context, listen: false)
                          .generalSetupModel
                          ?.data
                          ?.searchTags ??
                      [])
                  .length;
          i++) {
        if (!tagList.contains(Provider.of<AiController>(context, listen: false)
                .generalSetupModel
                ?.data
                ?.searchTags ??
            '')) {
          tagList.add(Provider.of<AiController>(context, listen: false)
                  .generalSetupModel
                  ?.data
                  ?.searchTags?[i] ??
              '');
        }
      }
    }

    _loadData();
  }

  Future<void> _loadData() async {
    if (Provider.of<AiController>(Get.context!, listen: false)
        .requestTypeImage) {
      await Provider.of<AiController>(Get.context!, listen: false)
          .generateMetaSeoSetup(
              title: widget.title ?? '',
              description: widget.description ?? '',
              seoTitleController: _seoTitleController,
              seoDescriptionController: _seoDescriptionController,
              formInit: true);
    }
    Provider.of<AiController>(Get.context!, listen: false)
        .setRequestType(false, willUpdate: false);
  }

  Future<void> route(
      bool isRoute, String name, String type, String? colorCode) async {
    if (isRoute) {
      if (type == 'meta') {
        metaImage = name;
      } else if (type == 'thumbnail') {
        thumbnailImage = name;
      }
      if (_update) {
        int withc = 0, withOurC = 0;

        if (Provider.of<AddProductImageController>(Get.context!, listen: false)
            .imagesWithColor
            .isNotEmpty) {
          for (int index = 0;
              index <
                  Provider.of<AddProductImageController>(Get.context!,
                          listen: false)
                      .imagesWithColor
                      .length;
              index++) {
            String retColor = Provider.of<AddProductImageController>(
                    Get.context!,
                    listen: false)
                .imagesWithColor[index]
                .color!;
            String? bb;
            if (retColor.contains('#')) {
              bb = retColor.replaceAll('#', '');
            }
            if (bb == colorCode) {
              Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .setStringImage(index, name, colorCode!);
              break;
            }
          }
        }

        for (int i = 0;
            i <
                Provider.of<AddProductImageController>(Get.context!,
                        listen: false)
                    .imagesWithColor
                    .length;
            i++) {
          if (Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .imagesWithColor[i]
                  .image !=
              null) {
            withc++;
          }
        }

        for (int i = 0;
            i <
                Provider.of<AddProductImageController>(Get.context!,
                        listen: false)
                    .withoutColor
                    .length;
            i++) {
          if (Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .withoutColor[i]
                  .image !=
              null) {
            withOurC++;
          }
        }
      } else {
        if (Provider.of<AddProductImageController>(Get.context!, listen: false)
            .imagesWithColor
            .isNotEmpty) {
          for (int index = 0;
              index <
                  Provider.of<AddProductImageController>(Get.context!,
                          listen: false)
                      .imagesWithColor
                      .length;
              index++) {
            String retColor = Provider.of<AddProductImageController>(
                    Get.context!,
                    listen: false)
                .imagesWithColor[index]
                .color!;
            String? bb;
            if (retColor.contains('#')) {
              bb = retColor.replaceAll('#', '');
            }
            if (bb == colorCode) {
              Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .setStringImage(index, name, colorCode!);
              break;
            }
          }
        }
        if (Provider.of<AddProductImageController>(Get.context!, listen: false)
            .withoutColor
            .isNotEmpty) {
          for (int index = 0;
              index <
                  Provider.of<AddProductImageController>(Get.context!,
                          listen: false)
                      .withoutColor
                      .length;
              index++) {}
        }

        counter++;

        if (metaImage == '') {
          total = Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .imagesWithColor
                  .length +
              Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .withoutColor
                  .length +
              1;
        } else {
          total = Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .imagesWithColor
                  .length +
              Provider.of<AddProductImageController>(Get.context!,
                      listen: false)
                  .withoutColor
                  .length +
              2;
        }

        if (counter == total) {
          counter++;
          Provider.of<AddProductController>(Get.context!, listen: false)
              .addProduct(context, _product!, _addProduct!, thumbnailImage,
                  metaImage, !_update, tagList);
        }
      }
    }
  }

  // @override
  // void didUpdateWidget(AddProductSeoScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   // Check if the product/unitPrice changed
  //   if (widget.unitPrice != oldWidget.unitPrice) {
  //     // Force update your local controllers or variables here
  //     print("SEO Screen Updated with Price: ${widget.unitPrice}");
  //
  //     // Example: if you have a controller
  //     // _unitPriceController.text = widget.unitPrice ?? '';
  //
  //     // If you are just using variables, call setState to refresh the UI
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        Provider.of<AddProductController>(context, listen: false)
            .setSelectedPageIndex(1, isUpdate: true);
      },
      child: Scaffold(
        // appBar: CustomAppBarWidget(title:  widget.product != null ?
        // getTranslated('update_product', context):
        // getTranslated('add_product', context),
        // onBackPressed: () {
        //   Navigator.pop(context);
        //   Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(1, isUpdate: true);},
        // ),

        body: SafeArea(child: Consumer<VariationController>(
            builder: (context, variationController, child) {
          return Consumer<AddProductController>(
            builder: (context, resProvider, child) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: (variationController.attributeList != null &&
                              variationController.attributeList!.isNotEmpty &&
                              categoryController.categoryList != null &&
                              Provider.of<SplashController>(context,
                                          listen: false)
                                      .colorList !=
                                  null)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        AddProductSectionWidget(
                                          childrenPadding:
                                              Dimensions.paddingSizeMedium,
                                          title: getTranslated(
                                              'seller_product_review_submit',
                                              context)!,
                                          subTitle: getTranslated(
                                              'seller_product_review_hint',
                                              context)!,
                                          childrens: [
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault),
                                            _ReviewRow(
                                              icon: Icons.inventory_2_outlined,
                                              label: getTranslated(
                                                      'product_name',
                                                      context) ??
                                                  '',
                                              value: widget.title ??
                                                  getTranslated(
                                                      'finance_not_set',
                                                      context) ??
                                                  '',
                                            ),
                                            _ReviewRow(
                                              icon: Icons.payments_outlined,
                                              label: getTranslated(
                                                      'unit_price', context) ??
                                                  '',
                                              value: widget.unitPrice == null
                                                  ? getTranslated(
                                                          'finance_not_set',
                                                          context) ??
                                                      ''
                                                  : PriceConverter.convertPrice(
                                                      context,
                                                      double.tryParse(
                                                          widget.unitPrice!)),
                                            ),
                                            _ReviewRow(
                                              icon: Icons.inventory_outlined,
                                              label: getTranslated(
                                                      'current_stock',
                                                      context) ??
                                                  '',
                                              value: widget.currentStock ??
                                                  getTranslated(
                                                      'finance_not_set',
                                                      context) ??
                                                  '',
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeMedium),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeDefault),
                                        if (false)
                                          AddProductSectionWidget(
                                            childrenPadding:
                                                Dimensions.paddingSizeMedium,
                                            title:
                                                getTranslated('tags', context)!,
                                            childrens: [
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                              Align(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                child: Text(
                                                  getTranslated(
                                                          'seller_product_search_tags_help',
                                                          context) ??
                                                      '',
                                                  style: robotoRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall),
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              TextFieldTags(
                                                textfieldTagsController:
                                                    _controller,
                                                initialTags:
                                                    (tagList.isNotEmpty)
                                                        ? tagList
                                                        : const [],
                                                textSeparators: const [
                                                  ' ',
                                                  ','
                                                ],
                                                letterCase: LetterCase.normal,
                                                validator: (String? tag) {
                                                  if (tag == 'php') {
                                                    return 'No, please just no';
                                                  } else if (_controller!
                                                      .getTags!
                                                      .contains(tag)) {
                                                    return 'you already entered that';
                                                  }
                                                  return null; // must return String? (null = no error)
                                                },
                                                inputfieldBuilder: (context,
                                                    tec,
                                                    fn,
                                                    error,
                                                    onChanged,
                                                    onSubmitted) {
                                                  return (context, sc, tags,
                                                      onTagDelete) {
                                                    tagList = tags;
                                                    return TextField(
                                                      controller: tec,
                                                      focusNode: fn,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        helperText: '',
                                                        helperStyle: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        hintText: _controller!
                                                                .hasTags
                                                            ? ''
                                                            : "Enter tag...",
                                                        hintStyle: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor),
                                                        errorText: error,
                                                        prefixIconConstraints:
                                                            BoxConstraints(
                                                                maxWidth:
                                                                    _distanceToField *
                                                                        0.74),
                                                        prefixIcon: tags
                                                                .isNotEmpty
                                                            ? SingleChildScrollView(
                                                                controller: sc,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                    children: tags.map(
                                                                        (String?
                                                                            tag) {
                                                                  return Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(
                                                                                20.0)),
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            5.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                            '$tag',
                                                                            style:
                                                                                const TextStyle(color: Colors.white)),
                                                                        const SizedBox(
                                                                            width:
                                                                                4.0),
                                                                        InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          child: const Icon(
                                                                              Icons.cancel,
                                                                              size: 14.0,
                                                                              color: Color.fromARGB(255, 233, 233, 233)),
                                                                          onTap:
                                                                              () {
                                                                            onTagDelete(tag!);
                                                                          },
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                }).toList()),
                                                              )
                                                            : null,
                                                      ),
                                                      onChanged: onChanged,
                                                      onSubmitted: onSubmitted,
                                                    );
                                                  };
                                                },
                                              ),
                                            ],
                                          ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeDefault),
                                        if (false)
                                          AddProductSectionWidget(
                                            childrenPadding:
                                                Dimensions.paddingSizeMedium,
                                            title: getTranslated(
                                                'product_seo', context)!,
                                            subTitle: getTranslated(
                                                'add_meta_titles_descriptions_and_images_for_products',
                                                context)!,
                                            aiWidget: Consumer<AiController>(
                                                builder: (context, aiController,
                                                    child) {
                                              return InkWell(
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
                                                    aiController.generateMetaSeoSetup(
                                                        title:
                                                            widget.title ?? '',
                                                        description: widget
                                                                .description ??
                                                            '',
                                                        seoTitleController:
                                                            _seoTitleController,
                                                        seoDescriptionController:
                                                            _seoDescriptionController);
                                                  }
                                                },
                                                child: !aiController
                                                        .metaSeoLoading
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
                                                              color:
                                                                  Colors.blue),
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
                                              );
                                            }),
                                            childrens: [
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                              CustomTextFieldWidget(
                                                formProduct: true,
                                                border: true,
                                                textInputType:
                                                    TextInputType.name,
                                                focusNode: _seoTitleNode,
                                                controller: _seoTitleController,
                                                nextNode: _seoDescriptionNode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                hintText: getTranslated(
                                                    'meta_title', context),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeLarge),
                                              CustomTextFieldWidget(
                                                formProduct: true,
                                                isDescription: true,
                                                border: true,
                                                controller:
                                                    _seoDescriptionController,
                                                focusNode: _seoDescriptionNode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                textInputType:
                                                    TextInputType.multiline,
                                                maxLine: 3,
                                                hintText: getTranslated(
                                                    'meta_description_hint',
                                                    context),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeLarge),
                                              Text(
                                                  getTranslated(
                                                      'meta_image', context)!,
                                                  style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color)),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              RichText(
                                                text: TextSpan(
                                                  style: DefaultTextStyle.of(
                                                          context)
                                                      .style
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
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
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              Consumer<
                                                      AddProductImageController>(
                                                  builder: (context,
                                                      addProductImageController,
                                                      child) {
                                                return Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Stack(children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeExtraSmall),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .paddingSizeSmall),
                                                          child: addProductImageController
                                                                      .selectedMetaImageFile !=
                                                                  null
                                                              ? Image.file(
                                                                  File(addProductImageController
                                                                      .selectedMetaImageFile!
                                                                      .path),
                                                                  width: 140,
                                                                  height: 140,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : widget.product !=
                                                                      null
                                                                  ? FadeInImage
                                                                      .assetNetwork(
                                                                      placeholder:
                                                                          Images
                                                                              .placeholderImage,
                                                                      image: _product!.metaSeoInfo != null
                                                                          ? _product!.metaSeoInfo?.imageFullUrl?.path ??
                                                                              ''
                                                                          : _product!.metaImageFullUrl?.path ??
                                                                              '',
                                                                      height:
                                                                          140,
                                                                      width:
                                                                          140,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageErrorBuilder: (c, o, s) => Image.asset(
                                                                          Images
                                                                              .placeholderImage,
                                                                          height:
                                                                              140,
                                                                          width:
                                                                              140,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          color:
                                                                              Theme.of(context).highlightColor),
                                                                    )
                                                                  : Image.asset(
                                                                      Images
                                                                          .placeholderImage,
                                                                      height:
                                                                          140,
                                                                      width:
                                                                          140,
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
                                                        child: Consumer<
                                                                AddProductImageController>(
                                                            builder: (context,
                                                                addProductImageController,
                                                                child) {
                                                          return InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            onTap: () =>
                                                                addProductImageController
                                                                    .pickImage(
                                                                        false,
                                                                        true,
                                                                        false,
                                                                        null),
                                                            child: DottedBorder(
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
                                                                    Dimensions
                                                                        .paddingEye),
                                                              ),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: addProductImageController
                                                                              .selectedMetaImageFile !=
                                                                          null
                                                                      ? Colors
                                                                          .black
                                                                          .withValues(
                                                                              alpha: 0.5)
                                                                      : null,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .paddingSizeSmall),
                                                                ),
                                                                child: (addProductImageController.selectedMetaImageFile ==
                                                                            null &&
                                                                        (_product!.metaSeoInfo?.imageFullUrl?.path ==
                                                                                null ||
                                                                            _product!.metaSeoInfo?.imageFullUrl?.path ==
                                                                                ''))
                                                                    ? Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CustomAssetImageWidget(
                                                                              Images.addImageIcon,
                                                                              height: 30,
                                                                              width: 30,
                                                                              color: Theme.of(context).hintColor),
                                                                          SizedBox(
                                                                              height: Dimensions.paddingSizeDefault),
                                                                          Text(
                                                                            getTranslated('click_to_add',
                                                                                context)!,
                                                                            style:
                                                                                robotoRegular.copyWith(
                                                                              color: Theme.of(context).hintColor.withValues(alpha: .7),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : const SizedBox
                                                                        .shrink(),
                                                              ),
                                                            ),
                                                          );
                                                        }),
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
                                                              child: InkWell(
                                                                onTap: () => addProductImageController
                                                                    .pickImage(
                                                                        false,
                                                                        true,
                                                                        false,
                                                                        null),
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
                                                    ]));
                                              }),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                            ],
                                          ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeDefault),
                                        if (false)
                                          Consumer<AiController>(builder:
                                              (context, aiController, child) {
                                            return AddProductSectionWidget(
                                              isAiGenerating:
                                                  aiController.metaSeoLoading,
                                              childrenPadding:
                                                  Dimensions.paddingSizeMedium,
                                              title: getTranslated(
                                                      'product_seo_settings',
                                                      context) ??
                                                  ' ',
                                              subTitle: getTranslated(
                                                      'setup_how_to_indexing_snippet_preview',
                                                      context) ??
                                                  ' ',
                                              aiWidget: Consumer<AiController>(
                                                  builder: (context,
                                                      aiController, child) {
                                                return InkWell(
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
                                                      aiController.generateMetaSeoSetup(
                                                          title: widget.title ??
                                                              '',
                                                          description: widget
                                                                  .description ??
                                                              '',
                                                          seoTitleController:
                                                              _seoTitleController,
                                                          seoDescriptionController:
                                                              _seoDescriptionController);
                                                    }
                                                  },
                                                  child: !aiController
                                                          .metaSeoLoading
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
                                                );
                                              }),
                                              childrens: [
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                                const MetaSeoWidget(),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                              ],
                                            );
                                          }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraLarge),
                                ])
                          : const Padding(
                              padding: EdgeInsets.only(top: 300.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),
                  ),
                  Consumer<AddProductController>(
                      builder: (context, resProvider, _) {
                    return Consumer<AiController>(
                        builder: (context, aiController, _) {
                      return Consumer<AddProductImageController>(
                          builder: (context, addProductImageController, _) {
                        return Container(
                          height: 80,
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
                          child: aiController.addProductMetaScreenLoading
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
                              : !resProvider.isLoading &&
                                      !addProductImageController.isLoading
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            widget.onTabChanged(1);
                                            resProvider.setSelectedPageIndex(1,
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
                                        Expanded(
                                          child: CustomButtonWidget(
                                              btnTxt: _update
                                                  ? getTranslated(
                                                      'update', context)
                                                  : getTranslated(
                                                      'seller_product_save',
                                                      context),
                                              buttonHeight: 55,
                                              onTap: () async {
                                                final digitalProductController =
                                                    Provider.of<
                                                            DigitalProductController>(
                                                        Get.context!,
                                                        listen: false);
                                                final categoryController =
                                                    Provider.of<
                                                            CategoryController>(
                                                        Get.context!,
                                                        listen: false);

                                                resProvider.initUpload();
                                                String? unit = widget.unit;
                                                if (unit == null ||
                                                    unit.isEmpty ||
                                                    unit == 'select_unit') {
                                                  unit = null;
                                                }
                                                String? brandId =
                                                    widget.brandyId;
                                                String productCode = resProvider
                                                    .productCode.text;
                                                bool isColorImageEmpty = false;

                                                // The seller owns one Arabic
                                                // source of truth for product
                                                // content in Sigma.
                                                final titleList = <String>[
                                                  resProvider
                                                      .titleControllerList
                                                      .first
                                                      .text
                                                      .trim(),
                                                ];
                                                final descriptionList =
                                                    <String>[
                                                  resProvider
                                                      .descriptionControllerList
                                                      .first
                                                      .text
                                                      .trim(),
                                                ];

                                                if (addProductImageController
                                                    .imagesWithColor
                                                    .isNotEmpty) {
                                                  for (int i = 0;
                                                      i <
                                                          addProductImageController
                                                              .imagesWithColor
                                                              .length;
                                                      i++) {
                                                    if (!_update &&
                                                        addProductImageController
                                                                .imagesWithColor[
                                                                    i]
                                                                .image ==
                                                            null &&
                                                        !isColorImageEmpty) {
                                                      isColorImageEmpty = true;
                                                    } else if (_update &&
                                                        addProductImageController
                                                                .imagesWithColor[
                                                                    i]
                                                                .colorImage
                                                                ?.imageName ==
                                                            null &&
                                                        !isColorImageEmpty) {
                                                      isColorImageEmpty = true;
                                                    }
                                                  }
                                                }

                                                CategoryController
                                                    categoryControllerr =
                                                    Provider.of<
                                                            CategoryController>(
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
                                                final configModel = Provider.of<
                                                            SplashController>(
                                                        context,
                                                        listen: false)
                                                    .configModel;

                                                bool? isValidateProduct;
                                                bool? isValidVariation;

                                                isValidateProduct = resProvider
                                                    .validateGeneralInfo(
                                                  context,
                                                  categoryController:
                                                      categoryControllerr,
                                                  imageController:
                                                      addProductImageController,
                                                  existingProduct:
                                                      widget.product,
                                                  youtubeLink: resProvider
                                                      .youtubeLinkController
                                                      .text
                                                      .trim(),
                                                );

                                                if (isValidateProduct) {
                                                  isValidVariation = resProvider
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
                                                    shippingCost: resProvider
                                                        .shippingCostController
                                                        .text
                                                        .trim(),
                                                    isUpdate:
                                                        widget.product != null,
                                                  );
                                                }

                                                if (!isValidateProduct) {
                                                  widget.onTabChanged(0);
                                                } else if (!(isValidVariation ??
                                                    false)) {
                                                  widget.onTabChanged(1);
                                                } else if (!_update &&
                                                    !variationController
                                                        .attributeList![0]
                                                        .active &&
                                                    imageController
                                                        .withoutColor.isEmpty) {
                                                  showCustomSnackBarWidget(
                                                      getTranslated(
                                                          'upload_product_image',
                                                          context),
                                                      context,
                                                      sanckBarType:
                                                          SnackBarType.warning);
                                                  widget.onTabChanged(0);
                                                } else if (_update &&
                                                    !variationController
                                                        .attributeList![0]
                                                        .active &&
                                                    (widget.product
                                                                ?.imagesFullUrl ??
                                                            [])
                                                        .isEmpty &&
                                                    imageController
                                                        .withoutColor.isEmpty) {
                                                  showCustomSnackBarWidget(
                                                      getTranslated(
                                                          'upload_product_image',
                                                          context),
                                                      context,
                                                      sanckBarType:
                                                          SnackBarType.warning);
                                                  widget.onTabChanged(0);
                                                } else {
                                                  if (Provider.of<ShopController>(
                                                                  context,
                                                                  listen: false)
                                                              .shopModel
                                                              ?.setupGuideApp !=
                                                          null &&
                                                      Provider.of<ShopController>(
                                                                      context,
                                                                      listen: false)
                                                                  .shopModel
                                                                  ?.setupGuideApp?[
                                                              'add_new_product'] !=
                                                          1) {
                                                    Provider.of<ShopController>(
                                                            context,
                                                            listen: false)
                                                        .updateTutorialFlow(
                                                            'add_new_product');
                                                    Provider.of<ShopController>(
                                                            context,
                                                            listen: false)
                                                        .updateSetupGuideApp(
                                                            'add_new_product',
                                                            1);
                                                  }
                                                  _addProduct =
                                                      AddProductModel();
                                                  _addProduct!.titleList =
                                                      titleList;
                                                  _addProduct!.descriptionList =
                                                      descriptionList;
                                                  _addProduct!.videoUrl = null;
                                                  _addProduct!.brandName =
                                                      widget.brandName;
                                                  _product!.taxIds = widget.tax;
                                                  _product!
                                                      .taxModel = resProvider
                                                              .taxTypeIndex ==
                                                          0
                                                      ? 'include'
                                                      : 'exclude';
                                                  _product!.unitPrice =
                                                      PriceConverter
                                                          .systemCurrencyToDefaultCurrency(
                                                              double.parse(widget
                                                                  .unitPrice!),
                                                              context);
                                                  _product!.discount = 0;
                                                  _product!.productType =
                                                      'physical';
                                                  _product!.unit = unit;
                                                  _product!.code = productCode;
                                                  _product!.shippingCost = 0;
                                                  _product!
                                                      .multiplyWithQuantity = 0;
                                                  final parsedBrandId =
                                                      int.tryParse(
                                                          brandId ?? '');
                                                  _product!.brandId =
                                                      parsedBrandId != null &&
                                                              parsedBrandId > 0
                                                          ? parsedBrandId
                                                          : null;
                                                  _product!.metaTitle = null;
                                                  _product!.metaDescription =
                                                      null;
                                                  _product!.currentStock =
                                                      int.parse(
                                                          widget.currentStock!);
                                                  _product!.minimumOrderQty =
                                                      int.parse(widget
                                                          .minimumOrderQuantity!);
                                                  _product!.metaTitle = null;
                                                  _product!.metaDescription =
                                                      null;
                                                  _product!.discountType =
                                                      'percent';
                                                  _product!.digitalProductType =
                                                      Provider.of<DigitalProductController>(
                                                                      Get
                                                                          .context!,
                                                                      listen:
                                                                          false)
                                                                  .digitalProductTypeIndex ==
                                                              0
                                                          ? 'ready_after_sell'
                                                          : 'ready_product';
                                                  _product!.digitalFileReady =
                                                      digitalProductController
                                                          .digitalProductFileName;
                                                  _product!.saleUnitType =
                                                      resProvider.saleUnitType;
                                                  _product!
                                                      .piecesPerUnit = resProvider
                                                              .saleUnitType ==
                                                          'package'
                                                      ? int.tryParse(resProvider
                                                          .piecesPerUnitController
                                                          .text
                                                          .trim())
                                                      : null;
                                                  _product!.length =
                                                      double.tryParse(
                                                          resProvider
                                                              .lengthController
                                                              .text
                                                              .trim());
                                                  _product!.width =
                                                      double.tryParse(
                                                          resProvider
                                                              .widthController
                                                              .text
                                                              .trim());
                                                  _product!.height =
                                                      double.tryParse(
                                                          resProvider
                                                              .heightController
                                                              .text
                                                              .trim());
                                                  _product!.dimensionUnit =
                                                      resProvider.dimensionUnit;
                                                  _product!.weight =
                                                      double.tryParse(
                                                          resProvider
                                                              .weightController
                                                              .text
                                                              .trim());
                                                  _product!.weightUnit =
                                                      resProvider.weightUnit;
                                                  _product!.productionDate =
                                                      resProvider
                                                          .productionDateController
                                                          .text
                                                          .trim();
                                                  _product!.expiryDate =
                                                      resProvider
                                                          .expiryDateController
                                                          .text
                                                          .trim();
                                                  _product!.categoryIds = [];
                                                  _product!.categoryIds!.add(
                                                      CategoryIds(
                                                          id: widget
                                                              .categoryId));

                                                  if (categoryController
                                                          .subCategoryIndex !=
                                                      0) {
                                                    _product!.categoryIds!.add(
                                                        CategoryIds(
                                                            id: widget
                                                                .subCategoryId));
                                                  }

                                                  _addProduct!.colorCodeList =
                                                      [];
                                                  _addProduct!.colorCodeList!
                                                      .addAll(
                                                          variationController
                                                              .colorCodeList);

                                                  _addProduct!.languageList = [
                                                    'ar'
                                                  ];

                                                  if (widget.product != null) {
                                                    for (ImageModel value
                                                        in addProductImageController
                                                            .imagesWithColor) {
                                                      ///if on online -> value.colorImage?.imageName?.path
                                                      ///if on offline -> value.image?.path
                                                      if (value.image?.path ==
                                                              null &&
                                                          value
                                                                  .colorImage
                                                                  ?.imageName
                                                                  ?.path ==
                                                              null) {
                                                        showCustomSnackBarWidget(
                                                            '${getTranslated('please_add_color_image', context)}',
                                                            context);
                                                        return;
                                                      }
                                                    }

                                                    if (addProductImageController
                                                            .selectedLogoFile !=
                                                        null) {
                                                      await addProductImageController
                                                          .addProductImage(
                                                              context,
                                                              addProductImageController
                                                                  .thumbnailImageModel,
                                                              route,
                                                              update: _update);
                                                    }

                                                    if (addProductImageController
                                                            .selectedMetaImageFile !=
                                                        null) {
                                                      await addProductImageController
                                                          .addProductImage(
                                                              Get.context!,
                                                              addProductImageController
                                                                  .metaImageModel,
                                                              route,
                                                              update: _update);
                                                    }

                                                    if (context.mounted) {
                                                      await addProductImageController
                                                          .onUploadColorImages(
                                                        context: context,
                                                        isUpdate: _update,
                                                        productId: _product?.id,
                                                        callBack: route,
                                                      );
                                                    }

                                                    if (addProductImageController
                                                        .withoutColor
                                                        .isNotEmpty) {
                                                      for (int i = 0;
                                                          i <
                                                              addProductImageController
                                                                  .withoutColor
                                                                  .length;
                                                          i++) {
                                                        if (addProductImageController
                                                                .withoutColor[i]
                                                                .image !=
                                                            null) {
                                                          await addProductImageController
                                                              .addProductImage(
                                                                  Get.context!,
                                                                  addProductImageController
                                                                          .withoutColor[
                                                                      i],
                                                                  route,
                                                                  index: i,
                                                                  update:
                                                                      _update);
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    if (addProductImageController
                                                            .selectedLogoFile !=
                                                        null) {
                                                      await addProductImageController
                                                          .addProductImage(
                                                              context,
                                                              addProductImageController
                                                                  .thumbnailImageModel,
                                                              route);
                                                    }

                                                    if (addProductImageController
                                                            .selectedMetaImageFile !=
                                                        null) {
                                                      await addProductImageController
                                                          .addProductImage(
                                                              Get.context!,
                                                              addProductImageController
                                                                  .metaImageModel,
                                                              route);
                                                    }

                                                    if (addProductImageController
                                                        .imagesWithColor
                                                        .isNotEmpty) {
                                                      for (int i = 0;
                                                          i <
                                                              addProductImageController
                                                                  .imagesWithColor
                                                                  .length;
                                                          i++) {
                                                        await addProductImageController
                                                            .addProductImage(
                                                                Get.context!,
                                                                addProductImageController
                                                                    .imagesWithColor[i],
                                                                route);
                                                      }
                                                    }

                                                    if (addProductImageController
                                                        .withoutColor
                                                        .isNotEmpty) {
                                                      for (int i = 0;
                                                          i <
                                                              addProductImageController
                                                                  .withoutColor
                                                                  .length;
                                                          i++) {
                                                        await addProductImageController
                                                            .addProductImage(
                                                                Get.context!,
                                                                addProductImageController
                                                                    .withoutColor[i],
                                                                route);
                                                      }
                                                    }
                                                  }
                                                }

                                                if (widget.product != null) {
                                                  Provider.of<AddProductController>(
                                                          Get.context!,
                                                          listen: false)
                                                      .addProduct(
                                                          Get.context!,
                                                          _product!,
                                                          _addProduct!,
                                                          thumbnailImage,
                                                          metaImage,
                                                          widget.product ==
                                                              null,
                                                          tagList);
                                                }
                                              }),
                                        )
                                      ],
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator()),
                        );
                      });
                    });
                  }),
                ],
              );
            },
          );
        })),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
            child: Text(label,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor))),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: robotoBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color))),
      ]),
    );
  }
}

// AddProductSectionWidget(
//                                 title: getTranslated('product_video_image', context)!,
//                                 childrens: [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeSmall),
//                                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                                       Row(
//                                         children: [
//                                           Image.asset(Images.alertCircle, width: Dimensions.paddingSizeDefault),
//                                           const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                                           Text(getTranslated('provide_embedded_link', context)!,
//                                             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: Dimensions.paddingSizeMedium),
//
//                                       CustomTextFieldWidget(
//                                         border: true,
//                                         maxLine: 1,
//                                         textInputType: TextInputType.text,
//                                         controller: _youtubeLinkController,
//                                         focusNode: _youtubeLinkNode,
//                                         textInputAction: TextInputAction.done,
//                                         hintText: getTranslated('youtube_video_link', context)!,
//                                       ),
//                                       const SizedBox(height: Dimensions.paddingSizeExtraLarge),
//
//                                       Text(getTranslated('upload_thumbnail', context)!,
//                                           style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
//                                       const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                                       Consumer<AddProductImageController>(
//                                         builder: (context, addProductImageController, child){
//                                           return Container(
//                                             width: double.infinity,
//                                             padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                                             decoration: BoxDecoration(
//                                               color: Theme.of(context).primaryColor.withValues(alpha:0.10),
//                                               borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                                             ),
//                                             child: Align(alignment: Alignment.center, child: Stack(children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                                   child: addProductImageController.selectedLogoFile != null ?  Image.file(File(addProductImageController.selectedLogoFile!.path),
//                                                     width: 150, height: 160, fit: BoxFit.cover,
//                                                   ) : widget.product != null ? FadeInImage.assetNetwork(
//                                                     placeholder: Images.placeholderImage,
//                                                     image: _product!.thumbnailFullUrl?.path ?? '',
//                                                     height: 160, width: 150, fit: BoxFit.cover,
//                                                     imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage,
//                                                         height: 160, width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor),
//                                                   ) : Image.asset(Images.placeholderImage, height: 160,
//                                                     width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor,),
//                                                 ),
//                                               ),
//                                               Positioned( bottom: 0, right: 0, top: 0, left: 0,
//                                                 child: InkWell(
//                                                   splashColor: Colors.transparent,
//                                                   onTap: () => addProductImageController.pickImage(true,false, false, null, isAddProduct: widget.product == null),
//                                                   child: DottedBorder(
//                                                     options: RoundedRectDottedBorderOptions (
//                                                       dashPattern: const [4,5],
//                                                       color: Theme.of(context).hintColor,
//                                                       radius: const Radius.circular(Dimensions.paddingEye),
//                                                     ),
//                                                     child: Container(
//                                                       width: double.infinity,
//                                                       decoration: BoxDecoration(
//                                                         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                                       ),
//                                                       child: (addProductImageController.selectedLogoFile == null && (_product!.thumbnailFullUrl?.path == null || _product!.thumbnailFullUrl?.path == '')) ?
//                                                       Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                                                         Image.asset(Images.uploadImageIcon, width: 40,),
//
//                                                         Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha: .7),))
//                                                       ],) : const SizedBox.shrink(),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ])),
//                                           );
//                                         }
//                                       ),
//
//
//                                       const SizedBox(height: Dimensions.paddingSizeDefault),
//
//
//
//                                       const SizedBox(height: Dimensions.paddingSizeDefault),
//                                       Text(getTranslated('additional_product_images', context)!,
//                                           style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
//                                       const SizedBox(height: Dimensions.paddingSizeDefault),
//
//                                       if(variationController.attributeList![0].active && variationController.attributeList![0].variants.isNotEmpty)
//                                         Consumer<AddProductImageController>(
//                                           builder: (context, addProductImageController, child) {
//                                             return GridView.builder(
//                                                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                                   childAspectRatio: 1,
//                                                   crossAxisCount: 2,
//                                                   crossAxisSpacing: 10,
//                                                   mainAxisSpacing: 10,
//                                                 ),
//                                                 shrinkWrap: true,
//                                                 physics: const NeverScrollableScrollPhysics(),
//                                                 itemCount: addProductImageController.imagesWithColor.length,
//                                                 itemBuilder: (context, index){
//                                                   String colorString = '0xff000000';
//                                                   if(addProductImageController.imagesWithColor[index].color != null){
//                                                     if(addProductImageController.imagesWithColor[index].color != null){
//                                                       colorString = '0xff${addProductImageController.imagesWithColor[index].color!.substring(1, 7)}';
//                                                     }
//                                                   }
//
//                                                   Brightness brightness = ThemeData.estimateBrightnessForColor(Color(int.parse(colorString)));
//
//
// // Pick icon color based on brightness
//                                                   Color iconColor = (brightness == Brightness.dark) ? Colors.white : Colors.black;
//
//                                                   return Padding(
//                                                     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                                                     child: (addProductImageController.imagesWithColor[index].color != null && addProductImageController.imagesWithColor[index].image == null) ?
//                                                     GestureDetector(
//                                                       onTap: () async {
//                                                         addProductImageController.pickImage(false, false, false, index, update: _update);
//
//                                                       },
//                                                       child: Stack(children: [
//                                                         DottedBorder(
//                                                           options: RoundedRectDottedBorderOptions (
//                                                             dashPattern: const [4,5],
//                                                             color: Theme.of(context).hintColor,
//                                                             radius: const Radius.circular(15),
//                                                           ),
//                                                           child: ClipRRect(
//                                                                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                                                 child: (_update) ? CustomImageWidget(image: addProductImageController.imagesWithColor[index].colorImage?.imageName?.path ?? "",
//                                                                     width: MediaQuery.of(context).size.width/2.3,
//                                                                     height: MediaQuery.of(context).size.width/2.3,
//                                                                     fit: BoxFit.cover):
//                                                                 Image.asset(Images.placeholderImage, height: MediaQuery.of(context).size.width/2.3,
//                                                                     width: MediaQuery.of(context).size.width/2.3, fit: BoxFit.cover),
//                                                             ),
//                                                         ),
//                                                         Positioned(bottom: 0, right: 0, top: 0, left: 0,
//                                                           child: Align(alignment: Alignment.center,
//                                                           child: Icon(Icons.camera_alt, color: Colors.black.withValues(alpha:.5), size: 40))
//                                                         ),
//
//                                                         Positioned(right: 5,top: 5,
//                                                           child: Container(width: 30,height: 30,
//                                                           decoration: BoxDecoration(color: Color(int.parse(colorString)),
//                                                               borderRadius: BorderRadius.circular(20)),
//                                                           child: Padding(padding: const EdgeInsets.all(8.0),
//                                                               child: Image.asset(Images.edit, color: iconColor,))))
//                                                       ],
//                                                       ),
//                                                     ) :
//
//                                                     Stack(children: [
//                                                       DottedBorder(
//                                                           options: RoundedRectDottedBorderOptions (
//                                                             dashPattern: const [4,5],
//                                                             color: Theme.of(context).hintColor,
//                                                             radius: const Radius.circular(15),
//                                                           ),
//                                                           child: Container(decoration: const BoxDecoration(color: Colors.white,
//                                                             borderRadius: BorderRadius.all(Radius.circular(20)),),
//                                                               child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
//                                                                   child: Image.file(File(addProductImageController.imagesWithColor[index].image!.path),
//                                                                       width: MediaQuery.of(context).size.width/2.3,
//                                                                       height: MediaQuery.of(context).size.width/2.3,
//                                                                       fit: BoxFit.cover)))),
//
//                                                       Positioned(top:5,right:5,
//                                                         child: InkWell(
//                                                           splashColor: Colors.transparent,
//                                                           onTap: (){
//                                                             addProductImageController.pickImage(false, false, false, index);
//                                                             // log("=update=>$_update");
//                                                             // resProvider.removeImage(index, true);
//                                                             // if(_update && resProvider.withColor[index].imageString != null &&  resProvider.withColor[index].imageString!.isNotEmpty){
//                                                             //   resProvider.deleteProductImage(_product!.id.toString(), resProvider.withColorKeys[index].toString(), resProvider.withColor[index].color.toString().replaceAll("#",''));
//                                                             // }
//                                                           },
//                                                           child: Container(width: 30,height: 30,
//                                                             decoration: BoxDecoration(
//                                                               color: Color(int.parse(colorString)),
//                                                               borderRadius: BorderRadius.circular(20)),
//                                                             child: Padding(padding: const EdgeInsets.all(8.0),
//                                                               child: Image.asset(Images.edit, color: iconColor))))
//                                                       ),
//
//                                                     ],
//                                                     ),
//                                                   );
//                                                 });
//                                           }
//                                         ),
//
//
//
//
//                                       if(_update)
//                                         Consumer<AddProductImageController>(
//                                           builder: (context, addProductImageController, _) {
//                                             return GridView.builder(
//                                                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                                     childAspectRatio: 1,
//                                                     crossAxisCount: 2,
//                                                     crossAxisSpacing: 10,
//                                                     mainAxisSpacing: 10),
//                                                 shrinkWrap: true,
//                                                 physics: const NeverScrollableScrollPhysics(),
//                                                 itemCount: addProductImageController.imagesWithoutColor.length,
//                                                 itemBuilder: (BuildContext context, index){
//                                                   return Stack(children: [
//                                                     DottedBorder(
//                                                       options: RoundedRectDottedBorderOptions (
//                                                         dashPattern: const [4,5],
//                                                         color: Theme.of(context).hintColor,
//                                                         radius: const Radius.circular(15),
//                                                       ),
//                                                       child: Container(
//                                                         decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
//                                                         child: ClipRRect(
//                                                           borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
//                                                           child: CustomImageWidget(
//                                                             image: addProductImageController.imagesWithoutColor[index],
//                                                             width: MediaQuery.of(context).size.width/2.3,
//                                                             height: MediaQuery.of(context).size.width/2.3,
//                                                             fit: BoxFit.cover,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//
//                                                     Positioned(top: 5, right : 5, child: InkWell(
//                                                       splashColor: Colors.transparent,
//                                                       onTap : () => addProductImageController.deleteProductImage(
//                                                         '${_product?.id}',
//                                                         _getFilenameFromFullImagePath(addProductImageController.imagesWithoutColor[index]),
//                                                         null,
//                                                       ),
//                                                       child: Container(
//                                                         decoration: BoxDecoration(
//                                                           color: Colors.white,
//                                                           boxShadow: [BoxShadow(
//                                                             color: Theme.of(context).hintColor.withValues(alpha:.25),
//                                                             blurRadius: 1,
//                                                             spreadRadius: 1,
//                                                             offset: const Offset(0,0),
//                                                           )],
//                                                           borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
//                                                         ),
//                                                         child: const Padding(
//                                                           padding: EdgeInsets.all(4.0),
//                                                           child: Icon(Icons.delete_forever_rounded,color: Colors.red,size: 25,),
//                                                         ),
//                                                       ),
//                                                     )),
//                                                   ]);
//                                                 });
//                                           }
//                                         ),
//
//
//                                       (_update && addProductImageController.imagesWithoutColor.isNotEmpty) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
//
//                                       Consumer<AddProductImageController>(
//                                         builder: (context, addProductImageController, child) {
//                                           return GridView.builder(
//                                               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                                 childAspectRatio: 1,
//                                                 crossAxisCount: 2,
//                                                 crossAxisSpacing: 10,
//                                                 mainAxisSpacing: 10,
//                                               ),
//                                               shrinkWrap: true,
//                                               physics: const NeverScrollableScrollPhysics(),
//                                               itemCount: addProductImageController.withoutColor.length + 1,
//                                               itemBuilder: (BuildContext context, index){
//                                                 return index == addProductImageController.withoutColor.length ?
//                                                 GestureDetector(
//                                                   onTap: ()=> addProductImageController.pickImage(false, false, false, null),
//                                                   child: Stack(children: [
//                                                     DottedBorder(
//                                                       options: RoundedRectDottedBorderOptions (
//                                                         dashPattern: const [4,5],
//                                                         color: Theme.of(context).hintColor,
//                                                         radius: const Radius.circular(15),
//                                                       ),
//                                                       child: ClipRRect(
//                                                         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                                         child:  Image.asset(Images.placeholderImage, height: MediaQuery.of(context).size.width/2.3,
//                                                             width: MediaQuery.of(context).size.width/2.3, fit: BoxFit.cover, color: Theme.of(context).highlightColor,),
//                                                       ),
//                                                     ),
//                                                     Positioned(bottom: 0, right: 0, top: 0, left: 0,
//                                                       child: Align(
//                                                         alignment: Alignment.center,
//                                                         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                                                           Image.asset(Images.uploadImageIcon, width: 40,),
//
//                                                           Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha: .7)),)
//                                                         ],),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                   ),
//                                                 ) :
//                                                 Stack(children: [
//                                                   DottedBorder(
//                                                     options: RoundedRectDottedBorderOptions (
//                                                       dashPattern: const [4,5],
//                                                       color: Theme.of(context).hintColor,
//                                                       radius: const Radius.circular(15),
//                                                     ),
//                                                     child: Container(
//                                                       decoration: const BoxDecoration(color: Colors.white,
//                                                         borderRadius: BorderRadius.all(Radius.circular(20)),),
//                                                       child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
//                                                         child: Image.file(File(addProductImageController.withoutColor[index].image!.path),
//                                                           width: MediaQuery.of(context).size.width/2.3,
//                                                           height: MediaQuery.of(context).size.width/2.3,
//                                                           fit: BoxFit.cover,),) ,),
//                                                   ),
//
//                                                   Positioned(top: 5, right : 5,
//                                                     child: InkWell(
//                                                       splashColor: Colors.transparent,
//                                                       onTap :() => addProductImageController.removeImage(index, false),
//                                                       child: Container(decoration: BoxDecoration(
//                                                           color: Colors.white,
//                                                           boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha:.25), blurRadius: 1,spreadRadius: 1,offset: const Offset(0,0))],
//                                                           borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
//                                                           child: const Padding(
//                                                             padding: EdgeInsets.all(4.0),
//                                                             child: Icon(Icons.delete_forever_rounded,color: Colors.red,size: 25,),)),
//                                                     ),
//                                                   ),
//                                                 ],
//                                                 );
//                                               });
//                                         }
//                                       ),
//
//
//                                       const SizedBox(height: 25),
//                                     ],),
//                                   )
//                                 ],
//                             )
