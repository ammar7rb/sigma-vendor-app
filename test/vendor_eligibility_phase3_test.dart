import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/repositories/order_details_repository.dart';
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/vendor_eligibility_view.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_test.dart' show OrderServiceFake, reply;
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';

Map<String, dynamic> fixture({bool partial = false, bool pending = false}) => {
      'id': 42,
      'order_status': 'confirmed',
      'fulfillment_eligibility': {
        'has_restrictions': true,
        'details_locked': !partial,
        'partially_locked': partial,
        'restricted_amount': 160.0,
        'accessible_amount': partial ? 148.0 : 0.0,
        'pending_on_vendor_side': pending,
        'forwarded_at': '2026-11-06T12:00:00Z',
      },
      'order_details': partial
          ? [
              {
                'qty': 2,
                'price': 70,
                'product_details': {'name': 'المنتج المتاح'}
              }
            ]
          : [],
    };

class RestrictedService extends OrderServiceFake {
  @override
  Future<ApiResponse> getOrderDetails(String id) async =>
      reply({'fulfillment_request': fixture()});
}

class EligibilityTransport extends FinanceApiFixture {
  final List<String> reads = [];
  EligibilityTransport(super.preferences);
  @override
  Future<Response> get(String uri,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    reads.add(uri);
    return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 200,
        data: {'fulfillment_request': fixture()});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'repository stops at the safe summary without requesting protected details',
      () async {
    SharedPreferences.setMockInitialValues({});
    final transport =
        EligibilityTransport(await SharedPreferences.getInstance());
    final response = await OrderDetailsRepository(dioClient: transport)
        .getOrderDetails('42');
    expect(transport.reads, ['/api/v3/seller/fulfillment-requests/order/42']);
    expect(
        response.response?.data['fulfillment_request']
            ['fulfillment_eligibility']['has_restrictions'],
        isTrue);
  });
  test('restricted payload never loads the normal fulfillment or shared proofs',
      () async {
    final service = RestrictedService();
    final controller =
        OrderDetailsController(orderDetailsServiceInterface: service);
    await controller.getOrderDetails('42');
    expect(controller.restrictedFulfillment?['id'], 42);
    expect(controller.orderDetails, isEmpty);
    expect(controller.shippingProofs, isEmpty);
    expect(controller.loadError, isNull);
    controller.emptyOrderDetails();
    expect(controller.restrictedFulfillment, isNull);
    controller.dispose();
  });

  testWidgets(
      'Arabic full and partial locks show separate totals and package prompt on phone and tablet',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await (FontLoader('VendorCare')
            ..addFont(rootBundle.load('assets/font/vendor-care/Vazirmatn.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    for (final width in [360.0, 768.0]) {
      for (final partial in [false, true]) {
        await tester.binding.setSurfaceSize(Size(width, 1100));
        final boundary = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            theme: light,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            home: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                    body: VendorEligibilityView(
                        order: fixture(partial: partial, pending: true),
                        onRefresh: () {})))));
        await tester.pumpAndSettle();
        expect(find.text('طلبات معلقة من جهة التاجر'), findsOneWidget);
        expect(find.text('160.00 ج.م'), findsOneWidget);
        expect(find.text('المنتج المتاح'),
            partial ? findsOneWidget : findsNothing);
        if (partial) {
          expect(find.text('الجزء المتاح: 148.00 ج.م'), findsOneWidget);
        }
        expect(find.text('SECRET'), findsNothing);
        expect(tester.takeException(), isNull);
        final capture = Platform.environment['VENDOR_QA_CAPTURE_DIR'];
        if (capture != null) {
          await tester.runAsync(() async {
            final image = await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            Directory(capture).createSync(recursive: true);
            File('$capture/eligibility-${partial ? 'partial' : 'full'}-${width.toInt()}.png')
                .writeAsBytesSync(bytes!.buffer.asUint8List());
          });
        }
        await tester.tap(find.text('عرض التفاصيل'));
        await tester.pumpAndSettle();
        expect(find.text('برجاء اختيار إحدى الباقات'), findsOneWidget);
        await tester.tap(find.text('إغلاق'));
        await tester.pumpAndSettle();
      }
    }
  });
}
