import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class BillingInfoWidget extends StatelessWidget {
  final AuctionDetailsProduct product;
  const BillingInfoWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productPrice = product.highestBidAmount ?? 0.0;
    final shippingFee = product.shippingFee ?? 0.0;
    /// ToDo: Remove hardcoded tax and use _calculateTax() instead when API provides tax details
    final tax = 10.0;
    final total = productPrice + shippingFee + tax;

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated('billing_info', context) ?? 'Billing Info',
            style: titilliumBold.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),
          Divider(height: 1, color: theme.hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _BillingRow(
            label: getTranslated('product_price', context) ?? 'Product Price',
            value: PriceConverter.convertPrice(context, productPrice),
          ),
          _BillingRow(
            label: getTranslated('shipping_fee', context) ?? 'Shipping Fee',
            value: PriceConverter.convertPrice(context, shippingFee),
          ),
          _BillingRow(
            label: getTranslated('tax', context) ?? 'Tax',
            value: PriceConverter.convertPrice(context, tax),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Divider(height: 1, color: theme.hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          _BillingRow(
            label: getTranslated('total', context) ?? 'Total',
            value: PriceConverter.convertPrice(context, total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _BillingRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isBold
        ? titilliumBold.copyWith(color: theme.textTheme.bodyLarge?.color)
        : titilliumRegular.copyWith(color: theme.textTheme.bodyLarge?.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: style),
          ),
          Text(' :   ', style: titilliumRegular.copyWith(color: theme.textTheme.bodyLarge?.color)),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: style.copyWith(overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
