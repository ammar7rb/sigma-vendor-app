import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/seller_shipping_assignment_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'seller_order_phase3_test.dart' show OrderServiceFake;

class SplashServiceFake implements SplashServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FinanceSplashFake extends SplashController {
  FinanceSplashFake() : super(serviceInterface: SplashServiceFake());
  @override
  ConfigModel get configModel =>
      ConfigModel(currencyModel: 'single_currency', decimalPointSettings: 2)
        ..currencySymbolPosition = 'right';
  @override
  CurrencyList get myCurrency =>
      CurrencyList(code: 'EGP', symbol: 'ج.م', exchangeRate: 1);
}

class LoadedLocale extends LocalizationsDelegate<AppLocalization> {
  final AppLocalization value;
  const LoadedLocale(this.value);
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<AppLocalization> load(Locale locale) => SynchronousFuture(value);
  @override
  bool shouldReload(LoadedLocale old) => false;
}

void main() {
  testWidgets(
      'Arabic delivery form fits narrow dark and light screens and completed state removes submit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = OrderDetailsController(
        orderDetailsServiceInterface: OrderServiceFake());
    final splash = FinanceSplashFake();
    addTearDown(controller.dispose);
    addTearDown(splash.dispose);
    final boundary = GlobalKey();
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(() async {
      await locale.load();
      await GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
      await GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));
    });
    Future<void> render(Brightness brightness, String status) async {
      final order = Order.fromJson({
        'id': 12,
        'order_status': status,
        'shipping_assignment': {
          'status': 'assigned',
          'responsible_party': 'seller',
          'seller_entitlement': 85,
          'seller_shipping_response': {'required': false}
        }
      });
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<OrderDetailsController>.value(
                value: controller),
            ChangeNotifierProvider<SplashController>.value(value: splash)
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: [
              LoadedLocale(locale),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: brightness)),
            home: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                    body: SingleChildScrollView(
                        child: SellerShippingAssignmentWidget(order: order)))),
          )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await render(Brightness.dark, 'processing');
    expect(find.text('إرسال الإثبات وإتمام الطلب'), findsOneWidget);
    await render(Brightness.light, 'processing');
    await render(Brightness.dark, 'delivered');
    expect(find.text('إرسال الإثبات وإتمام الطلب'), findsNothing);
    expect(find.textContaining('تم حفظ إثبات التسليم'), findsOneWidget);
  });
}
