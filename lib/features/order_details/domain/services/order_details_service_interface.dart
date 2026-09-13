import 'dart:io';

import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_setup_model.dart';

abstract class OrderDetailsServiceInterface {
  Future<dynamic> setUpOrder(OrderSetupModel orderSetUpModel);
  Future<dynamic> getOrderDetails(String orderID);
  Future<dynamic> getSellerOrderInsurance(String orderID);
  Future<dynamic> paySellerOrderInsurance(String orderID, String paymentMethod);
  Future<dynamic> submitSellerOrderInsuranceOffline(
      String orderID, String methodId, String proofPath, String note);
  Future<dynamic> getShippingProofs(String orderID);
  Future<dynamic> respondToShipping(
      String orderID, String decision, String reason);
  Future<dynamic> getShippingProofFile(String orderID, int proofId);
  Future<dynamic> submitShippingProof(
      String orderID, String status, String proofPath, String note);
  Future<dynamic> getOrderStatusList(String type);
  Future<dynamic> uploadAfterSellDigitalProduct(
      File? filePath, String token, String orderId);
  Future<HttpClientResponse> productDownload(String url);

  Future<dynamic> getOrderInvoice(String orderID);
}
