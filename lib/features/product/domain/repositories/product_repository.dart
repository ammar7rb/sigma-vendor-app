import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/repositories/product_repository_interface.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';


class ProductRepository implements ProductRepositoryInterface{
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  ProductRepository({required this.sharedPreferences, required this.dioClient});

  @override
  Future<ApiResponse> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    FilterModel? filterModel,
}) async {
    try {

      final Map<String, dynamic> queryParams = {
        'limit': 20,
        'offset': offset,
        'search': search,
        if (filterModel?.productType != null && filterModel!.productType!.isNotEmpty) 'product_types': jsonEncode(filterModel.productType),
        if (filterModel?.minPrice != null) 'min_price': filterModel?.minPrice,
        if (filterModel?.maxPrice != null) 'max_price': filterModel?.maxPrice,
        if (filterModel?.startDate != null) 'start_date': DateConverter.durationDateTime(filterModel!.startDate!),
        if (filterModel?.endDate != null) 'end_date': DateConverter.durationDateTime(filterModel!.endDate!),
        if (filterModel?.brandIds != null && filterModel!.brandIds!.isNotEmpty) 'brand_ids': jsonEncode(filterModel.brandIds),
        if (filterModel?.categoryIds != null && filterModel!.categoryIds!.isNotEmpty) 'category_ids': jsonEncode(filterModel.categoryIds),
        if (filterModel?.filterSubCategoryIds != null && filterModel!.filterSubCategoryIds!.isNotEmpty) 'filter_sub_category_ids': jsonEncode(filterModel.filterSubCategoryIds),
        if (filterModel?.filterSubSubCategoryIds != null && filterModel!.filterSubSubCategoryIds!.isNotEmpty) 'filter_sub_sub_category_ids': jsonEncode(filterModel.filterSubSubCategoryIds),
        if (filterModel?.publishingHouseIds != null && filterModel!.publishingHouseIds!.isNotEmpty) 'publishing_house_ids': jsonEncode(filterModel.publishingHouseIds),
        if (filterModel?.authorIds != null && filterModel!.authorIds!.isNotEmpty) 'author_ids': jsonEncode(filterModel.authorIds),
        if (filterModel?.status != null && filterModel!.status!.isNotEmpty) 'product_status' :
        filterModel.status?.length == 1 ? filterModel.status!.contains('active') ? jsonEncode([1]) : filterModel.status!.contains('inactive') ? jsonEncode([0]) : jsonEncode([0,1]) : jsonEncode([0,1]),
        if (filterModel?.isApproved != null && filterModel!.isApproved!.isNotEmpty && const ['submitted', 'under_review', 'approved_published', 'suspended', 'rejected', 'deleted'].contains(filterModel.isApproved)) 'seller_review_status': filterModel.isApproved,
        if (filterModel?.isApproved != null && filterModel!.isApproved!.isNotEmpty && filterModel.isApproved != 'all' && !const ['submitted', 'under_review', 'approved_published', 'suspended', 'rejected', 'deleted'].contains(filterModel.isApproved)) 'request_status': filterModel.isApproved == 'approved' ? '1' : filterModel.isApproved == 'denied' ? '2': filterModel.isApproved == 'new_product' ? '0' : '',
        if (filterModel?.sorting != null && filterModel!.sorting!.isNotEmpty) 'filter_sort_by': filterModel.sorting,
      };

      debugPrint('-----------queryParams $queryParams');

      final response = await dioClient!.get(
        '${AppConstants.sellerProductUri}$sellerId/all-products',
        queryParameters: queryParams,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getPosProductList(int offset, List <String> ids) async {
    try {
      final response = await dioClient!.get('${AppConstants.posProductList}?limit=10&&offset=$offset&category_id=${jsonEncode(ids)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSearchedPosProductList(String search, List <String> ids) async {
    try {
      final response = await dioClient!.get('${AppConstants.searchPosProductList}?limit=10&offset=1&name=$search&category_id=${jsonEncode(ids)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getStockLimitedProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.stockOutProductUri}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getStockViolations(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.stockViolationsUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getMostPopularProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.mostPopularProduct}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getTopSellingProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.topSellingProduct}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
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
  Future delete(int id) async{
    try {
      final response = await dioClient!.post('${AppConstants.deleteProductUri}/$id',data: {
        '_method':'delete'
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
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
  Future<ApiResponse> getStockLimitStatus() async {
    try {
      final response = await dioClient!.get(AppConstants.stockLimitStatus);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  bool isShowCookies() {
    return sharedPreferences!.containsKey(AppConstants.showCookies);
  }

  @override
  Future<void> setIsShowCookies() async {
    await sharedPreferences!.setString(AppConstants.showCookies, 'cookies');
  }

  @override
  Future<void> removeShowCookies() async {
    await sharedPreferences!.remove(AppConstants.showCookies);
  }

  @override
  Future<ApiResponse> getBrandList(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.brandUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}
