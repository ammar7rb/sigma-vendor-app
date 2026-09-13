import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTimelineEntry {
  final String label;
  final String dateTime;

  const AuctionTimelineEntry({
    required this.label,
    required this.dateTime,
  });
}

class AuctionTimelineWidget extends StatelessWidget {
  final List<AuctionTimelineEntry> entries;

  const AuctionTimelineWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('auction_timeline', context) ?? "",
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          ...entries.asMap().entries.map((map) {
            final index = map.key;
            final entry = map.value;
            return Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSize),
                Text(getTranslated(entry.label, context) ?? ""  ,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color)
                ),
                const SizedBox(height: Dimensions.paddingSizeOrder),

                Text(entry.dateTime,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSize),

                if (index < entries.length - 1)
                Divider(color: Theme.of(context).cardColor, thickness: 1, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
