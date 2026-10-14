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
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_balance_funding_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_finance_phase2_test.dart' show FundingServiceFake;
import 'seller_order_phase3_widget_test.dart'
    show FinanceSplashFake, LoadedLocale;
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

class FundingWalletFixture extends WalletController {
  FundingWalletFixture() : super(walletServiceInterface: FundingServiceFake());
  @override
  SellerBalanceModel? get sellerBalance => SellerBalanceModel.fromJson({
        'summary': {'operating': 1000},
        'offline_payment_available': true,
        'funding_settings': {
          'min_amount': 1,
          'max_amount': 0,
          'currency_code': 'EGP'
        },
        'offline_payment_methods': [
          {
            'id': 1,
            'method_name': 'InstaPay',
            'payment_channel': 'instapay',
            'method_fields': [],
            'method_informations': []
          }
        ]
      });
  @override
  Future<bool> getSellerBalance([BuildContext? context]) async => true;
}

class IntentApiFixture extends FinanceApiFixture {
  bool completed = false;
  IntentApiFixture(super.prefs);
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
            'packages': [
              {
                'id': 1,
                'name': 'الأساسية',
                'package_price': 3000,
                'product_limit': 5
              }
            ],
            'subscription': {'id': 5, 'expires_at': '2026-11-15'},
            'extra_settings': {
              'enabled': true,
              'unit_price': '200.00',
              'max_slots': 100
            },
            'intents': {
              'data': [
                {
                  'id': 8,
                  'deposit_id': 10,
                  'purchase_amount': '3000.00',
                  'status': completed ? 'completed' : 'insufficient_balance',
                  'message': completed
                      ? 'تم الشراء بالشروط المثبتة.'
                      : 'رصيد المدفوعات غير كافٍ. اشحن الرصيد ثم اضغط إعادة المحاولة.'
                }
              ]
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
    submissions.add({'uri': uri});
    completed = true;
    return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 200,
        data: {
          'intent': {'status': 'completed'}
        });
  }
}

void main() {
  testWidgets(
      'funding defaults to credit only and requires explicit plan choice and retry on Arabic phone and tablet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = IntentApiFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(client);
    addTearDown(() => di.sl.unregister<DioClient>());
    final wallet = FundingWalletFixture();
    final splash = FinanceSplashFake();
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(wallet.dispose);
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
      client.completed = false;
      await tester.binding.setSurfaceSize(size);
      final boundary = GlobalKey();
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<WalletController>.value(value: wallet),
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
                  child: SellerBalanceFundingScreen(key: ValueKey(size))))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('إضافة رصيد فقط'), findsOneWidget);
      expect(client.submissions, isEmpty);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('شراء أو تجديد باقة أختارها').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('3000'), findsWidgets);
      final capture = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
      if (capture != null)
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory(capture).createSync(recursive: true);
          File('$capture/funding-${size.width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      await tester.ensureVisible(find.text('إعادة محاولة الشراء'));
      await tester.tap(find.text('إعادة محاولة الشراء'));
      await tester.pumpAndSettle();
      expect(client.submissions.last['uri'],
          '/api/v3/seller/balance/funding-intents/8/retry');
      expect(find.text('تم الشراء بالشروط المثبتة.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      client.submissions.clear();
    }
  });
}
