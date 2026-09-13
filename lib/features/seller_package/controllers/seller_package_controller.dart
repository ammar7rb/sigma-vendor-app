import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/services/seller_package_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class SellerPackageController with ChangeNotifier {
  final SellerPackageServiceInterface sellerPackageServiceInterface;

  SellerPackageController({required this.sellerPackageServiceInterface});

  SellerPackageOverviewModel? _overview;
  SellerPackageOverviewModel? get overview => _overview;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSubmittingPayment = false;
  bool get isSubmittingPayment => _isSubmittingPayment;
  SellerPackagePerformance? _performance;
  SellerPackagePerformance? get performance => _performance;

  Future<void> getOverview() async {
    _isLoading = true;
    notifyListeners();
    final ApiResponse response = await sellerPackageServiceInterface.getOverview();
    if (response.response != null && response.response!.statusCode == 200) {
      // Preserve the last valid overview when the request fails later due to a temporary network error.
      _overview = SellerPackageOverviewModel.fromJson(Map<String, dynamic>.from(response.response!.data as Map));
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getPerformance(int subscriptionId) async {
    final response = await sellerPackageServiceInterface.getPerformance(subscriptionId);
    if (response.response != null && response.response!.statusCode == 200) {
      final data = Map<String, dynamic>.from(response.response!.data as Map);
      _performance = SellerPackagePerformance.fromJson(Map<String, dynamic>.from(data['performance'] as Map));
      notifyListeners();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<bool> cancelPackage({required int subscriptionId, required String reason}) async {
    _isSubmittingPayment = true;
    notifyListeners();
    final response = await sellerPackageServiceInterface.cancelPackage(subscriptionId: subscriptionId, reason: reason);
    _isSubmittingPayment = false;
    if (response.response != null && response.response!.statusCode == 200) {
      await getOverview();
      return true;
    }
    ApiChecker.checkApi(response);
    notifyListeners();
    return false;
  }

  Future<String?> payPackage({required int packageId, required String paymentMethod}) async {
    _isSubmittingPayment = true;
    notifyListeners();
    final response = await sellerPackageServiceInterface.payPackage(packageId: packageId, paymentMethod: paymentMethod);
    _isSubmittingPayment = false;
    notifyListeners();

    if (response.response != null && response.response!.statusCode == 200) {
      final data = Map<String, dynamic>.from(response.response!.data as Map);
      return data['redirect_link']?.toString();
    }
    ApiChecker.checkApi(response);
    return null;
  }

  Future<bool> payPackageFromOperatingBalance({required int packageId}) async {
    _isSubmittingPayment = true;
    notifyListeners();
    final response = await sellerPackageServiceInterface.payPackageFromOperatingBalance(packageId: packageId);
    _isSubmittingPayment = false;
    if (response.response != null && response.response!.statusCode == 200) {
      await getOverview();
      return true;
    }
    ApiChecker.checkApi(response);
    notifyListeners();
    return false;
  }

  Future<bool> submitOfflinePackagePayment({
    required int packageId, required int methodId, required Map<String, String> methodInformations,
    required XFile paymentProof, String? paymentNote,
  }) async {
    _isSubmittingPayment = true;
    notifyListeners();
    final response = await sellerPackageServiceInterface.submitOfflinePayment(
      packageId: packageId, methodId: methodId, methodInformations: methodInformations,
      paymentProof: paymentProof, paymentNote: paymentNote,
    );
    _isSubmittingPayment = false;
    if (response.response != null && response.response!.statusCode == 200) {
      await getOverview();
      return true;
    }
    ApiChecker.checkApi(response);
    notifyListeners();
    return false;
  }

}
