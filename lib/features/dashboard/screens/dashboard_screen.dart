import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/network_info.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/features/home/screens/home_page_screen.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/vendor_menu_widget.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/seller_profile_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    String languageCode =
        Provider.of<LocalizationController>(context, listen: false)
                    .locale
                    .countryCode ==
                'US'
            ? 'en'
            : Provider.of<LocalizationController>(context, listen: false)
                .locale
                .countryCode!
                .toLowerCase();
    Provider.of<ProfileController>(context, listen: false).getSellerInfo();
    Provider.of<DigitalProductController>(context, listen: false)
        .getDigitalAuthor();
    Provider.of<DigitalProductController>(context, listen: false)
        .getPublishingHouse();
    Provider.of<CategoryController>(context, listen: false)
        .getCategoryList(context, null, languageCode);
    Provider.of<CartController>(context, listen: false).getCartData();
    Provider.of<ShopController>(context, listen: false).getShopInfo();

    Provider.of<TransactionController>(context, listen: false)
        .getTransactionList(context, 'all', '', '');
    Provider.of<WalletController>(context, listen: false).getPaymentInfoList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AuctionProductController>(context, listen: false)
          .getAuctionList(tabIndex: 0, offset: 1);
      Provider.of<AuctionProductController>(context, listen: false)
          .getAuctionProductList('pending', 1);
    });

    if (Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.isAiFeatureActive ==
        1) {
      Provider.of<AiController>(context, listen: false).generateLimitCheck();
    }

    _screens = [
      HomePageScreen(callback: () {
        setState(() {
          setPage(1);
        });
      }),
      const OrderScreen(),
      const ProductListMenuScreen(fromDashboard: true),
      const SellerProfileScreen(showBackButton: false),
    ];

    NetworkInfo.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (_pageIndex != 0) {
          setPage(0);
        } else {
          _onWillPop(context);
        }
        if (didPop) return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          height: 78,
          padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
          ),
          child: Row(
              children: List.generate(5, (index) {
            final data = [
              (Icons.home_outlined, getTranslated('home', context)),
              (Icons.receipt_long_outlined, getTranslated('my_order', context)),
              (Icons.inventory_2_outlined, getTranslated('products', context)),
              (Icons.person_outline_rounded, getTranslated('profile', context)),
              (Icons.grid_view_rounded, getTranslated('menu', context)),
            ][index];
            return Expanded(
                child: _VendorNavItem(
              icon: data.$1,
              label: data.$2 ?? '',
              selected: _pageIndex == index,
              onTap: () {
                if (index != 4) {
                  setPage(index);
                } else {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => const MenuBottomSheetWidget());
                }
              },
            ));
          })),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    showAnimatedDialogWidget(
        context,
        ConfirmationDialogWidget(
          icon: Images.logOut,
          title: getTranslated('exit_app', context),
          description: getTranslated('do_you_want_to_exit_the_app', context),
          onYesPressed: () {
            SystemNavigator.pop();
          },
        ),
        isFlip: true);

    return true;
  }
}

class _VendorNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _VendorNavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                size: 23,
                color: selected ? Colors.white : Theme.of(context).hintColor),
          ),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor)),
        ]),
      );
}
