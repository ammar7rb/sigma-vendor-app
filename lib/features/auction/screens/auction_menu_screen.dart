import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_tab_view.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_list_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_request_list_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_sales_report_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_tax_report_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_transaction_list_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_menu_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class AuctionMenuScreen extends StatefulWidget {
  const AuctionMenuScreen({super.key});

  @override
  State<AuctionMenuScreen> createState() => _AuctionMenuScreenState();
}

class _AuctionMenuScreenState extends State<AuctionMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AuctionProductController>(context, listen: false);
      controller.getAuctionList(tabIndex: 0, offset: 1, isUpdate: true);
      controller.getAuctionProductList('pending', 1, isUpdate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('auction_menu', context),
      ),
      body: Consumer<AuctionProductController>(
        builder: (context, controller, _) {
          final configModel = Provider.of<SplashController>(context, listen: false).configModel;
          final bool canCreateAuction = configModel?.isAuctionFeatureEnabled == true && configModel?.activeAuctionForVendor == true;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimensions.paddingSizeDefault),
                  if (canCreateAuction) ...[
                    AuctionCard(
                      title: getTranslated('create_auction', context) ?? '',
                      image: Images.auctionCreate,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddAuctionProductTabView(fromPage: AddAuctionFromPage.auctionRequest),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSizeMedium),
                  ],
                  AuctionCard(
                    title: getTranslated('all_auctions', context) ?? '',
                    image: Images.allAuctions,
                    count: controller.auctionListModel?.totalSize,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuctionListScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeMedium),
                  AuctionCard(
                    title: getTranslated('auction_request_list', context) ?? '',
                    image: Images.pendingForApproval,
                    count: controller.pendingModel?.totalSize,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuctionRequestListScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeMedium),
                  AuctionCard(
                    title: getTranslated('auction_sales_report', context) ?? '',
                    image: Images.auctionSalesReport,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuctionSalesReportScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeMedium),
                  AuctionCard(
                    title: getTranslated('transaction_with_admin', context) ?? '',
                    image: Images.transactionWithAdmin,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuctionTransactionListScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeMedium),
                  AuctionCard(
                    title: getTranslated('auction_tax_report', context) ?? '',
                    icon: Icons.receipt_long,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuctionTaxReportScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
