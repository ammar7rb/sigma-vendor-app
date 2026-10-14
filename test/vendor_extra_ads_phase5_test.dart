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
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_extra_ads_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart'
    show FinanceSplashFake, LoadedLocale;
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

class ExtraFixture extends FinanceApiFixture {
  bool failFirst = true;
  ExtraFixture(super.prefs);
  @override
  Future<Response> get(String uri,
          {Map<String, dynamic>? queryParameters,
          Options? options,
          CancelToken? cancelToken,
          ProgressCallback? onReceiveProgress}) async =>
      Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 200,
          data: {
            'settings': {
              'enabled': true,
              'unit_price': '200.00',
              'max_slots': 100
            },
            'purchases': {
              'data': [
                {
                  'admin_reference': 'VAD-2026-EXAMPLE',
                  'quantity': 2,
                  'unit_price': '200.00',
                  'total_price': '400.00',
                  'status': 'manual_settlement',
                  'expires_at': '2026-11-14',
                  'review_note': 'تسوية يدوية مطلوبة'
                }
              ],
              'next_page_url': null
            }
          });
  @override
  Future<Response> post(String uri,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    submissions.add(Map<String, dynamic>.from(data));
    if (failFirst) {
      failFirst = false;
      throw DioException(
          requestOptions: RequestOptions(path: uri),
          type: DioExceptionType.receiveTimeout);
    }
    return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 200,
        data: {
          'purchase': {'status': 'paid'}
        });
  }
}

void main() {
  testWidgets(
      'extra purchase shows final total, keeps retry key, and fits Arabic phone and tablet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = ExtraFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(client);
    addTearDown(() => di.sl.unregister<DioClient>());
    final splash = FinanceSplashFake();
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(splash.dispose);
    addTearDown(theme.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(() async {
      await locale.load();
      await (FontLoader('VendorCare')
            ..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    for (final size in [const Size(360, 1000), const Size(800, 1100)]) {
      await tester.binding.setSurfaceSize(size);
      final boundary = GlobalKey();
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<SplashController>.value(value: splash),
            ChangeNotifierProvider<ThemeController>.value(value: theme)
          ],
          child: MaterialApp(
              theme: light,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: [
                LoadedLocale(locale),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              home: RepaintBoundary(
                  key: boundary,
                  child: SellerExtraAdsScreen(
                      key: ValueKey(size),
                      subscription: const {'id': 1, 'expires_at': '2026-11-14'},
                      overview: SellerPackageOverviewModel.fromJson({
                        'packages': [],
                        'subscription': {},
                        'offline_payment_methods': []
                      }))))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      final capture = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
      if (capture != null)
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory(capture).createSync(recursive: true);
          File('$capture/extra-ads-${size.width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      await tester.ensureVisible(find.text('شراء من رصيد المدفوعات'));
      await tester.tap(find.text('شراء من رصيد المدفوعات'));
      await tester.pumpAndSettle();
      expect(find.textContaining('400'), findsWidgets);
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();
      if (size.width == 360) {
        final key = client.submissions.last['request_key'];
        await tester.ensureVisible(find.text('شراء من رصيد المدفوعات'));
        await tester.tap(find.text('شراء من رصيد المدفوعات'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('تأكيد'));
        await tester.pumpAndSettle();
        expect(client.submissions.last['request_key'], key);
        expect(client.submissions.last['quantity'], 2);
        expect(client.submissions.last['expected_unit_price'], '200.00');
      }
      expect(tester.takeException(), isNull);
    }
  });
}
