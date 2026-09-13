import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:image_picker/image_picker.dart';

class WalletService implements WalletServiceInterface {
  final WalletRepositoryInterface walletRepoInterface;
  WalletService({required this.walletRepoInterface});

  @override
  Future<ApiResponse> getSellerBalance({int limit = 10}) =>
      walletRepoInterface.getSellerBalance(limit: limit);

  @override
  Future<ApiResponse> getSellerDashboardOverview() =>
      walletRepoInterface.getSellerDashboardOverview();

  @override
  Future<ApiResponse> payOperatingBalance(
          {required String amount,
          required String paymentMethod,
          String walletTarget = 'operating'}) =>
      walletRepoInterface.payOperatingBalance(
          amount: amount,
          paymentMethod: paymentMethod,
          walletTarget: walletTarget);

  @override
  Future<ApiResponse> submitOfflineBalancePayment(
          {required String amount,
          required int methodId,
          required Map<String, String> methodInformations,
          required XFile paymentProof,
          String? paymentNote,
          String walletTarget = 'operating'}) =>
      walletRepoInterface.submitOfflineBalancePayment(
          amount: amount,
          methodId: methodId,
          methodInformations: methodInformations,
          paymentProof: paymentProof,
          paymentNote: paymentNote,
          walletTarget: walletTarget);

  @override
  Future getDynamicWithDrawMethod() async {
    ApiResponse apiResponse =
        await walletRepoInterface.getDynamicWithDrawMethod();
    if (apiResponse.response?.statusCode == 200) {
      return apiResponse;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  @override
  Future withdrawBalance(List<String?> typeKey, List<String> typeValue, int? id,
      String balance) async {
    ApiResponse apiResponse = await walletRepoInterface.withdrawBalance(
        typeKey, typeValue, id, balance);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      return apiResponse;
    } else {
      return apiResponse;
    }
  }

  @override
  Future updateWithdrawRequest(List<String?> typeKey, List<String> typeValue,
      int? methodId, String balance, int requestId) async {
    ApiResponse apiResponse = await walletRepoInterface.updateWithdrawRequest(
      typeKey,
      typeValue,
      methodId,
      balance,
      requestId,
    );
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      return apiResponse;
    } else {
      return apiResponse;
    }
  }

  @override
  Future getPaymentInfoList() {
    return walletRepoInterface.getPaymentInfoList();
  }

  @override
  Future closeWithdrawRequest(int? id, String balance) async {
    return walletRepoInterface.closeWithdrawRequest(id, balance);
  }
}
