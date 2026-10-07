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
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_finance_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart'
    show FinanceSplashFake, LoadedLocale;

// Test-only transport fixture; production screens always use the persisted API.
class FinanceApiFixture extends DioClient {
  final List<Map<String, dynamic>> submissions = [];
  FinanceApiFixture(SharedPreferences prefs)
      : super('https://fixture.invalid', Dio(),
            loggingInterceptor: LoggingInterceptor(), sharedPreferences: prefs);
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
            'financial_summary': {
              'available': 100,
              'operating': 50,
              'order_insurance_credit': 75,
              'pending_withdraw': 0
            },
            'withdrawal_methods': [
              {'id': 12, 'method_name': 'حساب البنك المحفوظ'}
            ],
            'transactions': {'data': [], 'last_page': 1},
            'withdrawals': {'data': [], 'last_page': 1},
            'security_deposits': {
              'summary': {
                'total_paid': 90,
                'next_return_at': '2027-01-05',
                'next_return_amount': 90
              },
              'records': {'data': [], 'last_page': 1}
            },
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
    if (submissions.length == 1)
      throw DioException(
          requestOptions: RequestOptions(path: uri),
          response: Response(
              requestOptions: RequestOptions(path: uri),
              statusCode: 422,
              data: {'message': 'تعذر الإرسال، حاول مرة أخرى'}));
    return Response(
        requestOptions: RequestOptions(path: uri), statusCode: 200, data: {});
  }
}

void main() {
  testWidgets(
      'wallet adapts to phone and tablet and preserves withdrawal identity on retry',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final client = FinanceApiFixture(prefs);
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
      final fonts = FontLoader('VendorCare')
        ..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf'));
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    final boundary = GlobalKey();
    final captureDir = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
    for (final size in [const Size(360, 800), const Size(800, 1100)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<SplashController>.value(value: splash),
            ChangeNotifierProvider<ThemeController>.value(value: theme)
          ],
          child: MaterialApp(
              theme: light,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: [
                LoadedLocale(locale),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              home: RepaintBoundary(
                  key: boundary, child: const SellerFinanceScreen()))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.add_box_outlined), findsOneWidget);
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (captureDir != null) {
          Directory(captureDir).createSync(recursive: true);
          File('$captureDir/flutter-wallet-${size.width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        }
        image.dispose();
      });
    }
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حساب البنك المحفوظ').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '101');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(client.submissions, isEmpty);
    await tester.enterText(find.byType(TextField), '40');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(client.submissions.length, 1);
    expect(find.text('تعذر الإرسال، حاول مرة أخرى'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(client.submissions.length, 2);
    expect(client.submissions[0]['request_key'],
        client.submissions[1]['request_key']);
    expect(client.submissions[1]['saved_method_id'], 12);
    expect(client.submissions[1]['amount'], 40);
  });
}
