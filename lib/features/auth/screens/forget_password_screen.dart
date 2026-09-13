import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/password_support_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/seller_auth_header.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  String tr(BuildContext context, String key, String fallback) =>
      getTranslated(key, context) ?? fallback;

  @override
  Widget build(BuildContext context) {
    return SellerAuthPage(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              SellerAuthHeader(
                title: tr(context, 'password_reset_support_title',
                    'استعادة كلمة المرور'),
                subtitle: tr(context, 'password_reset_support_message',
                    'فريق سيجما سيتحقق من بيانات حساب التاجر لحمايته'),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(Icons.verified_user_outlined,
                            color: Theme.of(context).primaryColor)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Text(
                            tr(
                                context,
                                'password_reset_support_identity_notice',
                                'أرسل بياناتك في تذكرة آمنة، وستتمكن من متابعة رد الإدارة والمحادثة معها مباشرة.'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.7))),
                  ]),
                  const SizedBox(height: 22),
                  CustomButtonWidget(
                      borderRadius: 18,
                      btnTxt:
                          tr(context, 'contact_support', 'بدء تذكرة الاستعادة'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const PasswordSupportScreen()))),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
