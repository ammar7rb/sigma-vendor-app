import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_sales_report_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/vat_management/screens/vat_report_screen.dart';
import 'package:sixvalley_vendor_app/features/vat_management/widgets/management_card_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class VatManagementScreen extends StatefulWidget {
  const VatManagementScreen({super.key});

  @override
  State<VatManagementScreen> createState() => _VatManagementScreenState();
}

class _VatManagementScreenState extends State<VatManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final isAuctionEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAuctionFeatureEnabled == true || Provider.of<ProfileController>(context, listen: false).userInfoModel?.showAuctionMenuForVendor == true;

    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('reports', context)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          // if (isAuctionEnabled) ...[
          //   ManagementCardWidget(
          //     name: getTranslated('auction_sales_report', context)!,
          //     image: Images.vatReportIcon,
          //     screenToRoute: AuctionSalesReportScreen(),
          //   ),
          //   SizedBox(height: Dimensions.paddingSizeLarge),
          // ],

          ManagementCardWidget(
            name: getTranslated('vat_report', context)!,
            description: getTranslated('see_vat_collected_and_applied_on_transactions', context)!,
            image: Images.vatReportIcon,
            screenToRoute: VatReportScreen(),
          ),
        ]),
      ),
    );
  }
}
