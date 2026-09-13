import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';

class AuctionBidListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionBid>? bids;

  AuctionBidListModel({this.totalSize, this.limit, this.offset, this.bids});

  factory AuctionBidListModel.fromJson(Map<String, dynamic> json) {
    return AuctionBidListModel(
      totalSize: _toInt(json['total_size']),
      limit: _toInt(json['limit']),
      offset: _toInt(json['offset']),
      bids: json['bids'] is List
          ? (json['bids'] as List)
              .whereType<Map>()
              .map((i) => AuctionBid.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

class AuctionBid {
  int? id;
  int? auctionProductId;
  int? userId;
  double? bidAmount;
  bool? isAutoBid;
  bool? isWithdrawBid;
  String? bidTime;
  bool? isLeadBid;
  bool? isMyBid;
  AuctionBidCustomer? customer;
  UserContext? userContext;

  AuctionBid({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidAmount,
    this.isAutoBid,
    this.bidTime,
    this.customer,
    this.userContext,
  });

  factory AuctionBid.fromJson(Map<String, dynamic> json) {
    return AuctionBid(
      id: _toInt(json['id']),
      auctionProductId: _toInt(json['auction_product_id']),
      userId: _toInt(json['user_id']),
      bidAmount: _toDouble(json['bid_amount']),
      isAutoBid: json['is_auto_bid'] == true,
      bidTime: json['bid_time']?.toString(),
      customer: json['customer'] != null
          ? AuctionBidCustomer.fromJson(Map<String, dynamic>.from(json['customer']))
          : null,
      userContext: json['user_context'] != null
          ? UserContext.fromJson(Map<String, dynamic>.from(json['user_context']))
          : null,
    );
  }
}

class UserContext {
  int? myPosition;
  bool? isLeading;
  bool? isWinner;
  String? claimEndTime;
  int? claimTimeRemaining;
  bool? isClaimExpired;

  UserContext({
    this.myPosition,
    this.isLeading,
    this.isWinner,
    this.claimEndTime,
    this.claimTimeRemaining,
    this.isClaimExpired,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      myPosition: _toInt(json['my_position']),
      isLeading: json['is_leading'] == true,
      isWinner: json['is_winner'] == true,
      claimEndTime: json['claim_end_time']?.toString(),
      claimTimeRemaining: _toInt(json['claim_time_remaining']),
      isClaimExpired: json['is_claim_expired'] == true,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
