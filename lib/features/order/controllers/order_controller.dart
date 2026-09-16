import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order/domain/services/order_service_interface.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_list_filter_model.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/helper/validation_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

class OrderController extends ChangeNotifier {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});

  String? _paymentStatus;
  String? get paymentStatus => _paymentStatus;
  String? _orderStatus;
  String? get orderStatus => _orderStatus;
  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

  final bool _selfDelivery = false;
  final bool _thirdPartyDelivery = false;
  bool get selfDelivery => _selfDelivery;
  bool get thirdPartyDelivery => _thirdPartyDelivery;

  FilePickerResult? _otherFile;
  FilePickerResult? get otherFile => _otherFile;

  PlatformFile? fileNamed;
  File? file;
  int? fileSize;
  bool assigning = false;
  final int _offset = 1;
  int get offset => _offset;
  DateTime? _startDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  DateTime? get startDate => _startDate;
  DateFormat get dateFormat => _dateFormat;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _orderTypeIndex = 0;
  int get orderTypeIndex => _orderTypeIndex;

  String _orderType = 'all';
  String get orderType => _orderType;

  String? _addOrderStatusErrorText;
  String? get addOrderStatusErrorText => _addOrderStatusErrorText;

  List<String>? _paymentImageList;
  List<String>? get paymentImageList => _paymentImageList;

  bool _isAddressLoading = false;
  bool get isAddressLoading => _isAddressLoading;

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  OrderListFilterModel filterModel = OrderListFilterModel();

  Future<void> getOrderList(BuildContext? context, int offset, String status,
      OrderListFilterModel? filter,
      {bool reload = true}) async {
    if (reload) {
      _orderModel = null;
    }
    _isLoading = true;
    _isFilterActive = false;
    ApiResponse apiResponse =
        await orderServiceInterface.getOrderList(offset, status, filter);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _orderModel = OrderModel.fromJson(apiResponse.response!.data);
      } else {
        _orderModel!.totalSize =
            OrderModel.fromJson(apiResponse.response!.data).totalSize;
        _orderModel!.offset =
            OrderModel.fromJson(apiResponse.response!.data).offset;
        _orderModel!.orders!
            .addAll(OrderModel.fromJson(apiResponse.response!.data).orders!);
      }

      for (Order order in _orderModel!.orders!) {
        _paymentStatus = order.paymentStatus;
      }

      if (filter != null && ValidationHelper.canOrderFilter(filter)) {
        _isFilterActive = true;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setIndex(BuildContext context, int index, {bool notify = true}) {
    _orderTypeIndex = index;
    filterModel = OrderListFilterModel();
    resetFilters(refreshOrderList: false, notify: false);
    if (_orderTypeIndex == 0) {
      _orderType = 'all';
      getOrderList(context, 1, 'all', null);
    } else if (_orderTypeIndex == 1) {
      _orderType = 'pending';
      getOrderList(context, 1, 'pending', null);
    } else if (_orderTypeIndex == 2) {
      _orderType = 'processing';
      getOrderList(context, 1, 'processing', null);
    } else if (_orderTypeIndex == 3) {
      _orderType = 'delivered';
      getOrderList(context, 1, 'delivered', null);
    } else if (_orderTypeIndex == 4) {
      _orderType = 'returned';
      getOrderList(context, 1, 'returned', null);
    } else if (_orderTypeIndex == 5) {
      _orderType = 'failed';
      getOrderList(context, 1, 'failed', null);
    } else if (_orderTypeIndex == 6) {
      _orderType = 'canceled';
      getOrderList(context, 1, 'canceled', null);
    } else if (_orderTypeIndex == 7) {
      _orderType = 'confirmed';
      getOrderList(context, 1, 'confirmed', null);
    } else if (_orderTypeIndex == 8) {
      _orderType = 'out_for_delivery';
      getOrderList(context, 1, 'out_for_delivery', null);
    } else if (_orderTypeIndex == 10) {
      _orderType = 'active';
      getOrderList(context, 1, 'active', null);
    } else if (_orderTypeIndex == 9) {
      _orderType = 'insurance_pending';
      getOrderList(context, 1, 'insurance_pending', null);
    } else if (_orderTypeIndex == 11) {
      _orderType = 'disputed';
      getOrderList(context, 1, 'disputed', null);
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context, {DateTime? dateTime}) async {
    await showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((date) {
      _startDate = date;
      notifyListeners();
    });
  }

  Future<ApiResponse> editShippingAndBillingAddress({
    String? orderID,
    String? addressType,
    String? contactPersonName,
    String? phone,
    String? city,
    String? zip,
    String? address,
    String? email,
    String? latitude,
    String? longitude,
  }) async {
    assigning = true;
    _isAddressLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderServiceInterface.orderAddressEdit(
        orderID: orderID,
        addressType: addressType,
        contactPersonName: contactPersonName,
        phone: phone,
        city: city,
        zip: zip,
        address: address,
        email: email,
        latitude: latitude,
        longitude: longitude);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Navigator.of(Get.context!).pop();
      showCustomSnackBarWidget(
          getTranslated('address_updated_successfully', Get.context!),
          Get.context!,
          isToaster: true,
          isError: false);
      Provider.of<OrderDetailsController>(Get.context!, listen: false)
          .getOrderDetails(orderID.toString());
    } else {
      assigning = false;
      ApiChecker.checkApi(apiResponse);
    }
    _isAddressLoading = false;
    notifyListeners();
    return apiResponse;
  }

  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  DateFormat get dateFormatFilter => _dateFormat;

  void selectFilterDate(String type, BuildContext context) {
    final bool isEnd = type == 'end';
    final DateTime firstDate =
        isEnd && _startDateFilter != null ? _startDateFilter! : DateTime(2022);
    final DateTime initialDate = isEnd && _startDateFilter != null
        ? (_endDateFilter != null &&
                !_endDateFilter!.isBefore(_startDateFilter!)
            ? _endDateFilter!
            : _startDateFilter!)
        : (type == 'start' && _startDateFilter != null
            ? _startDateFilter!
            : DateTime.now());

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    ).then((date) {
      if (date == null) return;
      if (type == 'start') {
        _startDateFilter = date;
        filterModel.startDate = date.toString();
        if (_endDateFilter != null && _endDateFilter!.isBefore(date)) {
          _endDateFilter = null;
          filterModel.endDate = null;
        }
      } else {
        _endDateFilter = date;
        filterModel.endDate = date.toString();
      }
      notifyListeners();
    });
  }

  void resetFilters({bool notify = true, bool refreshOrderList = true}) {
    filterModel = OrderListFilterModel();
    _startDateFilter = null;
    _endDateFilter = null;
    Provider.of<CustomerController>(Get.context!, listen: false)
        .resetCustomerId(isUpdate: true, customerId: -1);
    Provider.of<CartController>(Get.context!, listen: false)
        .emptyCustomerTextField();
    if (refreshOrderList) {
      getOrderList(Get.context!, 1, _orderStatus ?? '', null);
    }
    if (notify) {
      notifyListeners();
    }
  }
}
