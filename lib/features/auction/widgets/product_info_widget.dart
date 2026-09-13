import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ProductInfoEntry {
  final String label;
  final String value;

  const ProductInfoEntry({required this.label, required this.value});
}

class ProductInfoWidget extends StatelessWidget {
  final List<ProductInfoEntry> entries;

  const ProductInfoWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeMedium, Dimensions.paddingSizeMedium, Dimensions.paddingSizeMedium, Dimensions.paddingSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('product_info', context) ?? "",
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(height: Dimensions.paddingSize),

          ...entries.map((entry) => ProductInfoRow(label: entry.label, value: entry.value),
          ),
        ],
      ),
    );
  }
}

class ProductInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProductInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSize),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w400, color: Theme.of(context).textTheme.bodyLarge?.color)
            ),
          ),

          Text(':',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w400, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Text(
              value,
               style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)
            ),
          ),
        ],
      ),
    );
  }
}
