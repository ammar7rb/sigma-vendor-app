import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/funding_amount.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';

class FundingServiceFake implements WalletServiceInterface {
  final request = Completer<ApiResponse>();
  int calls = 0;
  @override
  Future<ApiResponse> payOperatingBalance(
      {required String amount,
      required String paymentMethod,
      String walletTarget = 'operating'}) {
    calls++;
    return request.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('funding prevents concurrent submission and releases lock after failure',
      () async {
    final service = FundingServiceFake();
    final controller = WalletController(walletServiceInterface: service);
    final first =
        controller.payOperatingBalance(amount: '10', paymentMethod: 'test');
    expect(controller.isFunding, isTrue);
    expect(
        await controller.payOperatingBalance(
            amount: '10', paymentMethod: 'test'),
        isNull);
    expect(service.calls, 1);
    final expectation = expectLater(first, throwsStateError);
    service.request.completeError(StateError('transport failed'));
    await expectation;
    expect(controller.isFunding, isFalse);
    controller.dispose();
  });
  test('funding supports unlimited maximum and rejects non-finite amounts', () {
    expect(
        fundingAmountError('100', {'min_amount': 1, 'max_amount': 0}), isNull);
    expect(fundingAmountError('NaN', {}), 'please_enter_amount');
    expect(fundingAmountError('Infinity', {}), 'please_enter_amount');
    expect(fundingAmountError('-1', {}), 'please_enter_amount');
    expect(fundingAmountError('9', {'min_amount': 10}), 'finance_below_min');
    expect(fundingAmountError('21', {'max_amount': 20}), 'finance_above_max');
    expect(fundingAmountError('20', {'max_amount': 20}), isNull);
  });
  test('financial summary keeps separate insurance credit from legacy payload',
      () {
    final model = SellerBalanceModel.fromJson({
      'summary': {'order_insurance_credit': '35.5', 'available': 9},
      'financial_summary': {'available': 12, 'operating': '50'},
    });
    expect(model.summary['order_insurance_credit'], 35.5);
    expect(model.summary['available'], 12);
    expect(model.summary['operating'], 50);
  });
  test('wallet labels have complete Arabic and English translations', () {
    final en =
        jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map;
    final ar =
        jsonDecode(File('assets/language/ar.json').readAsStringSync()) as Map;
    final screen =
        File('lib/features/wallet/screens/seller_finance_screen.dart')
            .readAsStringSync();
    final keys =
        RegExp(r"'((?:finance_)[a-z_]+)'").allMatches(screen).map((m) => m[1]!);
    for (final key in keys) {
      expect(en[key], isNotEmpty, reason: key);
      expect(ar[key], matches(RegExp(r'[\u0600-\u06ff]')), reason: key);
    }
  });
}
