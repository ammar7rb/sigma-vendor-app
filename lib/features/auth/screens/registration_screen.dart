import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_pass_textfeild_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/models/register_model.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/seller_registration_verification_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/seller_auth_header.dart';
import 'package:sixvalley_vendor_app/helper/email_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String tr(String key, String fallback) =>
      getTranslated(key, context) ?? fallback;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    auth.emptyRegistrationData();
    auth.setCountryDialCode('+20');
    auth.loadRequiredRegistrationPolicies();
  }

  void _submit(AuthController auth) {
    final phone =
        auth.phoneController.text.trim().replaceFirst(RegExp(r'^0'), '');
    if (!auth.registrationPoliciesLoaded) {
      _warning('registration_policies_loading', 'جاري تحميل السياسات');
    } else if (EmailChecker.isNotValid(auth.emailController.text.trim())) {
      _warning('email_is_ot_valid', 'أدخل بريدًا إلكترونيًا صحيحًا');
    } else if (!RegExp(r'^1[0-25][0-9]{8}$').hasMatch(phone)) {
      _warning('phone_number_is_not_valid', 'أدخل رقم هاتف مصري صحيحًا');
    } else if (auth.passwordController.text.length < 8) {
      _warning(
          'password_minimum_length_is_6', 'كلمة المرور يجب ألا تقل عن 8 أحرف');
    } else if (auth.passwordController.text !=
        auth.confirmPasswordController.text) {
      _warning('password_is_mismatch', 'كلمتا المرور غير متطابقتين');
    } else if (auth.isTermsAndCondition != true) {
      _warning('terms_and_conditions_must_be_accepted',
          'يجب الموافقة على الشروط والسياسات');
    } else {
      final model = RegisterModel(
        phone: '+20$phone',
        email: auth.emailController.text.trim(),
        password: auth.passwordController.text,
        confirmPassword: auth.confirmPasswordController.text,
        policyVersionIds: auth.requiredRegistrationPolicies
            .map((p) => int.tryParse(p['id'].toString()) ?? 0)
            .where((id) => id > 0)
            .toList(),
      );
      auth.registration(Get.context!, model).then((response) async {
        if (response.response?.statusCode == 200 && mounted) {
          final data = response.response!.data is String
              ? jsonDecode(response.response!.data) as Map<String, dynamic>
              : Map<String, dynamic>.from(response.response!.data);
          final reference = data['registration_reference'] as String?;
          if (reference == null) return;
          await auth.saveRegistrationReference(reference);
          if (data['token'] is String) await auth.saveUserToken(data['token']);
          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => SellerRegistrationVerificationScreen(
                        registrationReference: reference,
                        mobileNumber: '+20$phone',
                        otpRequired: data['otp']?['required'] != false,
                        resendAfter: data['otp']?['resend_after'] as int? ?? 0,
                        supportTicketRequired: data['eligibility']
                                ?['verification']?['support_ticket_required'] ==
                            true,
                      )));
        }
      });
    }
  }

  void _warning(String key, String fallback) =>
      showCustomSnackBarWidget(tr(key, fallback), context,
          sanckBarType: SnackBarType.warning);

  @override
  Widget build(BuildContext context) {
    return SellerAuthPage(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      child: Consumer<AuthController>(builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(children: [
              SellerAuthHeader(
                  compact: true,
                  title: tr('seller_registration_title', 'إنشاء حساب تاجر'),
                  subtitle: tr('seller_registration_subtitle',
                      'ابدأ شراكتك مع سيجما وأدر نشاطك بسهولة')),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(tr('email', 'البريد الإلكتروني')),
                      CustomTextFieldWidget(
                          border: true,
                          prefixIconImage: 'assets/images/email_icon.png',
                          hintText: tr('email_hint', 'name@example.com'),
                          controller: auth.emailController,
                          focusNode: auth.emailNode,
                          nextNode: auth.phoneNode,
                          textInputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next),
                      const SizedBox(height: 16),
                      _label(tr('phone', 'رقم الهاتف')),
                      Row(children: [
                        Container(
                            height: 56,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(18)),
                            child: const Text('+20',
                                textDirection: TextDirection.ltr)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: CustomTextFieldWidget(
                                border: true,
                                hintText: '10xxxxxxxx',
                                controller: auth.phoneController,
                                focusNode: auth.phoneNode,
                                nextNode: auth.passwordNode,
                                isPhoneNumber: true,
                                textInputType: TextInputType.phone,
                                textInputAction: TextInputAction.next)),
                      ]),
                      const SizedBox(height: 16),
                      _label(tr('new_password', 'كلمة المرور')),
                      CustomPasswordTextFieldWidget(
                          border: true,
                          hintTxt:
                              tr('enter_your_password', 'أدخل كلمة مرور قوية'),
                          controller: auth.passwordController,
                          focusNode: auth.passwordNode,
                          nextNode: auth.confirmPasswordNode,
                          textInputAction: TextInputAction.next,
                          onChanged: (v) => auth.validPassCheck(v ?? '')),
                      const SizedBox(height: 16),
                      _label(tr('confirm_password', 'تأكيد كلمة المرور')),
                      CustomPasswordTextFieldWidget(
                          border: true,
                          hintTxt:
                              tr('confirm_password', 'أعد كتابة كلمة المرور'),
                          controller: auth.confirmPasswordController,
                          focusNode: auth.confirmPasswordNode,
                          textInputAction: TextInputAction.done),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: auth.isTermsAndCondition ?? false,
                          onChanged: auth.updateTermsAndCondition,
                          title: Text(
                              tr('agree_to_terms_privacy_and_confidentiality',
                                  'أوافق على الشروط وسياسة الخصوصية'),
                              style: Theme.of(context).textTheme.bodySmall)),
                      const SizedBox(height: 14),
                      auth.isLoading || !auth.registrationPoliciesLoaded
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButtonWidget(
                              borderRadius: 18,
                              btnTxt:
                                  tr('create_an_account', 'إنشاء حساب التاجر'),
                              onTap: () => _submit(auth)),
                    ]),
              ),
            ]),
          )),
        );
      }),
    );
  }

  Widget _label(String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(value,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)));
}
