import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/models/seller_promotion_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/services/seller_promotion_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class SellerPromotionController with ChangeNotifier {
  final SellerPromotionServiceInterface sellerPromotionServiceInterface;

  SellerPromotionController({required this.sellerPromotionServiceInterface});

  final Map<SellerPromotionType, SellerPromotionOverviewModel?> _overviews = {};
  final Map<SellerPromotionType, bool> _loading = {};
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  SellerPromotionOverviewModel? overview(SellerPromotionType type) => _overviews[type];
  bool isLoading(SellerPromotionType type) => _loading[type] ?? false;

  Future<void> getOverview(SellerPromotionType type) async {
    _loading[type] = true;
    notifyListeners();
    final ApiResponse response = await sellerPromotionServiceInterface.getOverview(type);
    if (response.response != null && response.response!.statusCode == 200) {
      _overviews[type] = SellerPromotionOverviewModel.fromJson(
        Map<String, dynamic>.from(response.response!.data as Map), type: type,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    _loading[type] = false;
    notifyListeners();
  }

  Future<bool> activatePromotion({required SellerPromotionType type, required int productId}) async {
    _isSubmitting = true;
    notifyListeners();
    final response = await sellerPromotionServiceInterface.activatePromotion(type: type, productId: productId);
    _isSubmitting = false;
    if (response.response != null && response.response!.statusCode == 200) {
      // Pending requests do not consume quota. Reload the server state to show
      // the admin-review status without decrementing the local counter.
      await getOverview(type);
      return true;
    }
    ApiChecker.checkApi(response);
    notifyListeners();
    return false;
  }
}
