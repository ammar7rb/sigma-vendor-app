import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart' show FinanceSplashFake, LoadedLocale;
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

class AdvertisingFixture extends FinanceApiFixture {
  AdvertisingFixture(super.prefs);
  int? selected = 1;
  @override
  Future<Response> get(String uri, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) async {
    return Response(requestOptions: RequestOptions(path: uri), statusCode: 200, data: uri.endsWith('/slots') ? {
      'slots': [{'id': 7, 'position': 1, 'product_id': selected, 'expires_at': '2026-11-14', 'product': selected == null ? null : {'id': selected, 'name': selected == 1 ? 'منتج قائم' : 'منتج بديل', 'request_status': 0}}],
      'products': [{'id': 1, 'name': 'منتج قائم'}, {'id': 2, 'name': 'منتج بديل'}]
    } : {
      'packages': [for (final entry in [(5,3000), (10,5000), (20,8000)]) {'id': entry.$1, 'name': 'باقة ${entry.$1}', 'product_limit': entry.$1, 'package_price': entry.$2, 'duration_unit': 'days', 'duration_value': 30}],
      'subscription': {'can_purchase': true, 'scheduled': [], 'active': {'id': 1, 'package_name': 'اشتراك قائم', 'product_limit': 5, 'expires_at': '2026-11-14'}},
      'operating_balance': 5000,
    });
  }
  @override
  Future<Response> post(String uri, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) async {
    submissions.add(Map<String, dynamic>.from(data));
    selected = data['product_id'] as int?;
    return Response(requestOptions: RequestOptions(path: uri), statusCode: 200, data: {'message': 'تم إرسال المنتج للمراجعة'});
  }
}

void main() {
  testWidgets('three final-price packages and slot replacement fit Arabic phone and tablet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = AdvertisingFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(client);
    addTearDown(() => di.sl.unregister<DioClient>());
    final splash = FinanceSplashFake();
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(splash.dispose); addTearDown(theme.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(() async {
      await locale.load();
      final fonts = FontLoader('VendorCare')..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf'));
      await fonts.load();
      final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    for (final size in [const Size(360, 1000), const Size(800, 1100)]) {
      await tester.binding.setSurfaceSize(size);
      final boundary = GlobalKey();
      await tester.pumpWidget(MultiProvider(providers: [ChangeNotifierProvider<SplashController>.value(value: splash), ChangeNotifierProvider<ThemeController>.value(value: theme)],
        child: MaterialApp(theme: light, locale: const Locale('ar'), supportedLocales: const [Locale('ar')], localizationsDelegates: [LoadedLocale(locale), GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: RepaintBoundary(key: boundary, child: SellerPackageScreen(key: ValueKey(size))))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('كوبون'), findsNothing);
      expect(find.text('باقة 5'), findsOneWidget);
      final capture = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
      if (capture != null) await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory(capture).createSync(recursive: true);
        File('$capture/advertising-${size.width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.scrollUntilVisible(find.byType(DropdownButtonFormField<int>).hitTestable(), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('منتج بديل').last);
      await tester.pumpAndSettle();
      expect(client.submissions.last['product_id'], 2);
      expect(tester.takeException(), isNull);
    }
  });
}
