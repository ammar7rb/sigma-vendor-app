import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/pass_view.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/profile_body.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/profile_info.dart';
import 'package:sixvalley_vendor_app/helper/image_size_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  static const String _egyptDialCode = '+20';

  File? file;
  final picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String _localEgyptianMobile(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  void _choose() async {
    final pickedFile = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: context
    );

    if(pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserAccount() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String password0 = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if(Provider.of<ProfileController>(context, listen: false).userInfoModel!.fName == _firstNameController.text
        && Provider.of<ProfileController>(context, listen: false).userInfoModel!.lName == _lastNameController.text
        && _localEgyptianMobile(Provider.of<ProfileController>(context, listen: false).userInfoModel!.phone ?? '') == _localEgyptianMobile(_phoneController.text) && file == null
    && _passwordController.text.isEmpty && _confirmPasswordController.text.isEmpty) {
      showCustomSnackBarWidget(getTranslated('change_something_to_update', context), context, sanckBarType: SnackBarType.warning);

    }else if (firstName.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_first_name', context), context, sanckBarType: SnackBarType.warning);

    }else if (lastName.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_first_name', context), context, sanckBarType: SnackBarType.warning);

    }else if (phoneNumber.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_phone_number', context), context, sanckBarType: SnackBarType.warning);
    }
    else if (!RegExp(r'^1[0-25][0-9]{8}$').hasMatch(_localEgyptianMobile(phoneNumber))) {
      showCustomSnackBarWidget(getTranslated('input_valid_phone_number', context), context, sanckBarType: SnackBarType.warning);
    }

    else if((password0.isNotEmpty && password0.length < 6)
        || (confirmPassword.isNotEmpty && confirmPassword.length < 6)) {
      showCustomSnackBarWidget(getTranslated('password_be_at_least', context), context, sanckBarType: SnackBarType.warning);
    }

    else if(password0 != confirmPassword) {
      showCustomSnackBarWidget(getTranslated('password_did_not_match', context), context, sanckBarType: SnackBarType.warning);

    }
    else if(password0.isNotEmpty && !Provider.of<AuthController>(context, listen: false).isPasswordValid()) {
      showCustomSnackBarWidget(getTranslated('enter_valid_password', context), context, sanckBarType: SnackBarType.warning);
    }

    else {
      ProfileInfoModel updateUserInfoModel = Provider.of<ProfileController>(context, listen: false).userInfoModel!;
      updateUserInfoModel.fName = _firstNameController.text;
      updateUserInfoModel.lName = _lastNameController.text;
      updateUserInfoModel.phone = '$_egyptDialCode${_localEgyptianMobile(_phoneController.text)}';
      String password = _passwordController.text;

      ProfileInfoModel bank = Provider.of<BankInfoController>(context, listen: false).bankInfo!;
      ProfileBody sellerBody = ProfileBody(
          sMethod: '_put', fName: _firstNameController.text, lName: _lastNameController.text,
        image: updateUserInfoModel.image,
          bankName: bank.bankName, branch: bank.branch, holderName: bank.holderName, accountNo: bank.accountNo,
      );

      await Provider.of<ProfileController>(context, listen: false).updateUserInfo(
        updateUserInfoModel, sellerBody, file, Provider.of<AuthController>(context, listen: false).getUserToken(), password);
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(context, listen: false).validPassCheck('', isUpdate: false);
    Provider.of<ProfileController>(context, listen: false).setCountryDialCode(_egyptDialCode);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(isBackButtonExist: true, title: getTranslated('edit_profile', context)),
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Consumer<ProfileController>(
            builder: (context, profile, child) {
              if(_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
                _firstNameController.text = profile.userInfoModel!.fName!;
                _lastNameController.text = profile.userInfoModel!.lName!;
                _phoneController.text = _localEgyptianMobile(profile.userInfoModel!.phone ?? '');
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        border: Border.all(color: Colors.white, width: 3),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: file == null ?
                            CustomImageWidget(width: 100,height: 100,fit: BoxFit.cover,
                                image: profile.userInfoModel!.imageFullUrl?.path ?? '')
                                : Image.file(file!, width: 100, height: 100, fit: BoxFit.fill),),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _choose,
                              child: Container(width: 30,height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
                                  border: Border.all(color: Theme.of(context).cardColor)
                                ),

                                child: IconButton(
                                  onPressed: _choose,
                                  padding: const EdgeInsets.all(0),
                                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: Dimensions.iconSizeDefault,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault),
                      child: Column(
                        children: [


                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          CustomTextFieldWidget(
                            formProduct: true,
                            labelText: getTranslated('first_name', context),
                            border: true,
                            textInputType: TextInputType.name,
                            focusNode: _fNameFocus,
                            nextNode: _lNameFocus,
                            hintText: profile.userInfoModel!.fName ?? '',
                            controller: _firstNameController,
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          CustomTextFieldWidget(
                            border: true,
                            formProduct: true,
                            labelText: getTranslated('last_name', context),
                            textInputType: TextInputType.name,
                            focusNode: _lNameFocus,
                            nextNode: _phoneFocus,
                            hintText: profile.userInfoModel!.lName,
                            controller: _lastNameController,
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          CustomTextFieldWidget(
                            idDate: true,
                            hintText: profile.userInfoModel!.email ?? "",
                            border: true,

                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Row(children: [
                            Container(
                              height: 56,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).hintColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(_egyptDialCode),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(child: CustomTextFieldWidget(
                              border: true,
                              textInputType: TextInputType.phone,
                              focusNode: _phoneFocus,
                              nextNode: _passwordFocus,
                              hintText: getTranslated('mobile_hint', context),
                              controller: _phoneController,
                              isPhoneNumber: true,
                            )),
                          ]),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          CustomTextFieldWidget(
                            border: true,
                            hintText: getTranslated('password', context),
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            isPassword: true,
                            nextNode: _confirmPasswordFocus,
                            textInputAction: TextInputAction.next,
                            onChanged: (value){
                              if(value.isNotEmpty){
                                if(!authController.showPassView) {
                                  authController.showHidePass();
                                }
                                authController.validPassCheck(value);
                              }else{
                                if(authController.showPassView){
                                  authController.showHidePass();
                                }
                              }
                            }
                          ),

                          authController.showPassView ? const PassView() : const SizedBox(),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          CustomTextFieldWidget(
                            border: true,
                            hintText: getTranslated('confirm_password', context),
                            isPassword: true,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ),
                    ),

                  ],
                ),
              );
            },
          );
        }
      ),
      bottomNavigationBar: Consumer<ProfileController>(
        builder: (context, profile, child) {
          return Container(height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),
                    spreadRadius: 2, blurRadius: 5, offset: Offset.fromDirection(1,2))],
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
            width: MediaQuery.of(context).size.width,
            child: !profile.isLoading
                ? CustomButtonWidget(
              borderRadius: 10,
                backgroundColor: Theme.of(context).primaryColor, onTap: _updateUserAccount,
                btnTxt: getTranslated('update_profile', context))
                : Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
          );
        }
      ),
    );
  }
}
