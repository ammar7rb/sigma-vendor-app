import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

/// Bottom sheet shown only when the user picks "Custom Date" from the filter
/// popup menu. Provides from/to date pickers.
class AuctionSalesCustomDateSheet extends StatefulWidget {
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final void Function(DateTime from, DateTime to) onApply;

  const AuctionSalesCustomDateSheet({
    super.key,
    this.initialFrom,
    this.initialTo,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? initialFrom,
    DateTime? initialTo,
    required void Function(DateTime from, DateTime to) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuctionSalesCustomDateSheet(
        initialFrom: initialFrom,
        initialTo: initialTo,
        onApply: onApply,
      ),
    );
  }

  @override
  State<AuctionSalesCustomDateSheet> createState() =>
      _AuctionSalesCustomDateSheetState();
}

class _AuctionSalesCustomDateSheetState
    extends State<AuctionSalesCustomDateSheet> {
  DateTime? _from;
  DateTime? _to;
  final _fmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  Future<void> _pick({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: (!isFrom && _from != null) ? _from! : DateTime(2000),
      lastDate: (isFrom && _to != null) ? _to! : now,
    );
    if (picked == null) return;
    setState(() => isFrom ? _from = picked : _to = picked);
  }

  void _apply() {
    if (_from == null || _to == null) return;
    if (_to!.isBefore(_from!)) {
      showCustomToast(
        isSuccess: false,
        message: getTranslated('end_date_should_not_before_start_date', context) ?? 'End time should not be before start time',
        context: context,
      );
      return;
    }
    widget.onApply(_from!, _to!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        top: Dimensions.paddingSizeDefault,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                getTranslated('custom_date', context) ?? 'Custom Date',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: Dimensions.iconSizeDefault, color: isDark ? Colors.white : Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: getTranslated('from', context) ?? 'From',
                  value: _from != null ? _fmt.format(_from!) : null,
                  onTap: () => _pick(isFrom: true),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _DateField(
                  label: getTranslated('to', context) ?? 'To',
                  value: _to != null ? _fmt.format(_to!) : null,
                  onTap: () => _pick(isFrom: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_from != null && _to != null) ? _apply : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeMedium),
              ),
              child: Text(
                getTranslated('apply', context) ?? 'Apply',
                style: robotoMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: robotoRegularForAddProductHeading.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: isDark ? Colors.white70 : const Color(0xFF9D9D9D))),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? getTranslated('select_date', context) ?? 'Select Date',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isDark ? Colors.white : (value != null ? Colors.black87 : Colors.grey),
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: Dimensions.iconSizeSmall,
                    color: isDark ? Colors.white70 : Colors.grey.shade500),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
