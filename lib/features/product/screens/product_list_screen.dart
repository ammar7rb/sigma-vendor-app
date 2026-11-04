import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_slots_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

/// Compatibility entry point: every former product/slot link opens one workspace.
class ProductListMenuScreen extends StatelessWidget {
  final bool fromNotification, fromDashboard, showAdvertisingSlots;
  const ProductListMenuScreen(
      {super.key,
      this.fromNotification = false,
      this.fromDashboard = false,
      this.showAdvertisingSlots = false});

  @override
  Widget build(BuildContext context) {
    void back() {
      if (fromDashboard) return;
      if (fromNotification) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false);
      } else {
        Navigator.of(context).maybePop();
      }
    }

    return PopScope(
        canPop: !fromDashboard && !fromNotification,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && fromNotification) back();
        },
        child: Scaffold(
            appBar: CustomAppBarWidget(
                title: getTranslated('phase5_spaces', context),
                isBackButtonExist: !fromDashboard,
                onBackPressed: back),
            body: const SellerSlotsScreen(embedded: true)));
  }
}
