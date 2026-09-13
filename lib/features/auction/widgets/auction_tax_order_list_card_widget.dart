import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_vat_report_model.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tax_detail_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTaxOrderListCardWidget extends StatelessWidget {
  final AuctionOrderTransaction? orderModel;
  const AuctionTaxOrderListCardWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {
    final status = orderModel?.auctionProduct?.deliveryStatus ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [

        Padding(
          padding: const EdgeInsets.all(Dimensions.fontSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: '${getTranslated('auction_id', context)} # ', style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                )),
                TextSpan(text: orderModel?.orderId.toString(), style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                )),
              ])),
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(PriceConverter.convertPrice(context, orderModel?.orderAmount), style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
            ]),

            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _StatusBadge(status: status),
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                DateConverter.formatDate(DateTime.tryParse(orderModel?.createdAt ?? '') ?? DateTime.now()),
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
            ]),
          ]),
        ),

        Container(
          padding: EdgeInsets.all(Dimensions.fontSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Dimensions.paddingSizeSmall),
              bottomRight: Radius.circular(Dimensions.paddingSizeSmall),
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Text(
                '${getTranslated('vat_all_capital', context)} : ${PriceConverter.convertPrice(context, orderModel?.tax)}',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(width: Dimensions.paddingSizeSmall),

            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).cardColor,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (_) => AuctionTaxDetailBottomSheetWidget(orderModel: orderModel),
                );
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.paddingEye),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),
              ),
            ),
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
