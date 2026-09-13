import 'dart:convert';

import 'package:sixvalley_vendor_app/data/model/image_full_url.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
export 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';

class AuctionProductListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionProduct>? products;
  AuctionCounts? counts;

  AuctionProductListModel({this.totalSize, this.limit, this.offset, this.products, this.counts});

  AuctionProductListModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['products'] != null) {
      products = <AuctionProduct>[];
      json['products'].forEach((v) {
        products!.add(AuctionProduct.fromJson(v));
      });
    }
    counts = json['counts'] != null ? AuctionCounts.fromJson(json['counts']) : null;
  }
}

class AuctionProduct {
  int? id;
  String? ownerType;
  int? ownerId;
  int? shopId;
  String? name;
  String? details;
  String? slug;
  int? categoryId;
  int? brandId;
  String? productType;
  String? itemCondition;
  double? entryFee;
  double? startingPrice;
  double ? minimumIncrementAmount;
  double ? maximumDecrementAmount;
  double? shippingFee;
  String? returnPolicy;
  String? thumbnail;
  String? images;
  String? videoProvider;
  String? videoUrl;
  String? youtubeVideoUrl;
  String? customVideoUrl;
  ImageFullUrl? customVideoUrlFullUrl;
  String? previewFile;
  String? startTime;
  String? endTime;
  String? status;
  String? approvalStatus;
  int? approvedByAdminId;
  String? approvedAt;
  String? rejectedNote;
  int? winnerUserId;
  int? winningBidId;
  double? currentHighestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? createdAt;
  String? updatedAt;
  int? bidsCount;
  int? participantsCount;
  String? auctionStatus;
  double? highestBidAmount;
  int? totalBidsCount;
  int? totalParticipantsCount;
  AuctionDetails? auctionDetails;
  Brand? brand;
  Category? category;
  HighestBid? highestBid;
  WinningBid? winningBid;
  Winner? winner;
  List<Translations>? translations;
  SeoInfo? seoInfo;
  ImageFullUrl? thumbnailFullUrl;
  ImageFullUrl? metaImageFullUrl;
  List<ImageFullUrl> ? additionalImageFullUrls;
  List<TaxVats> ? taxVats;
  bool? adminCommissionGiven;
  String? claimRemainingDuration;
  List<String>? auctionTags;
  bool? isRelaunched;

  AuctionProduct(
      {this.id,
        this.ownerType,
        this.ownerId,
        this.shopId,
        this.name,
        this.details,
        this.slug,
        this.categoryId,
        this.brandId,
        this.productType,
        this.itemCondition,
        this.entryFee,
        this.startingPrice,
        this.minimumIncrementAmount,
        this.maximumDecrementAmount,
        this.shippingFee,
        this.returnPolicy,
        this.thumbnail,
        this.images,
        this.videoProvider,
        this.videoUrl,
        this.youtubeVideoUrl,
        this.customVideoUrl,
        this.customVideoUrlFullUrl,
        this.previewFile,
        this.startTime,
        this.endTime,
        this.status,
        this.approvalStatus,
        this.approvedByAdminId,
        this.approvedAt,
        this.rejectedNote,
        this.winnerUserId,
        this.winningBidId,
        this.currentHighestBidAmount,
        this.totalBids,
        this.totalParticipants,
        this.totalViews,
        this.createdAt,
        this.updatedAt,
        this.bidsCount,
        this.participantsCount,
        this.auctionStatus,
        this.highestBidAmount,
        this.totalBidsCount,
        this.totalParticipantsCount,
        this.auctionDetails,
        this.brand,
        this.category,
        this.highestBid,
        this.winningBid,
        this.winner,
        this.translations,
        this.seoInfo,
        this.thumbnailFullUrl,
        this.metaImageFullUrl,
        this.additionalImageFullUrls,
        this.taxVats,
        this.adminCommissionGiven,
        this.claimRemainingDuration,
        this.auctionTags,
        this.isRelaunched,
      });

  AuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerType = json['owner_type'];
    ownerId = json['owner_id'];
    shopId = json['shop_id'];
    name = json['name'];
    details = json['details'];
    slug = json['slug'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    productType = json['product_type'];
    itemCondition = json['item_condition'];
    entryFee = json['entry_fee'] != null ? double.tryParse('${json['entry_fee']}') : null;
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    minimumIncrementAmount = json['minimum_increment_amount'] != null ? double.tryParse('${json['minimum_increment_amount']}') : null;
    maximumDecrementAmount = json['maximum_decrement_amount'] != null ? double.tryParse('${json['maximum_decrement_amount']}') : null;
    shippingFee = json['shipping_fee'] != null ? double.tryParse('${json['shipping_fee']}') : null;
    returnPolicy = json['return_policy'];
    thumbnail = json['thumbnail'];
    images = json['images'];
    videoProvider = json['video_provider'];
    videoUrl = json['video_url'];
    youtubeVideoUrl = json['youtube_video_url'];
    customVideoUrl = json['custom_video_url'];
    customVideoUrlFullUrl = json['custom_video_url_full_url'] != null
        ? ImageFullUrl.fromJson(json['custom_video_url_full_url'])
        : null;
    previewFile = json['preview_file'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'].toString();
    approvalStatus = json['approval_status'];
    approvedByAdminId = json['approved_by_admin_id'];
    approvedAt = json['approved_at'];
    rejectedNote = json['rejected_note'];
    winnerUserId = json['winner_user_id'];
    winningBidId = json['winning_bid_id'];
    currentHighestBidAmount = json['current_highest_bid_amount'] != null ? double.tryParse('${json['current_highest_bid_amount']}') : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bidsCount = json['bids_count'];
    participantsCount = json['participants_count'];
    auctionStatus = json['auction_status'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    totalBidsCount = json['total_bids_count'];
    totalParticipantsCount = json['total_participants_count'];
    auctionDetails = json['auction_details'] != null
        ? AuctionDetails.fromJson(json['auction_details'])
        : null;
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null
      ? Category.fromJson(json['category'])
      : null;
    highestBid = json['highest_bid'] != null ? HighestBid.fromJson(json['highest_bid']) : null;
    winningBid = json['winning_bid'] != null ? WinningBid.fromJson(json['winning_bid']) : null;
    winner = json['winner'] != null ? Winner.fromJson(json['winner']) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
      adminCommissionGiven = json['admin_commission_given'];
    }

    seoInfo = json['seo_info'] != null
      ? SeoInfo.fromJson(json['seo_info'])
      : null;

    thumbnailFullUrl = (json['thumbnail_full_url'] != null
      ? ImageFullUrl.fromJson(json['thumbnail_full_url'])
      : null)!;

    metaImageFullUrl = json['meta_image_full_url'] != null
      ? ImageFullUrl.fromJson(json['meta_image_full_url'])
      : null;

    additionalImageFullUrls = json['images_full_url'] != null
      ? (json['images_full_url'] as List).map((i) => ImageFullUrl.fromJson(i)).toList()
      : null;

    taxVats = json['tax_vats'] != null
      ? (json['tax_vats'] as List).map((i) => TaxVats.fromJson(i)).toList()
      : null;

    claimRemainingDuration = json['claim_remaining_duration'];
    auctionTags = (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    isRelaunched = json['is_relaunched'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['owner_type'] = ownerType;
    data['owner_id'] = ownerId;
    data['shop_id'] = shopId;
    data['name'] = name;
    data['details'] = details;
    data['slug'] = slug;
    data['category_id'] = categoryId;
    data['brand_id'] = brandId;
    data['product_type'] = productType;
    data['item_condition'] = itemCondition;
    data['entry_fee'] = entryFee;
    data['starting_price'] = startingPrice;
    data['minimum_increment_amount'] = minimumIncrementAmount;
    data['maximum_decrement_amount'] = maximumDecrementAmount;
    data['shipping_fee'] = shippingFee;
    data['return_policy'] = returnPolicy;
    data['thumbnail'] = thumbnail;
    data['images'] = images;
    data['video_provider'] = videoProvider;
    data['video_url'] = videoUrl;
    data['youtube_video_url'] = youtubeVideoUrl;
    data['custom_video_url'] = customVideoUrl;
    if (customVideoUrlFullUrl != null) {
      data['custom_video_url_full_url'] = customVideoUrlFullUrl!.toJson();
    }
    data['preview_file'] = previewFile;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['status'] = status;
    data['approval_status'] = approvalStatus;
    data['approved_by_admin_id'] = approvedByAdminId;
    data['approved_at'] = approvedAt;
    data['rejected_note'] = rejectedNote;
    data['winner_user_id'] = winnerUserId;
    data['winning_bid_id'] = winningBidId;
    data['current_highest_bid_amount'] = currentHighestBidAmount;
    data['total_bids'] = totalBids;
    data['total_participants'] = totalParticipants;
    data['total_views'] = totalViews;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bids_count'] = bidsCount;
    data['participants_count'] = participantsCount;
    data['auction_status'] = jsonEncode(auctionStatus);
    data['highest_bid_amount'] = highestBidAmount;
    data['total_bids_count'] = totalBidsCount;
    data['total_participants_count'] = totalParticipantsCount;
    if (auctionDetails != null) {
      data['auction_details'] = auctionDetails!.toJson();
    }
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['highest_bid'] = highestBid;
    data['winning_bid'] = winningBid;
    data['winner'] = winner;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (seoInfo != null) {
      data['seo_info'] = seoInfo!.toJson();
    }
    if (thumbnailFullUrl != null) {
      data['thumbnail_full_url'] = thumbnailFullUrl!.toJson();
    }
    if (metaImageFullUrl != null) {
      data['meta_image_full_url'] = metaImageFullUrl!.toJson();
    }
    if (additionalImageFullUrls != null) {
      data['images_full_url'] = additionalImageFullUrls!.map((v) => v.toJson()).toList();
    }

    data['tax_vats'] = taxVats?.map((v) => v.toJson()).toList();
    data['admin_commission_given'] = adminCommissionGiven;
    data['claim_remaining_duration'] = claimRemainingDuration;
    data['is_relaunched'] = isRelaunched;

    return data;
  }
}


class AuctionDetails {
  String? startTime;
  String? endTime;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? status;
  String? deliveryStatus;

  AuctionDetails(
      {this.startTime,
        this.endTime,
        this.highestBidAmount,
        this.totalBids,
        this.totalParticipants,
        this.totalViews,
        this.status,
        this.deliveryStatus
      });

  AuctionDetails.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    status = json['status'];
    deliveryStatus = json['delivery_status'];
  }

  AuctionStatus get auctionEnum => AuctionStatus.fromAuctionDetails(
    status: status,
    deliveryStatus: deliveryStatus,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['highest_bid_amount'] = highestBidAmount;
    data['total_bids'] = totalBids;
    data['total_participants'] = totalParticipants;
    data['total_views'] = totalViews;
    data['status'] = status;
    data['delivery_status'] = deliveryStatus;
    return data;
  }
}

class Translations {
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  int? id;

  Translations(
      {this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        this.id});

  Translations.fromJson(Map<String, dynamic> json) {
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['id'] = id;
    return data;
  }
}

class SeoInfo {
  int? id;
  String? seoableType;
  int? seoableId;
  String? title;
  String? description;
  String? index;
  String? noFollow;
  String? noImageIndex;
  String? noArchive;
  String? noSnippet;
  String? maxSnippet;
  String? maxSnippetValue;
  String? maxVideoPreview;
  String? maxVideoPreviewValue;
  String? maxImagePreview;
  String? maxImagePreviewValue;
  String? createdAt;
  String? updatedAt;
  ImageFullUrl? imageFullUrl;

  SeoInfo(
      {this.id,
        this.seoableType,
        this.seoableId,
        this.title,
        this.description,
        this.index,
        this.noFollow,
        this.noImageIndex,
        this.noArchive,
        this.noSnippet,
        this.maxSnippet,
        this.maxSnippetValue,
        this.maxVideoPreview,
        this.maxVideoPreviewValue,
        this.maxImagePreview,
        this.maxImagePreviewValue,
        this.createdAt,
        this.updatedAt,
        this.imageFullUrl,
      });

  SeoInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seoableType = json['seoable_type'];
    seoableId = json['seoable_id'];
    title = json['title'];
    description = json['description'];
    index = json['index'];
    noFollow = json['no_follow'];
    noImageIndex = json['no_image_index'];
    noArchive = json['no_archive'];
    noSnippet = json['no_snippet'];
    maxSnippet = json['max_snippet'];
    maxSnippetValue = json['max_snippet_value'];
    maxVideoPreview = json['max_video_preview'];
    maxVideoPreviewValue = json['max_video_preview_value'];
    maxImagePreview = json['max_image_preview'];
    maxImagePreviewValue = json['max_image_preview_value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'] != null
      ? ImageFullUrl.fromJson(json['image_full_url'])
      : null;
    
    
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['seoable_type'] = seoableType;
    data['seoable_id'] = seoableId;
    data['title'] = title;
    data['description'] = description;
    data['index'] = index;
    data['no_follow'] = noFollow;
    data['no_image_index'] = noImageIndex;
    data['no_archive'] = noArchive;
    data['no_snippet'] = noSnippet;
    data['max_snippet'] = maxSnippet;
    data['max_snippet_value'] = maxSnippetValue;
    data['max_video_preview'] = maxVideoPreview;
    data['max_video_preview_value'] = maxVideoPreviewValue;
    data['max_image_preview'] = maxImagePreview;
    data['max_image_preview_value'] = maxImagePreviewValue;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (imageFullUrl != null) {
      data['image_full_url'] = imageFullUrl!.toJson();
    }
    return data;
  }
}




class AuctionCounts {
  final int upcoming;
  final int live;
  final int readyToClaim;
  final int purchaseComplete;
  final int readyToDelivery;
  final int onTheWay;
  final int delivered;
  final int unsold;
  final int pending;
  final int rejected;
  final int canceled;

  const AuctionCounts({
    this.upcoming = 0,
    this.live = 0,
    this.readyToClaim = 0,
    this.purchaseComplete = 0,
    this.readyToDelivery = 0,
    this.onTheWay = 0,
    this.delivered = 0,
    this.unsold = 0,
    this.pending = 0,
    this.rejected = 0,
    this.canceled = 0,
  });

  int get total => upcoming + live + readyToClaim + purchaseComplete + readyToDelivery + onTheWay + delivered + unsold;

  factory AuctionCounts.fromJson(Map<String, dynamic> json) {
    return AuctionCounts(
      upcoming: json['upcoming'] as int? ?? 0,
      live: json['live'] as int? ?? 0,
      readyToClaim: json['ready_to_claim'] as int? ?? 0,
      purchaseComplete: json['purchase_complete'] as int? ?? 0,
      readyToDelivery: json['ready_to_delivery'] as int? ?? 0,
      onTheWay: json['on_the_way'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      unsold: json['unsold'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      canceled: json['canceled'] as int? ?? 0,
    );
  }
}


class TaxVats {
  int? id;
  String? taxableType;
  int? taxableId;
  int? taxId;
  int? systemTaxSetupId;
  String? createdAt;
  String? updatedAt;
  TaxVatModel? tax;

  TaxVats(
      {this.id,
        this.taxableType,
        this.taxableId,
        this.taxId,
        this.systemTaxSetupId,
        this.createdAt,
        this.updatedAt,
        this.tax});

  TaxVats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxableType = json['taxable_type'];
    taxableId = json['taxable_id'];
    taxId = json['tax_id'];
    systemTaxSetupId = json['system_tax_setup_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    tax = json['tax'] != null ? TaxVatModel.fromJson(json['tax']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['taxable_type'] = taxableType;
    data['taxable_id'] = taxableId;
    data['tax_id'] = taxId;
    data['system_tax_setup_id'] = systemTaxSetupId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    return data;
  }
}


class HighestBid {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidAmount;
  String? bidTime;
  bool? isLeadBid;
  bool? isMyBid;

  HighestBid(
      {this.id,
        this.auctionProductId,
        this.userId,
        this.bidAmount,
        this.bidTime,
        this.isLeadBid,
        this.isMyBid});

  HighestBid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    userId = json['user_id'];
    bidAmount = json['bid_amount'] != null ? int.tryParse('${json['bid_amount']}') ?? double.tryParse('${json['bid_amount']}')?.toInt() : null;
    bidTime = json['bid_time'];
    isLeadBid = json['is_lead_bid'];
    isMyBid = json['is_my_bid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['auction_product_id'] = auctionProductId;
    data['user_id'] = userId;
    data['bid_amount'] = bidAmount;
    data['bid_time'] = bidTime;
    data['is_lead_bid'] = isLeadBid;
    data['is_my_bid'] = isMyBid;
    return data;
  }
}


class WinningBid {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidAmount;
  String? bidTime;
  bool? isLeadBid;
  bool? isMyBid;

  WinningBid(
      {this.id,
        this.auctionProductId,
        this.userId,
        this.bidAmount,
        this.bidTime,
        this.isLeadBid,
        this.isMyBid});

  WinningBid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    userId = json['user_id'];
    bidAmount = json['bid_amount'] != null ? int.tryParse('${json['bid_amount']}') ?? double.tryParse('${json['bid_amount']}')?.toInt() : null;
    bidTime = json['bid_time'];
    isLeadBid = json['is_lead_bid'];
    isMyBid = json['is_my_bid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['auction_product_id'] = auctionProductId;
    data['user_id'] = userId;
    data['bid_amount'] = bidAmount;
    data['bid_time'] = bidTime;
    data['is_lead_bid'] = isLeadBid;
    data['is_my_bid'] = isMyBid;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['image'] = image;
    if (imageFullUrl != null) {
      data['image_full_url'] = imageFullUrl!.toJson();
    }
    return data;
  }
}

