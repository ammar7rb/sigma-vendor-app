class AuctionShippingSetupModel {
  bool? success;
  String? message;
  Data? data;

  AuctionShippingSetupModel({this.success, this.message, this.data});

  AuctionShippingSetupModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  AuctionAiShippingData? auctionAiShippingData;
  int? remainingCount;

  Data({this.auctionAiShippingData, this.remainingCount});

  Data.fromJson(Map<String, dynamic> json) {
    auctionAiShippingData = json['data'] != null ? AuctionAiShippingData.fromJson(json['data']) : null;
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (auctionAiShippingData != null) {
      data['data'] = auctionAiShippingData!.toJson();
    }
    data['remaining_count'] = remainingCount;
    return data;
  }
}

class AuctionAiShippingData {
  double? shippingFee;
  String? returnPolicy;

  AuctionAiShippingData({this.shippingFee, this.returnPolicy});

  AuctionAiShippingData.fromJson(Map<String, dynamic> json) {
    shippingFee = (json['shipping_fee'] as num?)?.toDouble();
    returnPolicy = json['return_policy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shipping_fee'] = shippingFee;
    data['return_policy'] = returnPolicy;
    return data;
  }
}