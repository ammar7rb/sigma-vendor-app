import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_media_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/add_auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/add_auction_product_service_interface.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_product_video_widget.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';

class AddAuctionProductController extends ChangeNotifier {
  final AddAuctionProductServiceInterface addAuctionProductServiceInterface;

  AddAuctionProductController({required this.addAuctionProductServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // SEO fields kept in controller for reliable access from parent view
  String? seoMetaIndex;
  String? seoMetaNoFollow; // 'nofollow' or '0'
  String? seoMetaNoImageIndex; // '1' or '0'
  String? seoMetaNoArchive; // '1' or '0'
  String? seoMetaNoSnippet; // '1' or '0'
  String? seoMetaMaxSnippet; // '1' or '0'
  String? seoMetaMaxSnippetValue;
  String? seoMetaMaxVideoPreview; // '1' or '0'
  String? seoMetaMaxVideoPreviewValue;
  String? seoMetaMaxImagePreview; // '1' or '0'
  String? seoMetaMaxImagePreviewValue;
  String? seoMetaImage;
  String? seoMetaTitle;
  String? seoMetaDescription;

  void updateSeoFields({
    String? metaTitle,
    String? metaDescription,
    String? metaIndex,
    String? metaNoFollow,
    String? metaNoImageIndex,
    String? metaNoArchive,
    String? metaNoSnippet,
    String? metaMaxSnippet,
    String? metaMaxSnippetValue,
    String? metaMaxVideoPreview,
    String? metaMaxVideoPreviewValue,
    String? metaMaxImagePreview,
    String? metaMaxImagePreviewValue,
    String? metaImage,
  }){
    seoMetaTitle = metaTitle ?? seoMetaTitle;
    seoMetaDescription = metaDescription ?? seoMetaDescription;
    seoMetaIndex = metaIndex ?? seoMetaIndex;
    seoMetaNoFollow = metaNoFollow ?? seoMetaNoFollow;
    seoMetaNoImageIndex = metaNoImageIndex ?? seoMetaNoImageIndex;
    seoMetaNoArchive = metaNoArchive ?? seoMetaNoArchive;
    seoMetaNoSnippet = metaNoSnippet ?? seoMetaNoSnippet;
    seoMetaMaxSnippet = metaMaxSnippet ?? seoMetaMaxSnippet;
    seoMetaMaxSnippetValue = metaMaxSnippetValue ?? seoMetaMaxSnippetValue;
    seoMetaMaxVideoPreview = metaMaxVideoPreview ?? seoMetaMaxVideoPreview;
    seoMetaMaxVideoPreviewValue = metaMaxVideoPreviewValue ?? seoMetaMaxVideoPreviewValue;
    seoMetaMaxImagePreview = metaMaxImagePreview ?? seoMetaMaxImagePreview;
    seoMetaMaxImagePreviewValue = metaMaxImagePreviewValue ?? seoMetaMaxImagePreviewValue;
    seoMetaImage = metaImage ?? seoMetaImage;
    // Debug log to verify updates at runtime
    if (metaIndex != null || metaNoFollow != null || metaMaxSnippetValue != null) {
      // This helps when debugging why values might not be present at submit time
      debugPrint('updateSeoFields: metaIndex=$seoMetaIndex metaNoFollow=$seoMetaNoFollow metaMaxSnippet=$seoMetaMaxSnippet metaMaxSnippetValue=$seoMetaMaxSnippetValue metaMaxVideoPreview=$seoMetaMaxVideoPreview metaMaxVideoPreviewValue=$seoMetaMaxVideoPreviewValue metaMaxImagePreview=$seoMetaMaxImagePreview metaMaxImagePreviewValue=$seoMetaMaxImagePreviewValue');
    }
    notifyListeners();
  }

  bool validateGeneralInfo(
      BuildContext context, {
        required List<TextEditingController> nameController,
        required List<TextEditingController> descriptionController,
        required String? selectedProductType,
        required String? selectedCategory,
        required String? selectedBrand,
        required String? selectedItemCondition,
        required TextEditingController shippingFeeController,
        required TextEditingController returnPolicyController,
        required XFile? thumbnailFile,
        required List<dynamic> additionalImages,
        required AuctionProduct? auctionProduct,
        required TextEditingController videoLinkController,
        VideoUploadType videoUploadType = VideoUploadType.link,
      }) {
    if (nameController.isNotEmpty && nameController[0].text.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_product_name', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (descriptionController.isNotEmpty && descriptionController[0].text.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (selectedProductType == null || selectedProductType.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_product_type', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (selectedCategory == null || selectedCategory.isEmpty) {
      showCustomSnackBarWidget(getTranslated('select_a_category', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (selectedBrand == null || selectedBrand.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_brand', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (selectedItemCondition == null || selectedItemCondition.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_item_condition', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (shippingFeeController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_shipping_cost', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (returnPolicyController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_return_policy', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    bool hasThumbnail = thumbnailFile != null;
    if (auctionProduct != null) {
      final bool hasExistingThumbnail = auctionProduct.thumbnailFullUrl?.path?.trim().isNotEmpty ?? false;
      hasThumbnail = hasExistingThumbnail || thumbnailFile != null;
    }

    if (!hasThumbnail) {
      showCustomSnackBarWidget(getTranslated('upload_thumbnail_image', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    bool hasAdditionalImage = additionalImages.isNotEmpty;
    if (auctionProduct != null) {
      final bool hasExistingAdditionalImage =
          auctionProduct.additionalImageFullUrls?.any((image) => image.path?.trim().isNotEmpty ?? false) ?? false;
      hasAdditionalImage = hasExistingAdditionalImage || additionalImages.isNotEmpty;
    }

    if (!hasAdditionalImage) {
      showCustomSnackBarWidget(getTranslated('upload_product_image', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (videoUploadType == VideoUploadType.link) {
      final videoLink = videoLinkController.text.trim();
      if (videoLink.isNotEmpty && !videoLink.contains('youtube.com/embed/')) {
        showCustomSnackBarWidget(getTranslated('provide_embedded_link', context), context, sanckBarType: SnackBarType.warning);
        return false;
      }
    }

    return true;
  }

  bool validateAuctionInfo(
      BuildContext context, {
        required TextEditingController startPriceController,
        required TextEditingController minimumIncrementController,
        required TextEditingController maximumDecrementController,
        required List<TaxVatModel>? selectedVatTaxRate,
        required DateTime? startTime,
        required DateTime? endTime,
      }) {
    if (startPriceController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_start_price', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    final double? startPrice = double.tryParse(startPriceController.text.trim());
    if (startPrice == null || startPrice <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_start_price', context), context,sanckBarType: SnackBarType.warning);
      return false;
    }

    if (minimumIncrementController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_minimum_increment', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    final double? minIncrement = double.tryParse(minimumIncrementController.text.trim());
    if (minIncrement == null || minIncrement <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_minimum_increment', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (maximumDecrementController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_maximum_decrement', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    final double? maxDecrement = double.tryParse(maximumDecrementController.text.trim());
    if (maxDecrement == null || maxDecrement <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_maximum_decrement', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (selectedVatTaxRate == null || selectedVatTaxRate.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_add_your_product_tax', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (startTime == null) {
      showCustomSnackBarWidget(getTranslated('please_select_start_time', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (endTime == null) {
      showCustomSnackBarWidget(getTranslated('please_select_end_time', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (!endTime.isAfter(startTime)) {
      showCustomSnackBarWidget(getTranslated('end_time_must_be_after_start_time', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (startTime.isBefore(DateTime.now())) {
      showCustomSnackBarWidget(getTranslated('start_time_must_be_in_future', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    return true;
  }

  bool validateSeoInfo(
      BuildContext context, {
        required TextEditingController metaTitleController,
        required TextEditingController metaDescriptionController,
      }) {
    if (metaTitleController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_meta_title', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    if (metaDescriptionController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_meta_description', context), context, sanckBarType: SnackBarType.warning);
      return false;
    }

    return true;
  }


  /// Submit auction product to the API
  Future<ApiResponse?> addAuctionProduct(
     BuildContext context, {
     required List<TextEditingController> nameController,
     required List<TextEditingController> descriptionController,
     required String? selectedCategory,
     required String? selectedBrand,
     required String? selectedProductType,
     required TextEditingController shippingFeeController,
     required TextEditingController returnPolicyController,
     required TextEditingController videoLinkController,
     VideoUploadType videoUploadType = VideoUploadType.link,
     required TextEditingController startPriceController,
     required TextEditingController minimumIncrementController,
     required TextEditingController maximumDecrementController,
     required String? selectedItemCondition,
     required List<TaxVatModel>? selectedVatTax,
     required DateTime? startTime,
     required DateTime? endTime,
     required TextEditingController metaTitleController,
     required TextEditingController metaDescriptionController,
     required List<String> languageList,

    // New SEO fields: optional strings matching repository expectations
    String? metaIndex,
    String? metaNoFollow,
    String? metaNoImageIndex,
    String? metaNoArchive,
    String? metaNoSnippet,
    String? metaMaxSnippet,
    String? metaMaxSnippetValue,
    String? metaMaxVideoPreview,
    String? metaMaxVideoPreviewValue,
    String? metaMaxImagePreview,
    String? metaMaxImagePreviewValue,
    String? metaImage,
    bool update = false,
    int? auctionId,
    String? currentCurrencyCode,
    String? tags,
    bool isRelaunch = false,
   }) async {
     _isLoading = true;
     notifyListeners();

    final mediaController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);

    // Resolve category ID from name
    int categoryId = 0;
    if (selectedCategory != null && categoryController.categoryList != null) {
      final matched = categoryController.categoryList!.where((c) => c.name == selectedCategory).firstOrNull;
      if (matched != null) {
        categoryId = matched.id ?? 0;
      }
    }

    // Resolve brand ID from name
    int? brandId;
    if (selectedBrand != null && productController.brandList != null) {
      final matched = productController.brandList!.where((b) => b.name == selectedBrand).firstOrNull;
      if (matched != null) {
        brandId = matched.id;
      }
    }


    List<String> titleList = [];
    List<String> descriptionList = [];

    for(TextEditingController textEditingController in nameController) {
      titleList.add(textEditingController.text.trim());
    }
    for (var description in descriptionController) {
      descriptionList.add(description.text.trim());
    }

    // Build the model — videoType always reflects the selected radio button
    final String selectedVideoType = videoUploadType == VideoUploadType.link ? 'youtube_link' : 'custom_video';
    AddAuctionProductModel addAuctionModel = AddAuctionProductModel(
      titleList: titleList,
      descriptionList: descriptionList,
      languageList: languageList,
      videoUrl: videoLinkController.text.trim().isNotEmpty ? videoLinkController.text.trim() : null,
      videoType: selectedVideoType,
    );

    // Format dates
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String startTimeStr = formatter.format(startTime!);
    final String endTimeStr = formatter.format(endTime!);

    // Calculate duration in days
    final int duration = endTime.difference(startTime).inDays;

    // Tax IDs
    List<int>? taxIds;
    if (selectedVatTax != null && selectedVatTax.isNotEmpty) {
      taxIds = [];
      for (var tax in selectedVatTax) {
        if (tax.id != null) {
          taxIds.add(tax.id!);
        }
      }
    }



    // Thumbnail and images
    XFile? thumbnail = mediaController.thumbnailFile;
    List<XFile> images = mediaController.productImages;

    // For create operations thumbnail and images are required. For updates keep existing media if not provided.
    final bool isUpdateRequest = update || auctionId != null;
    if (!isUpdateRequest) {
      if (thumbnail == null) {
        showCustomSnackBarWidget(getTranslated('upload_thumbnail_image', context), context, sanckBarType: SnackBarType.warning);
        _isLoading = false;
        notifyListeners();
        return null;
      }

      if (images.isEmpty) {
        showCustomSnackBarWidget(getTranslated('upload_product_image', context), context, sanckBarType: SnackBarType.warning);
        _isLoading = false;
        notifyListeners();
        return null;
      }
    }

    // Customer video
    XFile? customerVideo;
    String? videoType = addAuctionModel.videoType;
    if (videoType == 'custom_video' && mediaController.pickedMediaFile != null) {
      customerVideo = mediaController.pickedMediaFile!.file;
    }

    // Prefer meta image file picked from media controller when available. This ensures the multipart uploader
    // receives a valid local file path instead of relying solely on a string stored earlier in the SEO controller.
    final String? metaImageToSend = mediaController.metaImageFile?.path ?? metaImage;

    ApiResponse? response;

    try {
      response = await addAuctionProductServiceInterface.addAuctionProduct(
        addAuctionProduct: addAuctionModel,
        categoryId: categoryId,
        brandId: brandId,
        productType: selectedProductType?.toLowerCase() ?? 'physical',
        itemCondition: selectedItemCondition?.trim().isNotEmpty == true ? selectedItemCondition!.trim() : '',
        entryFee: 0,
        startingPrice: double.tryParse(startPriceController.text.trim()) ?? 0,
        minimumIncrementAmount: double.tryParse(minimumIncrementController.text.trim()) ?? 0,
        maximumDecrementAmount: double.tryParse(maximumDecrementController.text.trim()) ?? 0,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: duration > 0 ? duration : 1,
        status: 1,
        shippingFee: double.tryParse(shippingFeeController.text.trim()) ?? 0,
        returnPolicy: returnPolicyController.text.trim(),
        thumbnail: thumbnail,
        images: images.isNotEmpty ? images : null,
        videoType: videoType,
        youtubeVideo: (videoType == 'youtube_link' || isUpdateRequest) && videoLinkController.text.trim().isNotEmpty ? videoLinkController.text.trim() : null,
        customerVideo: customerVideo,
        taxIds: taxIds,
        metaTitle: metaTitleController.text.trim().isNotEmpty ? metaTitleController.text.trim() : null,
        metaDescription: metaDescriptionController.text.trim().isNotEmpty ? metaDescriptionController.text.trim() : null,

        // Forward SEO fields received by controller
        metaIndex: metaIndex,
        metaNoFollow: metaNoFollow,
        metaNoImageIndex: metaNoImageIndex,
        metaNoArchive: metaNoArchive,
        metaNoSnippet: metaNoSnippet,
        metaMaxSnippet: metaMaxSnippet,
        metaMaxSnippetValue: metaMaxSnippetValue,
        metaMaxVideoPreview: metaMaxVideoPreview,
        metaMaxVideoPreviewValue: metaMaxVideoPreviewValue,
        metaMaxImagePreview: metaMaxImagePreview,
        metaMaxImagePreviewValue: metaMaxImagePreviewValue,
        metaImageFile: mediaController.metaImageFile,
        metaImage: metaImageToSend,
        update: update,
        auctionId: auctionId,
        retainedImages: isUpdateRequest ? mediaController.retainedImageNames : null,
        currentCurrencyCode: currentCurrencyCode,
        tags: tags,
        isRelaunch: isRelaunch,
      );

      if (response?.response != null && response!.response!.statusCode == 200) {
        dynamic responseData = response.response?.data;
        if (responseData is Map && responseData.containsKey('errors')) {
          List errors = responseData['errors'] ?? [];
          if (errors.isNotEmpty) {
            String errorMessage = errors[0]['message'] ?? 'Error occurred';
            _isLoading = false;
            notifyListeners();
            showCustomSnackBarWidget(errorMessage, Get.context!, isError: true, sanckBarType: SnackBarType.error);
            return response;
          }
        }
        _isLoading = false;
        notifyListeners();
        mediaController.reset();
        showCustomSnackBarWidget(getTranslated(isRelaunch ? 'auction_relaunched_successfully' : 'product_added_successfully', Get.context!), Get.context!, isError: false);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('product_add_failed', Get.context!), Get.context!, sanckBarType: SnackBarType.error);
    }

    return response;
  }



}
