class AuctionNotificationListModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? newNotification;
  List<AuctionNotificationItem>? notifications;

  AuctionNotificationListModel.fromJson(Map<String, dynamic> json) {
    totalSize       = int.tryParse('${json['total_size']}');
    limit           = int.tryParse('${json['limit']}');
    offset          = int.tryParse('${json['offset']}');
    newNotification = int.tryParse('${json['new_notification']}');
    if (json['notifications'] != null) {
      notifications = <AuctionNotificationItem>[];
      json['notifications'].forEach((v) => notifications!.add(AuctionNotificationItem.fromJson(v)));
    }
  }
}

class AuctionNotificationItem {
  int?    id;
  int?    auctionProductId;
  int?    userId;
  int?    senderId;
  String? senderType;
  int?    receiverId;
  String? receiverType;
  String? type;
  String? message;
  bool?   isRead;
  String? createdAt;
  String? updatedAt;
  String? auctionProductName;
  String? slug;
  String? auctionProductThumbnailFullUrl;

  String get typeLabel {
    const labels = {
      'auction_won':                          'Auction Won',
      'auction_approved':                     'Auction Approved',
      'auction_denied':                       'Auction Denied',
      'auction_new_participation':            'New Participation',
      'auction_new_bid':                      'New Bid',
      'auction_expired_result':              'Auction Result',
      'auction_item_claimed':                 'Item Claimed',
      'auction_claim_payment_verified_owner': 'Payment Verified',
      'auction_withdrawal_approved':          'Withdrawal Approved',
      'auction_withdrawal_rejected':          'Withdrawal Rejected',
    };
    if (type == null) return 'Auction Notification';
    return labels[type!] ??
        type!
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
  }

  AuctionNotificationItem.fromJson(Map<String, dynamic> json) {
    id                             = json['id'];
    auctionProductId               = json['auction_product_id'];
    userId                         = json['user_id'];
    senderId                       = json['sender_id'];
    senderType                     = json['sender_type'];
    receiverId                     = json['receiver_id'];
    receiverType                   = json['receiver_type'];
    type                           = json['type'];
    message                        = json['message'];
    isRead                         = json['is_read'];
    createdAt                      = json['created_at'];
    updatedAt                      = json['updated_at'];
    auctionProductName             = json['auction_product_name'];
    slug                           = json['slug'];
    auctionProductThumbnailFullUrl = json['auction_product_thumbnail_full_url'];
  }
}
