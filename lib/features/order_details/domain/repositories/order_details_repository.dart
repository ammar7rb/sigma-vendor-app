import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_setup_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/repositories/order_details_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class OrderDetailsRepository implements OrderDetailsRepositoryInterface {
  final DioClient? dioClient;
  OrderDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponse> getOrderStatusList(String type) async {
    try {
      List<String> addressTypeList = [];
      if (type == 'inhouse_shipping') {
        addressTypeList = ['pending', 'confirmed', 'processing'];
      } else {
        addressTypeList = [
          'pending',
          'confirmed',
          'processing',
          'out_for_delivery',
          'delivered',
          'returned',
          'failed',
          'canceled',
        ];
      }

      Response response = Response(
          requestOptions: RequestOptions(path: ''),
          data: addressTypeList,
          statusCode: 200);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getOrderDetails(String orderID) async {
    try {
      final response =
          await dioClient!.get('${AppConstants.orderDetails}$orderID');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSellerOrderInsurance(String orderID) async {
    try {
      final response = await dioClient!.get(
          '${AppConstants.orderDetails}$orderID${AppConstants.sellerOrderInsuranceSuffix}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> paySellerOrderInsurance(
      String orderID, String paymentMethod) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.orderDetails}$orderID${AppConstants.sellerOrderInsuranceSuffix}/pay',
        data: {'payment_method': paymentMethod},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> submitSellerOrderInsuranceOffline(
      String orderID, String methodId, String proofPath, String note) async {
    try {
      final form = FormData.fromMap({
        'method_id': methodId,
        'payment_note': note,
        'payment_proof': await MultipartFile.fromFile(proofPath,
            filename: basename(proofPath)),
      });
      final response = await dioClient!.post(
        '${AppConstants.orderDetails}$orderID${AppConstants.sellerOrderInsuranceSuffix}/offline-payment',
        data: form,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> respondToShipping(
      String orderID, String decision, String reason) async {
    try {
      return ApiResponse.withSuccess(await dioClient!.post(
          '${AppConstants.orderDetails}$orderID/shipping-response',
          data: {'decision': decision, 'reason': reason}));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getShippingProofFile(String orderID, int proofId) async {
    try {
      return ApiResponse.withSuccess(await dioClient!.get(
          '${AppConstants.orderDetails}$orderID/shipping-proofs/$proofId/download',
          options: Options(responseType: ResponseType.bytes)));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getShippingProofs(String orderID) async {
    try {
      final response = await dioClient!
          .get('${AppConstants.orderDetails}$orderID/shipping-proofs');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> submitShippingProof(
      String orderID, String status, String proofPath, String note) async {
    try {
      final form = FormData.fromMap({
        'shipping_status': status,
        'note': note,
        'proof': await MultipartFile.fromFile(proofPath,
            filename: basename(proofPath)),
      });
      final response = await dioClient!.post(
          '${AppConstants.orderDetails}$orderID/shipping-proofs',
          data: form);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> uploadAfterSellDigitalProduct(
      File? filePath, String token, String orderId) async {
    http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${AppConstants.baseUrl}${AppConstants.digitalProductUploadAfterSell}'));
    request.headers.addAll(<String, String>{'Authorization': 'Bearer $token'});
    if (kDebugMode) {
      print('Here is ===>$filePath');
    }
    if (filePath != null) {
      Uint8List list = await filePath.readAsBytes();
      var part = http.MultipartFile('digital_file_after_sell',
          filePath.readAsBytes().asStream(), list.length,
          filename: basename(filePath.path));
      request.files.add(part);
    }

    Map<String, String> fields = {};
    fields.addAll(<String, String>{'order_id': orderId, '_method': 'put'});

    request.fields.addAll(fields);
    if (kDebugMode) {
      print('=====> ${request.url.path}\n${request.fields}');
    }

    http.StreamedResponse response = await request.send();
    var res = await http.Response.fromStream(response);
    if (kDebugMode) {
      print('=====Response body is here==>${res.body}');
    }

    try {
      return ApiResponse.withSuccess(Response(
          statusCode: response.statusCode,
          requestOptions: RequestOptions(path: ''),
          statusMessage: response.reasonPhrase,
          data: res.body));
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

  @override
  Future<HttpClientResponse> productDownload(String? url) async {
    HttpClient client = HttpClient();
    final response = await client.getUrl(Uri.parse(url!)).then(
      (HttpClientRequest request) {
        return request.close();
      },
    );
    return response;
  }

  @override
  Future<ApiResponse> setUpOrder(OrderSetupModel orderSetUpModel) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.setUpOrder,
        data: orderSetUpModel.toJson(),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future getOrderInvoice(String orderID) async {
    try {
      final response =
          await dioClient!.get('${AppConstants.generateInvoice}$orderID');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
