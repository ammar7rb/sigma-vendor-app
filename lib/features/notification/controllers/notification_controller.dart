import 'package:flutter/cupertino.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/data/model/response/response_model.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/auction_notification_model.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/notification_model.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/services/notification_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class NotificationController with ChangeNotifier{

  final NotificationServiceInterface notificationServiceInterface ;
  NotificationController({required this.notificationServiceInterface});


  NotificationItemModel? notificationModel;

  AuctionNotificationListModel? _auctionNotificationModel;
  AuctionNotificationListModel? get auctionNotificationModel => _auctionNotificationModel;

  bool _isAuctionNotificationLoading = false;
  bool get isAuctionNotificationLoading => _isAuctionNotificationLoading;


  Future<void> getNotificationList(int offset) async{
    ApiResponse apiResponse = await notificationServiceInterface.getNotificationList(offset);
    if(apiResponse.response?.statusCode == 200) {
      if(offset == 1){
        notificationModel = NotificationItemModel.fromJson(apiResponse.response?.data);
      }else{
        notificationModel?.notification?.addAll(NotificationItemModel.fromJson(apiResponse.response?.data).notification!);
        notificationModel?.offset = NotificationItemModel.fromJson(apiResponse.response?.data).offset;
        notificationModel?.totalSize = NotificationItemModel.fromJson(apiResponse.response?.data).totalSize;
      }
    }else{
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }

  Future<void> getAuctionNotificationList(int offset, {int limit = 10}) async {
    if (offset == 1) {
      _auctionNotificationModel = null;
      _isAuctionNotificationLoading = true;
      notifyListeners();
    }

    ApiResponse apiResponse = await notificationServiceInterface
        .getAuctionNotificationList(limit: limit, offset: offset);

    if (apiResponse.response?.statusCode == 200) {
      if (offset == 1) {
        _auctionNotificationModel =
            AuctionNotificationListModel.fromJson(apiResponse.response!.data);
      } else {
        final newData =
            AuctionNotificationListModel.fromJson(apiResponse.response!.data);
        _auctionNotificationModel?.notifications?.addAll(newData.notifications ?? []);
        _auctionNotificationModel?.offset = newData.offset;
        _auctionNotificationModel?.totalSize = newData.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isAuctionNotificationLoading = false;
    notifyListeners();
  }

  Future<void> markAuctionNotificationSeen({int? id}) async {
    ApiResponse apiResponse =
        await notificationServiceInterface.markAuctionNotificationSeen(id: id);

    if (apiResponse.response?.statusCode == 200) {
      final data = apiResponse.response!.data;

      if (id != null) {
        try {
          _auctionNotificationModel?.notifications
              ?.firstWhere((n) => n.id == id)
              .isRead = true;
        } catch (_) {}
      }

      final unreadCount = int.tryParse('${data['unread_count']}');
      if (unreadCount != null && _auctionNotificationModel != null) {
        _auctionNotificationModel!.newNotification = unreadCount;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> seenNotification(int id) async{
    ResponseModel responseModel = await notificationServiceInterface.seenNotification(id);
    if(responseModel.isSuccess){
      getNotificationList(1);
    }
    notifyListeners();
  }
}