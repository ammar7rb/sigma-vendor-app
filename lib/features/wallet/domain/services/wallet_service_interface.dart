import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:image_picker/image_picker.dart';

abstract class WalletServiceInterface {
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
  Future<dynamic> getDynamicWithDrawMethod();
  Future<dynamic> withdrawBalance(
      List<String?> typeKey, List<String> typeValue, int? id, String balance);
  Future<dynamic> getPaymentInfoList();
  Future<dynamic> closeWithdrawRequest(int? id, String balance);
  Future<dynamic> updateWithdrawRequest(List<String?> typeKey,
      List<String> typeValue, int? methodId, String balance, int requestId);
}
