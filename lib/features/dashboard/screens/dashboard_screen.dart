import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
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
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/vendor_motion.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen(
      {super.key, this.showWelcome = false, this.openAdvertisingSlots = false});
  final bool openAdvertisingSlots;
  final bool showWelcome;

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
    VendorWorkspace.instance.start();
    if (widget.openAdvertisingSlots) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const ProductListMenuScreen(showAdvertisingSlots: true)));
        }
      });
    }
    if (widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(children: [
            Icon(Icons.check_circle_outline,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(getTranslated('vendor_login_welcome', context) ?? '',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                      getTranslated('vendor_login_welcome_hint', context) ?? '',
                      style: Theme.of(context).textTheme.bodySmall),
                ])),
            IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                icon: const Icon(Icons.close, color: Color(0xff52627a))),
          ]),
        ));
      });
    }
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

    if (Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.isAiFeatureActive ==
        1) {
      Provider.of<AiController>(context, listen: false).generateLimitCheck();
    }

    _screens = [
      HomePageScreen(callback: () {
        setState(() {
          setPage(3);
        });
      }),
      const SellerFinanceScreen(),
      const ProductListMenuScreen(fromDashboard: true),
      const OrderScreen(),
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
        bottomNavigationBar: VendorBottomNavigation(
            selectedIndex: _pageIndex,
            onSelected: (index) {
              if (index != 4) {
                setPage(index);
              } else {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const MenuBottomSheetWidget());
              }
            }),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

class VendorBottomNavigation extends StatelessWidget {
  const VendorBottomNavigation(
      {super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          height: 80,
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
          ),
          child: AnimatedBuilder(
              animation: VendorWorkspace.instance,
              builder: (context, _) => Row(
                      children: List.generate(5, (index) {
                    final data = [
                      (
                        Icons.home_outlined,
                        Icons.home_rounded,
                        getTranslated('home', context)
                      ),
                      (
                        Icons.account_balance_wallet_outlined,
                        Icons.account_balance_wallet_rounded,
                        getTranslated('finance_my_wallet', context)
                      ),
                      (
                        Icons.inventory_2_outlined,
                        Icons.inventory_2_rounded,
                        getTranslated('phase5_spaces', context)
                      ),
                      (
                        Icons.receipt_long_outlined,
                        Icons.receipt_long_rounded,
                        getTranslated('my_order', context)
                      ),
                      (
                        Icons.grid_view_outlined,
                        Icons.grid_view_rounded,
                        getTranslated('vendor_other', context)
                      ),
                    ][index];
                    return Expanded(
                        child: _VendorNavItem(
                      icon: data.$1,
                      selectedIcon: data.$2,
                      count: index == 3
                          ? VendorWorkspace.instance.counts['orders'] ?? 0
                          : 0,
                      label: data.$3 ?? '',
                      selected: selectedIndex == index,
                      onTap: () => onSelected(index),
                    ));
                  }))),
        ),
      );
}

/// One bottom bar destination: scales down while pressed, lifts on hover,
/// fills its icon and slides in a highlight when selected, and pops the icon
/// once each time it becomes selected.
class _VendorNavItem extends StatefulWidget {
  final int count;
  final IconData icon, selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _VendorNavItem(
      {this.count = 0,
      required this.icon,
      required this.selectedIcon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  State<_VendorNavItem> createState() => _VendorNavItemState();
}

class _VendorNavItemState extends State<_VendorNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _popScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.22), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.22, end: .94), weight: 30),
    TweenSequenceItem(tween: Tween(begin: .94, end: 1), weight: 35),
  ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant _VendorNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected && !reduceMotion(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hint = Theme.of(context).hintColor;
    final selected = widget.selected;
    return PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      pressedScale: .88,
      semanticLabel: widget.label,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
              horizontal: selected ? 18 : 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: selected ? AppDesign.brandGradient : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: primary.withValues(alpha: .28),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : const [],
          ),
          child: ScaleTransition(
            scale: _popScale,
            child: Badge(
                isLabelVisible: widget.count > 0,
                backgroundColor: AppDesign.danger,
                label: Text('+${widget.count}'),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child)),
                  child: Icon(selected ? widget.selectedIcon : widget.icon,
                      key: ValueKey(selected),
                      size: 23,
                      color: selected ? Colors.white : hint),
                )),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
              fontSize: selected ? 12.5 : 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? primary : hint),
          child: Text(widget.label,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
