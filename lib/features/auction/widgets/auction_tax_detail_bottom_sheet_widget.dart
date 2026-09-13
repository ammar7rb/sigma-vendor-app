import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_vat_report_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTaxDetailBottomSheetWidget extends StatelessWidget {
  final AuctionOrderTransaction? orderModel;
  const AuctionTaxDetailBottomSheetWidget({super.key, required this.orderModel});

  @override
  Widget build(BuildContext context) {
    final status = orderModel?.auctionProduct?.deliveryStatus ?? '';
    final paymentStatus = orderModel?.paymentStatus ?? '';

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // drag handle
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -7),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.cancel_outlined, size: Dimensions.iconSizeMedium, color: Theme.of(context).hintColor),
            ),
          ),
        ),
        SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // Auction ID + status badge
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${getTranslated('auction_id', context)} #${orderModel?.orderId}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
              SizedBox(width: Dimensions.paddingSizeSmall),
              _StatusBadge(status: status),
            ]),
            SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Date
            Center(
              child: Text(
                DateConverter.formatDate(DateTime.tryParse(orderModel?.createdAt ?? '') ?? DateTime.now()),
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeLarge),

            // Payment status row
            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('payment_status', context) ?? 'Payment Status',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                  )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: Text(getTranslated(paymentStatus, context) ?? paymentStatus,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    )),
                ),
              ]),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            // Auction amount + VAT breakdown
            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Auction Amount
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(getTranslated('auction_amount', context) ?? 'Auction Amount',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
                    )),
                  Text(PriceConverter.convertPrice(context, orderModel?.orderAmount),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                ]),
                SizedBox(height: Dimensions.paddingSizeSmall),

                // Auction Basic header
                // Text(getTranslated('auction_basic', context) ?? 'Auction Basic',
                //   style: robotoBold.copyWith(
                //     fontSize: Dimensions.fontSizeSmall,
                //     color: Theme.of(context).textTheme.bodyLarge?.color,
                //   )),
                // SizedBox(height: Dimensions.paddingSizeExtraSmall),

                // VAT groups
                ListView.separated(
                  itemCount: orderModel?.vatAmountFormats?.allVatGroups?.length ?? 0,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    final group = orderModel?.vatAmountFormats?.allVatGroups?[index];
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(group?.groupName ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),
                      ...List.generate(group?.data?.length ?? 0, (i) {
                        final item = group!.data![i];
                        return Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(item.name ?? '',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
                              )),
                            Text(PriceConverter.convertPrice(context, item.taxAmount),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              )),
                          ]),
                        );
                      }),
                    ]);
                  },
                ),

                Divider(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                  thickness: 1,
                  height: Dimensions.paddingSizeLarge,
                ),

                // Total VAT
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(getTranslated('total_vat_amount', context) ?? 'Total VAT Amount',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                  Text(PriceConverter.convertPrice(context, orderModel?.tax),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                ]),
              ]),
            ),
            SizedBox(height: Dimensions.paddingSizeDefault),
          ]),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'delivered':
        bg = cs.onTertiaryContainer.withValues(alpha: 0.15);
        text = cs.onTertiaryContainer;
        break;
      case 'pending':
        bg = cs.tertiary.withValues(alpha: 0.15);
        text = cs.tertiary;
        break;
      case 'cancelled':
      case 'failed':
        bg = cs.error.withValues(alpha: 0.15);
        text = cs.error;
        break;
      default:
        bg = cs.primary.withValues(alpha: 0.15);
        text = cs.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      child: Text(
        getTranslated(status, context) ?? status,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: text),
      ),
    );
  }
}
