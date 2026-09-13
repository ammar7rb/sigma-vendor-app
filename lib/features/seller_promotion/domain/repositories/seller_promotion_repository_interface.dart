import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/models/seller_promotion_overview_model.dart';

abstract class SellerPromotionRepositoryInterface {
  Future<ApiResponse> getOverview(SellerPromotionType type);
  Future<ApiResponse> activatePromotion({required SellerPromotionType type, required int productId});
}
