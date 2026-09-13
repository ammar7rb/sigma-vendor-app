class AuctionInfoModel {
  bool? success;
  String? message;
  Data? data;

  AuctionInfoModel({this.success, this.message, this.data});

  AuctionInfoModel.fromJson(Map<String, dynamic> json) {
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
  AuctionInfoData? auctionInfoData;
  int? remainingCount;

  Data({this.auctionInfoData, this.remainingCount});

  Data.fromJson(Map<String, dynamic> json) {
    auctionInfoData = json['data'] != null ? AuctionInfoData.fromJson(json['data']) : null;
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (auctionInfoData != null) {
      data['data'] = auctionInfoData!.toJson();
    }
    data['remaining_count'] = remainingCount;
    return data;
  }
}

class AuctionInfoData {
  int? entryFee;
  int? startingPrice;
  int? minimumIncrementAmount;
  int? maximumDecrementAmount;
  List<String>? taxNames;
  String? startTime;
  String? endTime;
  List<int>? taxIds;
  List<String>? tags;
  String? tagsCsv;

  AuctionInfoData(
      {this.entryFee,
        this.startingPrice,
        this.minimumIncrementAmount,
        this.maximumDecrementAmount,
        this.taxNames,
        this.startTime,
        this.endTime,
        this.taxIds,
        this.tags,
        this.tagsCsv});

  AuctionInfoData.fromJson(Map<String, dynamic> json) {
    entryFee = json['entry_fee'];
    startingPrice = json['starting_price'];
    minimumIncrementAmount = json['minimum_increment_amount'];
    maximumDecrementAmount = json['maximum_decrement_amount'];
    taxNames = json['tax_names'].cast<String>();
    startTime = json['start_time'];
    endTime = json['end_time'];
    taxIds = json['tax_ids'].cast<int>();
    tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    tagsCsv = json['tags_csv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['entry_fee'] = entryFee;
    data['starting_price'] = startingPrice;
    data['minimum_increment_amount'] = minimumIncrementAmount;
    data['maximum_decrement_amount'] = maximumDecrementAmount;
    data['tax_names'] = taxNames;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['tax_ids'] = taxIds;
    data['tags'] = tags;
    data['tags_csv'] = tagsCsv;
    return data;
  }
}