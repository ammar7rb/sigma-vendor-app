import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/services/order_details_service_interface.dart';

ApiResponse reply(dynamic body, [int code = 200]) =>
    ApiResponse.withSuccess(Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: code,
        data: body));

class OrderServiceFake implements OrderDetailsServiceInterface {
  bool failDetails = false;
  int detailCalls = 0, proofCalls = 0;
  String status = 'processing';
  Completer<ApiResponse>? delayed;
  Completer<ApiResponse>? proofRequest;
  @override
  Future<ApiResponse> getOrderDetails(String id) async {
    detailCalls++;
    if (delayed != null) return delayed!.future;
    if (failDetails) throw StateError('transport failed');
    return reply([
      {
        'id': 1,
        'price': 10,
        'tax': 0,
        'discount': 0,
        'qty': 1,
        'order': {'id': 12, 'order_status': status}
      }
    ]);
  }

  @override
  Future<ApiResponse> getOrderStatusList(String type) async =>
      reply(['processing', 'delivered']);
  @override
  Future<ApiResponse> getShippingProofs(String id) async => reply({
        'proofs': status == 'delivered'
            ? [
                {
                  'id': 1,
                  'original_name': 'delivery.pdf',
                  'shipping_status': 'delivered'
                }
              ]
            : []
      });
  @override
  Future<ApiResponse> submitShippingProof(
      String id, String status, String path, String note) async {
    proofCalls++;
    if (proofRequest != null) return proofRequest!.future;
    this.status = status;
    return reply({'order_status': status}, 201);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('order opens directly and retains shipping proof loading', () async {
    final service = OrderServiceFake();
    final c = OrderDetailsController(orderDetailsServiceInterface: service);
    await c.getOrderDetails('12');
    expect(service.detailCalls, 1);
    expect(c.orderDetails!.first.order!.id, 12);
    expect(c.loadError, isNull);
    c.dispose();
  });
  test('administrative access failure remains closed and retry loads the order',
      () async {
    final service = OrderServiceFake()..failDetails = true;
    final c = OrderDetailsController(orderDetailsServiceInterface: service);
    await c.getOrderDetails('12');
    expect(c.orderDetails, isEmpty);
    expect(c.loadError, isNotNull);
    expect(c.actionInProgress, isFalse);
    service.failDetails = false;
    await c.getOrderDetails('12');
    expect(c.loadError, isNull);
    expect(c.orderDetails!.first.order!.id, 12);
    c.dispose();
  });
  test('late order response cannot restore data after leaving the screen',
      () async {
    final service = OrderServiceFake()..delayed = Completer<ApiResponse>();
    final c = OrderDetailsController(orderDetailsServiceInterface: service);
    final request = c.getOrderDetails('12');
    c.emptyOrderDetails();
    service.delayed!.complete(reply([
      {
        'id': 1,
        'order': {'id': 12}
      }
    ]));
    await request;
    expect(c.orderDetails, isNull);
    expect(c.actionInProgress, isFalse);
    c.dispose();
  });
  test('delivery proof completes order and refreshes private history',
      () async {
    final service = OrderServiceFake();
    final c = OrderDetailsController(orderDetailsServiceInterface: service);
    await c.getOrderDetails('12');
    expect(
        await c.submitShippingProof(
            '12', 'delivered', 'delivery.pdf', 'received'),
        isTrue);
    expect(c.orderDetails!.first.order!.orderStatus, 'delivered');
    expect(c.shippingProofs.single['original_name'], 'delivery.pdf');
    c.dispose();
  });
  test('duplicate delivery submit blocked and failure releases action lock',
      () async {
    final service = OrderServiceFake()..proofRequest = Completer<ApiResponse>();
    final c = OrderDetailsController(orderDetailsServiceInterface: service);
    await c.getOrderDetails('12');
    final pending =
        c.submitShippingProof('12', 'delivered', 'delivery.pdf', '');
    expect(await c.submitShippingProof('12', 'delivered', 'delivery.pdf', ''),
        isFalse);
    expect(service.proofCalls, 1);
    final failure = expectLater(pending, throwsStateError);
    service.proofRequest!.completeError(StateError('network'));
    await failure;
    expect(c.shippingProofLoading, isFalse);
    c.dispose();
  });
  test('phase three copy is translated in Arabic and English', () {
    final en =
        jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map;
    final ar =
        jsonDecode(File('assets/language/ar.json').readAsStringSync()) as Map;
    for (final file in Directory('lib/features/order_details')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      for (final match in RegExp(r"'(seller_journey_[a-z_]+)'")
          .allMatches(file.readAsStringSync())) {
        expect(en[match[1]], isNotEmpty, reason: match[1]);
        expect(ar[match[1]], matches(RegExp(r'[\u0600-\u06ff]')),
            reason: match[1]);
      }
    }
  });
}
