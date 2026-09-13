abstract class AuctionProductServiceInterface {
  Future<dynamic> getAuctionProductList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  });

  Future<dynamic> getAuctionList({
    required int offset,
    String auctionStatus = '',
    String search = '',
    int limit = 10,
    Map<String, dynamic> extraParams = const {},
  });

  Future<dynamic> deleteAuctionProduct(int id);
  Future<dynamic> getAuctionProductDetails(int id, {String auctionStatus = ''});
  Future<dynamic> toggleAuctionStatus(int id);
  Future<dynamic> getBidList(int auctionProductId, {int limit = 10, int offset = 1});
  Future<dynamic> uploadTrackingUrl(int auctionProductId, String trackingUrl);
  Future<dynamic> updateAuctionAddress({
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

  Future<dynamic> updatePaymentStatus(
    int id, {
    required String paymentStatus,
  });

  Future<dynamic> updateDeliveryStatus(int id, {required String deliveryStatus});
  Future<dynamic> submitWithdrawRequest(Map<String, dynamic> data);
  Future<dynamic> payCommission(int id, Map<String, dynamic> data);
  Future<dynamic> getAuctionInvoice(int auctionId);

  Future<dynamic> getSalesReport({
    required int offset,
    String dateType = '',
    String? from,
    String? to,
    String search = '',
    int limit = 10,
  });

  Future<dynamic> getAuctionVatReport({
    required int limit,
    required int offset,
    String? startDate,
    String? endDate,
  });

  Future<dynamic> cancelAuctionProduct(int id);
}
