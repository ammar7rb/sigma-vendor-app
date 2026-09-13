import 'dart:io';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_setup_model.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class OrderDetailsRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> setUpOrder(OrderSetupModel orderSetUpModel);
  Future<ApiResponse> getOrderDetails(String orderID);
  Future<ApiResponse> getSellerOrderInsurance(String orderID);
  Future<ApiResponse> paySellerOrderInsurance(
      String orderID, String paymentMethod);
  Future<ApiResponse> submitSellerOrderInsuranceOffline(
      String orderID, String methodId, String proofPath, String note);
  Future<ApiResponse> getShippingProofs(String orderID);
  Future<ApiResponse> respondToShipping(
      String orderID, String decision, String reason);
  Future<ApiResponse> getShippingProofFile(String orderID, int proofId);
  Future<ApiResponse> submitShippingProof(
      String orderID, String status, String proofPath, String note);
  Future<ApiResponse> getOrderStatusList(String type);
  Future<ApiResponse> uploadAfterSellDigitalProduct(
      File? filePath, String token, String orderId);
  Future<HttpClientResponse> productDownload(String url);
  Future<dynamic> getOrderInvoice(String orderID);
}
