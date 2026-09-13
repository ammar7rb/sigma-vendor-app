import 'dart:convert';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/order/domain/repositories/order_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_list_filter_model.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class OrderRepository implements OrderRepositoryInterface {
  final DioClient? dioClient;
  OrderRepository({required this.dioClient});

  @override
  Future<ApiResponse> getOrderList(
      int offset, String status, OrderListFilterModel? filter) async {
    try {
      final queryParameters = {
        'limit': 10,
        'offset': offset,
        'status': status,
        ...?filter?.toQueryParams(),
      };

      if (status == 'all' &&
          filter?.orderStatus != null &&
          filter!.orderStatus.isNotEmpty) {
        queryParameters.remove('order_status');
        queryParameters.remove('status');
        queryParameters
            .addAll({'order_current_status': jsonEncode(filter.orderStatus)});
      } else if (status == 'all') {
        queryParameters.remove('order_status');
        queryParameters.remove('order_current_status');
      } else if (status == 'active') {
        queryParameters.addAll({
          'order_current_status': jsonEncode(
              ['pending', 'confirmed', 'processing', 'out_for_delivery'])
        });
      } else {
        queryParameters.addAll({
          'order_current_status': jsonEncode([status])
        });
      }

      final response = status == 'insurance_pending'
          ? await dioClient!.get(AppConstants.insurancePendingOrdersUri,
              queryParameters: {'limit': 10, 'offset': offset})
          : await dioClient!
              .post(AppConstants.orderListUri, data: queryParameters);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> orderAddressEdit({
    String? orderID,
    String? addressType,
    String? contactPersonName,
    String? phone,
    String? city,
    String? zip,
    String? address,
    String? email,
    String? latitude,
    String? longitude,
  }) async {
    try {
      final response =
          await dioClient!.post(AppConstants.orderAddressEdit, data: {
        "order_id": orderID,
        "contact_person_name": contactPersonName,
        "phone": phone,
        "city": city,
        "zip": zip,
        "email": email,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "address_type": addressType,
      });
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
