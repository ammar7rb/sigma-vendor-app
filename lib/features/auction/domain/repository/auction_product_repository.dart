import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/repository/auction_product_repository_interface.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class AuctionProductRepository implements AuctionProductRepositoryInterface {
  final DioClient? dioClient;
  AuctionProductRepository({required this.dioClient});

  @override
  Future<ApiResponse> getAuctionProductList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  }) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.auctionProductListUri}?limit=$limit&offset=$offset&approval_status=$approvalStatus',
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getAuctionList({
    required int offset,
    String auctionStatus = '',
    String search = '',
    int limit = 10,
    Map<String, dynamic> extraParams = const {},
  }) async {

    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
        'approval_status': 'approved',
        'include_counts': true,
        if (search.isNotEmpty) 'search': search,
        if (auctionStatus.isNotEmpty) 'auction_status': auctionStatus,
        ...extraParams,
      };

      final response = await dioClient!.post(
        AppConstants.auctionProductListUri,
        data: queryParams,
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> deleteAuctionProduct(int id) async {
    try {
      final response = await dioClient!.delete('${AppConstants.deleteAuctionProductUri}$id');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getAuctionProductDetails(int id, {String auctionStatus = ''}) async {
    try {
      final String query = auctionStatus.isNotEmpty ? '?auction_status=$auctionStatus' : '';
      final response = await dioClient!.get('${AppConstants.vendorAuctionDetailsUri}$id$query');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> toggleAuctionStatus(int id) async {
    try {
      final response = await dioClient!.put('${AppConstants.vendorAuctionStatusToggle}$id');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> uploadTrackingUrl(int auctionProductId, String trackingUrl) async {
    try {
      final response = await dioClient!.put(
        '${AppConstants.auctionUploadTrackingUri}$auctionProductId',
        data: {
          'tracking_url': trackingUrl,
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
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
  }) async {
    try {
      final Map<String, dynamic> data = {
        'auction_product_id': auctionProductId,
        'address_type': addressType,
        if (contactPersonName != null && contactPersonName.isNotEmpty) 'contact_person_name': contactPersonName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (city != null && city.isNotEmpty) 'city': city,
        if (zip != null && zip.isNotEmpty) 'zip': zip,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        if (country != null && country.isNotEmpty) 'country': country,
      };
      final response = await dioClient!.post(AppConstants.auctionAddressUpdateUri, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getBidList(int auctionProductId, {int limit = 10, int offset = 1}) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.vendorAuctionBidsList}$auctionProductId?limit=$limit&offset=$offset',
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updatePaymentStatus(
    int id, {
    required String paymentStatus,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'payment_status': paymentStatus,
      };
      final response = await dioClient!.put('${AppConstants.auctionPaymentStatusUri}$id', data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateDeliveryStatus(int id, {required String deliveryStatus}) async {
    try {
      final response = await dioClient!.put(
        '${AppConstants.auctionDeliveryStatusUpdateUri}$id',
        data: {'delivery_status': deliveryStatus},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> submitWithdrawRequest(Map<String, dynamic> data) async {
    try {
      final response = await dioClient!.post(
        AppConstants.auctionWithdrawRequest,
        data: data,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> payCommission(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.auctionPayCommission}$id',
        data: data,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getAuctionInvoice(int auctionId) async {
    try {
      final response = await dioClient!.get('${AppConstants.auctionGenerateInvoiceUri}$auctionId');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSalesReport({
    required int offset,
    String dateType = '',
    String? from,
    String? to,
    String search = '',
    int limit = 10,
  }) async {
    try {
      final parts = <String>['limit=$limit', 'offset=$offset'];
      if (dateType.isNotEmpty) parts.add('date_type=$dateType');
      if (from != null && from.isNotEmpty) parts.add('from=$from');
      if (to != null && to.isNotEmpty) parts.add('to=$to');
      if (search.isNotEmpty) parts.add('search=$search');
      final response = await dioClient!
          .get('${AppConstants.auctionSalesReportUri}?${parts.join('&')}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getAuctionVatReport({
    required int limit,
    required int offset,
    String? startDate,
    String? endDate,
  }) async {
    String url = '${AppConstants.auctionVatTaxReportList}?limit=$limit&offset=$offset';
    if (startDate != null && endDate != null && startDate != 'null' && endDate != 'null') {
      url += '&start_date=$startDate&end_date=$endDate';
    }
    try {
      final response = await dioClient!.get(url);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> cancelAuctionProduct(int id) async {
    try {
      final Map<String, dynamic> fields = {'is_canceled': true};
      final response = await dioClient!.post('${AppConstants.auctionCancelUri}$id', data: fields);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }
}
