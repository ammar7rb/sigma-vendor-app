class EgyptPhoneHelper {
  EgyptPhoneHelper._();

  static final RegExp _localPattern = RegExp(r'^01[0125][0-9]{8}$');

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String normalizeLocal(String value) {
    var digits = digitsOnly(value);
    if (digits.startsWith('0020')) digits = digits.substring(4);
    if (digits.startsWith('20')) digits = digits.substring(2);
    return digits;
  }

  static bool isValidLocal(String value) => _localPattern.hasMatch(normalizeLocal(value));

  static String toInternational(String value) {
    final local = normalizeLocal(value);
    return local.startsWith('0') ? '+20${local.substring(1)}' : '+20$local';
  }
}
