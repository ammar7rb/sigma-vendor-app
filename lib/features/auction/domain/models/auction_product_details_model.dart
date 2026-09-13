import 'dart:convert';

import 'package:sixvalley_vendor_app/data/model/image_full_url.dart';

class AuctionProductDetailsModel {
  AuctionDetailsProduct? product;
  AuctionPayment? auctionPayment;
  DeliveredPayout? deliveredPayout;
  AuctionWithdrawInfo? auctionWithdrawInfo;
  
  AuctionProductDetailsModel({this.product, this.auctionPayment, this.deliveredPayout, this.auctionWithdrawInfo});

  factory AuctionProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return AuctionProductDetailsModel(
      product: json['product'] != null
          ? AuctionDetailsProduct.fromJson(Map<String, dynamic>.from(json['product']))
          : null,

      auctionPayment: json['auction_payment'] != null
        ? AuctionPayment.fromJson(Map<String, dynamic>.from(json['auction_payment']))
        : null,

      deliveredPayout: json['delivered_payout'] != null
        ? DeliveredPayout.fromJson(Map<String, dynamic>.from(json['delivered_payout']))
        : null,

      auctionWithdrawInfo: json['auction_withdraw'] != null ? AuctionWithdrawInfo.fromJson({'withdraw': json['auction_withdraw']}) : null,
    );
  }
}

class AuctionDetailsProduct {
  int? id;
  String? name;
  String? details;
  String? productType;
  String? itemCondition;
  String? returnPolicy;
  String? status;
  String? approvalStatus;
  String? auctionStatus;
  String? rejectedNote;
  String? videoUrl;
  String? startTime;
  String? endTime;
  String? createdAt;
  String? updatedAt;
  double? entryFee;
  double? startingPrice;
  double? minimumIncrementAmount;
  double? maximumDecrementAmount;
  double? shippingFee;
  double? currentHighestBidAmount;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  AuctionDetailsInfo? auctionDetails;
  ImageFullUrl? thumbnailFullUrl;
  ImageFullUrl? previewFileFullUrl;
  ImageFullUrl? metaImageFullUrl;
  List<ImageFullUrl>? imagesFullUrl;
  AuctionBrandInfo? brand;
  AuctionCategoryInfo? category;
  AuctionSeoInfo? seoInfo;
  List<AuctionTaxVatInfo>? taxVats;
  int? approvedByAdminId;
  String? approvedAt;
  String? deliveryStatus;
  String? paymentStatus;
  int? shippingAddressId;
  AuctionAddressInfo? shippingAddressInfo;
  int? billingAddressId;
  AuctionAddressInfo? billingAddressInfo;
  AuctionInsights? auctionInsights;
  Winner? winner;
  bool? adminCommissionGiven;
  List<AuctionTransaction>? transactions;
  String? trackingUrl;

  bool? billingSameAsShipping;
  String? videoProvider;
  String? youtubeVideoUrl;
  ImageFullUrl? customVideoUrlFullUrl;

  AuctionDetailsProduct({
    this.id,
    this.name,
    this.details,
    this.productType,
    this.itemCondition,
    this.returnPolicy,
    this.status,
    this.approvalStatus,
    this.auctionStatus,
    this.rejectedNote,
    this.videoUrl,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.entryFee,
    this.startingPrice,
    this.minimumIncrementAmount,
    this.maximumDecrementAmount,
    this.shippingFee,
    this.currentHighestBidAmount,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.auctionDetails,
    this.thumbnailFullUrl,
    this.previewFileFullUrl,
    this.metaImageFullUrl,
    this.imagesFullUrl,
    this.brand,
    this.category,
    this.seoInfo,
    this.taxVats,
    this.approvedAt,
    this.approvedByAdminId,
    this.deliveryStatus,
    this.paymentStatus,
    this.shippingAddressId,
    this.shippingAddressInfo,
    this.billingAddressId,
    this.billingAddressInfo,
    this.auctionInsights,
    this.winner,
    this.adminCommissionGiven,
    this.transactions,
    this.trackingUrl,
    this.billingSameAsShipping,
    this.videoProvider,
    this.youtubeVideoUrl,
    this.customVideoUrlFullUrl
  });

  factory AuctionDetailsProduct.fromJson(Map<String, dynamic> json) {

    AuctionDetailsProduct auctionModel =  AuctionDetailsProduct(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      details: json['details']?.toString(),
      productType: json['product_type']?.toString(),
      itemCondition: json['item_condition']?.toString(),
      returnPolicy: json['return_policy']?.toString(),
      status: json['status']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      auctionStatus: json['auction_status']?.toString(),
      rejectedNote: json['rejected_note']?.toString(),
      videoUrl: json['video_url']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      entryFee: _toDouble(json['entry_fee']),
      startingPrice: _toDouble(json['starting_price']),
      minimumIncrementAmount: _toDouble(json['minimum_increment_amount']),
      maximumDecrementAmount: _toDouble(json['maximum_decrement_amount']),
      shippingFee: _toDouble(json['shipping_fee']),
      currentHighestBidAmount: _toDouble(json['current_highest_bid_amount']),
      highestBidAmount: double.tryParse(json['highest_bid_amount']?.toString() ?? '0') ?? 0.0,
      totalBids: _toInt(json['total_bids']),
      totalParticipants: _toInt(json['total_participants']),
      totalViews: _toInt(json['total_views']),
      auctionDetails: json['auction_details'] != null
          ? AuctionDetailsInfo.fromJson(Map<String, dynamic>.from(json['auction_details']))
          : null,
      thumbnailFullUrl: json['thumbnail_full_url'] != null
          ? ImageFullUrl.fromJson(Map<String, dynamic>.from(json['thumbnail_full_url']))
          : null,
      previewFileFullUrl: json['preview_file_full_url'] != null
          ? ImageFullUrl.fromJson(Map<String, dynamic>.from(json['preview_file_full_url']))
          : null,
      metaImageFullUrl: json['meta_image_full_url'] != null
          ? ImageFullUrl.fromJson(Map<String, dynamic>.from(json['meta_image_full_url']))
          : null,
      imagesFullUrl: json['images_full_url'] is List
          ? (json['images_full_url'] as List)
              .whereType<Map>()
              .map((i) => ImageFullUrl.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,
      brand: json['brand'] != null
          ? AuctionBrandInfo.fromJson(Map<String, dynamic>.from(json['brand']))
          : null,
      category: json['category'] != null
          ? AuctionCategoryInfo.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
      seoInfo: json['seo_info'] != null
          ? AuctionSeoInfo.fromJson(Map<String, dynamic>.from(json['seo_info']))
          : null,
      taxVats: json['tax_vats'] is List
          ? (json['tax_vats'] as List)
              .whereType<Map>()
              .map((i) => AuctionTaxVatInfo.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,

      approvedAt: json['approved_at']?.toString(),
      approvedByAdminId: _toInt(json['approved_by_admin_id']),
      auctionInsights: json['auction_insights'] != null
          ? AuctionInsights.fromJson(Map<String, dynamic>.from(json['auction_insights']))
          : null,

      winner: json['winner'] != null
        ? Winner.fromJson(Map<String, dynamic>.from(json['winner']))
        : null,

      deliveryStatus: json['delivery_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      shippingAddressId: _toInt(json['shipping_address_id']),
      shippingAddressInfo: _parseAddressInfo(json['shipping_address_info']),
      billingAddressId: _toInt(json['billing_address_id']),
      billingAddressInfo: _parseAddressInfo(json['billing_address_info']),
      adminCommissionGiven: json['admin_commission_given'] == true || json['admin_commission_given'] == 1,
      transactions: json['transactions'] is List
          ? (json['transactions'] as List)
              .whereType<Map>()
              .map((i) => AuctionTransaction.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,
      trackingUrl: json['tracking_url']?.toString(),
      billingSameAsShipping: json['billing_same_as_shipping'] == true || json['billing_same_as_shipping'] == 1,
      videoProvider: json['video_provider']?.toString(),
      youtubeVideoUrl: json['youtube_video_url'],
      customVideoUrlFullUrl: json['custom_video_url_full_url'] != null ? ImageFullUrl.fromJson(json['custom_video_url_full_url']) : null,
    );

    return auctionModel;
  }
}

class AuctionDetailsInfo {
  String? startTime;
  String? endTime;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? status;

  AuctionDetailsInfo({
    this.startTime,
    this.endTime,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.status,
  });

  factory AuctionDetailsInfo.fromJson(Map<String, dynamic> json) {
    return AuctionDetailsInfo(
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      highestBidAmount: _toDouble(json['highest_bid_amount']),
      totalBids: _toInt(json['total_bids']),
      totalParticipants: _toInt(json['total_participants']),
      totalViews: _toInt(json['total_views']),
      status: json['status']?.toString(),
    );
  }
}

class AuctionBrandInfo {
  int? id;
  String? name;

  AuctionBrandInfo({this.id, this.name});

  factory AuctionBrandInfo.fromJson(Map<String, dynamic> json) {
    return AuctionBrandInfo(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class AuctionCategoryInfo {
  int? id;
  String? name;

  AuctionCategoryInfo({this.id, this.name});

  factory AuctionCategoryInfo.fromJson(Map<String, dynamic> json) {
    return AuctionCategoryInfo(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class AuctionSeoInfo {
  String? title;
  String? description;
  ImageFullUrl? imageFullUrl;

  AuctionSeoInfo({this.title, this.description, this.imageFullUrl});

  factory AuctionSeoInfo.fromJson(Map<String, dynamic> json) {
    return AuctionSeoInfo(
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      imageFullUrl: json['image_full_url'] != null
          ? ImageFullUrl.fromJson(Map<String, dynamic>.from(json['image_full_url']))
          : null,
    );
  }
}

class AuctionTaxVatInfo {
  AuctionTaxInfo? tax;

  AuctionTaxVatInfo({this.tax});

  factory AuctionTaxVatInfo.fromJson(Map<String, dynamic> json) {
    return AuctionTaxVatInfo(
      tax: json['tax'] != null
          ? AuctionTaxInfo.fromJson(Map<String, dynamic>.from(json['tax']))
          : null,
    );
  }
}

class AuctionTaxInfo {
  String? name;
  double? taxRate;

  AuctionTaxInfo({this.name, this.taxRate});

  factory AuctionTaxInfo.fromJson(Map<String, dynamic> json) {
    return AuctionTaxInfo(
      name: json['name']?.toString(),
      taxRate: _toDouble(json['tax_rate']),
    );
  }
}

class AuctionInsights {
  int? totalBids;
  double? avgBidIncrease;
  double? highestJump;

  AuctionInsights({this.totalBids, this.avgBidIncrease, this.highestJump});

  factory AuctionInsights.fromJson(Map<String, dynamic> json) {
    return AuctionInsights(
      totalBids: _toInt(json['total_bids']),
      avgBidIncrease: _toDouble(json['avg_bid_increase']),
      highestJump: _toDouble(json['highest_jump']),
    );
  }
}

class AuctionBidCustomer {
  int? id;
  String? fName;
  String? lName;
  String? image;
  ImageFullUrl? imageFullUrl;

  AuctionBidCustomer({this.id, this.fName, this.lName, this.image, this.imageFullUrl});

  factory AuctionBidCustomer.fromJson(Map<String, dynamic> json) {
    return AuctionBidCustomer(
      id: _toInt(json['id']),
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      image: json['image']?.toString(),
      imageFullUrl: json['image_full_url'] != null
          ? ImageFullUrl.fromJson(Map<String, dynamic>.from(json['image_full_url']))
          : null,
    );
  }
}



double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}



AuctionAddressInfo? _parseAddressInfo(dynamic value) {
  if (value == null) return null;
  try {
    Map<String, dynamic> map;
    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is! Map) return null;
      map = Map<String, dynamic>.from(decoded);
    } else if (value is Map) {
      map = Map<String, dynamic>.from(value);
    } else {
      return null;
    }
    return AuctionAddressInfo.fromJson(map);
  } catch (_) {
    return null;
  }
}

class AuctionAddressInfo {
  String? contactPersonName;
  String? phone;
  String? city;
  String? zip;
  String? address;
  String? country;
  String? email;
  String? latitude;
  String? longitude;

  AuctionAddressInfo({
    this.contactPersonName,
    this.phone,
    this.city,
    this.zip,
    this.address,
    this.country,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory AuctionAddressInfo.fromJson(Map<String, dynamic> json) {
    return AuctionAddressInfo(
      contactPersonName: json['contact_person_name']?.toString(),
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      zip: json['zip']?.toString(),
      address: json['address']?.toString(),
      country: json['country']?.toString(),
      email: json['email']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class Winner {
  int? id;
  String? fName;
  String? lName;
  String? image;
  ImageFullUrl? imageFullUrl;

  Winner({this.id, this.fName, this.lName, this.image, this.imageFullUrl});

  Winner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null ? ImageFullUrl.fromJson(json['image_full_url']) : null;
  }
}

class AuctionPayment {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidId;
  String? type;
  double? amount;
  String? currencyCode;
  String? paymentMethod;
  dynamic paymentInfo;
  String? paymentStatus;
  dynamic transactionRef;
  String? createdAt;
  String? updatedAt;

  AuctionPayment({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidId,
    this.type,
    this.amount,
    this.currencyCode,
    this.paymentMethod,
    this.paymentInfo,
    this.paymentStatus,
    this.transactionRef,
    this.createdAt,
    this.updatedAt,
  });

  factory AuctionPayment.fromJson(Map<String, dynamic> json) {
    return AuctionPayment(
      id: _toInt(json['id']),
      auctionProductId: _toInt(json['auction_product_id']),
      userId: _toInt(json['user_id']),
      bidId: _toInt(json['bid_id']),
      type: json['type']?.toString(),
      amount: _toDouble(json['amount']),
      currencyCode: json['currency_code']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentInfo: json['payment_info'],
      paymentStatus: json['payment_status']?.toString(),
      transactionRef: json['transaction_ref'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auction_product_id': auctionProductId,
      'user_id': userId,
      'bid_id': bidId,
      'type': type,
      'amount': amount,
      'currency_code': currencyCode,
      'payment_method': paymentMethod,
      'payment_info': paymentInfo,
      'payment_status': paymentStatus,
      'transaction_ref': transactionRef,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class DeliveredPayout {
  String? claimPaymentMethod;
  PayoutBreakdown? breakdown;

  DeliveredPayout({this.claimPaymentMethod, this.breakdown});

  factory DeliveredPayout.fromJson(Map<String, dynamic> json) {
    return DeliveredPayout(
      claimPaymentMethod: json['claim_payment_method']?.toString(),
      breakdown: json['breakdown'] != null
          ? PayoutBreakdown.fromJson(Map<String, dynamic>.from(json['breakdown']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claim_payment_method': claimPaymentMethod,
      'breakdown': breakdown?.toJson(),
    };
  }
}

class AuctionWithdrawInfo {
  Withdraw? withdraw;
  PayoutBreakdown? breakdown;

  AuctionWithdrawInfo({this.withdraw, this.breakdown});

  factory AuctionWithdrawInfo.fromJson(Map<String, dynamic> json) {
    return AuctionWithdrawInfo(
      withdraw: json['withdraw'] != null
          ? Withdraw.fromJson(Map<String, dynamic>.from(json['withdraw']))
          : null,
      breakdown: json['breakdown'] != null
          ? PayoutBreakdown.fromJson(Map<String, dynamic>.from(json['breakdown']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withdraw': withdraw?.toJson(),
      'breakdown': breakdown?.toJson(),
    };
  }
}

class PayoutBreakdown {
  double? bidAmount;
  double? shippingFee;
  double? taxAmount;
  String? taxType;
  double? totalPayable;
  double? commissionPercentage;
  double? commissionAmount;
  double? vendorReceivable;

  PayoutBreakdown({
    this.bidAmount,
    this.shippingFee,
    this.taxAmount,
    this.taxType,
    this.totalPayable,
    this.commissionPercentage,
    this.commissionAmount,
    this.vendorReceivable,
  });

  factory PayoutBreakdown.fromJson(Map<String, dynamic> json) {
    return PayoutBreakdown(
      bidAmount: _toDouble(json['bid_amount']),
      shippingFee: _toDouble(json['shipping_fee']),
      taxAmount: _toDouble(json['tax_amount']),
      taxType: json['tax_type']?.toString(),
      totalPayable: _toDouble(json['total_payable']),
      commissionPercentage: _toDouble(json['commission_percentage']),
      commissionAmount: _toDouble(json['commission_amount']),
      vendorReceivable: _toDouble(json['vendor_receivable']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bid_amount': bidAmount,
      'shipping_fee': shippingFee,
      'tax_amount': taxAmount,
      'tax_type': taxType,
      'total_payable': totalPayable,
      'commission_percentage': commissionPercentage,
      'commission_amount': commissionAmount,
      'vendor_receivable': vendorReceivable,
    };
  }
}

class Withdraw {
  int? id;
  String? ownerType;
  int? ownerId;
  int? auctionProductId;
  double? amount;
  double? commissionAmount;
  int? withdrawalMethodId;
  Map<String, dynamic>? withdrawalMethodFields;
  String? transactionNote;
  String? requestTime;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deniedNote;

  Withdraw({
    this.id,
    this.ownerType,
    this.ownerId,
    this.auctionProductId,
    this.amount,
    this.commissionAmount,
    this.withdrawalMethodId,
    this.withdrawalMethodFields,
    this.transactionNote,
    this.requestTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deniedNote,
  });

  factory Withdraw.fromJson(Map<String, dynamic> json) {
    return Withdraw(
      id: _toInt(json['id']),
      ownerType: json['owner_type']?.toString(),
      ownerId: _toInt(json['owner_id']),
      auctionProductId: _toInt(json['auction_product_id']),
      amount: _toDouble(json['amount']),
      commissionAmount: _toDouble(json['commission_amount']),
      withdrawalMethodId: _toInt(json['withdrawal_method_id']),
      withdrawalMethodFields: json['withdrawal_method_fields'] != null
          ? Map<String, dynamic>.from(json['withdrawal_method_fields'])
          : null,
      transactionNote: json['transaction_note']?.toString(),
      requestTime: json['request_time']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deniedNote: json['denied_note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'auction_product_id': auctionProductId,
      'amount': amount,
      'commission_amount': commissionAmount,
      'withdrawal_method_id': withdrawalMethodId,
      'withdrawal_method_fields': withdrawalMethodFields,
      'transaction_note': transactionNote,
      'request_time': requestTime,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'denied_note': deniedNote,
    };
  }
}

class AuctionTransaction {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidId;
  String? type;
  double? amount;
  String? currencyCode;
  String? paymentMethod;
  dynamic paymentInfo;
  String? paymentStatus;
  dynamic transactionRef;
  String? createdAt;
  String? updatedAt;

  AuctionTransaction({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidId,
    this.type,
    this.amount,
    this.currencyCode,
    this.paymentMethod,
    this.paymentInfo,
    this.paymentStatus,
    this.transactionRef,
    this.createdAt,
    this.updatedAt,
  });

  factory AuctionTransaction.fromJson(Map<String, dynamic> json) {
    return AuctionTransaction(
      id: _toInt(json['id']),
      auctionProductId: _toInt(json['auction_product_id']),
      userId: _toInt(json['user_id']),
      bidId: _toInt(json['bid_id']),
      type: json['type']?.toString(),
      amount: _toDouble(json['amount']),
      currencyCode: json['currency_code']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentInfo: json['payment_info'],
      paymentStatus: json['payment_status']?.toString(),
      transactionRef: json['transaction_ref'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

