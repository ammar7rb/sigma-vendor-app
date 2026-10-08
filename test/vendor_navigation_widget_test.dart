import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/seller_dashboard_overview_widget.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/vendor_menu_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_navigation_actions.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart'
    show FinanceSplashFake, LoadedLocale;
import 'seller_finance_phase2_test.dart' show FundingServiceFake;
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

class OverviewFixture extends WalletController {
  OverviewFixture() : super(walletServiceInterface: FundingServiceFake());
  @override
  Map<String, dynamic>? get dashboardOverview => {
        'sales': {'orders_count': 12, 'sold_units': 48},
        'products': {'total': 3}
      };
}

void main() {
  testWidgets(
      'approved navigation renders in Arabic and English and inbox icons open their pages',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    di.sl.registerSingleton<DioClient>(
        FinanceApiFixture(await SharedPreferences.getInstance()));
    addTearDown(() => di.sl.unregister<DioClient>());
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final wallet = OverviewFixture();
    final splash = FinanceSplashFake();
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(wallet.dispose);
    addTearDown(splash.dispose);
    addTearDown(theme.dispose);
    await tester.runAsync(() async {
      await (FontLoader('VendorCare')
            ..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    VendorWorkspace.instance.counts
        .addAll({'orders': 2, 'notifications': 2, 'messages': 1});
    addTearDown(VendorWorkspace.instance.stop);
    for (final language in ['ar', 'en']) {
      final locale = AppLocalization(Locale(language));
      await tester.runAsync(locale.load);
      for (final size in [const Size(360, 800), const Size(800, 1100)]) {
        await tester.binding.setSurfaceSize(size);
        final boundary = GlobalKey();
        int selected = -1;
        await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider<WalletController>.value(value: wallet),
              ChangeNotifierProvider<SplashController>.value(value: splash),
              ChangeNotifierProvider<ThemeController>.value(value: theme),
            ],
            child: RepaintBoundary(
                key: boundary,
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: light,
                    locale: Locale(language),
                    supportedLocales: const [Locale('ar'), Locale('en')],
                    localizationsDelegates: [
                      LoadedLocale(locale),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate
                    ],
                    home: Scaffold(
                      appBar: AppBar(
                          title: Image.asset(Images.sigmaLogoTransparent,
                              width: 110, height: 48),
                          actions: const [VendorNavigationActions()]),
                      bottomNavigationBar: VendorBottomNavigation(
                          selectedIndex: 0,
                          onSelected: (index) => selected = index),
                      body: const SingleChildScrollView(
                          child: SellerDashboardOverviewWidget()),
                    )))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find
            .ancestor(
                of: find.byIcon(Icons.receipt_long_outlined),
                matching: find.byType(InkWell))
            .first);
        expect(selected, 3);
        await tester.pumpAndSettle();
        Future<void> capture(String name) async {
          final dir = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
          if (dir == null) return;
          await tester.runAsync(() async {
            final image = await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            Directory(dir).createSync(recursive: true);
            File('$dir/$name-$language-${size.width.toInt()}.png')
                .writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('flutter-home');
        for (final icon in [Icons.mail_outline, Icons.notifications_outlined]) {
          await tester.tap(find
              .ancestor(
                  of: find.byIcon(icon), matching: find.byType(IconButton))
              .first);
          await tester.pumpAndSettle();
          expect(find.byType(VendorInboxScreen), findsOneWidget);
          expect(
              tester
                  .widget<VendorInboxScreen>(find.byType(VendorInboxScreen))
                  .messages,
              icon == Icons.mail_outline);
          expect(tester.takeException(), isNull);
          final ctx = tester.element(find.byType(VendorInboxScreen));
          Navigator.pop(ctx);
          await tester.pumpAndSettle();
        }
        final ctx = tester.element(find.byType(SellerDashboardOverviewWidget));
        showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            builder: (_) => const MenuBottomSheetWidget());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet_outlined),
            findsOneWidget); // bottom bar only
        await capture('flutter-other');
        Navigator.pop(tester.element(find.byType(MenuBottomSheetWidget)));
        await tester.pumpAndSettle();
      }
    }
  });
}
