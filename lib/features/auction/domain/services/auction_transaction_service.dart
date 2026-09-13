import 'package:sixvalley_vendor_app/features/auction/domain/repository/auction_transaction_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/auction_transaction_service_interface.dart';

class AuctionTransactionService implements AuctionTransactionServiceInterface {
  final AuctionTransactionRepositoryInterface repositoryInterface;
  AuctionTransactionService({required this.repositoryInterface});

  @override
  Future getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    List<String>? transactionTypes,
    String? filterDurationType,
    String? startDate,
    String? endDate,
  }) async {
    return await repositoryInterface.getAuctionTransactionList(
      searchAuctionId: searchAuctionId,
      limit: limit,
      offset: offset,
      transactionTypes: transactionTypes,
      filterDurationType: filterDurationType,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
