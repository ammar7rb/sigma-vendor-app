import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/models/register_model.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/data/model/response/response_model.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixvalley_vendor_app/features/auth/enums/from_page.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/otp_verification_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/reset_password_widget.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/helper/image_size_checker.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';

class AuthController with ChangeNotifier {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface});
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _requiredRegistrationPolicies = [];
  List<Map<String, dynamic>> get requiredRegistrationPolicies => _requiredRegistrationPolicies;
  bool _registrationPoliciesLoaded = false;
  bool get registrationPoliciesLoaded => _registrationPoliciesLoaded;
  Map<String, dynamic>? _activation;
  Map<String, dynamic>? get activation => _activation;
  bool _activationJustApproved = false;
  bool get activationJustApproved => _activationJustApproved;
  final String _loginErrorMessage = '';
  String get loginErrorMessage => _loginErrorMessage;
  XFile? _sellerProfileImage;
  XFile? _shopLogo;
  XFile? _shopBanner;
  XFile? secondaryBanner;
  XFile? offerBanner;
  XFile? get sellerProfileImage => _sellerProfileImage;
  XFile? get shopLogo => _shopLogo;
  XFile? get shopBanner => _shopBanner;
  bool? _isTermsAndCondition = false;
  bool? get isTermsAndCondition => _isTermsAndCondition;
  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;
  int _selectionTabIndex = 1;
  int get selectionTabIndex =>_selectionTabIndex;
  String _verificationCode = '';
  String get verificationCode => _verificationCode;
  bool _isEnableVerificationCode = false;
  bool get isEnableVerificationCode => _isEnableVerificationCode;
  String? _verificationMsg = '';
  String? get verificationMessage => _verificationMsg;
  final String _email = '';
  final String _phone = '';
  String get email => _email;
  String get phone => _phone;
  bool _isPhoneNumberVerificationButtonLoading = false;
  bool get isPhoneNumberVerificationButtonLoading => _isPhoneNumberVerificationButtonLoading;
  String? _countryDialCode = '+20';
  String? get countryDialCode => _countryDialCode;

  bool _resendButtonLoading = false;
  bool get resendButtonLoading => _resendButtonLoading;

  String? _verificationID = '';
  String? get verificationID => _verificationID;


  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();

  FocusNode firstNameNode = FocusNode();
  FocusNode lastNameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode shopNameNode = FocusNode();
  FocusNode shopAddressNode = FocusNode();

  bool _lengthCheck = false;
  bool _numberCheck = false;
  bool _uppercaseCheck = false;
  bool _lowercaseCheck = false;
  bool _spatialCheck = false;
  bool _showPassView = false;

  bool get lengthCheck => _lengthCheck;
  bool get numberCheck => _numberCheck;
  bool get uppercaseCheck => _uppercaseCheck;
  bool get lowercaseCheck => _lowercaseCheck;
  bool get spatialCheck => _spatialCheck;
  bool get showPassView => _showPassView;

  bool _isUnAuthorize = false;
  bool get isUnAuthorize => _isUnAuthorize;

  Future<ApiResponse> login(BuildContext context, {String? emailAddress, String? password}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authServiceInterface.login(emailAddress: emailAddress, password: password);
    _isLoading = false;
    notifyListeners();
    if(apiResponse.response?.statusCode == 200) {
      _activation = null;
      _activationJustApproved = false;
      final loginData = apiResponse.response!.data;
      await saveRegistrationReference(loginData is Map ? '${loginData['registration_reference'] ?? ''}' : '');
      await Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
      setCurrentLanguage(Provider.of<LocalizationController>(Get.context!, listen: false).getCurrentLanguage()??'en');
      setUnAuthorize(false);
      notifyListeners();
    }
    return apiResponse;
  }

  Future<void> setCurrentLanguage(String currentLanguage) async {
      await authServiceInterface.setLanguageCode(currentLanguage);
  }

  Future<ResponseModel?> forgotPassword(String email, bool isNumber, ConfigModel? config, {FromPage? fromPage})async {
    bool isResend = fromPage == FromPage.verification;
    ResponseModel? responseModel;

    _isLoading = true;
    if(isResend) {
      _resendButtonLoading = true;
    }
    notifyListeners();

    if(isNumber && config?.forgotPasswordVerification == 'phone' &&  config?.vendorForgotPasswordSmsMethod == 'firebase') {
      checkVendorExistPhone(email).then((response) {
        if(response.response?.statusCode == 200) {
          firebaseVerifyPhoneNumber(email, isResend: isResend, isForgetPassword: true);
        } else {
          _isLoading = false;
          if(isResend) {
            _resendButtonLoading = false;
          }
          notifyListeners();
          showCustomSnackBarWidget(response.error, Get.context!, sanckBarType: SnackBarType.error);
        }
      });
    } else {
      responseModel = await authServiceInterface.forgotPassword(email);
      _isLoading = false;
    }


    if(isResend) {
      _resendButtonLoading = false;
    }
    notifyListeners();
    return responseModel;
  }



  Future<void> updateToken(BuildContext context) async {
      await authServiceInterface.updateToken();
  }

  void updateTermsAndCondition(bool? value) {
    _isTermsAndCondition = value;
    notifyListeners();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    notifyListeners();
  }

  void setIndexForTabBar(int index, {bool isNotify = true}){
    _selectionTabIndex = index;
    if(isNotify){
      notifyListeners();
    }
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData({bool fromUnAuthorizationError = false}) async {
    _activation = null;
    _activationJustApproved = false;
    await saveRegistrationReference('');
    if(fromUnAuthorizationError){
      if (kDebugMode) {
        print("===Inside==fromUnAuthorizationError");
      }
    }
    Provider.of<ShopController>(Get.context!, listen: false).clearShopModel();
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password) {
    authServiceInterface.saveUserNumberAndPassword(number, password);
  }

  String getUserEmail() {
    return authServiceInterface.getUserEmail();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserEmailAndPassword() async {
    return await authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }


  void updateVerificationCode(String query) {
    if (query.length == 6) {
      _isEnableVerificationCode = true;
    } else {
      _isEnableVerificationCode = false;
    }
    _verificationCode = query;
    notifyListeners();
  }



  Future<ResponseModel> verifyOtp(String phone) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ResponseModel responseModel = await authServiceInterface.verifyOtp(phone, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    _verificationMsg = responseModel.message;
    notifyListeners();
    return responseModel;
  }


  Future<ResponseModel> resetPassword(String identity, String otp, String password, String confirmPassword, String? token) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ResponseModel responseModel = await authServiceInterface.resetPassword(identity,otp,password,confirmPassword, token);
    _isPhoneNumberVerificationButtonLoading = false;
    _verificationMsg = responseModel.message;
    notifyListeners();
    return responseModel;
  }


  void pickImage(bool isProfile, bool shopLogo, bool isRemove, {bool secondary = false, bool offer = false}) async {
    if(isRemove) {
      _sellerProfileImage = null;
      _shopLogo = null;
      _shopBanner = null;
      secondaryBanner = null;
    } else {
      XFile? image = await ImageValidationHelper.validateAndPickImage(
        source: ImageSource.gallery,
        context: Get.context!
      );

      double value = 0;

      if (isProfile && image != null) {
        _sellerProfileImage = image;
      } else if(shopLogo && image != null) {
        _shopLogo = image;
      }else if(secondary && image != null) {
        secondaryBanner = image;
      }else if(offer && image != null) {
        offerBanner = image;
      }else if ( image != null) {
        _shopBanner = image;
      }
    }
    notifyListeners();
  }

  Future<ApiResponse> registration(BuildContext context, RegisterModel registerModel) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response;
    try {
      response = await authServiceInterface.registration(_sellerProfileImage, _shopLogo, _shopBanner, secondaryBanner, registerModel);
    } catch (error) {
      response = ApiResponse.withError(error.toString());
    }

    if(response.response?.statusCode == 200) {
      _isLoading = false;
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      shopNameController.clear();
      shopAddressController.clear();
      _sellerProfileImage = null;
      _shopLogo = null;
      _shopBanner = null;
      secondaryBanner = null;
      Provider.of<ShopController>(Get.context!, listen: false).clearShopModel();
      showCustomSnackBarWidget(getTranslated("you_are_successfully_registered", Get.context!), Get.context!, isError: false, sanckBarType: SnackBarType.success);
    } else if (response.response?.data is String && jsonDecode(response.response?.data ?? '')["message"][0]["message"] != null) {
      showCustomSnackBarWidget('${jsonDecode(response.response?.data ?? '')["message"][0]["message"]}', Get.context!, sanckBarType: SnackBarType.warning);
    } else {
      log("---->log===> ${response.response?.statusCode}/${response.error}/${response.response?.statusMessage}/${response.response?.data}");
      _isLoading = false;
      showCustomSnackBarWidget("The email has already been taken", Get.context!, sanckBarType: SnackBarType.warning);
    }
    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<void> loadRequiredRegistrationPolicies() async {
    _registrationPoliciesLoaded = false;
    notifyListeners();
    final response = await authServiceInterface.requiredRegistrationPolicies() as ApiResponse;
    if (response.response?.statusCode == 200) {
      final raw = response.response!.data;
      final data = raw is String ? jsonDecode(raw) as Map : raw as Map;
      _requiredRegistrationPolicies = List<Map<String, dynamic>>.from((data['policies'] ?? []).map((item) => Map<String, dynamic>.from(item)));
    } else {
      _requiredRegistrationPolicies = [];
    }
    _registrationPoliciesLoaded = true;
    notifyListeners();
  }

  Future<ApiResponse> acceptRegistrationPolicies(String registrationReference) async {
    final ids = _requiredRegistrationPolicies.map((policy) => policy['id'] as int).toList();
    return await authServiceInterface.acceptRegistrationPolicies(registrationReference, ids) as ApiResponse;
  }

  Future<ApiResponse> sendRegistrationOtp(String registrationReference) async {
    return await authServiceInterface.sendRegistrationOtp(registrationReference) as ApiResponse;
  }

  Future<ApiResponse> verifyRegistrationOtp(String registrationReference, String otp) async {
    return await authServiceInterface.verifyRegistrationOtp(registrationReference, otp) as ApiResponse;
  }

  Future<void> saveRegistrationReference(String value) async => authServiceInterface.saveRegistrationReference(value);
  Future<void> saveUserToken(String value) async => authServiceInterface.saveUserToken(value);
  String getRegistrationReference() => authServiceInterface.getRegistrationReference();

  Future<ApiResponse> loadActivationStatus() async {
    final reference = getRegistrationReference();
    if (reference.isEmpty) return ApiResponse.withError('registration_reference_missing');
    final response = await authServiceInterface.activationStatus(reference) as ApiResponse;
    if (response.response?.statusCode == 200 && response.response?.data is Map) {
      final previousStatus = _activation?['status'];
      _activation = Map<String, dynamic>.from((response.response!.data as Map)['activation'] ?? {});
      _activationJustApproved = _activationJustApproved || (previousStatus != 'active' && _activation?['status'] == 'active');
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse> openActivationTicket() async {
    final response = await authServiceInterface.openActivationTicket(getRegistrationReference()) as ApiResponse;
    await loadActivationStatus();
    return response;
  }

  Future<ApiResponse> activationTicketMessages({int? ticketId}) async => await authServiceInterface.activationTicketMessages(getRegistrationReference(), ticketId: ticketId) as ApiResponse;
  Future<ApiResponse> sendActivationTicketMessage(String body, {int? ticketId, List<XFile> attachments = const []}) async => await authServiceInterface.sendActivationTicketMessage(getRegistrationReference(), body, ticketId: ticketId, attachments: attachments) as ApiResponse;
  void dismissActivationApprovedBanner() {
    _activationJustApproved = false;
    notifyListeners();
  }

  void setCountryDialCode (String? setValue){
    _countryDialCode = setValue;
  }


  void emptyRegistrationData ({bool isUpdate = false}) {
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    shopNameController.clear();
    shopAddressController.clear();
    _sellerProfileImage = null;
    _shopLogo = null;
    _shopBanner = null;
    secondaryBanner = null;
    if(isUpdate){
      notifyListeners();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}){
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      notifyListeners();
    }
  }

  void showHidePass({bool isUpdate = true}) {
    _showPassView = ! _showPassView;
    if(isUpdate) {
      notifyListeners();
    }
  }


  bool isPasswordValid (){
    return (_lengthCheck && _numberCheck && _lowercaseCheck && _uppercaseCheck && _spatialCheck && _numberCheck);
  }


  void setUnAuthorize(bool value, {bool update = false}) {
    _isUnAuthorize = value;
    if(update) {
      notifyListeners();
    }
  }



  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, {bool isForgetPassword = false, bool isResend = false, String? toNavigateScreen, VoidCallback? onLoginSuccess}) async {
    if(!isResend) {
      _isLoading = true;
    }
    _resendButtonLoading = true;
    notifyListeners();

    // String? vID;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isPhoneNumberVerificationButtonLoading = false;
        _isLoading = false;
        notifyListeners();

        // Navigator.of(Get.context!).pop();

        if(e.code == 'invalid-phone-number') {

          showCustomSnackBarWidget(getTranslated('please_submit_a_valid_phone_number', Get.context!), Get.context!);
        }else{
          showCustomSnackBarWidget(getTranslated('${e.message}'.replaceAll('_', ' ').toCapitalized(), Get.context!), Get.context!);
        }

      },
      codeSent: (String vId, int? resendToken) async {
        _isPhoneNumberVerificationButtonLoading = false;
        _resendButtonLoading = false;
        notifyListeners();

        bool callRoute = !isResend;


        await callFirebaseStoretiken(phoneNumber, vId);

        _verificationID = vId;


        if(isResend) {
          showCustomSnackBarWidget(getTranslated('resend_code_successful', Get.context!), Get.context!, isError: false);
        }

        if(callRoute) {
          Navigator.push(Get.context!, MaterialPageRoute(builder: (_) => VerificationScreen(phoneNumber, session: vId)));
          _isLoading = false;
        }
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _resendButtonLoading = false;
        _isLoading = false;
      },
    );


    //await Future.delayed(Duration(seconds: 10));

    _resendButtonLoading = false;
    notifyListeners();
  }


  Future<void> callFirebaseStoretiken (String phoneNumber, String vID) async {
     await authServiceInterface.firebaseAuthTokenStore(userInput: phoneNumber, token: vID);
  }


  Future<ApiResponse> checkVendorExistPhone(String  phone) async {
    notifyListeners();
    ApiResponse responseModel = await authServiceInterface.checkVendorExistPhone(phoneNumber: phone);


    notifyListeners();
    return responseModel;
  }



  Future<void> firebaseOtpVerification({required String phoneNumber, required String session, required String otp, bool isForgetPassword = false}) async {
    _isPhoneNumberVerificationButtonLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await authServiceInterface.firebaseAuthVerify(
      session: session, phoneNumber: phoneNumber,
      otp: otp, isForgetPassword: isForgetPassword,
    );

    if(apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(
        builder: (_) => ResetPasswordWidget(
          mobileNumber: phoneNumber,
          otp: otp,
          token: session,
        )), (route) => false
      );
    } else {
      ApiChecker.checkApi(apiResponse, firebaseResponse: true);
    }

    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
  }







}
