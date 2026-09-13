import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/maintenance/maintenance_screen.dart';
import 'package:sixvalley_vendor_app/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_details_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/features/update/screen/update_screen.dart';
import 'package:sixvalley_vendor_app/helper/network_info.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/notification/models/notification_body.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/auth_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .86, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));
    _animationController.forward();
    Provider.of<AuthController>(Get.context!, listen: false)
        .setUnAuthorize(false, update: false);
    initCall();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initCall() async {
    if (!kIsWeb) {
      NetworkInfo.checkConnectivity(context);
    }
    Provider.of<SplashController>(context, listen: false)
        .initConfig()
        .then((bool isSuccess) {
      if (isSuccess) {
        Provider.of<SplashController>(Get.context!, listen: false)
            .getBusinessPagesList('default');
        Provider.of<SplashController>(Get.context!, listen: false)
            .initShippingTypeList(Get.context!, '');
        Timer(const Duration(seconds: 1), () async {
          final config =
              Provider.of<SplashController>(Get.context!, listen: false)
                  .configModel;
          SellerAppVersionControl? appVersion =
              Provider.of<SplashController>(Get.context!, listen: false)
                  .configModel
                  ?.sellerAppVersionControl;
          String? minimumVersion = '0';

          if (!kIsWeb && Platform.isAndroid) {
            minimumVersion = appVersion?.forAndroid?.version ?? '0';
          } else if (!kIsWeb && Platform.isIOS) {
            minimumVersion = appVersion?.forIos?.version ?? '0';
          }

          if (compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
            Navigator.of(Get.context!).pushReplacement(
                MaterialPageRoute(builder: (_) => const UpdateScreen()));
          } else if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
              config?.maintenanceModeData?.selectedMaintenanceSystem
                      ?.vendorApp ==
                  1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
              builder: (_) => const MaintenanceScreen(),
              settings: const RouteSettings(name: 'MaintenanceScreen'),
            ));
          } else {
            if (widget.body != null) {
              String notificationType = widget.body?.type ?? "";

              switch (notificationType.toLowerCase()) {
                case 'chatting':
                case 'wallet':
                case 'wallet_withdraw':
                  {
                    // Inbox and earnings pages are hidden from vendors; keep notifications reachable.
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const NotificationScreen()));
                  }
                  break;

                case 'theme':
                  {
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const NotificationScreen()));
                  }
                  break;

                case 'order':
                  {
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                                orderId:
                                    int.parse(widget.body!.orderId.toString()),
                                fromNotification: true)));
                  }
                  break;

                case 'product_request_approved_message':
                  {
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const ProductListMenuScreen(
                                fromNotification: true)));
                  }
                  break;

                case 'refund':
                  {
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => RefundDetailsScreen(
                                fromNotification: true,
                                refundModel:
                                    RefundModel(id: widget.body!.refundId),
                                orderDetailsId: widget.body!.orderDetailsId)));
                  }
                  break;

                default:
                  {
                    Navigator.of(Get.context!).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const NotificationScreen()));
                  }
                  break;
              }
            } else {
              if (Provider.of<AuthController>(context, listen: false)
                  .isLoggedIn()) {
                await Provider.of<AuthController>(context, listen: false)
                    .updateToken(context);
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const DashboardScreen()));
              } else {
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => const AuthScreen()));
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDesign.brandGradient,
          image: DecorationImage(
              image: AssetImage(Images.sigmaSplashBackground),
              fit: BoxFit.cover),
        ),
        child: Stack(children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Hero(
                  tag: 'logo',
                  child: ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Image.asset(Images.sigmaLogoTransparent,
                        width: MediaQuery.sizeOf(context).width * .76,
                        fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part =
          i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part =
          i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }
}
