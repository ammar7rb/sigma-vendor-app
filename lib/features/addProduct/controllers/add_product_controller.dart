import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/attribute_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/product_image_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/variant_type_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/ai/domain/models/ai_meta_seo_model.dart';
import 'package:sixvalley_vendor_app/features/ai/domain/models/genara_setup_model.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/edt_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/image_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/helper/product_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

class AddProductController extends ChangeNotifier {
  final AddProductServiceInterface shopServiceInterface;

  AddProductController({required this.shopServiceInterface});

  final int _totalQuantity = 0;
  int get totalQuantity => _totalQuantity;
  String? _unitValue;
  String? get unitValue => _unitValue;
  int _discountTypeIndex = 0;
  int _taxTypeIndex = -1;
  String _imagePreviewSelectedType = 'large';
  int _unitIndex = 0;

  MetaSeoInfo? _metaSeoInfo = MetaSeoInfo();
  final TextEditingController maxSnippetController =
      TextEditingController(text: '-1');
  final TextEditingController maxImagePreviewController =
      TextEditingController(text: '-1');

  int get unitIndex => _unitIndex;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAttributeActive = false;
  bool get isAttributeActive => _isAttributeActive;

  EditProductModel? _editProduct;
  EditProductModel? get editProduct => _editProduct;
  int get discountTypeIndex => _discountTypeIndex;
  int get taxTypeIndex => _taxTypeIndex;
  String get imagePreviewSelectedType => _imagePreviewSelectedType;

  bool _isMultiply = false;
  bool get isMultiply => _isMultiply;

  final picker = ImagePicker();
  List<TextEditingController> _titleControllerList = [];
  List<TextEditingController> _descriptionControllerList = [];

  List<TextEditingController> get titleControllerList => _titleControllerList;
  List<TextEditingController> get descriptionControllerList =>
      _descriptionControllerList;
  final TextEditingController _productCode = TextEditingController();
  TextEditingController get productCode => _productCode;
  List<FocusNode>? _titleNode;
  List<FocusNode>? _descriptionNode;
  List<FocusNode>? get titleNode => _titleNode;
  List<FocusNode>? get descriptionNode => _descriptionNode;
  int _productTypeIndex = 0;
  int get productTypeIndex => _productTypeIndex;

  int _totalVariantQuantity = 0;
  int get totalVariantQuantity => _totalVariantQuantity;

  List<Map<String, dynamic>>? productReturnImage = [];
  final int _variationTotalQuantity = 0;
  int get variationTotalQuantity => _variationTotalQuantity;
  final bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;
  int? _selectedPageIndex = 0;
  int? get selectedPageIndex => _selectedPageIndex;

  MetaSeoInfo? get metaSeoInfo => _metaSeoInfo;

  List<String> pages = ['general_info', 'variation_setup', 'product_seo'];
  List<String> imagePreviewType = ['large', 'medium', 'small'];

  TextEditingController unitPriceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController shippingCostController = TextEditingController();
  TextEditingController minimumOrderQuantityController =
      TextEditingController();
  TextEditingController youtubeLinkController = TextEditingController();
  final TextEditingController piecesPerUnitController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController productionDateController =
      TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  String saleUnitType = 'piece';
  String dimensionUnit = 'cm';
  String weightUnit = 'kg';

  @override
  void dispose() {
    unitPriceController.dispose();
    discountController.dispose();
    shippingCostController.dispose();
    minimumOrderQuantityController.dispose();
    youtubeLinkController.dispose();
    piecesPerUnitController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    weightController.dispose();
    productionDateController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  void setTitle(int index, String title, {bool isUpdate = false}) {
    _titleControllerList[index].text = title;

    if (isUpdate) {
      notifyListeners();
    }
  }

  void setDescription(int index, String description) {
    _descriptionControllerList[index].text = description;
  }

  void getTitleAndDescriptionList(
      List<Language> languageList, EditProductModel? edtProduct) {
    _titleControllerList = [];
    _descriptionControllerList = [];
    for (int i = 0; i < languageList.length; i++) {
      if (edtProduct != null) {
        if (i == 0) {
          String plainProductDetails =
              ProductHelper.htmlToPlainText(edtProduct.details ?? '');
          _titleControllerList.insert(
              i, TextEditingController(text: edtProduct.name));
          _descriptionControllerList
              .add(TextEditingController(text: plainProductDetails));
        } else {
          for (var lan in edtProduct.translations!) {
            if (lan.locale == languageList[i].code && lan.key == 'name') {
              _titleControllerList.add(TextEditingController(text: lan.value));
            }
            if (lan.locale == languageList[i].code &&
                lan.key == 'description') {
              String plainText = ProductHelper.htmlToPlainText(lan.value ?? '');
              _descriptionControllerList
                  .add(TextEditingController(text: plainText));

              debugPrint('--------description---------${lan.value}');
            }
          }
        }
      } else {
        _titleControllerList.add(TextEditingController());
        _descriptionControllerList.add(TextEditingController());
      }
    }
    if (edtProduct != null) {
      if (_titleControllerList.length < languageList.length) {
        int l1 = languageList.length - _titleControllerList.length;
        for (int i = 0; i < l1; i++) {
          _titleControllerList
              .add(TextEditingController(text: editProduct!.name));
          debugPrint('--------name---------${editProduct!.name}');
        }
      }
      if (_descriptionControllerList.length < languageList.length) {
        int l0 = languageList.length - _descriptionControllerList.length;
        for (int i = 0; i < l0; i++) {
          _descriptionControllerList
              .add(TextEditingController(text: editProduct!.details));
          debugPrint('--------description---------${editProduct!.details}');
        }
      }
    } else {
      if (_titleControllerList.length < languageList.length) {
        int l = languageList.length - _titleControllerList.length;
        for (int i = 0; i < l; i++) {
          _titleControllerList.add(TextEditingController());
        }
      }
      if (_descriptionControllerList.length < languageList.length) {
        int l2 = languageList.length - _descriptionControllerList.length;
        for (int i = 0; i < l2; i++) {
          _descriptionControllerList.add(TextEditingController());
        }
      }
    }
  }

  void resetDiscountTypeIndex() {
    _discountTypeIndex = 0;
  }

  String discountType = 'percent';

  void setDiscountTypeIndex(int index, bool notify) {
    _discountTypeIndex = index;
    if (_discountTypeIndex == 0) {
      discountType = 'percent';
    } else {
      discountType = 'flat';
    }
    if (notify) {
      notifyListeners();
    }
  }

  void setTaxTypeIndex(int index, bool notify) {
    _taxTypeIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  void setImagePreviewType(String type, bool notify) {
    _imagePreviewSelectedType = type;
    if (notify) {
      notifyListeners();
    }
  }

  void toggleMultiply(BuildContext context) {
    _isMultiply = !_isMultiply;
    notifyListeners();
  }

  ///Move to Add Product Directory
  Future<void> getEditProduct(BuildContext context, int? id) async {
    _editProduct = null;
    ApiResponse response = await shopServiceInterface.getEditProduct(id);
    if (response.response != null && response.response!.statusCode == 200) {
      _editProduct = EditProductModel.fromJson(response.response!.data);
      if (_editProduct?.seoInfo != null) {
        convertSeoInfoToMetaSeoInfo(_editProduct!.seoInfo!);
      }

      getTitleAndDescriptionList(
          Provider.of<SplashController>(Get.context!, listen: false)
              .configModel!
              .languageList!,
          _editProduct);
      Provider.of<DigitalProductController>(Get.context!, listen: false)
          .initDigitalProductVariation(_editProduct!);
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  void convertSeoInfoToMetaSeoInfo(SeoInfo seoInfo) {
    _metaSeoInfo = MetaSeoInfo(
        metaIndex: seoInfo.index,
        metaNoFollow: seoInfo.noFollow,
        metaNoImageIndex: seoInfo.noImageIndex,
        metaNoArchive: seoInfo.noArchive,
        metaNoSnippet: seoInfo.noSnippet,
        metaMaxSnippet: seoInfo.maxSnippet,
        metaMaxSnippetValue: seoInfo.maxSnippetValue,
        metaMaxVideoPreview: seoInfo.maxVideoPreview,
        metaMaxVideoPreviewValue: seoInfo.maxVideoPreviewValue,
        metaMaxImagePreview: seoInfo.maxImagePreview,
        metaMaxImagePreviewValue: seoInfo.maxImagePreviewValue,
        imageFullUrl: seoInfo.imageFullUrl);
  }

  void setUnitIndex(int index, bool notify) {
    _unitIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  int totalUploaded = 0;
  void initUpload() {
    totalUploaded = 0;
    notifyListeners();
  }

  Future<void> addProduct(
      BuildContext context,
      Product product,
      AddProductModel addProduct,
      String? thumbnail,
      String? metaImage,
      bool isAdd,
      List<String?> tags) async {
    _isLoading = true;
    notifyListeners();

    final addProductImageController =
        Provider.of<AddProductImageController>(context, listen: false);
    bool isDigitalVariationEmpty =
        Provider.of<DigitalProductController>(context, listen: false)
            .selectedDigitalVariation
            .isNotEmpty;

    DigitalVariationModel? digitalVariationModel;
    String? token;

    List<AttributeModel>? attributeList =
        Provider.of<VariationController>(context, listen: false).attributeList;

    Map<String, dynamic> variationFields =
        Provider.of<VariationController>(context, listen: false)
            .processVariantData(context);

    Provider.of<VariationController>(context, listen: false)
        .onClearColorVariations(addProduct);

    List<Map<String, dynamic>>? productReturnImages =
        addProductImageController.productReturnImageList;

    List<ColorImage> colorImageObjects =
        addProductImageController.colorImageObject;

    String? digitalProductFileName =
        Provider.of<DigitalProductController>(context, listen: false)
            .digitalProductFileName;

    if (_productTypeIndex == 1) {
      digitalVariationModel =
          Provider.of<DigitalProductController>(context, listen: false)
              .getDigitalVariationModel();
    } else {
      digitalVariationModel = DigitalVariationModel();
    }

    token = Provider.of<AuthController>(context, listen: false).getUserToken();

    setMetaSeoData(product);

    ApiResponse response = await shopServiceInterface.addProduct(
        product,
        addProduct,
        variationFields,
        productReturnImages,
        thumbnail,
        metaImage,
        isAdd,
        attributeList![0].active,
        colorImageObjects,
        tags,
        digitalProductFileName,
        digitalVariationModel,
        isDigitalVariationEmpty,
        token);
    if (response.response != null && response.response?.statusCode == 200) {
      await addProductImageController.onDeleteColorImages(product);

      _productCode.clear();
      Navigator.pushAndRemoveUntil(
          Get.context!,
          MaterialPageRoute(
              builder: (_) =>
                  const ProductListMenuScreen(fromNotification: true)),
          (route) => false);
      showCustomSnackBarWidget(
        isAdd
            ? getTranslated(
                'seller_product_uploaded_under_review', Get.context!)
            : getTranslated('product_updated_successfully', Get.context!),
        Get.context!,
        isError: false,
      );
      titleControllerList.clear();
      descriptionControllerList.clear();
      Provider.of<AddProductImageController>(Get.context!, listen: false)
          .removeProductImage();
      emptyDigitalProductData();
      _isLoading = false;
      _metaSeoInfo = MetaSeoInfo();
    } else {
      Provider.of<AddProductImageController>(Get.context!, listen: false)
          .emptyWithColorImage();
      _isLoading = false;
      // Keep the backend's specific entitlement reason visible to the seller.
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setMetaSeoData(Product product) {
    metaSeoInfo?.metaMaxImagePreviewValue = _imagePreviewSelectedType;
    product.metaSeoInfo = metaSeoInfo;
  }

  void loadingFalse() {
    _isLoading = false;
    notifyListeners();
  }

  void setValueForUnit(String? setValue) {
    if (kDebugMode) {
      debugPrint('------$setValue====$_unitValue');
    }
    _unitValue = setValue;
  }

  void setProductTypeIndex(int index, bool notify) {
    _productTypeIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  void setTotalVariantTotalQuantity(int total) {
    _totalVariantQuantity = total;
  }

  Future<void> updateProductQuantity(BuildContext context, int? productId,
      int currentStock, List<Variation> variations) async {
    if (kDebugMode) {
      debugPrint("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for (int i = 0; i < variations.length; i++) {
      updatedVariations.add(Variation(
          type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse(
              Provider.of<VariationController>(context, listen: false)
                  .variantTypeList[i]
                  .qtyController
                  .text)));
    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.updateProductQuantity(
        productId, currentStock, updatedVariations);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(
          getTranslated('quantity_updated_successfully', Get.context!),
          Get.context!,
          isError: false);
      Provider.of<ProductController>(Get.context!, listen: false)
          .getStockOutProductList(1, 'en');
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> updateRestockProductQuantity(BuildContext context,
      int? productId, int currentStock, List<Variation> variations,
      {int? index}) async {
    if (kDebugMode) {
      debugPrint("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for (int i = 0; i < variations.length; i++) {
      updatedVariations.add(Variation(
          type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse(
              Provider.of<VariationController>(context, listen: false)
                  .variantTypeList[i]
                  .qtyController
                  .text)));
    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await shopServiceInterface.updateRestockProductQuantity(
            productId, currentStock, updatedVariations);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(
          getTranslated('quantity_updated_successfully', Get.context!),
          Get.context!,
          isError: false);
      await Provider.of<RestockController>(Get.context!, listen: false)
          .getRestockProductList(1);
      // Provider.of<RestockController>(Get.context!, listen: false).removeItem(index);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  List<String> imagesWithoutColor = [];
  List<String> imagesWithColorForUpdate = [];
  ProductImagesModel? productImagesModel;

  void setSelectedPageIndex(int index, {bool isUpdate = true}) {
    _selectedPageIndex = index;
    if (isUpdate) {
      notifyListeners();
    }
  }

  List<String> processList(List<String> inputList) {
    return inputList.map((str) => str.toLowerCase().trim()).toList();
  }

  void updateState() {
    notifyListeners();
  }

  void emptyDigitalProductData() {
    Provider.of<DigitalProductController>(Get.context!, listen: false)
        .emptyDigitalProductData();
  }

  Future<void> generateAndSetOtherData(
      {String? title, String? description, String? langCode}) async {
    AiController aiController =
        Provider.of<AiController>(Get.context!, listen: false);

    await aiController
        .generateGeneralSetup(
      title: title ?? '',
      description: description ?? '',
      langCode: langCode ?? '',
    )
        .then((value) {
      GeneralSetupModel? generalSetupModel = aiController.generalSetupModel;

      //Set brand
      if (generalSetupModel != null) {
        ProductController productController =
            Provider.of<ProductController>(Get.context!, listen: false);
        productController.setAiBrandIndex(generalSetupModel.data?.brandId ?? 0);
      }

      //Set category
      if (generalSetupModel != null) {
        CategoryController categoryController =
            Provider.of<CategoryController>(Get.context!, listen: false);
        categoryController.setAiCategoryIndex(
            generalSetupModel.data?.categoryId,
            generalSetupModel.data?.subCategoryId,
            generalSetupModel.data?.subSubCategoryId);
      }

      // print('---UnitValue---${generalSetupModel?.data?.unitName}--');

      //print('---UnitValue--01--${generalSetupModel != null && generalSetupModel.data?.unitName != null && generalSetupModel.data!.unitName!.isNotEmpty}--');

      if (generalSetupModel != null &&
          generalSetupModel.data?.unitName != null &&
          generalSetupModel.data!.unitName!.isNotEmpty) {
        _unitValue = generalSetupModel.data?.unitName;
      }

      if (generalSetupModel != null &&
          generalSetupModel.data?.productType != null) {
        _productTypeIndex =
            generalSetupModel.data?.productType == 'physical' ? 0 : 1;
      }

      if (generalSetupModel != null &&
          generalSetupModel.data?.productType != null &&
          generalSetupModel.data?.productType == 'digital' &&
          generalSetupModel.data?.deliveryType != null) {
        Provider.of<DigitalProductController>(Get.context!, listen: false)
            .setDigitalProductTypeIndex(
                generalSetupModel.data?.deliveryType == 'ready_product' ? 1 : 0,
                true);
      }
      notifyListeners();
    });
  }

  void updateMetaSeoInfo(AiMetaSEOModel? aiMetaSeoModel) {
    if (aiMetaSeoModel != null) {
      _metaSeoInfo?.metaIndex =
          aiMetaSeoModel.data?.metaIndex == '0' ? '0' : '1';
      _metaSeoInfo?.metaNoFollow =
          aiMetaSeoModel.data?.metaNoFollow == 0 ? '0' : 'nofollow';
      _metaSeoInfo?.metaNoIndex =
          aiMetaSeoModel.data?.metaNoImageIndex == 0 ? '0' : '1';
      _metaSeoInfo?.metaNoArchive =
          aiMetaSeoModel.data?.metaNoArchive == 0 ? '0' : '1';
      _metaSeoInfo?.metaNoSnippet =
          aiMetaSeoModel.data?.metaNoSnippet == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxSnippet =
          aiMetaSeoModel.data?.metaMaxSnippet == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxVideoPreview =
          aiMetaSeoModel.data?.metaMaxVideoPreview == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxImagePreview =
          aiMetaSeoModel.data?.metaMaxImagePreview == 0 ? '0' : '1';

      _metaSeoInfo?.metaMaxSnippetValue =
          aiMetaSeoModel.data?.metaMaxSnippetValue.toString();
      _metaSeoInfo?.metaMaxVideoPreviewValue =
          aiMetaSeoModel.data?.metaMaxVideoPreviewValue.toString();
      _metaSeoInfo?.metaMaxImagePreviewValue =
          aiMetaSeoModel.data?.metaMaxImagePreviewValue.toString();
      notifyListeners();
    }
  }

  void setIsAttributeActive(bool isActive, {bool notify = false}) {
    _isAttributeActive = isActive;
    if (notify) {
      notifyListeners();
    }
  }

  // Inside AddProductController class
  bool validateGeneralInfo(
    BuildContext context, {
    required CategoryController categoryController,
    required AddProductImageController imageController,
    required Product? existingProduct, // For update checks/ For update checks
    required String? youtubeLink,
  }) {
    bool isUpdate = existingProduct != null;

    // 1. Check Titles
    if (titleControllerList.isNotEmpty && titleControllerList[0].text.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('please_input_all_title', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    // 2. Check Description and seller identity/contact policy before upload.
    if (descriptionControllerList.isNotEmpty &&
        descriptionControllerList[0].text.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('please_input_all_des', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    final restrictedText = <String>[
      ...titleControllerList.map((controller) => controller.text),
      ...descriptionControllerList.map((controller) => controller.text),
    ].join(' ');
    if (_containsRestrictedSellerIdentityData(restrictedText)) {
      showCustomSnackBarWidget(
        getTranslated('seller_product_description_policy_warning', context),
        context,
        sanckBarType: SnackBarType.warning,
      );
      return false;
    }

    // 3. Check Category
    if (categoryController.categoryIndex == 0 ||
        categoryController.categoryIndex == -1) {
      showCustomSnackBarWidget(
          getTranslated('select_a_category', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    // Unit and measurements are optional for seller products.

    // 4. Check Product Code
    if (productCode.text.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('product_code_is_required', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }
    if (productCode.text.length < 6 || productCode.text == '000000') {
      showCustomSnackBarWidget(
          getTranslated('product_code_minimum_6_digit', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    // 5. Check Thumbnail
    bool hasExistingThumbnail = isUpdate &&
        (existingProduct.thumbnailFullUrl?.path != null &&
            existingProduct.thumbnailFullUrl?.path != '');

    if (!isUpdate && imageController.selectedLogoFile == null) {
      showCustomSnackBarWidget(
          getTranslated('upload_thumbnail_image', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (isUpdate &&
        imageController.selectedLogoFile == null &&
        !hasExistingThumbnail) {
      showCustomSnackBarWidget(
          getTranslated('upload_thumbnail_image', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    // 6. Require five product images. The thumbnail is intentionally not part
    // of this count because the API stores it separately from product images.
    bool hasExistingImages = isUpdate &&
        (existingProduct.imagesFullUrl != null &&
            existingProduct.imagesFullUrl!.isNotEmpty);
    final existingImageCount = hasExistingImages
        ? existingProduct.imagesFullUrl!
            .where((image) => image.path?.isNotEmpty ?? false)
            .length
        : 0;
    final newColorImageCount = imageController.imagesWithColor
        .where((image) => image.image != null)
        .length;
    final productImageCount = isUpdate
        ? existingImageCount +
            imageController.withoutColor.length +
            newColorImageCount
        : imageController.withoutColor.length + newColorImageCount;
    if (productImageCount < 5) {
      showCustomSnackBarWidget(
        '${getTranslated('seller_product_minimum_images_required', context)} ($productImageCount/5)',
        context,
        sanckBarType: SnackBarType.warning,
      );
      return false;
    }

    if (saleUnitType == 'package' &&
        (int.tryParse(piecesPerUnitController.text.trim()) ?? 0) < 1) {
      showCustomSnackBarWidget(
          getTranslated('seller_product_pieces_per_unit_required', context),
          context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    final productionDate =
        DateTime.tryParse(productionDateController.text.trim());
    final expiryDate = DateTime.tryParse(expiryDateController.text.trim());
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (productionDate == null || expiryDate == null) {
      showCustomSnackBarWidget(
          getTranslated('product_dates_are_required', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }
    if (expiryDate.isBefore(productionDate) || !expiryDate.isAfter(todayOnly)) {
      showCustomSnackBarWidget(
          getTranslated('product_expiry_date_is_invalid', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    final optionalMeasurements = [
      lengthController.text,
      widthController.text,
      heightController.text,
      weightController.text
    ].where((value) => value.trim().isNotEmpty);
    if (optionalMeasurements
        .any((value) => (double.tryParse(value.trim()) ?? 0) <= 0)) {
      showCustomSnackBarWidget(
          getTranslated('seller_product_measurement_invalid', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    if (youtubeLink != null &&
        youtubeLink.trim().isNotEmpty &&
        !youtubeLink.contains('youtube.com/embed/')) {
      showCustomSnackBarWidget(
          getTranslated('provide_embedded_link', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    return true;
  }

  bool _containsRestrictedSellerIdentityData(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;

    final hasPhone = RegExp(
            r'(?:\+?20|0?1[0125])(?:[\s-]?\d){8,10}|(?:٠١|01)[٠-٩0-9\s-]{8,12}')
        .hasMatch(normalized);
    final hasDirectContact = RegExp(
            r'\b(?:https?://|www\.|[\w.+-]+@[\w-]+\.[\w.-]+|whatsapp|telegram|contact\s+us)\b|(?:واتساب|تليجرام|تواصل\s*معنا|اتصل\s*بنا|العنوان|شارع)',
            caseSensitive: false)
        .hasMatch(normalized);
    return hasPhone || hasDirectContact;
  }

  void initializeProductSpecifications(Product? product) {
    saleUnitType = product?.saleUnitType == 'box'
        ? 'package'
        : (product?.saleUnitType ?? 'piece');
    piecesPerUnitController.text = saleUnitType == 'package'
        ? (product?.piecesPerUnit?.toString() ?? '')
        : '';
    lengthController.text = product?.length?.toString() ?? '';
    widthController.text = product?.width?.toString() ?? '';
    heightController.text = product?.height?.toString() ?? '';
    weightController.text = product?.weight?.toString() ?? '';
    dimensionUnit = product?.dimensionUnit ?? 'cm';
    weightUnit = product?.weightUnit ?? 'kg';
    productionDateController.text = product?.productionDate ?? '';
    expiryDateController.text = product?.expiryDate ?? '';
  }

  void setSaleUnitType(String value) {
    saleUnitType = value == 'box' ? 'package' : value;
    if (value == 'piece') piecesPerUnitController.clear();
    notifyListeners();
  }

  void setDimensionUnit(String value) {
    dimensionUnit = value;
    notifyListeners();
  }

  void setWeightUnit(String value) {
    weightUnit = value;
    notifyListeners();
  }

  // Inside AddProductController class

  bool validateVariations(
    BuildContext context, {
    required DigitalProductController digitalProductController,
    required VariationController variationController,
    required AddProductTaxController taxController,
    required AddProductImageController imageController,
    required ConfigModel? configModel, // Pass ConfigModel from SplashController

    // Pass the text values from your UI TextControllers
    required String unitPrice,
    required String currentStock,
    required String orderQuantity,
    required String shippingCost,
    required bool isUpdate,
  }) {
    bool digitalProductVariationEmpty = false;
    bool isTitleEmpty = false;
    bool isFileEmpty = false;
    bool isPriceEmpty = false;
    bool isSKUEmpty = false;

    // 1. Digital Product Checks
    for (int index = 0;
        index < digitalProductController.selectedDigitalVariation.length;
        index++) {
      if (digitalProductController.digitalVariationExtantion[index].isEmpty) {
        digitalProductVariationEmpty = true;
        break;
      }
    }

    for (int index = 0;
        index < digitalProductController.selectedDigitalVariation.length;
        index++) {
      for (int i = 0;
          i < digitalProductController.variationFileList[index].length;
          i++) {
        if (digitalProductController.variationFileList[index][i].fileName ==
            null) {
          isFileEmpty = true;
          break;
        }
        if (digitalProductController
                .variationFileList[index][i].priceController?.text
                .trim() ==
            '') {
          isPriceEmpty = true;
          break;
        }
        if (digitalProductController
                .variationFileList[index][i].skuController?.text
                .trim() ==
            '') {
          isSKUEmpty = true;
          break;
        }
        if (digitalProductController.variationFileList[index][i].fileName ==
            null) {
          isTitleEmpty = true;
          break;
        }
      }
    }

    // 2. Physical Variant Checks
    bool haveBlankVariant = false;
    bool blankVariantPrice = false;
    bool blankVariantQuantity = false;

    if (variationController.attributeList != null) {
      for (AttributeModel attr in variationController.attributeList!) {
        if (attr.active && attr.variants.isEmpty) {
          haveBlankVariant = true;
          break;
        }
      }
    }

    for (VariantTypeModel variantType in variationController.variantTypeList) {
      if (variantType.controller.text.isEmpty) {
        blankVariantPrice = true;
        break;
      }
      if (variantType.qtyController.text.isEmpty) {
        blankVariantQuantity = true;
        break;
      }
    }

    // 3. Color Image Checks
    bool isColorImageEmpty = false;
    if (imageController.imagesWithColor.isNotEmpty) {
      for (int i = 0; i < imageController.imagesWithColor.length; i++) {
        if (!isUpdate &&
            imageController.imagesWithColor[i].image == null &&
            !isColorImageEmpty) {
          isColorImageEmpty = true;
        } else if (isUpdate &&
            imageController.imagesWithColor[i].colorImage?.imageName == null &&
            !isColorImageEmpty) {
          isColorImageEmpty = true;
        }
      }
    }

    // 4. MAIN VALIDATIONS
    if (unitPrice.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('enter_unit_price', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (currentStock.isEmpty && productTypeIndex == 0) {
      showCustomSnackBarWidget(
          getTranslated('enter_total_quantity', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (orderQuantity.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('enter_minimum_order_quantity', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (haveBlankVariant) {
      showCustomSnackBarWidget(
          getTranslated(
              'add_at_least_one_variant_for_every_attribute', context),
          context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (blankVariantPrice) {
      showCustomSnackBarWidget(
          getTranslated('enter_price_for_every_variant', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (blankVariantQuantity) {
      showCustomSnackBarWidget(
          getTranslated('enter_quantity_for_every_variant', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }
    // Shipping validation is intentionally omitted because admin owns delivery pricing.
    else if ((isUpdate || !isUpdate) &&
        productTypeIndex == 1 &&
        digitalProductController.digitalProductTypeIndex == 1 &&
        isFileEmpty) {
      showCustomSnackBarWidget(
          getTranslated('digital_product_file_empty', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (productTypeIndex == 1 && isPriceEmpty) {
      showCustomSnackBarWidget(
          getTranslated('digital_product_price_empty', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (productTypeIndex == 1 && isSKUEmpty) {
      showCustomSnackBarWidget(
          getTranslated('digital_product_sku_empty', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (productTypeIndex == 1 && digitalProductVariationEmpty) {
      showCustomSnackBarWidget(
          getTranslated('digital_product_variation_empty', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (!isUpdate &&
        (productTypeIndex == 1 &&
            digitalProductController.digitalProductTypeIndex == 1 &&
            digitalProductController.selectedFileForImport == null) &&
        digitalProductController.selectedDigitalVariation.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('please_choose_digital_product', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (configModel?.systemTaxType == 'product_wise' &&
        configModel?.systemTaxIncludeStatus == 0 &&
        taxController.selectedTaxList.isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('please_add_your_product_tax', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    } else if (!isUpdate &&
        variationController.attributeList![0].active &&
        variationController.attributeList![0].variants.isNotEmpty &&
        isColorImageEmpty) {
      showCustomSnackBarWidget(
          getTranslated('upload_product_color_image', context), context,
          sanckBarType: SnackBarType.warning);
      return false;
    }

    return true; // Validation Passed
  }

  void resetMetaSeoInfo({bool isUpdate = false}) {
    _metaSeoInfo = MetaSeoInfo();
    if (isUpdate) {
      notifyListeners();
    }
  }
}
