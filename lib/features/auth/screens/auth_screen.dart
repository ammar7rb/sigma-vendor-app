import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/seller_auth_header.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  String tr(BuildContext context, String key, String fallback) =>
      getTranslated(key, context) ?? fallback;

  @override
  Widget build(BuildContext context) {
    context.read<AuthController>().isActiveRememberMe;
    return SellerAuthPage(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 54),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SellerAuthHeader(
                      title: tr(
                          context, 'seller_login_title', 'تسجيل دخول التاجر'),
                      subtitle: tr(context, 'seller_login_subtitle',
                          'أدر منتجاتك وطلباتك وأرصدتك بسهولة من مكان واحد'),
                    ),
                    const SizedBox(height: 28),
                    const LoginScreen(),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
