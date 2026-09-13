class AuctionGeneralSetupModel {
  bool? success;
  String? message;
  AuctionGeneralSetupData? auctionGeneralSetupModel;

  AuctionGeneralSetupModel({this.success, this.message, this.auctionGeneralSetupModel});

  AuctionGeneralSetupModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    auctionGeneralSetupModel = json['data'] != null ? AuctionGeneralSetupData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (auctionGeneralSetupModel != null) {
      data['data'] = auctionGeneralSetupModel!.toJson();
    }
    return data;
  }
}

class AuctionGeneralSetupData {
  Data? data;
  int? remainingCount;

  AuctionGeneralSetupData({this.data, this.remainingCount});

  AuctionGeneralSetupData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['remaining_count'] = remainingCount;
    return data;
  }
}

class Data {
  String? productType;
  String? categoryName;
  String? brandName;
  String? itemCondition;
  int? categoryId;
  int? brandId;

  Data(
      {this.productType,
        this.categoryName,
        this.brandName,
        this.itemCondition,
        this.categoryId,
        this.brandId});

  Data.fromJson(Map<String, dynamic> json) {
    productType = json['product_type'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    itemCondition = json['item_condition'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_type'] = productType;
    data['category_name'] = categoryName;
    data['brand_name'] = brandName;
    data['item_condition'] = itemCondition;
    data['category_id'] = categoryId;
    data['brand_id'] = brandId;
    return data;
  }
}