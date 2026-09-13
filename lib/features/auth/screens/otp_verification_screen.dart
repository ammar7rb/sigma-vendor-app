import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/enums/from_page.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/reset_password_widget.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class VerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String? session;

  const VerificationScreen(this.mobileNumber,  {super.key, this.session});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = Provider.of<SplashController>(context, listen: false).configModel?.otpResendTime ?? 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =  Provider.of<SplashController>(context, listen: false).configModel!;

    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: SizedBox( width: 1170,
                child: Consumer<AuthController>(
                  builder: (context, authProvider, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(alignment: Alignment.centerLeft,
                        child: IconButton(icon: const Icon(Icons.arrow_back_ios, size: Dimensions.iconSizeDefault),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 55),

                      Image.asset(Images.logo, width: 100, height: 100,),
                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Center(child: Text('${getTranslated('please_enter_4_digit_code', context)}\n${widget.mobileNumber}',
                            textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeButton),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 35),
                        child: PinCodeTextField(
                          length: 6,
                          appContext: context,
                          obscureText: false,
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          textStyle: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeExtraLarge),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 55,
                            fieldWidth: 50,
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: ColorHelper.darken(Theme.of(context).colorScheme.primary, 0.2),
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Theme.of(context).cardColor,
                            inactiveColor: ColorHelper.darken(Theme.of(context).colorScheme.primary, 0.2),
                            activeColor: ColorHelper.darken(Theme.of(context).colorScheme.primary, 0.1),
                            activeFillColor: Theme.of(context).cardColor,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: authProvider.updateVerificationCode,
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                      ),

                      Center(child: Text(getTranslated('i_didnt_receive_the_code', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

                      Consumer<AuthController>(
                        builder: (context, authProvider, _) {
                          return Column(children: [
                            if (_seconds! > 0)
                              Text('${(_seconds! ~/ 60).toString().padLeft(2, '0')}:${(_seconds! % 60).toString().padLeft(2, '0')} Sec',
                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),

                            if (_seconds! <= 0)
                              Center(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    Provider.of<AuthController>(context, listen: false)
                                        .forgotPassword(widget.mobileNumber, true, configModel, fromPage: FromPage.verification)
                                        .then((value) {
                                      if (value!.isSuccess) {
                                        _startTimer();
                                        showCustomSnackBarWidget('Resent code successful', Get.context!, isError: false, sanckBarType: SnackBarType.success);
                                      } else {
                                        showCustomSnackBarWidget(value.message, Get.context!);
                                      }
                                    });
                                  },
                                  child: authProvider.resendButtonLoading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 1))
                                      : Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    child: Text(getTranslated('resend_code', context)!,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          );
                        },
                      ),
                      const SizedBox(height: 48),

                      (authProvider.isEnableVerificationCode) ? !authProvider.isPhoneNumberVerificationButtonLoading ?
                      authProvider.resendButtonLoading ? SizedBox() :
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: CustomButtonWidget(
                          btnTxt: getTranslated('verify', context),

                          onTap: () {
                            bool phoneVerification = Provider.of<SplashController>(context,listen: false).
                            configModel!.forgotPasswordVerification =='phone';

                            bool firebaseVerification = Provider.of<SplashController>(context,listen: false).
                            configModel!.vendorForgotPasswordSmsMethod == 'firebase';

                            if(phoneVerification) {
                              if(firebaseVerification) {
                                authProvider.firebaseOtpVerification(phoneNumber: widget.mobileNumber, session: widget.session ?? '', otp: authProvider.verificationCode);
                              } else {
                                Provider.of<AuthController>(context, listen: false).verifyOtp(widget.mobileNumber).then((value) {
                                  if(value.isSuccess) {
                                    Navigator.pushAndRemoveUntil(
                                        Get.context!, MaterialPageRoute(
                                        builder: (_) => ResetPasswordWidget(mobileNumber: widget.mobileNumber, otp: authProvider.verificationCode)), (route) => false);
                                  } else {
                                    showCustomSnackBarWidget(getTranslated('input_valid_otp', Get.context!), Get.context!,  sanckBarType: SnackBarType.error);
                                  }
                                });
                              }
                            }

                          },
                        ),
                      ) : Center(child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
