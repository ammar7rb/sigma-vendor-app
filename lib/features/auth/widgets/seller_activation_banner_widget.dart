import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/seller_activation_ticket_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerActivationBannerWidget extends StatefulWidget {
  const SellerActivationBannerWidget({super.key});
  @override
  State<SellerActivationBannerWidget> createState() =>
      _SellerActivationBannerWidgetState();
}

class _SellerActivationBannerWidgetState
    extends State<SellerActivationBannerWidget> {
  Timer? _timer;
  bool _refreshing = false;
  Future<void> _refresh() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await context.read<AuthController>().loadActivationStatus();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(builder: (_, auth, __) {
      final banner = auth.activation?['banner'];
      if (auth.activationJustApproved) {
        return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
            decoration: BoxDecoration(
                color: AppDesign.success,
                borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Icon(Icons.verified_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      getTranslated('seller_account_activated', context) ?? '',
                      style: const TextStyle(color: Colors.white))),
              IconButton(
                  color: Colors.white,
                  onPressed: auth.dismissActivationApprovedBanner,
                  icon: const Icon(Icons.close))
            ]));
      }
      if (banner == null || banner['visible'] != true)
        return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SellerActivationTicketScreen()))
                  .then((_) => auth.loadActivationStatus()),
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
                  decoration: BoxDecoration(
                      color: AppDesign.danger,
                      borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            getTranslated(
                                    'seller_activation_required', context) ??
                                '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700))),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ])),
            )),
      );
    });
  }
}
