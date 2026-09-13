import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';

abstract class OrderEditServiceInterface {



  Future<dynamic> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    required String orderId,
  });


  Future<dynamic> editOrderSubmit({
    required Map<String, dynamic> data,
  });

  Future<ApiResponse> switchToCod(int orderId);

  Future<dynamic> editOrderValidation({
    required Map<String, dynamic> data,
  });

}