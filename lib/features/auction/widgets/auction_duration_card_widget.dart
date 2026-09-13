import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionDurationCardWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const AuctionDurationCardWidget({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  Duration get _duration => endDate.difference(startDate);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    final Duration d = _duration.isNegative ? Duration.zero : _duration;
    final int days  = d.inDays;
    final int hours = d.inHours.remainder(24);
    final int mins  = d.inMinutes.remainder(60);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeExtraLarge,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).hintColor.withValues(alpha: 0.09),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated('auction_duration', context) ?? "",
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            DurationRow(days: days, hours: hours, mins: mins),

            const SizedBox(height: Dimensions.paddingSizeMedium),

            Text(
              '${DateConverter.formatDateWithComma(startDate)} - ${DateConverter.formatDateWithComma(endDate)}',
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DurationRow extends StatelessWidget {
  final int days;
  final int hours;
  final int mins;

  const DurationRow({super.key, required this.days, required this.hours, required this.mins});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DurationUnit(value: days,  label: getTranslated('days', context) ?? 'Days'),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        _DurationUnit(value: hours, label: getTranslated('hours', context) ?? 'Hours'),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        _DurationUnit(value: mins,  label: getTranslated('mins', context) ?? 'Mins'),
      ],
    );
  }
}

class _DurationUnit extends StatelessWidget {
  final int value;
  final String label;

  const _DurationUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:  Theme.of(context).primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLargeTwenty,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          label,
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
