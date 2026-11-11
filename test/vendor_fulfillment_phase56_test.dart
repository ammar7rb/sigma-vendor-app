import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/order_details/widgets/vendor_fulfillment_view.dart';
import 'vendor_finance_widget_test.dart' show FinanceApiFixture;

class FulfillmentApiFixture extends FinanceApiFixture {
  FulfillmentApiFixture(super.prefs);
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
            'quote': {
              'token': 'confirmed-cost-only',
              'extra_count': 1,
              'unit_price': 100,
              'total': 100,
              'wallet_debit': 30,
              'debt': 70,
              'expires_at': '2026-12-06',
              'message': 'المساحات مشغولة. ستضاف مساحة برسوم.'
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
    submissions.add({'path': uri, 'data': data});
    return Response(
        requestOptions: RequestOptions(path: uri), statusCode: 200, data: {});
  }
}

void main() {
  late FulfillmentApiFixture api;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    api = FulfillmentApiFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(api);
  });
  tearDown(() async => di.sl.reset());
  Map<String, dynamic> order(Map<String, dynamic> portion,
          {bool locked = false}) =>
      {
        'id': 42,
        'order_details': locked
            ? []
            : [
                {
                  'id': 11,
                  'qty': 2,
                  'price': 70,
                  'product_details': {'name': 'منتج التاجر الأصلي'}
                }
              ],
        'shipping_address_data':
            locked ? null : {'address': 'عنوان الجزء المتاح'},
        'fulfillment_eligibility': {
          'portion_actions_enabled': true,
          'has_restrictions': locked,
          'details_locked': locked,
          'partially_locked': false,
          'restricted_amount': 160,
          'forwarded_at': '2026-11-06T12:00:00Z',
          'portions': [portion]
        },
      };

  for (final width in [360.0, 768.0]) {
    testWidgets(
        'allocation requires reviewing wallet/debt and explicit confirmation at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var refreshes = 0;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: VendorFulfillmentView(
                  order: order({
                    'id': 1,
                    'status': 'locked',
                    'amount': 160,
                    'can_request_unlock': true
                  }, locked: true),
                  onRefresh: () async {
                    refreshes++;
                  }))));
      expect(find.text('منتج التاجر الأصلي'), findsNothing);
      await tester.ensureVisible(find.text('فتح الإعلان وعرض التفاصيل'));
      await tester.tap(find.text('فتح الإعلان وعرض التفاصيل'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('يسجل دينًا: 70.00 ج.م'), findsOneWidget);
      expect(find.textContaining('خصم من رصيد المدفوعات: 30.00 ج.م'),
          findsOneWidget);
      expect(api.submissions, isEmpty);
      await tester.tap(find.text('تأكيد التخصيص وعرض التفاصيل'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(api.submissions.single['path'],
          '/api/v3/seller/fulfillment-requests/1/unlock');
      expect(api.submissions.single['data'], {'token': 'confirmed-cost-only'});
      expect(refreshes, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'viewing available details never accepts and reject requires a reason',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: VendorFulfillmentView(
                order: order({
                  'id': 2,
                  'status': 'available',
                  'amount': 160,
                  'line_ids': [11],
                  'actions': ['accept', 'reject']
                }),
                onRefresh: () async {}))));
    expect(find.text('منتج التاجر الأصلي'), findsOneWidget);
    expect(api.submissions, isEmpty);
    await tester.ensureVisible(find.text('رفض قبل القبول — دون غرامة'));
    await tester.tap(find.text('رفض قبل القبول — دون غرامة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'تأكيد القرار'));
    expect(button.onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'غير مناسب');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('تأكيد القرار'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(api.submissions.single['data'],
        {'action': 'reject', 'reason': 'غير مناسب'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel displays assessed penalty and submits its revision',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: VendorFulfillmentView(
                order: order({
                  'id': 3,
                  'status': 'accepted',
                  'amount': 160,
                  'line_ids': [11],
                  'actions': ['cancel'],
                  'cancellation_preview': {
                    'assessed_amount': '14.00',
                    'revision': 9
                  }
                }),
                onRefresh: () async {}))));
    await tester.ensureVisible(find.text('إلغاء بعد القبول'));
    await tester.tap(find.text('إلغاء بعد القبول'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('الغرامة الحالية: 14.00 ج.م'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'تعذر التنفيذ');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('تأكيد القرار'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(api.submissions.single['data'],
        {'action': 'cancel', 'reason': 'تعذر التنفيذ', 'penalty_revision': 9});
    expect(tester.takeException(), isNull);
  });
}
