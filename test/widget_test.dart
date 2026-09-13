import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/seller_order_insurance_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/models/seller_balance_model.dart';
import 'package:sixvalley_vendor_app/helper/egypt_location_helper.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

void main() {
  test('mobile environment and Egypt-only location contract are valid', () {
    expect(AppConstants.baseUrl, isNotEmpty);
    expect(EgyptLocationHelper.contains(const LatLng(30.0444, 31.2357)), isTrue);
    expect(EgyptLocationHelper.contains(const LatLng(23.5880, 58.3829)), isFalse);
    expect(EgyptLocationHelper.normalize(const LatLng(23.5880, 58.3829)), EgyptLocationHelper.center);
  });

  test('per-order insurance remains hidden until the API allows details', () {
    final envelope = SellerOrderInsuranceEnvelope.fromJson({
      'enabled': true,
      'seller_order_insurance': {
        'id': 4,
        'order_id': 90,
        'amount': '125.50',
        'details_hidden': true,
        'can_view_order_details': false,
        'balances': {'operating': '500', 'reusable_insurance_credit': '50'},
      },
      'payment_options': {'operating_balance': false, 'reusable_insurance_credit': true},
    });

    expect(envelope.insurance?.detailsHidden, isTrue);
    expect(envelope.insurance?.canViewOrderDetails, isFalse);
    expect(envelope.insurance?.amount, 125.5);
    expect(envelope.paymentOptions.operatingBalance, isFalse);
    expect(envelope.paymentOptions.reusableInsuranceCredit, isTrue);
  });

  test('wallet presentation keeps financial tabs from the same payload', () {
    final balance = SellerBalanceModel.fromJson({
      'financial_summary': {'available': '100'},
      'financial_records': [],
      'financial_tabs': {
        'shipping': [
          {'bucket': 'available', 'direction': 'credit', 'amount': '20', 'shipment_reference': 'SHP-1'},
        ],
      },
      'deposits': [],
      'settlements': {},
      'funding_settings': {},
    });

    expect(balance.summary['available'], 100);
    expect(balance.financialTabs['shipping']?.single.shipmentReference, 'SHP-1');
  });
}
