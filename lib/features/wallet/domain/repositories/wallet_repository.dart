import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class WalletRepository implements WalletRepositoryInterface {
  final DioClient dioClient;
  WalletRepository({required this.dioClient});

  @override
  Future<ApiResponse> getSellerBalance({int limit = 10}) async {
    try {
      final response =
          await dioClient.get('${AppConstants.sellerBalanceUri}?limit=$limit');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSellerDashboardOverview() async {
    try {
      final response =
          await dioClient.get(AppConstants.sellerDashboardOverviewUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> payOperatingBalance(
      {required String amount,
      required String paymentMethod,
      String walletTarget = 'operating'}) async {
    try {
      final response =
          await dioClient.post(AppConstants.sellerBalancePayUri, data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_platform': 'vendor_app',
        'wallet_target': walletTarget,
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> submitOfflineBalancePayment(
      {required String amount,
      required int methodId,
      required Map<String, String> methodInformations,
      required XFile paymentProof,
      String? paymentNote,
      String walletTarget = 'operating'}) async {
    try {
      final proof = MultipartFile.fromBytes(await paymentProof.readAsBytes(),
          filename: paymentProof.name);
      final response = await dioClient
          .postMultipart(AppConstants.sellerBalanceOfflinePaymentUri, data: {
        'amount': amount,
        'method_id': methodId,
        'method_informations': jsonEncode(methodInformations),
        'payment_note': paymentNote ?? '',
        'wallet_target': walletTarget,
      }, files: [
        MultipartWithKey(key: 'payment_proof', multipartFile: proof)
      ]);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getDynamicWithDrawMethod() async {
    try {
      final response = await dioClient.get(AppConstants.dynamicWithdrawMethod);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> withdrawBalance(List<String?> typeKey,
      List<String> typeValue, int? id, String balance) async {
    try {
      Map<String?, String> fields = {};

      for (var i = 0; i < typeKey.length; i++) {
        fields.addAll(<String?, String>{typeKey[i]: typeValue[i]});
      }
      fields.addAll(<String, String>{
        'amount': balance,
        'withdraw_method_id': id.toString()
      });
      if (kDebugMode) {
        print('--here is type key =$id');
      }

      Response response =
          await dioClient.post(AppConstants.balanceWithdraw, data: fields);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateWithdrawRequest(
      List<String?> typeKey,
      List<String> typeValue,
      int? methodId,
      String balance,
      int requestId) async {
    try {
      Map<String?, String> fields = {};

      for (var i = 0; i < typeKey.length; i++) {
        fields.addAll(<String?, String>{typeKey[i]: typeValue[i]});
      }
      fields.addAll(<String, String>{
        'amount': balance,
        'withdraw_method_id': methodId.toString(),
        'withdraw_request_id': requestId.toString(),
      });

      Response response = await dioClient
          .post(AppConstants.balanceWithdrawUpdate, data: fields);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> closeWithdrawRequest(int? id, String balance) async {
    try {
      Map<String?, String> fields = {};
      fields.addAll(<String, String>{
        '_method': 'delete',
        'amount': balance,
        'id': id.toString()
      });
      if (kDebugMode) {
        print('--here is type key =$id');
      }

      Response response =
          await dioClient.post(AppConstants.cancelBalanceRequest, data: fields);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getPaymentInfoList() async {
    try {
      final response = await dioClient.get(AppConstants.paymentInformationList);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
