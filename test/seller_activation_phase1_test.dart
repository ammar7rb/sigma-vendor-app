import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/seller_activation_banner_widget.dart';

class ActivationServiceFake implements AuthServiceInterface {
  String status = 'pending';
  @override
  String getRegistrationReference() => 'reference';
  @override
  Future<ApiResponse> activationStatus(String reference) async =>
      ApiResponse.withSuccess(Response(
          requestOptions: RequestOptions(path: '/activation'),
          statusCode: 200,
          data: {
            'activation': {
              'status': status,
              'banner': {'visible': status != 'active'}
            }
          }));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'red activation banner becomes green and remains green after refresh',
      (tester) async {
    final service = ActivationServiceFake();
    final auth = AuthController(authServiceInterface: service);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
            home: Scaffold(body: SellerActivationBannerWidget()))));
    await tester.pump();
    expect(find.text('seller_activation_required'), findsOneWidget);
    service.status = 'active';
    await auth.loadActivationStatus();
    await tester.pump();
    expect(find.text('seller_account_activated'), findsOneWidget);
    expect(find.text('seller_activation_required'), findsNothing);
    await auth.loadActivationStatus();
    await tester.pump();
    expect(auth.activationJustApproved, isTrue);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await auth.loadActivationStatus();
    await tester.pump();
    expect(find.text('seller_account_activated'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
  });
  test('Arabic covers all English keys including phase one messages', () {
    final english =
        jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map;
    final arabic =
        jsonDecode(File('assets/language/ar.json').readAsStringSync()) as Map;
    expect(
        english.keys.where((key) =>
            !arabic.containsKey(key) || '${arabic[key]}'.trim().isEmpty),
        isEmpty);
    for (final key in [
      'activation_chat_notice',
      'support_attachment_limits',
      'support_send_failed'
    ]) {
      expect(arabic[key], matches(RegExp(r'[\u0600-\u06FF]')));
    }
  });
}
