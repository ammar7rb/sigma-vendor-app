class AuctionVatReportModel {
  double? totalTax;
  int? totalOrders;
  double? totalOrderAmount;
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionOrderTransaction>? orderTransactions;
  List<AuctionTypeWiseTaxes>? typeWiseTaxesList;

  AuctionVatReportModel({
    this.totalTax,
    this.totalOrders,
    this.totalOrderAmount,
    this.totalSize,
    this.limit,
    this.offset,
    this.orderTransactions,
    this.typeWiseTaxesList,
  });

  AuctionVatReportModel.fromJson(Map<String, dynamic> json) {
    totalTax = double.tryParse(json['total_tax'].toString());
    totalOrders = int.tryParse(json['total_orders'].toString());
    totalOrderAmount = double.tryParse(json['total_order_amount'].toString());
    totalSize = int.tryParse(json['total_size'].toString());
    limit = int.tryParse(json['limit'].toString());
    offset = int.tryParse(json['offset'].toString());
    if (json['order_transactions'] != null) {
      orderTransactions = (json['order_transactions'] as List)
          .map((v) => AuctionOrderTransaction.fromJson(v))
          .toList();
    }
    if (json['type_wise_taxes_list'] != null) {
      typeWiseTaxesList = (json['type_wise_taxes_list'] as List)
          .map((v) => AuctionTypeWiseTaxes.fromJson(v))
          .toList();
    }
  }
}

// ─── Type-wise summary (used in header cards) ────────────────────────────────

class AuctionTypeWiseTaxes {
  String? name;
  List<AuctionTaxRateItem>? data;

  AuctionTypeWiseTaxes({this.name, this.data});

  AuctionTypeWiseTaxes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['data'] != null) {
      data = (json['data'] as List).map((v) => AuctionTaxRateItem.fromJson(v)).toList();
    }
  }
}

class AuctionTaxRateItem {
  String? name;
  double? taxRate;
  double? totalAmount;
  double? taxAmount;

  AuctionTaxRateItem({this.name, this.taxRate, this.totalAmount, this.taxAmount});

  AuctionTaxRateItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    taxRate = double.tryParse(json['tax_rate']?.toString() ?? '');
    totalAmount = double.tryParse(json['total_amount']?.toString() ?? '');
    taxAmount = double.tryParse(json['tax_amount']?.toString() ?? '');
  }
}

// ─── Order transaction ────────────────────────────────────────────────────────

class AuctionOrderTransaction {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidId;
  String? type;
  double? amount;
  String? currencyCode;
  String? paymentMethod;
  String? paymentStatus;
  String? createdAt;
  String? updatedAt;
  int? orderId;
  double? orderAmount;
  double? tax;
  AuctionVatAmountFormats? vatAmountFormats;
  AuctionProductSummary? auctionProduct;
  List<AuctionOrderTax>? orderTaxes;

  AuctionOrderTransaction({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidId,
    this.type,
    this.amount,
    this.currencyCode,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.orderId,
    this.orderAmount,
    this.tax,
    this.vatAmountFormats,
    this.auctionProduct,
    this.orderTaxes,
  });

  AuctionOrderTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    userId = json['user_id'];
    bidId = json['bid_id'];
    type = json['type'];
    amount = double.tryParse(json['amount']?.toString() ?? '');
    currencyCode = json['currency_code'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderId = json['order_id'];
    orderAmount = double.tryParse(json['order_amount']?.toString() ?? '');
    tax = double.tryParse(json['tax']?.toString() ?? '');
    vatAmountFormats = json['vat_amount_formats'] != null
        ? AuctionVatAmountFormats.fromJson(json['vat_amount_formats'])
        : null;
    auctionProduct = json['auction_product'] != null
        ? AuctionProductSummary.fromJson(json['auction_product'])
        : null;
    if (json['order_taxes'] != null) {
      orderTaxes = (json['order_taxes'] as List).map((v) => AuctionOrderTax.fromJson(v)).toList();
    }
  }
}

// ─── VAT amount formats ───────────────────────────────────────────────────────

class AuctionVatAmountFormats {
  double? totalVatAmount;
  List<AuctionVatGroup>? allVatGroups;

  AuctionVatAmountFormats({this.totalVatAmount, this.allVatGroups});

  AuctionVatAmountFormats.fromJson(Map<String, dynamic> json) {
    totalVatAmount = double.tryParse(json['total_vat_amount']?.toString() ?? '');
    if (json['all_vat_groups'] != null) {
      allVatGroups = (json['all_vat_groups'] as List).map((v) => AuctionVatGroup.fromJson(v)).toList();
    }
  }
}

class AuctionVatGroup {
  String? groupName;
  List<AuctionTaxRateItem>? data;

  AuctionVatGroup({this.groupName, this.data});

  AuctionVatGroup.fromJson(Map<String, dynamic> json) {
    groupName = json['group_name'];
    if (json['data'] != null) {
      data = (json['data'] as List).map((v) => AuctionTaxRateItem.fromJson(v)).toList();
    }
  }
}

// ─── Auction product summary (only fields needed for display) ─────────────────

class AuctionProductSummary {
  int? id;
  String? name;
  String? deliveryStatus;
  String? thumbnail;
  AuctionImageUrl? thumbnailFullUrl;

  AuctionProductSummary({this.id, this.name, this.deliveryStatus, this.thumbnail, this.thumbnailFullUrl});

  AuctionProductSummary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    deliveryStatus = json['delivery_status'];
    thumbnail = json['thumbnail'];
    thumbnailFullUrl = json['thumbnail_full_url'] != null
        ? AuctionImageUrl.fromJson(json['thumbnail_full_url'])
        : null;
  }
}

class AuctionImageUrl {
  String? key;
  String? path;
  int? status;

  AuctionImageUrl({this.key, this.path, this.status});

  AuctionImageUrl.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    path = json['path'];
    status = json['status'];
  }
}

// ─── Order tax line ───────────────────────────────────────────────────────────

class AuctionOrderTax {
  String? taxName;
  String? taxType;
  String? taxOn;
  double? taxRate;
  double? taxAmount;
  String? createdAt;

  AuctionOrderTax({this.taxName, this.taxType, this.taxOn, this.taxRate, this.taxAmount, this.createdAt});

  AuctionOrderTax.fromJson(Map<String, dynamic> json) {
    taxName = json['tax_name'];
    taxType = json['tax_type'];
    taxOn = json['tax_on'];
    taxRate = double.tryParse(json['tax_rate']?.toString() ?? '');
    taxAmount = double.tryParse(json['tax_amount']?.toString() ?? '');
    createdAt = json['created_at'];
  }
}
