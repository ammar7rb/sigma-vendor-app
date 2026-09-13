import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/models/seller_promotion_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/repositories/seller_promotion_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/services/seller_promotion_service_interface.dart';

class SellerPromotionService implements SellerPromotionServiceInterface {
  final SellerPromotionRepositoryInterface sellerPromotionRepositoryInterface;

  SellerPromotionService({required this.sellerPromotionRepositoryInterface});

  @override
  Future<ApiResponse> getOverview(SellerPromotionType type) => sellerPromotionRepositoryInterface.getOverview(type);

  @override
  Future<ApiResponse> activatePromotion({required SellerPromotionType type, required int productId}) {
    return sellerPromotionRepositoryInterface.activatePromotion(type: type, productId: productId);
  }
}
