import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/repositories/seller_package_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class SellerPackageRepository implements SellerPackageRepositoryInterface {
  final DioClient dioClient;

  SellerPackageRepository({required this.dioClient});

  @override
  Future<ApiResponse> getOverview() async {
    try {
      // The endpoint returns plans and the current package subscription.
      final response = await dioClient.get(AppConstants.sellerPackagesUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getPerformance(int subscriptionId) async {
    try {
      return ApiResponse.withSuccess(await dioClient.get(AppConstants.sellerPackagePerformanceUri(subscriptionId)));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> cancelPackage({required int subscriptionId, required String reason}) async {
    try {
      return ApiResponse.withSuccess(await dioClient.post(AppConstants.sellerPackageCancelUri(subscriptionId), data: {'reason': reason}));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> payPackage({required int packageId, required String paymentMethod}) async {
    try {
      // vendor_app tells the payment system which client originated the secure redirect.
      final response = await dioClient.post(AppConstants.sellerPackagePayUri, data: {
        'package_id': packageId,
        'payment_method': paymentMethod,
        'payment_platform': 'vendor_app',
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> payPackageFromOperatingBalance({required int packageId}) async {
    try {
      final response = await dioClient.post(AppConstants.sellerPackagePayUri, data: {
        'package_id': packageId,
        'payment_method': 'operating_balance',
        'payment_platform': 'vendor_app',
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> submitOfflinePayment({
    required int packageId, required int methodId, required Map<String, String> methodInformations,
    required XFile paymentProof, String? paymentNote,
  }) async {
    try {
      final proof = MultipartFile.fromBytes(await paymentProof.readAsBytes(), filename: paymentProof.name);
      // The proof is a real multipart image; text data stays in method_informations as JSON.
      final response = await dioClient.postMultipart(AppConstants.sellerPackageOfflinePaymentUri, data: {
        'package_id': packageId,
        'method_id': methodId,
        'method_informations': jsonEncode(methodInformations),
        'payment_note': paymentNote ?? '',
      }, files: [MultipartWithKey(key: 'payment_proof', multipartFile: proof)]);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}
