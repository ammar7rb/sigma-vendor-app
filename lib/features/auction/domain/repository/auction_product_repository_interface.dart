import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class AuctionProductRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getAuctionProductList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  });

  Future<ApiResponse> getAuctionList({
    required int offset,
    String auctionStatus = '',
    String search = '',
    int limit = 10,
    Map<String, dynamic> extraParams = const {},
  });

  Future<ApiResponse> deleteAuctionProduct(int id);
  Future<ApiResponse> getAuctionProductDetails(int id, {String auctionStatus = ''});
  Future<ApiResponse> toggleAuctionStatus(int id);
  Future<ApiResponse> getBidList(int auctionProductId, {int limit = 10, int offset = 1});
  Future<ApiResponse> uploadTrackingUrl(int auctionProductId, String trackingUrl);
  Future<ApiResponse> updateAuctionAddress({
    required int auctionProductId,
    required String addressType,
    String? contactPersonName,
    String? phone,
    String? city,
    String? zip,
    String? email,
    String? address,
    String? country,
  });

  Future<ApiResponse> updatePaymentStatus(
    int id, {
    required String paymentStatus,
  });

  Future<ApiResponse> updateDeliveryStatus(int id, {required String deliveryStatus});
  Future<ApiResponse> submitWithdrawRequest(Map<String, dynamic> data);
  Future<ApiResponse> payCommission(int id, Map<String, dynamic> data);
  Future<ApiResponse> getAuctionInvoice(int auctionId);

  Future<ApiResponse> getSalesReport({
    required int offset,
    String dateType = '',
    String? from,
    String? to,
    String search = '',
    int limit = 10,
  });

  Future<ApiResponse> getAuctionVatReport({
    required int limit,
    required int offset,
    String? startDate,
    String? endDate,
  });

  Future<ApiResponse> cancelAuctionProduct(int id);
}
