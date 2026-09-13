
class ImageResponseModel {
  bool? success;
  String? message;
  ImageResponseData? data;

  ImageResponseModel({this.success, this.message, this.data});

  ImageResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if(json['data'] is String){
      data = ImageResponseData(data: json['data']);
    } else {
      data = json['data'] != null ? ImageResponseData.fromJson(json['data']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    map['data'] = data?.toJson();
    return map;
  }
}

class ImageResponseData {
  String? data;
  int? remainingCount;

  ImageResponseData({this.data, this.remainingCount});

  ImageResponseData.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    remainingCount = json['remaining_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['data'] = data;
    map['remaining_count'] = remainingCount;
    return map;
  }
}
