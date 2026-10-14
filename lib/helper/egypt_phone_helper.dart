class EgyptPhoneHelper {
  EgyptPhoneHelper._();

  static final RegExp _localPattern = RegExp(r'^01[0125][0-9]{8}$');

  static String digitsOnly(String value) => value.trim().replaceAllMapped(
    RegExp(r'[٠-٩۰-۹]'), (match) {
      final code = match[0]!.codeUnitAt(0);
      return (code >= 0x06f0 ? code - 0x06f0 : code - 0x0660).toString();
    }).replaceAll(RegExp(r'[\s()\-\u200e\u200f]'), '');

  static String normalizeLocal(String value) {
    var digits = digitsOnly(value);
    if (digits.startsWith('+20')) { digits = '0${digits.substring(3)}'; }
    else if (digits.startsWith('0020')) { digits = '0${digits.substring(4)}'; }
    else if (digits.startsWith('20')) { digits = '0${digits.substring(2)}'; }
    return digits;
  }

  static bool isValidLocal(String value) => _localPattern.hasMatch(normalizeLocal(value));

  static String toInternational(String value) {
    final local = normalizeLocal(value);
    return local.startsWith('0') ? '+20${local.substring(1)}' : '+20$local';
  }
}
