import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart' show OpenFile;
import 'package:path/path.dart' as path show join;
import 'package:permission_handler/permission_handler.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_bid_list_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_filter_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_sales_report_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_vat_report_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/auction_product_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:intl/intl.dart';

class AuctionProductController extends ChangeNotifier {
  final AuctionProductServiceInterface auctionProductServiceInterface;
  AuctionProductController({required this.auctionProductServiceInterface});

  int? _paymentMethodIndex;
  int? get paymentMethodIndex => _paymentMethodIndex;

  String? _selectedPaymentMethod;
  String? get selectedPaymentMethod => _selectedPaymentMethod;

  bool _isCODChecked = false;
  bool get isCODChecked => _isCODChecked;

  bool _isWalletChecked = false;
  bool get isWalletChecked => _isWalletChecked;

  bool _isOfflineChecked = false;
  bool get isOfflineChecked => _isOfflineChecked;

  int _offlineMethodSelectedIndex = -1;
  int get offlineMethodSelectedIndex => _offlineMethodSelectedIndex;

  double? _cashChangesAmount;
  double? get cashChangesAmount => _cashChangesAmount;

  void setOfflineChecked(String type, {bool notify = true}) {
    _isCODChecked = false;
    _isWalletChecked = false;
    _isOfflineChecked = false;
    _paymentMethodIndex = -1;
    _selectedPaymentMethod = '';

    if (type == 'cod') {
      _isCODChecked = true;
    } else if (type == 'wallet') {
      _isWalletChecked = true;
    } else if (type == 'offline') {
      _isOfflineChecked = true;
    }
    if(notify) {
      notifyListeners();
    }
  }

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    _selectedPaymentMethod = name;
    _isCODChecked = false;
    _isWalletChecked = false;
    _isOfflineChecked = false;
    notifyListeners();
  }

  void setOfflinePaymentMethodSelectedIndex(int index) {
    _offlineMethodSelectedIndex = index;
    notifyListeners();
  }

  void onChangeCashChangesAmount(double? amount) {
    _cashChangesAmount = amount;
    notifyListeners();
  }

  void updatePaymentSelection() {
    // This can be used to trigger any logic after saving payment selection
    notifyListeners();
  }

  AuctionProductListModel? _pendingModel;
  AuctionProductListModel? get pendingModel => _pendingModel;
  bool _isPendingLoading = false;
  bool get isPendingLoading => _isPendingLoading;

  AuctionProductListModel? _rejectedModel;
  AuctionProductListModel? get rejectedModel => _rejectedModel;
  bool _isRejectedLoading = false;
  bool get isRejectedLoading => _isRejectedLoading;

  AuctionProductListModel? _auctionListModel;
  AuctionProductListModel? get auctionListModel => _auctionListModel;
  AuctionCounts? get auctionCounts => _auctionListModel?.counts;
  AuctionCounts? get auctionRequestCounts => _pendingModel?.counts ?? _rejectedModel?.counts;
  bool _isAuctionListLoading = false;
  bool get isAuctionListLoading => _isAuctionListLoading;

  final Map<int, AuctionFilterParams> _tabFilterParams = {};

  AuctionFilterParams filterParamsForTab(int tabIndex) => _tabFilterParams[tabIndex] ?? const AuctionFilterParams();

  int activeFilterCountForTab(int tabIndex) => filterParamsForTab(tabIndex).activeCountForTab(tabIndex);

  void updateFilter(int tabIndex, AuctionFilterParams params) {
    _tabFilterParams[tabIndex] = params;
    notifyListeners();
  }

  void resetFilter(int tabIndex) {
    _tabFilterParams[tabIndex] = const AuctionFilterParams();
    notifyListeners();
  }

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  bool _isCanceling = false;
  bool get isCanceling => _isCanceling;

  AuctionProductDetailsModel? _auctionProductDetailsModel;
  AuctionProductDetailsModel? get auctionProductDetailsModel => _auctionProductDetailsModel;
  bool _isDetailsLoading = false;
  bool get isDetailsLoading => _isDetailsLoading;

  AuctionProduct? _auctionProductForEdit;
  AuctionProduct? get auctionProductForEdit => _auctionProductForEdit;

  Future<void> getAuctionProductForEdit(int id) async {
    final ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionProductDetails(id);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      try {
        final dynamic raw = apiResponse.response!.data;
        final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
        final productJson = map['product'] ?? map;
        _auctionProductForEdit = AuctionProduct.fromJson(Map<String, dynamic>.from(productJson as Map));
      } catch (_) {
        _auctionProductForEdit = null;
      }
      notifyListeners();
    }
  }

  Future<void> getAuctionList({
    required int tabIndex,
    String auctionStatus = '',
    String search = '',
    required int offset,
    bool reload = false,
    bool isUpdate = true,
  }) async {
    if (reload || offset == 1) {
      _auctionListModel = null;
      _isAuctionListLoading = true;
      if(isUpdate) {
        notifyListeners();
      }
    }

    final AuctionFilterParams tabFilter = filterParamsForTab(tabIndex);

    final Map<String, dynamic> extraParams = tabFilter.toQueryParams()..remove('search');

    if (auctionStatus.isNotEmpty) extraParams.remove('auction_status');

    if (auctionStatus.isEmpty && !extraParams.containsKey('active_status')) {
      extraParams['active_status'] = ['active'];
    }

    ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionList(
      offset: offset,
      auctionStatus: auctionStatus,
      search: search,
      extraParams: extraParams,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _auctionListModel = AuctionProductListModel.fromJson(apiResponse.response!.data);
      } else {
        final newData = AuctionProductListModel.fromJson(apiResponse.response!.data);
        _auctionListModel?.products?.addAll(newData.products ?? []);
        _auctionListModel?.offset = newData.offset;
        _auctionListModel?.totalSize = newData.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isAuctionListLoading = false;
    notifyListeners();
  }

  Future<void> getAuctionProductList(String approvalStatus, int offset, {bool reload = false, bool isUpdate = true}) async {
    if (approvalStatus == 'pending') {
      if (reload || offset == 1) {
        _pendingModel = null;
        _isPendingLoading = true;
        if(isUpdate) {
          notifyListeners();
        }
      }
    } else {
      if (reload || offset == 1) {
        _rejectedModel = null;
        _isRejectedLoading = true;
        if(isUpdate) {
          notifyListeners();
        }
      }
    }

    ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionProductList(
      offset: offset,
      approvalStatus: approvalStatus,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if (approvalStatus == 'pending') {
        if (offset == 1) {
          _pendingModel = AuctionProductListModel.fromJson(apiResponse.response!.data);
        } else {
          _pendingModel?.products?.addAll(
            AuctionProductListModel.fromJson(apiResponse.response!.data).products ?? [],
          );
          _pendingModel?.offset = AuctionProductListModel.fromJson(apiResponse.response!.data).offset;
          _pendingModel?.totalSize = AuctionProductListModel.fromJson(apiResponse.response!.data).totalSize;
        }
        _isPendingLoading = false;
      } else {
        if (offset == 1) {
          _rejectedModel = AuctionProductListModel.fromJson(apiResponse.response!.data);
        } else {
          _rejectedModel?.products?.addAll(AuctionProductListModel.fromJson(apiResponse.response!.data).products ?? []);
          _rejectedModel?.offset = AuctionProductListModel.fromJson(apiResponse.response!.data).offset;
          _rejectedModel?.totalSize = AuctionProductListModel.fromJson(apiResponse.response!.data).totalSize;
        }
        _isRejectedLoading = false;
      }
    } else {
      if (approvalStatus == 'pending') {
        _isPendingLoading = false;
      } else {
        _isRejectedLoading = false;
      }
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }


  Future<bool> toggleAuctionStatus(int id) async {
    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.toggleAuctionStatus(id);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelAuctionProduct(int id) async {
    _isCanceling = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.cancelAuctionProduct(id);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isCanceling = false;
        notifyListeners();
        return true;
      } else {
        _isCanceling = false;
        ApiChecker.checkApi(apiResponse);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isCanceling = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAuctionProduct(int id) async {
    _isDeleting = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.deleteAuctionProduct(id);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isDeleting = false;
        notifyListeners();
        return true;
      } else {
        _isDeleting = false;
        ApiChecker.checkApi(apiResponse);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getAuctionProductDetails(int id, {bool reload = true, String auctionStatus = ''}) async {
    if (reload) {
      _auctionProductDetailsModel = null;
    }
    _isDetailsLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionProductDetails(id, auctionStatus: auctionStatus);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      try {
        final dynamic raw = apiResponse.response!.data;
        Map<String, dynamic> map = {};

        if (raw is Map<String, dynamic>) {
          map = raw;
        } else if (raw is Map) {
          map = Map<String, dynamic>.from(raw);
        }

        if (map['data'] is Map && map['product'] == null) {
          map = Map<String, dynamic>.from(map['data']);
        }

        if (map['product'] == null && map.isNotEmpty) {
          map = {'product': map};
        }

        _auctionProductDetailsModel = AuctionProductDetailsModel.fromJson(map);
      } catch (_) {
        _auctionProductDetailsModel = null;
      }
      _isDetailsLoading = false;
    } else {
      _isDetailsLoading = false;
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }

  AuctionBidListModel? _bidListModel;
  AuctionBidListModel? get bidListModel => _bidListModel;
  bool _isBidListLoading = false;
  bool get isBidListLoading => _isBidListLoading;

  Future<void> getBidList(int auctionProductId, int offset) async {
    if (offset == 1) {
      _bidListModel = null;
      _isBidListLoading = true;
      notifyListeners();
    }

    ApiResponse apiResponse = await auctionProductServiceInterface.getBidList(auctionProductId, offset: offset);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _bidListModel = AuctionBidListModel.fromJson(apiResponse.response!.data);
      } else {
        final newData = AuctionBidListModel.fromJson(apiResponse.response!.data);
        _bidListModel?.bids?.addAll(newData.bids ?? []);
        _bidListModel?.offset = newData.offset;
        _bidListModel?.totalSize = newData.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isBidListLoading = false;
    notifyListeners();
  }

  bool _isTrackingUrlSaving = false;
  bool get isTrackingUrlSaving => _isTrackingUrlSaving;

  Future<bool> uploadTrackingUrl(int auctionProductId, String trackingUrl) async {
    _isTrackingUrlSaving = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.uploadTrackingUrl(auctionProductId, trackingUrl);

      _isTrackingUrlSaving = false;
      notifyListeners();

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      _isTrackingUrlSaving = false;
      notifyListeners();
      return false;
    }
  }

  bool _isAddressUpdating = false;
  bool get isAddressUpdating => _isAddressUpdating;

  Future<bool> updateAuctionAddress({
    required int auctionProductId,
    required String addressType,
    String? contactPersonName,
    String? phone,
    String? city,
    String? zip,
    String? email,
    String? address,
    String? country,
  }) async {
    _isAddressUpdating = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.updateAuctionAddress(
        auctionProductId: auctionProductId,
        addressType: addressType,
        contactPersonName: contactPersonName,
        phone: phone,
        city: city,
        zip: zip,
        email: email,
        address: address,
        country: country,
      );

      _isAddressUpdating = false;
      notifyListeners();

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      _isAddressUpdating = false;
      notifyListeners();
      return false;
    }
  }

  bool _isPaymentStatusUpdating = false;
  bool get isPaymentStatusUpdating => _isPaymentStatusUpdating;

  Future<bool> updatePaymentStatus(
    int id, {
    required String paymentStatus,
  }) async {
    _isPaymentStatusUpdating = true;
    notifyListeners();
    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.updatePaymentStatus(
        id,
        paymentStatus: paymentStatus,
      );
      _isPaymentStatusUpdating = false;
      notifyListeners();
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      _isPaymentStatusUpdating = false;
      notifyListeners();
      return false;
    }
  }

  bool _isDeliveryStatusUpdating = false;
  bool get isDeliveryStatusUpdating => _isDeliveryStatusUpdating;

  Future<bool> updateDeliveryStatus(int id, {required String deliveryStatus}) async {
    _isDeliveryStatusUpdating = true;
    notifyListeners();
    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.updateDeliveryStatus(id, deliveryStatus: deliveryStatus);
      _isDeliveryStatusUpdating = false;
      notifyListeners();
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      _isDeliveryStatusUpdating = false;
      notifyListeners();
      return false;
    }
  }

  void selectWithdrawMethodById(
    WalletController walletController,
    int? id, {
    Map<String, dynamic>? initialFieldValues,
  }) {
    if (id != null) {
      final allMethods = [
        ...walletController.myMethodsIds,
        ...walletController.methodsIds,
      ];
      final match = allMethods.firstWhere((m) => m?.id == id, orElse: () => null);

      if (match != null) {
        walletController.setMethodTypeIndex(match);
        if (initialFieldValues != null && match.type == 'other') {
          for (int i = 0; i < walletController.keyList.length; i++) {
            final key = walletController.keyList[i];
            if (key != null &&
                initialFieldValues.containsKey(key) && i < walletController.inputFieldControllerList.length) {
              walletController.inputFieldControllerList[i].text = initialFieldValues[key]?.toString() ?? '';
            }
          }
        }
        return;
      }
    }
    walletController.setDefaultPaymentMethod();
  }

  bool _isWithdrawRequestLoading = false;
  bool get isWithdrawRequestLoading => _isWithdrawRequestLoading;

  Future<bool> submitWithdrawRequest(Map<String, dynamic> data) async {
    _isWithdrawRequestLoading = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.submitWithdrawRequest(data);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isWithdrawRequestLoading = false;
        final responseData = apiResponse.response!.data;
        if (responseData != null && _auctionProductDetailsModel != null) {
          _auctionProductDetailsModel!.auctionWithdrawInfo = AuctionWithdrawInfo.fromJson(Map<String, dynamic>.from(responseData));
        }
        notifyListeners();
        return true;
      } else {
        _isWithdrawRequestLoading = false;
        ApiChecker.checkApi(apiResponse);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isWithdrawRequestLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool _isPayCommissionLoading = false;
  bool get isPayCommissionLoading => _isPayCommissionLoading;

  bool _isInvoiceLoading = false;
  bool get isInvoiceLoading => _isInvoiceLoading;

  Future<String?> payCommission(int id, Map<String, dynamic> data) async {
    _isPayCommissionLoading = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await auctionProductServiceInterface.payCommission(id, data);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isPayCommissionLoading = false;
        notifyListeners();
        
        final responseData = apiResponse.response!.data;
        if (responseData is Map && responseData.containsKey('redirect_link')) {
           return responseData['redirect_link']?.toString() ?? '';
        }
        
        return '';
      } else {
        _isPayCommissionLoading = false;
        ApiChecker.checkApi(apiResponse);
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isPayCommissionLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<ApiResponse> getAuctionInvoice(int auctionId) async {
    _isInvoiceLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionInvoice(auctionId);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      await _requestPermissions();
      final downloadsDirectory = Directory('/storage/emulated/0/Download');
      List<int> intList = List<int>.from(apiResponse.response!.data);

      String fileName = '$auctionId.pdf';
      var filePath = path.join(downloadsDirectory.path, fileName);
      int fileCounter = 1;
      while (await File(filePath).exists()) {
        fileName = '$auctionId($fileCounter).pdf';
        filePath = path.join(downloadsDirectory.path, fileName);
        fileCounter++;
      }

      final file = File(filePath);
      await file.writeAsBytes(intList);
      await OpenFile.open(filePath);
      showCustomSnackBarWidget(
        getTranslated('invoice_downloaded_successfully', Get.context!),
        Get.context!,
        sanckBarType: SnackBarType.success,
      );
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isInvoiceLoading = false;
    notifyListeners();
    return apiResponse;
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // ─── Auction VAT Report ────────────────────────────────────────────────────

  AuctionVatReportModel? _auctionVatReportModel;
  AuctionVatReportModel? get auctionVatReportModel => _auctionVatReportModel;

  bool _isAuctionVatReportLoading = false;
  bool get isAuctionVatReportLoading => _isAuctionVatReportLoading;

  DateTime? _vatStartDate;
  DateTime? get vatStartDate => _vatStartDate;

  DateTime? _vatEndDate;
  DateTime? get vatEndDate => _vatEndDate;

  bool _isVatFilterActive = false;
  bool get isVatFilterActive => _isVatFilterActive;

  final DateFormat _vatDateFormat = DateFormat('d MMM yy');
  DateFormat get vatDateFormat => _vatDateFormat;

  void setVatInitialDateRange() {
    _vatEndDate = DateTime.now();
    _vatStartDate = _vatEndDate!.subtract(const Duration(days: 7));
    _isVatFilterActive = true;
  }

  void resetVatData({bool isUpdate = true}) {
    _vatStartDate = null;
    _vatEndDate = null;
    _isVatFilterActive = false;
    if (isUpdate) notifyListeners();
  }

  void setVatFilterActive(bool value) {
    _isVatFilterActive = value;
    notifyListeners();
  }

  void selectVatDate(String type, BuildContext context) {
    final bool isEnd = type == 'end';
    final DateTime firstDate = isEnd && _vatStartDate != null ? _vatStartDate! : DateTime(1900);
    final DateTime initialDate = isEnd && _vatStartDate != null
        ? (_vatEndDate != null && !_vatEndDate!.isBefore(_vatStartDate!) ? _vatEndDate! : _vatStartDate!)
        : (type == 'start' && _vatStartDate != null ? _vatStartDate! : DateTime.now());

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    ).then((date) {
      if (date == null) return;
      final combined = DateTime(date.year, date.month, date.day);
      if (type == 'start') {
        _vatStartDate = combined;
        if (_vatEndDate != null && _vatEndDate!.isBefore(combined)) {
          _vatEndDate = null;
        }
      } else {
        _vatEndDate = combined;
      }
      notifyListeners();
    });
  }

  Future<void> getAuctionVatReport(int offset, {String? startDate, String? endDate}) async {
    if (offset == 1) {
      _auctionVatReportModel = null;
      _isAuctionVatReportLoading = true;
      notifyListeners();
    }

    final ApiResponse apiResponse = await auctionProductServiceInterface.getAuctionVatReport(
      limit: 10,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _auctionVatReportModel = AuctionVatReportModel.fromJson(apiResponse.response!.data);
      } else {
        final newData = AuctionVatReportModel.fromJson(apiResponse.response!.data);
        _auctionVatReportModel?.orderTransactions?.addAll(newData.orderTransactions ?? []);
        _auctionVatReportModel?.offset = newData.offset;
        _auctionVatReportModel?.totalSize = newData.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isAuctionVatReportLoading = false;
    notifyListeners();
  }

  // ─── Sales Report ──────────────────────────────────────────────────────────

  AuctionSalesReportModel? _salesReportModel;
  AuctionSalesReportModel? get salesReportModel => _salesReportModel;

  bool _isSalesReportLoading = false;
  bool get isSalesReportLoading => _isSalesReportLoading;

  Future<void> getSalesReport({
    required int offset,
    String dateType = '',
    String? from,
    String? to,
    String search = '',
    int limit = 10,
    bool reload = false,
  }) async {
    if (reload || offset == 1) {
      _salesReportModel = null;
      _isSalesReportLoading = true;
      notifyListeners();
    }

    final ApiResponse apiResponse =
        await auctionProductServiceInterface.getSalesReport(
      offset: offset,
      dateType: dateType,
      from: from,
      to: to,
      search: search,
      limit: limit,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (offset == 1) {
        _salesReportModel = AuctionSalesReportModel.fromJson(data);
      } else {
        final newData = AuctionSalesReportModel.fromJson(data);
        _salesReportModel?.auctions?.addAll(newData.auctions ?? []);
        _salesReportModel?.offset = newData.offset;
        _salesReportModel?.totalSize = newData.totalSize;
        // keep summary stats from first page
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isSalesReportLoading = false;
    notifyListeners();
  }
}