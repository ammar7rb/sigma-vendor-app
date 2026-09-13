import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/repositories/seller_package_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/services/seller_package_service_interface.dart';
import 'package:image_picker/image_picker.dart';

class SellerPackageService implements SellerPackageServiceInterface {
  final SellerPackageRepositoryInterface sellerPackageRepositoryInterface;

  SellerPackageService({required this.sellerPackageRepositoryInterface});

  @override
  Future<ApiResponse> getOverview() => sellerPackageRepositoryInterface.getOverview();

  @override
  Future<ApiResponse> getPerformance(int subscriptionId) => sellerPackageRepositoryInterface.getPerformance(subscriptionId);

  @override
  Future<ApiResponse> cancelPackage({required int subscriptionId, required String reason}) =>
      sellerPackageRepositoryInterface.cancelPackage(subscriptionId: subscriptionId, reason: reason);

  @override
  Future<ApiResponse> payPackage({required int packageId, required String paymentMethod}) {
    return sellerPackageRepositoryInterface.payPackage(packageId: packageId, paymentMethod: paymentMethod);
  }

  @override
  Future<ApiResponse> payPackageFromOperatingBalance({required int packageId}) {
    return sellerPackageRepositoryInterface.payPackageFromOperatingBalance(packageId: packageId);
  }

  @override
  Future<ApiResponse> submitOfflinePayment({
    required int packageId, required int methodId, required Map<String, String> methodInformations,
    required XFile paymentProof, String? paymentNote,
  }) {
    return sellerPackageRepositoryInterface.submitOfflinePayment(
      packageId: packageId, methodId: methodId, methodInformations: methodInformations,
      paymentProof: paymentProof, paymentNote: paymentNote,
    );
  }

}
