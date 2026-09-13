import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class InfoSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final List<({String label, List<String> values})> listValueItems;
  final String? statusBadge;

  const InfoSectionWidget({
    super.key,
    required this.title,
    required this.items,
    this.listValueItems = const [],
    this.statusBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeMedium,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              if (statusBadge != null) _StatusBadge(status: statusBadge!),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          ...items.map((item) => InfoRowWidget(label: item['label']!, value: item['value']!)),
          ...listValueItems.map((item) => InfoRowListWidget(label: item.label, values: item.values)),
        ],
      ),
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const InfoRowWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
              style: titilliumRegular.copyWith(color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color),
            ),
          ),

          Text(' :   ', style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(value,
                    textAlign: TextAlign.end,
                    style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRowListWidget extends StatelessWidget {
  final String label;
  final List<String> values;

  const InfoRowListWidget({super.key, required this.label, required this.values});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
              style: titilliumRegular.copyWith(color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color),
            ),
          ),

          Text(' :   ', style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: values.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                child: Text(v,
                  style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = status == 'paid'
        ? Theme.of(context).colorScheme.onTertiaryContainer
        : status == 'unpaid' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(getTranslated(status, context) ?? status,
        style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }
}