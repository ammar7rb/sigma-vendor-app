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
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;
import 'seller_order_phase3_widget_test.dart' show LoadedLocale;

class FreeVendorFixture extends FinanceApiFixture {
  FreeVendorFixture(super.preferences);

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
            'subscription': null,
            'slots': [],
            'products': [],
            'capacity': {},
            'extra_settings': {'enabled': false},
            'can_buy_extra': false,
          });
}

void main() {
  testWidgets(
      'vendor without a package has an enabled Arabic submission action',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    di.sl.registerSingleton<DioClient>(
        FreeVendorFixture(await SharedPreferences.getInstance()));
    addTearDown(() => di.sl.unregister<DioClient>());
    final theme = ThemeController(sharedPreferences: null);
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
    final boundary = GlobalKey();
    for (final size in [const Size(360, 800), const Size(768, 1024)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(ChangeNotifierProvider<ThemeController>.value(
          value: theme,
          child: MaterialApp(
              theme: light,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: [
                LoadedLocale(locale),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: RepaintBoundary(
                  key: boundary, child: const ProductListMenuScreen()))));
      await tester.pumpAndSettle();
      expect(find.text('لا اشتراك مدفوع'), findsOneWidget);
      expect(find.text('إضافة منتج دون مساحة'), findsOneWidget);
      expect(
          tester
              .widget<FloatingActionButton>(find.byType(FloatingActionButton))
              .onPressed,
          isNotNull);
      expect(tester.takeException(), isNull);
      final capture = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
      if (capture != null) {
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory(capture).createSync(recursive: true);
          File('$capture/free-product-${size.width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }
    }
  });
}
