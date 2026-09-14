import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/helper/egypt_phone_helper.dart';

void main() {
  test('accepts only supported 11-digit Egyptian mobile prefixes', () {
    for (final number in ['01012345678', '01112345678', '01212345678', '01512345678']) {
      expect(EgyptPhoneHelper.isValidLocal(number), isTrue);
    }
    for (final number in ['01312345678', '0101234567', '010123456789']) {
      expect(EgyptPhoneHelper.isValidLocal(number), isFalse);
    }
  });

  test('normalizes a local number to the backend canonical form', () {
    expect(EgyptPhoneHelper.toInternational('01012345678'), '+201012345678');
    expect(EgyptPhoneHelper.toInternational('+20 10 1234 5678'), '+201012345678');
  });
}
