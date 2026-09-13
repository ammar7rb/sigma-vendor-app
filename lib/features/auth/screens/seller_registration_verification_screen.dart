import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/auth_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/seller_activation_ticket_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class SellerRegistrationVerificationScreen extends StatefulWidget {
  final String registrationReference;
  final String mobileNumber;
  final bool otpRequired;
  final int resendAfter;
  final bool supportTicketRequired;

  const SellerRegistrationVerificationScreen({
    super.key,
    required this.registrationReference,
    required this.mobileNumber,
    required this.otpRequired,
    required this.resendAfter,
    required this.supportTicketRequired,
  });

  @override
  State<SellerRegistrationVerificationScreen> createState() => _SellerRegistrationVerificationScreenState();
}

class _SellerRegistrationVerificationScreenState extends State<SellerRegistrationVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.resendAfter;
    if (_seconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds <= 1) {
          timer.cancel();
          setState(() => _seconds = 0);
        } else {
          setState(() => _seconds--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().length != 6) {
      showCustomSnackBarWidget(getTranslated('input_valid_otp', context), context, sanckBarType: SnackBarType.warning);
      return;
    }
    setState(() => _loading = true);
    final response = await Provider.of<AuthController>(context, listen: false).verifyRegistrationOtp(widget.registrationReference, _otpController.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (response.response?.statusCode == 200) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
    } else {
      showCustomSnackBarWidget(response.error?.toString(), context, sanckBarType: SnackBarType.warning);
    }
  }

  Future<void> _resend() async {
    final response = await Provider.of<AuthController>(context, listen: false).sendRegistrationOtp(widget.registrationReference);
    if (response.response?.statusCode == 200 && mounted) {
      setState(() => _seconds = 60);
    } else if (mounted) {
      showCustomSnackBarWidget(response.error?.toString(), context, sanckBarType: SnackBarType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitingForActivation = !widget.otpRequired;
    return Scaffold(
      appBar: AppBar(title: Text(waitingForActivation ? getTranslated('account_under_review', context) ?? '' : getTranslated('verify', context) ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(waitingForActivation ? getTranslated('your_account_is_in_review_process', context) ?? '' : "${getTranslated('please_enter_6_digit_code', context)}\n${widget.mobileNumber}", style: robotoRegular, textAlign: TextAlign.center),
          if (!waitingForActivation) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            TextField(controller: _otpController, keyboardType: TextInputType.number, maxLength: 6, decoration: InputDecoration(border: const OutlineInputBorder(), labelText: getTranslated('verify', context))),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _loading ? const Center(child: CircularProgressIndicator()) : CustomButtonWidget(btnTxt: getTranslated('verify', context), onTap: _verify),
            TextButton(onPressed: _seconds == 0 ? _resend : null, child: Text(_seconds == 0 ? getTranslated('resend_code', context) ?? '' : '$_seconds')),
          ],
          if (waitingForActivation) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButtonWidget(btnTxt: getTranslated('dashboard', context), onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false)),
          ],
        ]),
      ),
    );
  }
}
