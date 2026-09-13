import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:image_picker/image_picker.dart';

abstract class SellerPackageRepositoryInterface {
  Future<ApiResponse> getOverview();
  Future<ApiResponse> getPerformance(int subscriptionId);
  Future<ApiResponse> cancelPackage({required int subscriptionId, required String reason});
  Future<ApiResponse> payPackage({required int packageId, required String paymentMethod});
  Future<ApiResponse> payPackageFromOperatingBalance({required int packageId});
  Future<ApiResponse> submitOfflinePayment({
    required int packageId, required int methodId, required Map<String, String> methodInformations,
    required XFile paymentProof, String? paymentNote,
  });
}
