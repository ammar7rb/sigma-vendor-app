import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/models/seller_promotion_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/repositories/seller_promotion_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class SellerPromotionRepository implements SellerPromotionRepositoryInterface {
  final DioClient dioClient;

  SellerPromotionRepository({required this.dioClient});

  @override
  Future<ApiResponse> getOverview(SellerPromotionType type) async {
    try {
      final response = await dioClient.get(_baseUri(type));
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> activatePromotion({required SellerPromotionType type, required int productId}) async {
    try {
      // The backend owns quota consumption and rejects bypass attempts even if the app is altered.
      final response = await dioClient.post('${_baseUri(type)}/activate', data: {'product_id': productId});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  String _baseUri(SellerPromotionType type) {
    return type == SellerPromotionType.search
        ? AppConstants.sellerSearchPromotionsUri : AppConstants.sellerHomepagePromotionsUri;
  }
}
