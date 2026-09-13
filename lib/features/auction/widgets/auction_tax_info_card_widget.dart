import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_vat_report_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTaxInfoCard extends StatelessWidget {
  final AuctionTypeWiseTaxes taxGroup;

  const AuctionTaxInfoCard({super.key, required this.taxGroup});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(taxGroup.name ?? '', style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
          SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 35,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: taxGroup.data?.length ?? 0,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (_, __) => SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, i) {
                final item = taxGroup.data![i];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingEye,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: Row(children: [
                    Text('${item.name} (${item.taxRate}%)', style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                    )),
                    SizedBox(width: Dimensions.paddingSizeButton),
                    Text(PriceConverter.convertPrice(context, item.totalAmount), style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
