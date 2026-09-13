class AuctionTitleSuggestionsModel {
  bool? success;
  String? message;
  Data? data;

  AuctionTitleSuggestionsModel({this.success, this.message, this.data});

  AuctionTitleSuggestionsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['success'] = success;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    return map;
  }
}

class Data {
  TitleData? data;
  int? remainingCount;

  Data({this.data, this.remainingCount});

  Data.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? TitleData.fromJson(json['data']) : null;
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    return {
      if (data != null) 'data': data!.toJson(),
      'remaining_count': remainingCount,
    };
  }
}

class TitleData {
  List<String>? titles;

  TitleData({this.titles});

  TitleData.fromJson(Map<String, dynamic> json) {
    titles = json['titles'] != null ? List<String>.from(json['titles']) : null;
  }

  Map<String, dynamic> toJson() {
    return {'titles': titles};
  }
}
