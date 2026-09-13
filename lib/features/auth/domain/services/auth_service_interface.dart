import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/models/register_model.dart';

abstract class AuthServiceInterface {
  Future<dynamic> login({String? emailAddress, String? password});
  Future<dynamic> setLanguageCode(String languageCode);
  Future<dynamic> forgotPassword(String identity);
  Future<dynamic> resetPassword(String identity, String otp ,String password, String confirmPassword, String? token);
  Future<dynamic> verifyOtp(String identity, String otp);
  Future<dynamic> updateToken();
  Future<void> saveUserToken(String token);
  String getUserToken();
  bool isLoggedIn();
  Future<dynamic> clearSharedData();
  Future<dynamic> saveUserNumberAndPassword(String number, String password);
  String getUserEmail();
  String getUserPassword();
  Future<dynamic> clearUserNumberAndPassword();
  Future<dynamic> registration(XFile? profileImage, XFile? shopLogo, XFile? shopBanner, XFile? secondaryBanner, RegisterModel registerModel);
  Future<dynamic> requiredRegistrationPolicies();
  Future<dynamic> acceptRegistrationPolicies(String registrationReference, List<int> policyVersionIds);
  Future<dynamic> sendRegistrationOtp(String registrationReference);
  Future<dynamic> verifyRegistrationOtp(String registrationReference, String otp);
  Future<dynamic> saveRegistrationReference(String value);
  String getRegistrationReference();
  Future<dynamic> activationStatus(String registrationReference);
  Future<dynamic> openActivationTicket(String registrationReference);
  Future<dynamic> activationTicketMessages(String registrationReference, {int? ticketId});
  Future<dynamic> sendActivationTicketMessage(String registrationReference, String body, {int? ticketId, List<XFile> attachments = const []});
  Future<dynamic>  firebaseAuthTokenStore({required String userInput, required String token});
  Future<dynamic> firebaseAuthVerify({required String phoneNumber, required String session, required String otp, required bool isForgetPassword});
  Future<dynamic> checkVendorExistPhone({required String phoneNumber});
}
