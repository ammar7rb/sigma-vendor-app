class AuctionSetupAutoFillModel {
  bool? success;
  String? message;
  Data? data;

  AuctionSetupAutoFillModel({this.success, this.message, this.data});

  AuctionSetupAutoFillModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? description;
  int? remainingCount;

  Data({this.name, this.description, this.remainingCount});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'remaining_count': remainingCount,
    };
  }
}
