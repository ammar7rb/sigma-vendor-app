/// Returns a translation key for invalid input. A zero maximum means unlimited.
String? fundingAmountError(String? value, Map<String, dynamic> settings) {
  final amount = double.tryParse((value ?? '').trim());
  final min = double.tryParse('${settings['min_amount']}') ?? 0;
  final max = double.tryParse('${settings['max_amount']}') ?? 0;
  if (amount == null || !amount.isFinite || amount <= 0) {
    return 'please_enter_amount';
  }
  if (amount < min) return 'finance_below_min';
  if (max > 0 && amount > max) return 'finance_above_max';
  return null;
}
