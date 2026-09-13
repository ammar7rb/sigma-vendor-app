import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';
import 'package:image_picker/image_picker.dart';

abstract class WalletRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getSellerBalance({int limit = 10});
  Future<ApiResponse> getSellerDashboardOverview();
  Future<ApiResponse> payOperatingBalance(
      {required String amount,
      required String paymentMethod,
      String walletTarget = 'operating'});
  Future<ApiResponse> submitOfflineBalancePayment(
      {required String amount,
      required int methodId,
      required Map<String, String> methodInformations,
      required XFile paymentProof,
      String? paymentNote,
      String walletTarget = 'operating'});
  Future<ApiResponse> getDynamicWithDrawMethod();
  Future<ApiResponse> withdrawBalance(
      List<String?> typeKey, List<String> typeValue, int? id, String balance);
  Future<ApiResponse> getPaymentInfoList();
  Future<ApiResponse> closeWithdrawRequest(int? id, String balance);
  Future<ApiResponse> updateWithdrawRequest(List<String?> typeKey,
      List<String> typeValue, int? methodId, String balance, int requestId);
}
