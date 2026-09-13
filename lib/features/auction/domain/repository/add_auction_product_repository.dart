import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/add_auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/repository/add_auction_product_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';


class AddAuctionProductRepository implements AddAuctionProductRepositoryInterface {
  final DioClient? dioClient;
  AddAuctionProductRepository({required this.dioClient});

  void _setRequestHeaders(String? token) {
    dioClient!.dio!.options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token ?? Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}'
    };
  }

  @override
  Future<ApiResponse> addAuctionProduct({
    required AddAuctionProductModel addAuctionProduct,
    required int categoryId,
    int? brandId,
    required String productType,
    required String itemCondition,
    required double entryFee,
    required double startingPrice,
    required double minimumIncrementAmount,
    required double maximumDecrementAmount,
    required String startTime,
    required String endTime,
    int? duration,
    required int status,
    required double shippingFee,
    String? returnPolicy,
    XFile? thumbnail,
    List<XFile>? images,
    String? videoType,
    String? youtubeVideo,
    XFile? customerVideo,
    List<int>? taxIds,
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
    XFile? metaImageFile,
    String? metaImage,
    bool update = false,
    int? auctionId,
    List<String>? retainedImages,
    String? currentCurrencyCode,
    String? tags,
    bool isRelaunch = false,
  }) async {

    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      // Build the request data map
      Map<String, dynamic> fields = {};

      // Basic auction product fields
      fields['name'] = jsonEncode(addAuctionProduct.titleList);
      fields['lang'] = jsonEncode(addAuctionProduct.languageList);
      fields['description'] = jsonEncode(addAuctionProduct.descriptionList);
      fields['category_id'] = categoryId;
      if (brandId != null) {
        fields['brand_id'] = brandId;
      }
      fields['product_type'] = productType;
      fields['item_condition'] = itemCondition;
      fields['entry_fee'] = entryFee;
      fields['starting_price'] = startingPrice;
      fields['minimum_increment_amount'] = minimumIncrementAmount;
      fields['maximum_decrement_amount'] = maximumDecrementAmount;
      fields['start_time'] = startTime;
      fields['end_time'] = endTime;
      if (duration != null) {
        fields['duration'] = duration;
      }
      fields['status'] = status;
      fields['shipping_fee'] = shippingFee;
      if (returnPolicy != null && returnPolicy.isNotEmpty) {
        fields['return_policy'] = returnPolicy;
      }

      // Video fields — always send video_provider based on selected type
      if (videoType != null && videoType.isNotEmpty) {
        fields['video_provider'] = videoType;
      }
      // Send youtube_video_url whenever a value exists (preserved during updates even if provider is custom_video)
      if (youtubeVideo != null && youtubeVideo.isNotEmpty) {
        fields['youtube_video_url'] = youtubeVideo;
      }

      // Tax
      if (taxIds != null && taxIds.isNotEmpty) {
        fields['tax_ids'] = jsonEncode(taxIds);
      }

      // Meta / SEO fields
      if (metaTitle != null) fields['meta_title'] = metaTitle;
      if (metaDescription != null) fields['meta_description'] = metaDescription;
      if (metaIndex != null) fields['meta_index'] = metaIndex;
      if (metaNoFollow != null) fields['meta_no_follow'] = metaNoFollow;
      if (metaNoImageIndex != null) fields['meta_no_image_index'] = metaNoImageIndex;
      if (metaNoArchive != null) fields['meta_no_archive'] = metaNoArchive;
      if (metaNoSnippet != null) fields['meta_no_snippet'] = metaNoSnippet;
      if (metaMaxSnippet != null) fields['meta_max_snippet'] = metaMaxSnippet;
      if (metaMaxSnippetValue != null) fields['meta_max_snippet_value'] = metaMaxSnippetValue;
      if (metaMaxVideoPreview != null) fields['meta_max_video_preview'] = metaMaxVideoPreview;
      if (metaMaxVideoPreviewValue != null) fields['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
      if (metaMaxImagePreview != null) fields['meta_max_image_preview'] = metaMaxImagePreview;
      if (metaMaxImagePreviewValue != null) fields['meta_max_image_preview_value'] = metaMaxImagePreviewValue;
      if (currentCurrencyCode != null) fields['current_currency_code'] = currentCurrencyCode;

      // Search tags — comma-separated string (e.g. "vintage, watch, collector")
      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags;
      }

      final bool isUpdate = update || auctionId != null;
      if (isUpdate || isRelaunch) {
        fields['_method'] = 'put';
        fields['id'] = auctionId;
      }

      if (kDebugMode) {
        print('---Fields for add/update Auction--> $fields');
      }

      List<MultipartWithKey> multipartFiles = [];

      if (thumbnail != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'thumbnail',
          multipartFile: MultipartFile.fromBytes(
            await thumbnail.readAsBytes(),
            filename: basename(thumbnail.path),
          ),
        ));
      }

      if (images != null && images.isNotEmpty) {
        final List<MultipartFile> imageMultiparts = [];
        for (int i = 0; i < images.length; i++) {
          final bytes = await images[i].readAsBytes();
          imageMultiparts.add(MultipartFile.fromBytes(bytes, filename: basename(images[i].path)));
        }
        fields['images[]'] = imageMultiparts;
      } else {
      }

      if (videoType == 'custom_video' && customerVideo != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'custom_video_url',
          multipartFile: MultipartFile.fromBytes(
            await customerVideo.readAsBytes(),
            filename: basename(customerVideo.path),
          ),
        ));
      }

      if (metaImageFile != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'meta_image',
          multipartFile: MultipartFile.fromBytes(
            await metaImageFile.readAsBytes(),
            filename: basename(metaImageFile.path),
          ),
        ));
      }

      if (isUpdate && retainedImages != null) {
        if (retainedImages.isEmpty) {
          fields['retained_images[]'] = '';
        } else {
          fields['retained_images[]'] = retainedImages;
        }
      }

      // Choose endpoint: relaunch, update, or add
      final String url = isRelaunch && auctionId != null
          ? '${AppConstants.baseUrl}${AppConstants.relaunchAuctionProductUri}$auctionId'
          : isUpdate
              ? '${AppConstants.baseUrl}${AppConstants.updateAuctionProductUri}/$auctionId'
              : '${AppConstants.baseUrl}${AppConstants.addAuctionProductUri}';

      if (kDebugMode) {
        print('===Add/Update Auction Request URL==> $url');
      }

      Response response = await dioClient!.postMultipart(
        url,
        data: fields,
        files: multipartFiles,
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }
}
