import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/repository/auction_ai_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class AuctionAiRepository implements AuctionAiRepositoryInterface {
  final DioClient? dioClient;

  AuctionAiRepository({required this.dioClient});

  @override
  Future<ApiResponse?> generateAuctionTitle({
    required String title,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionTitleAutoFill,
        data: {
          'name': title,
          'langCode': langCode,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateAuctionDescription({
    required String title,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionDescriptionAutoFill,
        data: {
          'name': title,
          'langCode': langCode,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionGeneralSetupAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionShippingPolicyAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateMetaSeoData({
    required String title,
    required String description,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionSeoSectionAutoFill,
        data: {
          'name': title,
          'description': description,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionInfoAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateLimitCheck() async {
    try {
      final response = await dioClient?.get(AppConstants.generateLimitCheck);
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateFromImage({required XFile image}) async {
    try {
      MultipartFile multiPartFile = MultipartFile.fromBytes(
        await image.readAsBytes(),
        filename: image.name,
      );
      final response = await dioClient?.postMultipart(
        AppConstants.auctionAnalyzeImageAutoFill,
        data: {},
        files: [MultipartWithKey(key: 'image', multipartFile: multiPartFile)],
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateSetupAutoFill({
    required String name,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionSetupAutoFill,
        data: {'name': name, 'langCode': langCode},
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateTitleSuggestions({required List<String> keywords}) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionGenerateTitleSuggestions,
        data: {'keywords': keywords},
      );
      return ApiResponse.withSuccess(response!);
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
