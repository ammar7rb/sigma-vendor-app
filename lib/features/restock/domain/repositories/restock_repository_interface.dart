
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class RestockRepositoryInterface<T> extends RepositoryInterface{

  Future<dynamic> getRestockProductList(Map<dynamic, dynamic> data);

  Future<dynamic> getRestockBrandList();

  Future<dynamic> deleteRestockItem(int id);

  Future<dynamic> deleteRestockProduct(String? type, String? id);

  Future<ApiResponse> updateRestockProductQuantity(int? productId,int currentStock, List <Variation> variation);

  Future<ApiResponse> updateProductQuantity(int? productId,int currentStock, List <Variation> variation);

}