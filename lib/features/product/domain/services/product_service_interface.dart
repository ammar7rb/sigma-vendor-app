import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';

abstract class ProductServiceInterface {
  Future<dynamic> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    FilterModel? filterModel,
  });
  Future<dynamic> getPosProductList(int offset, List <String> ids);
  Future<dynamic> getStockLimitStatus();
  Future<dynamic> getSearchedPosProductList(String search, List <String> ids);
  Future<dynamic> getStockLimitedProductList(int offset, String languageCode );
  Future<dynamic> getStockViolations(String languageCode);
  Future<dynamic> getMostPopularProductList(int offset, String languageCode );
  Future<dynamic> getTopSellingProductList(int offset, String languageCode );
  Future<dynamic> deleteProduct(int? productID);
  bool isShowCookies();
  Future<void> setIsShowCookies();
  Future<void> removeShowCookies();
  Future<dynamic> getBrandList(String languageCode);
}
