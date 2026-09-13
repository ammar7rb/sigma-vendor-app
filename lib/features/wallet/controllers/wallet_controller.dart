import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/withdraw_model.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/domain/models/payment_information_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class WalletController with ChangeNotifier {
  final WalletServiceInterface walletServiceInterface;
  WalletController({required this.walletServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  SellerBalanceModel? _sellerBalance;
  SellerBalanceModel? get sellerBalance => _sellerBalance;
  double get availableBalance => _sellerBalance?.summary['available'] ?? 0;
  Map<String, dynamic>? _dashboardOverview;
  Map<String, dynamic>? get dashboardOverview => _dashboardOverview;

  Future<void> getSellerDashboardOverview() async {
    final response = await walletServiceInterface.getSellerDashboardOverview();
    if (response.response != null &&
        response.response!.statusCode == 200 &&
        response.response!.data is Map) {
      _dashboardOverview =
          Map<String, dynamic>.from(response.response!.data as Map);
      notifyListeners();
      return;
    }
    ApiChecker.checkApi(response);
  }

  Future<bool> getSellerBalance([BuildContext? context]) async {
    try {
      final response = await walletServiceInterface.getSellerBalance(limit: 20);
      if (response.response?.statusCode == 200 &&
          response.response?.data is Map) {
        _sellerBalance = SellerBalanceModel.fromJson(
            Map<String, dynamic>.from(response.response!.data));
        notifyListeners();
        return true;
      }
    } catch (_) {/* Keep the last successful snapshot. */}
    return false;
  }

  bool _isFunding = false;
  bool get isFunding => _isFunding;

  Future<String?> payOperatingBalance(
      {required String amount,
      required String paymentMethod,
      String walletTarget = 'operating'}) async {
    if (_isFunding) return null;
    _isFunding = true;
    notifyListeners();
    try {
      final response = await walletServiceInterface.payOperatingBalance(
          amount: amount,
          paymentMethod: paymentMethod,
          walletTarget: walletTarget);
      if (response.response != null && response.response!.statusCode == 200) {
        final data = response.response!.data;
        await getSellerBalance();
        notifyListeners();
        return data is Map ? data['redirect_link']?.toString() : null;
      }
      ApiChecker.checkApi(response);
      notifyListeners();
      return null;
    } finally {
      _isFunding = false;
      notifyListeners();
    }
  }

  Future<bool> submitOfflineBalancePayment(
      {required String amount,
      required int methodId,
      required Map<String, String> methodInformations,
      required XFile paymentProof,
      String? paymentNote,
      String walletTarget = 'operating'}) async {
    if (_isFunding) return false;
    _isFunding = true;
    notifyListeners();
    try {
      final response = await walletServiceInterface.submitOfflineBalancePayment(
          amount: amount,
          methodId: methodId,
          methodInformations: methodInformations,
          paymentProof: paymentProof,
          paymentNote: paymentNote,
          walletTarget: walletTarget);
      if (response.response != null && response.response!.statusCode == 200) {
        await getSellerBalance();
        notifyListeners();
        return true;
      }
      ApiChecker.checkApi(response);
      notifyListeners();
      return false;
    } finally {
      _isFunding = false;
      notifyListeners();
    }
  }

  WithdrawModel? withdrawModel;
  List<WithdrawModel> methodList = [];
  MethodModel? methodSelected;
  List<MethodModel?> methodsIds = [];
  List<MethodModel?> myMethodsIds = [];

  List<String> inputValueList = [];
  bool validityCheck = false;

  PaymentInformationModel? _paymentInformationModel;
  PaymentInformationModel? get paymentInformationModel =>
      _paymentInformationModel;

  void setTitle(int index, String title) {
    inputFieldControllerList[index].text = title;
  }

  List<TextEditingController> inputFieldControllerList = [];
  void getInputFieldList() {
    inputFieldControllerList = [];
    if (methodSelected?.methodFields != null) {
      for (int i = 0; i < (methodSelected?.methodFields?.length ?? 0); i++) {
        inputFieldControllerList.add(TextEditingController());
      }
    }
  }

  List<String?> keyList = [];

  void setMethodTypeIndex(MethodModel? index, {bool notify = true}) {
    methodSelected = index;

    keyList = [];
    if (methodSelected?.methodFields != null) {
      for (int i = 0; i < (methodSelected?.methodFields?.length ?? 0); i++) {
        keyList.add(methodSelected?.methodFields![i].inputName);
      }
      getInputFieldList();
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> getWithdrawMethods(BuildContext context,
      {bool includeGlobalMethods = false}) async {
    methodList = [];
    methodsIds = [];
    await getPaymentInfoList();

    // The regular seller wallet can request withdrawals only through a
    // seller-owned destination that was approved and activated by the admin.
    // The global method catalog is kept only for the legacy auction flow.
    if (includeGlobalMethods) {
      ApiResponse response =
          await walletServiceInterface.getDynamicWithDrawMethod();
      final raw = response.response?.data;
      final methods = raw is Map
          ? (raw['data'] as List? ?? const [])
          : (raw as List? ?? const []);
      for (final method in methods) {
        if (method is Map) {
          final withdraw =
              WithdrawModel.fromJson(Map<String, dynamic>.from(method));
          methodList.add(withdraw);
          methodsIds.add(MethodModel(
            id: withdraw.id,
            inputName: withdraw.methodName,
            type: 'other',
            methodFields: withdraw.methodFields,
            isDefault: withdraw.isDefault,
          ));
        }
      }
    }

    setDefaultPaymentMethod();
    getInputFieldList();
    notifyListeners();
  }

  void checkValidity() {
    for (int i = 0; i < inputValueList.length; i++) {
      if (inputValueList[i].isEmpty) {
        inputValueList.clear();
        validityCheck = true;
        notifyListeners();
      }
    }
  }

  Future<ApiResponse> updateBalance(
      String balance, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (methodSelected?.type == 'other') {
      for (TextEditingController textEditingController
          in inputFieldControllerList) {
        inputValueList.add(textEditingController.text.trim());
      }
    } else if (methodSelected?.type == 'my_methods') {
      inputValueList = [];
      keyList = [];

      methodSelected?.methodInfo?.forEach((key, value) {
        keyList.add(key);
        inputValueList.add(value);
      });
    }

    ApiResponse apiResponse = await walletServiceInterface.withdrawBalance(
        keyList, inputValueList, methodSelected?.id, balance);
    if (Provider.of<ShopController>(Get.context!, listen: false)
                .shopModel
                ?.setupGuideApp !=
            null &&
        Provider.of<ShopController>(Get.context!, listen: false)
                .shopModel
                ?.setupGuideApp?['withdraw_setup'] !=
            1) {
      Provider.of<ShopController>(Get.context!, listen: false)
          .updateTutorialFlow('withdraw_setup');
      Provider.of<ShopController>(Get.context!, listen: false)
          .updateSetupGuideApp('withdraw_setup', 1);
    }

    if (apiResponse.response?.statusCode == 200) {
      inputValueList.clear();
      inputFieldControllerList.clear();
      Provider.of<TransactionController>(Get.context!, listen: false)
          .getTransactionList(Get.context!, 'all', '', '');
      Provider.of<ProfileController>(Get.context!, listen: false)
          .getSellerInfo();
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(
          getTranslated('withdraw_request_sent_successfully', Get.context!),
          Get.context!,
          isToaster: true,
          isError: false);
      Navigator.pop(Get.context!);
    } else if (apiResponse.error != null && apiResponse.error.isNotEmpty) {
      showToast(message: apiResponse.error.toString());
      _isLoading = false;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  Future<ApiResponse> updateWithdrawRequest(
      String balance, int requestId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (methodSelected?.type == 'other') {
      for (TextEditingController textEditingController
          in inputFieldControllerList) {
        inputValueList.add(textEditingController.text.trim());
      }
    } else if (methodSelected?.type == 'my_methods') {
      inputValueList = [];
      keyList = [];

      methodSelected?.methodInfo?.forEach((key, value) {
        keyList.add(key);
        inputValueList.add(value);
      });
    }

    ApiResponse apiResponse =
        await walletServiceInterface.updateWithdrawRequest(
            keyList, inputValueList, methodSelected?.id, balance, requestId);

    if (apiResponse.response?.statusCode == 200) {
      inputValueList.clear();
      inputFieldControllerList.clear();
      Provider.of<TransactionController>(Get.context!, listen: false)
          .getTransactionList(Get.context!, 'all', '', '');
      Provider.of<ProfileController>(Get.context!, listen: false)
          .getSellerInfo();
      showCustomSnackBarWidget(
          getTranslated('withdraw_request_updated_successfully', Get.context!),
          Get.context!,
          isToaster: true,
          isError: false);
      Navigator.pop(Get.context!);
    } else if (apiResponse.error != null && apiResponse.error.isNotEmpty) {
      showToast(message: apiResponse.error.toString());
      _isLoading = false;
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }

  Future<void> getPaymentInfoList() async {
    ApiResponse apiResponse = await walletServiceInterface.getPaymentInfoList();
    myMethodsIds = [];
    methodSelected = null;
    inputValueList = [];
    keyList = [];
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _paymentInformationModel =
          PaymentInformationModel.fromJson(apiResponse.response?.data);

      for (int index = 0;
          index < (_paymentInformationModel?.data?.length ?? 0);
          index++) {
        final payment = _paymentInformationModel?.data?[index];
        if (payment?.approvalStatus != 'approved' ||
            payment?.isActive != true) {
          continue;
        }
        myMethodsIds.add(MethodModel(
          id: payment?.id,
          inputName: payment?.methodName,
          type: 'my_methods',
          methodFields: payment?.withdrawMethod?.methodFields,
          methodInfo: payment?.methodInfo,
          isDefault: payment?.isDefault ?? false,
        ));
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setDefaultPaymentMethod() {
    if (methodSelected != null) {
      return;
    }

    MethodModel? selected;
    for (final paymentInfo in myMethodsIds) {
      if (paymentInfo?.isDefault ?? false) {
        selected = paymentInfo;
        break;
      }
    }
    selected ??= myMethodsIds.isNotEmpty ? myMethodsIds.first : null;
    selected ??= methodsIds.isNotEmpty ? methodsIds.first : null;
    if (selected != null) {
      setMethodTypeIndex(selected, notify: false);
    }
  }

  Future<ApiResponse> closeWithdrawRequest(int id, String balance) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse =
        await walletServiceInterface.closeWithdrawRequest(id, balance);
    if (apiResponse.response?.statusCode == 200) {
      Provider.of<ProfileController>(Get.context!, listen: false)
          .updateWalletAmount(balance);
      Provider.of<ShopController>(Get.context!, listen: false).getShopInfo();
    }
    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }

  void showToast(
      {Color backGroundColor = Colors.red, required String message}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: backGroundColor,
        textColor: Colors.white,
        fontSize: Dimensions.fontSizeDefault);
  }
}
