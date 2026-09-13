import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/media_file_model.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/image_size_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_contoller.dart';

class AddAuctionProductMediaController extends ChangeNotifier {

  XFile? _thumbnailFile;
  XFile? get thumbnailFile => _thumbnailFile;

  XFile? _metaImageFile;
  XFile? get metaImageFile => _metaImageFile;

  String? _existingThumbnailUrl;
  String? get existingThumbnailUrl => _existingThumbnailUrl;

  String? _existingMetaImageUrl;
  String? get existingMetaImageUrl => _existingMetaImageUrl;

  MediaFileModel? _pickedMediaFile;
  MediaFileModel? get pickedMediaFile => _pickedMediaFile;
  bool _isPickingMedia = false;
  bool get isPickingMedia => _isPickingMedia;

  String? _existingCustomVideoFilename;
  String? get existingCustomVideoFilename => _existingCustomVideoFilename;

  void clearExistingCustomVideo() {
    _existingCustomVideoFilename = null;
    notifyListeners();
  }

  final List<String> _existingImageUrls = [];
  List<String> get existingImageUrls => List.unmodifiable(_existingImageUrls);

  final List<String> _existingImageKeys = [];
  bool _existingImagesModified = false;

  List<String>? get retainedImageNames {
    if (!_existingImagesModified) return null;
    return List.unmodifiable(_existingImageKeys);
  }

  Future<void> pickThumbnail() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );

    if (picked != null) {
      _thumbnailFile = picked;
      _existingThumbnailUrl = null;
      if ((_existingMetaImageUrl == null || (_existingMetaImageUrl?.isEmpty ?? true)) && _metaImageFile == null) {
        _metaImageFile = picked;
        try {
          final auctionController = Provider.of<AddAuctionProductController>(Get.context!, listen: false);
          auctionController.updateSeoFields(metaImage: picked.path);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  Future<void> pickMetaImage() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );

    if (picked != null) {
      _metaImageFile = picked;
      _existingMetaImageUrl = null;
      try {
        final auctionController = Provider.of<AddAuctionProductController>(Get.context!, listen: false);
        auctionController.updateSeoFields(metaImage: picked.path);
      } catch (_) {}
      notifyListeners();
    }
  }

  void removeThumbnail() {
    _thumbnailFile = null;
    // Keep existingThumbnailUrl as-is (user may want to keep existing), but if UI intends removal it can call clearExistingThumbnail
    notifyListeners();
  }

  void removeMetaImage() {
    _metaImageFile = null;
    try {
      final auctionController = Provider.of<AddAuctionProductController>(Get.context!, listen: false);
      if (_existingMetaImageUrl == null) auctionController.updateSeoFields(metaImage: '');
    } catch (_) {}
    notifyListeners();
  }

  void clearExistingThumbnail() {
    _existingThumbnailUrl = null;
    notifyListeners();
  }

  void clearExistingMetaImage() {
    _existingMetaImageUrl = null;
    try {
      final auctionController = Provider.of<AddAuctionProductController>(Get.context!, listen: false);
      auctionController.updateSeoFields(metaImage: '');
    } catch (_) {}
    notifyListeners();
  }

  final List<XFile> _productImages = [];
  List<XFile> get productImages => List.unmodifiable(_productImages);

  Future<void> pickProductImage() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );

    if (picked != null) {
      _productImages.add(picked);
      notifyListeners();
    }
  }

  void removeProductImage(int index) {
    if (index < 0 || index >= _productImages.length) return;
    _productImages.removeAt(index);
    notifyListeners();
  }

  void removeExistingImageAt(int index) {
    if (index < 0 || index >= _existingImageUrls.length) return;
    _existingImageUrls.removeAt(index);
    if (index < _existingImageKeys.length) _existingImageKeys.removeAt(index);
    _existingImagesModified = true;
    notifyListeners();
  }


  Future<void> pickSingleMedia() async {
    _isPickingMedia = true;
    notifyListeners();

    final configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: AppConstants.videoExtensions,
    );

    if (result == null || result.files.isEmpty) {
      _isPickingMedia = false;
      notifyListeners();
      return;
    }

    final PlatformFile file = result.files.first;
    final String extension = file.extension?.toLowerCase() ?? '';

    if (!AppConstants.videoExtensions.contains(extension)) {
      showCustomSnackBarWidget(getTranslated('invalid_file_type', Get.context!), Get.context!, sanckBarType: SnackBarType.error);
      _isPickingMedia = false;
      notifyListeners();
      return;
    }

    final double fileSizeMB = await ImageValidationHelper.getImageSizeFromXFile(file.xFile);
    final double maxSizeMB = (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile).toDouble();

    if (fileSizeMB > maxSizeMB) {
      showCustomSnackBarWidget('${getTranslated('maximum_file_size', Get.context!)} ${maxSizeMB}MB', Get.context!, sanckBarType: SnackBarType.warning);
      _isPickingMedia = false;
      notifyListeners();
      return;
    }

    final String? thumbnailPath = await _generateVideoThumbnail(file.path ?? '');
    if (thumbnailPath != null) {
      _pickedMediaFile = MediaFileModel(
        file: file.xFile,
        thumbnailPath: thumbnailPath,
        isVideo: true,
      );
    }

    _isPickingMedia = false;
    notifyListeners();
  }

  void removeMediaFile() {
    _pickedMediaFile = null;
    notifyListeners();
  }

  Future<String?> _generateVideoThumbnail(String filePath) async {
    final directory = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: filePath,
      thumbnailPath: directory.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      maxWidth: 200,
      quality: 1,
    );
    return thumbnailPath.path;
  }

  void reset() {
    _thumbnailFile = null;
    _productImages.clear();
    _pickedMediaFile = null;
    _existingImageUrls.clear();
    _existingImageKeys.clear();
    _existingImagesModified = false;
    _existingThumbnailUrl = null;
    _metaImageFile = null;
    _existingMetaImageUrl = null;
    _existingCustomVideoFilename = null;
    notifyListeners();
  }


  void loadFromAuctionProduct(AuctionProduct? product, {bool isUpdate = true}) {
    _thumbnailFile = null;
    _productImages.clear();
    _pickedMediaFile = null;
    _existingImageUrls.clear();
    _existingThumbnailUrl = null;
    _metaImageFile = null;
    _existingMetaImageUrl = null;
    _existingCustomVideoFilename = null;

    if (product == null) {
      if (isUpdate) notifyListeners();
      return;
    }

    if (product.thumbnail != null && product.thumbnail!.isNotEmpty) {
      if (_thumbnailFile == null) {
        _existingThumbnailUrl = product.thumbnailFullUrl?.path ?? '';
      }
    }

    try {
      final seoPath = product.seoInfo?.imageFullUrl?.path ?? '';
      final directPath = product.metaImageFullUrl?.path ?? '';
      final metaPath = seoPath.isNotEmpty ? seoPath : directPath;
      if (metaPath.isNotEmpty && _metaImageFile == null) {
        _existingMetaImageUrl = metaPath;
      }
    } catch (_) {}

    if (product.customVideoUrl != null && product.customVideoUrl!.isNotEmpty) {
      _existingCustomVideoFilename = product.customVideoUrl;
    }

    _existingImageUrls.clear();
    _existingImageKeys.clear();
    _existingImagesModified = false;
    final rawImages = product.additionalImageFullUrls;
    if (rawImages != null && rawImages.isNotEmpty) {
      try {
        for (var item in rawImages) {
          if (item.path != null && item.path!.isNotEmpty) {
            _existingImageUrls.add(item.path!);
            _existingImageKeys.add(item.key ?? '');
          }
        }
      } catch (_) {}
    }

    if(isUpdate) {
      notifyListeners();
    }

  }
}