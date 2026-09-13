import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class AuctionTransactionRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    List<String>? transactionTypes,
    String? filterDurationType,
    String? startDate,
    String? endDate,
  });
}
