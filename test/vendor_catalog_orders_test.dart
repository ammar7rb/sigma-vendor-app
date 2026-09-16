import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home removes duplicated product ranking sections', () {
    final home = File('lib/features/home/screens/home_page_screen.dart')
        .readAsStringSync();

    expect(home, isNot(contains('TopSellingProductScreen')));
    expect(home, isNot(contains('MostPopularProductScreen')));
    expect(home, isNot(contains('getTopSellingProductList')));
    expect(home, isNot(contains('getMostPopularProductList')));
  });

  test('bank information flow is null safe while data is loading', () {
    final info = File('lib/features/bank_info/screens/bank_info_screen.dart')
        .readAsStringSync();
    final edit = File('lib/features/bank_info/screens/bank_editing_screen.dart')
        .readAsStringSync();

    expect(info, contains('bankProvider.bankInfo == null'));
    expect(info, isNot(contains('bankProvider.bankInfo!')));
    expect(edit, contains('widget.sellerModel?.bankName'));
  });

  test('orders expose all active insurance pending and dispute filters', () {
    final orders =
        File('lib/features/order/screens/order_screen.dart').readAsStringSync();
    final repository =
        File('lib/features/order/domain/repositories/order_repository.dart')
            .readAsStringSync();

    for (final index in ['index: 0', 'index: 10', 'index: 9', 'index: 11']) {
      expect(orders, contains(index));
    }
    expect(repository, contains("status == 'disputed'"));
    expect(repository, contains("queryParameters['status'] = 'all'"));
  });
}
