import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class OrderEditRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    required String orderId,
  });


  Future<ApiResponse> editOrderSubmit(Map<String, dynamic> data);

  Future<ApiResponse> switchToCod(int orderId);

  Future<ApiResponse> editOrderValidation(Map<String, dynamic> data);


}
