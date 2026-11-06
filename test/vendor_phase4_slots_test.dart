import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_slots_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart'
    show FinanceSplashFake, LoadedLocale;
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

import 'vendor_advertising_phase4_test.dart' show AdvertisingFixture;

class ReservationFixture extends AdvertisingFixture {
  ReservationFixture(super.prefs) {
    selected = null;
  }
  String mode = 'available';
  bool allowExtra = false;
  @override
  Future<Response> get(String uri,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    final response = uri.endsWith('/slots')
        ? Response(requestOptions: RequestOptions(path: uri), statusCode: 200, data: {
            'subscription': {'id': 1, 'package_name': 'اشتراك قائم', 'starts_at': '2026-10-14', 'expires_at': '2026-11-14'},
            'capacity': {'total': 1, 'used': selected == null ? 0 : 1, 'reserved': 0, 'available': selected == null ? 1 : 0},
            'extra_settings': {'enabled': false},
            'slots': [{'id': 7, 'position': 1, 'capacity_status': mode, 'editable': true, 'product_id': selected,
              'expires_at': '2026-11-14', 'statistics': {'visits': 7, 'orders': 2},
              'product': selected == null ? null : {'id': selected, 'name': selected == 1 ? 'منتج قائم' : 'منتج بديل', 'request_status': 0}}],
            'products': [{'id': 1, 'name': 'منتج قائم'}, {'id': 2, 'name': 'منتج بديل'}],
          })
        : await super.get(uri);
    if (uri.endsWith('/slots')) {
      response.data['can_buy_extra'] = allowExtra;
      response.data['extra_publish_enabled'] = allowExtra;
      if (allowExtra) response.data['extra_settings'] = {'enabled': true, 'unit_price': 200};
      response.data['slots'][0]['capacity_status'] = mode;
      response.data['slots'][0]['editable'] = mode != 'expired';
      if (response.data['slots'][0]['product'] != null) {
        response.data['slots'][0]['product']['request_status'] = 0;
        response.data['slots'][0]['product']['vendor_workspace'] = {
          'advertising_visible': mode == 'occupied',
        };
      }
      response.data['capacity']['reserved'] = mode == 'reserved' ? 1 : 0;
      response.data['capacity']['available'] = mode == 'available' ? 1 : 0;
    }
    return response;
  }

  @override
  Future<Response> post(String uri,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    submissions.add({'uri': uri, ...Map<String, dynamic>.from(data ?? {})});
    mode = uri.endsWith('/reserve') ? 'reserved' : 'available';
    return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 200,
        data: {'slot_id': 7, 'expires_at': '2026-11-14'});
  }
}

void main() {
  testWidgets(
      'slot form reserves on open, cancellation frees it, and occupied and expired cards fit both locales',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = ReservationFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(client);
    addTearDown(() => di.sl.unregister<DioClient>());
    final splash = FinanceSplashFake();
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(splash.dispose);
    addTearDown(theme.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await (FontLoader('VendorCare')
            ..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    for (final lang in ['ar', 'en']) {
      final locale = AppLocalization(Locale(lang));
      await tester.runAsync(() => locale.load());
      for (final width in [360.0, 800.0]) {
        await tester.binding.setSurfaceSize(Size(width, 1000));
        var opened = false;
        final boundary = GlobalKey();
        Widget mount() => MultiProvider(
                providers: [
                  ChangeNotifierProvider<SplashController>.value(value: splash),
                  ChangeNotifierProvider<ThemeController>.value(value: theme)
                ],
                child: MaterialApp(
                    theme: light,
                    locale: Locale(lang),
                    supportedLocales: const [Locale('ar'), Locale('en')],
                    localizationsDelegates: [
                      LoadedLocale(locale),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate
                    ],
                    home: RepaintBoundary(
                        key: boundary,
                        child: SellerSlotsScreen(
                            key: UniqueKey(),
                            openProductForm: (slot, token) async {
                              expect(slot, 7);
                              expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(token),
                                  isTrue);
                              opened = true;
                            }))));
        client.mode = 'available';
        client.selected = null;
        await tester.pumpWidget(mount());
        await tester.pumpAndSettle();
        await tester
            .tap(find.text(lang == 'ar' ? 'إضافة منتج' : 'Add product'));
        await tester.pumpAndSettle();
        expect(opened, isTrue);
        expect(client.submissions.last['uri'], endsWith('/7/reserve'));
        await tester.tap(find.text(lang == 'ar'
            ? 'إلغاء الإضافة'
            : 'Cancel addition'));
        await tester.pumpAndSettle();
        expect(
            client.submissions.last['uri'], endsWith('/7/cancel-reservation'));
        expect(find.text(lang == 'ar' ? 'إضافة منتج' : 'Add product'),
            findsOneWidget);
        client.mode = 'occupied';
        client.selected = 1;
        await tester.pumpWidget(mount());
        await tester.pumpAndSettle();
        expect(find.text('منتج قائم'), findsOneWidget);
        expect(find.text(lang == 'ar' ? 'نشط' : 'Active'), findsWidgets);
        expect(find.text('مراجعة الإدارة مطلوبة'), findsNothing);
        expect(find.text('Administration review required'), findsNothing);
        expect(tester.takeException(), isNull);
        client.mode = 'expired';
        await tester.pumpWidget(mount());
        await tester.pumpAndSettle();
        expect(find.text(lang == 'ar' ? 'إضافة منتج' : 'Add product'),
            findsNothing);
        expect(find.text('منتج قائم'), findsOneWidget);
        expect(tester.takeException(), isNull);
        final search = find.byKey(const ValueKey('saved-ad-search'));
        await tester.scrollUntilVisible(search, 300,
            scrollable: find.byType(Scrollable).first);
        await tester.enterText(search, 'اسم غير موجود');
        await tester.pumpAndSettle();
        expect(
            find.text(lang == 'ar'
                ? 'لا توجد إعلانات تطابق اختيارك.'
                : 'No advertisements match your selection.'),
            findsOneWidget);
        await tester.enterText(search, '');
        await tester.pumpAndSettle();
        expect(find.text('منتج بديل'), findsOneWidget);
        if (lang == 'ar' && width == 360.0) {
          client.mode = 'available';
          client.allowExtra = true;
          await tester.pumpWidget(mount());
          await tester.pumpAndSettle();
          final addExtra = find.text('إضافة إعلان');
          await tester.scrollUntilVisible(addExtra, 300, scrollable: find.byType(Scrollable).first);
          final submittedBefore = client.submissions.length;
          await tester.tap(addExtra);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.textContaining('يُخصم عند نشر المنتج من الرصيد النقدي'), findsOneWidget);
          expect(client.submissions.length, submittedBefore);
          await tester.tap(find.text('رجوع').last);
          await tester.pumpAndSettle();
          client.allowExtra = false;
        }
      }
    }
  });
}
