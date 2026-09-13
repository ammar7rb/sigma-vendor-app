import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/ai/domain/models/image_response_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_description_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_setup_auto_fill_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_seo_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_general_setup_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_info_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_shipping_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_ai_titile_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auctionAi/auction_title_suggestions_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/auction_ai_service_interface.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/helper/product_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import '../../../main.dart';

class AuctionAiController extends ChangeNotifier {
  final AuctionAiServiceInterface auctionAiServiceInterface;

  AuctionAiController({required this.auctionAiServiceInterface});

  bool _titleLoading = false;
  bool get titleLoading => _titleLoading;

  bool _descLoading = false;
  bool get descLoading => _descLoading;

  bool _generalSetupLoading = false;
  bool get generalSetupLoading => _generalSetupLoading;

  bool _shippingSetupLoading = false;
  bool get shippingSetupLoading => _shippingSetupLoading;

  bool _auctionInfoLoading = false;
  bool get auctionInfoLoading => _auctionInfoLoading;

  bool _metaSeoLoading = false;
  bool get metaSeoLoading => _metaSeoLoading;

  final bool _auctionBasicSetupLoading = false;
  bool get auctionBasicSetupLoading => _auctionBasicSetupLoading;

  bool _addProductMetaScreenLoading = false;
  bool get addProductMetaScreenLoading => _addProductMetaScreenLoading;

  bool _requestTypeImage = false;
  bool get requestTypeImage => _requestTypeImage;

  bool _autoFillAuctionInfoPending = false;
  bool get autoFillAuctionInfoPending => _autoFillAuctionInfoPending;

  void consumeAutoFillAuctionInfoPending() {
    _autoFillAuctionInfoPending = false;
  }

  int genLimit = 0;

  AuctionTitleModel? _titleModel;
  AuctionTitleModel? get titleModel => _titleModel;

  AuctionDescriptionModel? _descriptionModel;
  AuctionDescriptionModel? get descriptionModel => _descriptionModel;

  AuctionGeneralSetupModel? _generalSetupModel;
  AuctionGeneralSetupModel? get generalSetupModel => _generalSetupModel;

  AuctionShippingSetupModel? _shippingSetupModel;
  AuctionShippingSetupModel? get shippingSetupModel => _shippingSetupModel;

  AuctionInfoModel? _auctionInfoModel;
  AuctionInfoModel? get auctionInfoModel => _auctionInfoModel;

  AuctionSEOModel? _metaSeoInfo;
  AuctionSEOModel? get metaSeoInfo => _metaSeoInfo;

  Future<void> generateAuctionTitle({
    required String title,
    required TextEditingController nameController,
    required String langCode,
  }) async {
    if (title.trim().isEmpty) return;

    _titleLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateAuctionTitle(
      title: title,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _titleModel = AuctionTitleModel.fromJson(apiResponse.response?.data);
      if (_titleModel?.data != null && _titleModel!.data!.data!.isNotEmpty) {
        nameController.text = _titleModel?.data?.data ?? '';
      }
    } else {
      _titleModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _titleLoading = false;
    notifyListeners();
  }

  Future<void> generateAuctionDescription({
    required String title,
    required TextEditingController descriptionController,
    required String langCode,
  }) async {
    if (title.trim().isEmpty) return;

    _descLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateAuctionDescription(
      title: title,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _descriptionModel = AuctionDescriptionModel.fromJson(apiResponse.response?.data);
      String plain = ProductHelper.htmlToPlainText(_descriptionModel?.data?.data ?? '');
      if (plain.isNotEmpty) {
        _descriptionModel?.data?.data = plain;
      }
      if (_descriptionModel?.data != null && _descriptionModel!.data!.data!.isNotEmpty) {
        descriptionController.text = _descriptionModel!.data!.data!;
      }
    } else {
      _descriptionModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _descLoading = false;
    notifyListeners();
  }

  Future<void> generateGeneralSetup({
    required String title,
    required String description,
    required String langCode,
  }) async {
    _generalSetupLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateGeneralData(
      title: title,
      description: description,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _generalSetupModel = AuctionGeneralSetupModel.fromJson(apiResponse.response?.data);
    } else {
      _generalSetupModel = null;
      ApiChecker.checkApi(apiResponse);
    }
    generateLimitCheck();
    _generalSetupLoading = false;
    notifyListeners();
  }

  Future<void> generateMetaSeoSetup({
    required String title,
    required String description,
    required TextEditingController seoTitleController,
    required TextEditingController seoDescriptionController,
    bool formInit = false,
  }) async {
    _metaSeoLoading = true;
    if (formInit) {
      _addProductMetaScreenLoading = true;
    }
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateMetaSeoData(
      title: title,
      description: description,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _metaSeoInfo = AuctionSEOModel.fromJson(apiResponse.response?.data);
      final seoData = _metaSeoInfo?.data?.data;
      if (seoData?.metaTitle != null && seoData!.metaTitle!.isNotEmpty) {
        seoTitleController.text = seoData.metaTitle!;
      }
      if (seoData?.metaDescription != null && seoData!.metaDescription!.isNotEmpty) {
        seoDescriptionController.text = seoData.metaDescription!;
      }
    } else {
      _metaSeoInfo = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _metaSeoLoading = false;
    if (formInit) {
      _addProductMetaScreenLoading = false;
    }
    notifyListeners();
  }

  Future<void> generateShippingPolicySetup({
    required String title,
    required String description,
    required String langCode,
  }) async {
    _shippingSetupLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateShippingData(
      title: title,
      description: description,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _shippingSetupModel = AuctionShippingSetupModel.fromJson(apiResponse.response?.data);
    } else {
      _shippingSetupModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _shippingSetupLoading = false;
    notifyListeners();
  }

  Future<void> generateAuctionInfoSetup({
    required String title,
    required String description,
    required String langCode,
  }) async {
    _auctionInfoLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionAiServiceInterface.generateAuctionInfoData(
      title: title,
      description: description,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _auctionInfoModel = AuctionInfoModel.fromJson(apiResponse.response?.data);
    } else {
      _auctionInfoModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _auctionInfoLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> generateLimitCheck() async {
    ApiResponse apiResponse = await auctionAiServiceInterface.generateLimitCheck();
    if (apiResponse.response?.statusCode == 200 && apiResponse.response?.data['message'] == 'Success') {
      genLimit = apiResponse.response?.data['data'] ?? genLimit;
    }
    notifyListeners();
    return apiResponse;
  }

  void setRequestType(bool type, {bool willUpdate = true}) {
    _requestTypeImage = type;
    if (willUpdate) {
      notifyListeners();
    }
  }

  // ── Image analysis ────────────────────────────────────────────────────────

  bool _imageLoading = false;
  bool get imageLoading => _imageLoading;

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  void pickImage() async {
    try {
      _pickedLogo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: AppConstants.imageQuality,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('----auction pickImage error---$e-----');
    }
  }

  void removeImage({bool willUpdate = true}) {
    _pickedLogo = null;
    // willUpdate:false lets callers reset state from initState without
    // notifying during the build phase. Notifying mid-build marks the
    // provider dirty inside a build it's already past — caught in debug,
    // but in release it corrupts the notification pipeline and freezes the
    // sheet (later pickImage/AI notifies get dropped into a janky frame).
    if (willUpdate) {
      notifyListeners();
    }
  }

  Future<XFile> compressImageFile({required File imageFile, int quality = 10}) async {
    final DateTime time = DateTime.now();
    final String targetPath = path.join(
      Directory.systemTemp.path,
      'auction_img_${time.millisecondsSinceEpoch}.jpg',
    );
    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      imageFile.path, targetPath,
      quality: quality,
      minHeight: 800, minWidth: 800,
    );
    if (compressed == null) throw 'Image compression failed. Please try again.';
    return compressed;
  }

  Future<ImageResponseModel?> generateAndSetDataFromImage({
    required XFile image,
    List<Language>? languageList,
    TabController? tabController,
    List<TextEditingController>? nameControllerList,
  }) async {
    _imageLoading = true;
    notifyListeners();

    late final ApiResponse apiResponse;
    try {
      final XFile compressed = await compressImageFile(imageFile: File(image.path));
      apiResponse = await auctionAiServiceInterface.generateFromImage(image: compressed);
    } catch (e) {
      _imageLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(
        getTranslated('image_compression_failed', Get.context!) ?? e.toString(),
        Get.context!,
        sanckBarType: SnackBarType.error,
      );
      return null;
    }

    generateLimitCheck();
    _imageLoading = false;
    notifyListeners();

    if (apiResponse.response?.statusCode == 200) {
      final ImageResponseModel model = ImageResponseModel.fromJson(apiResponse.response?.data);
      if (model.data?.data != null && (model.data!.data?.isNotEmpty ?? false)) {
        nameControllerList?[tabController?.index ?? 0].text = model.data!.data!;
        _requestTypeImage = true;
        notifyListeners();
      }
      return model;
    } else {
      Navigator.of(Get.context!).pop();
      Navigator.of(Get.context!).pop();
      await Future.delayed(const Duration(milliseconds: 500));
      ApiChecker.checkApi(apiResponse);
      if (apiResponse.response?.statusCode == 403) {
        showCustomSnackBarWidget(
          apiResponse.response?.data['message'],
          Get.context!,
          sanckBarType: SnackBarType.error,
        );
      }
      return null;
    }
  }

  // ── Setup auto-fill ───────────────────────────────────────────────────────

  bool _setupAutoFillLoading = false;
  bool get setupAutoFillLoading => _setupAutoFillLoading;

  AuctionSetupAutoFillModel? _setupAutoFillModel;
  AuctionSetupAutoFillModel? get setupAutoFillModel => _setupAutoFillModel;

  Future<AuctionSetupAutoFillModel?> generateSetupAutoFill({
    required String name,
    required String langCode,
    required List<TextEditingController> nameControllerList,
    required List<TextEditingController> descriptionControllerList,
    required TabController? tabController,
  }) async {
    if (name.trim().isEmpty) return null;

    _setupAutoFillLoading = true;
    notifyListeners();

    final ApiResponse apiResponse = await auctionAiServiceInterface.generateSetupAutoFill(
      name: name,
      langCode: langCode,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _setupAutoFillModel = AuctionSetupAutoFillModel.fromJson(apiResponse.response?.data);
      final int index = tabController?.index ?? 0;
      if (_setupAutoFillModel?.data?.name != null && _setupAutoFillModel!.data!.name!.isNotEmpty) {
        nameControllerList[index].text = _setupAutoFillModel!.data!.name!;
      }
      if (_setupAutoFillModel?.data?.description != null && _setupAutoFillModel!.data!.description!.isNotEmpty) {
        final String plain = ProductHelper.htmlToPlainText(_setupAutoFillModel!.data!.description!);
        descriptionControllerList[index].text = plain.isNotEmpty ? plain : _setupAutoFillModel!.data!.description!;
      }
    } else {
      _setupAutoFillModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _setupAutoFillLoading = false;
    notifyListeners();
    return _setupAutoFillModel;
  }


  // ── Title suggestions ─────────────────────────────────────────────────────

  bool _titleSuggestionsLoading = false;
  bool get titleSuggestionsLoading => _titleSuggestionsLoading;

  List<String> _titleSuggestions = [];
  List<String> get titleSuggestions => _titleSuggestions;

  AuctionTitleSuggestionsModel? _titleSuggestionsModel;

  void clearTitleSuggestions() {
    _titleSuggestions = [];
    notifyListeners();
  }

  Future<List<String>> generateTitleSuggestions({required List<String> keywords}) async {
    if (keywords.isEmpty) return [];

    _titleSuggestionsLoading = true;
    notifyListeners();

    final ApiResponse apiResponse = await auctionAiServiceInterface.generateTitleSuggestions(keywords: keywords);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _titleSuggestionsModel = AuctionTitleSuggestionsModel.fromJson(apiResponse.response?.data);
      _titleSuggestions = _titleSuggestionsModel?.data?.data?.titles ?? [];
    } else {
      _titleSuggestions = [];
      ApiChecker.checkApi(apiResponse);
    }

    generateLimitCheck();
    _titleSuggestionsLoading = false;
    notifyListeners();
    return _titleSuggestions;
  }

  Future<void> generateAuctionPageSetupFromImage({
    required String title,
    required String langCode,
    required List<TextEditingController> nameControllerList,
    required List<TextEditingController> descriptionControllerList,
    required TabController? tabController,
    VoidCallback? onResultsReady,
  }) async {
    final int index = tabController?.index ?? 0;

    await generateAuctionDescription(
      title: title,
      descriptionController: descriptionControllerList[index],
      langCode: langCode,
    );
    final String description = descriptionControllerList[index].text.trim();

    await generateGeneralSetup(
      title: title,
      description: description,
      langCode: langCode,
    );

    await generateShippingPolicySetup(
      title: title,
      description: description,
      langCode: langCode,
    );

    onResultsReady?.call();

    _autoFillAuctionInfoPending = true;

    showCustomSnackBarWidget(
      getTranslated('tap_next_to_automatically_generate', Get.context!) ?? '',
      Get.context!,
      sanckBarType: SnackBarType.warning,
    );
  }
}
