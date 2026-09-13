import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/refund/controllers/refund_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/refund/widgets/refund_details_widget.dart';

class RefundPricingWidget extends StatelessWidget {
  final RefundModel? refundModel;
  const RefundPricingWidget({super.key, this.refundModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 7,
        )]
      ),
      child: Consumer<RefundController>(
        builder: (context, refund,_) {
            return Padding(padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault),
              child: refund.refundDetailsModel != null ?
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAssetImageWidget(Images.billingSummeryIcon, height: 20, width: 20),
                      SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(getTranslated('billing_summery', context)!,
                        style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                      ),
                    ]
                  )
                ),

                SizedBox(height: 1, child:  Divider(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.10), height: 1, thickness: 1)),
                const SizedBox(height: Dimensions.paddingSizeSmall,),

                ProductCalculationItem(title: 'product_price', qty: refund.refundDetailsModel?.quntity,
                  price: (refund.refundDetailsModel!.productPrice! * (refund.refundDetailsModel?.quntity??1)), isQ: true, isPositive: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),

                ProductCalculationItem(title: 'product_discount',price: refund.refundDetailsModel!.productTotalDiscount, isNegative: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'coupon_discount',price: refund.refundDetailsModel!.couponDiscount, isNegative: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'product_tax',price: refund.refundDetailsModel!.productTotalTax, isPositive: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'subtotal',price: refund.refundDetailsModel!.subtotal),

                if(refund.refundDetailsModel?.referralDiscount != null && refund.refundDetailsModel!.referralDiscount! > 0) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  ProductCalculationItem(title: 'referral_discount',price: refund.refundDetailsModel?.referralDiscount, isNegative: true),
                ],
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Divider(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.10), height: 1, thickness: 1),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Text('${getTranslated('total_refund_amount', context)}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const Spacer(),

                  Text(PriceConverter.convertPrice(context, refund.refundDetailsModel!.refundAmount),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700),
                  ),
                ]),
              ]) : const SizedBox(),
            );
          }
      ),
    );
  }
}



class RefundDataWidget extends StatelessWidget {
  final RefundModel? refundModel;
  const RefundDataWidget({super.key, this.refundModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),

      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 7,
          )]
      ),
      child: Consumer<RefundController>(
          builder: (context, refund,_) {
            return Padding(padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault),
              child: refund.refundDetailsModel != null ?
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        getTranslated('order_date_details', context) ?? '',
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                    ),

                    Text(
                        DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(refund.refundDetailsModel!.refundRequest!.first.createdAt!)),
                        style: robotoMedium.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Container(
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          getTranslated('refund_id', context) ?? '',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                      ),

                      Text(
                          '#${refundModel!.id}',
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Container(
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          getTranslated('order_id_small', context) ?? '',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                      ),

                      Text(
                          '#${refundModel!.orderId}' ,
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        getTranslated('order_type', context) ?? '',
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Text(
                          refundModel?.order?.orderType == 'POS' ?
                          getTranslated('pos_order_small', context) ?? '' :
                          getTranslated('regular', context) ?? ' ',
                          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                if(refundModel?.order?.paymentStatus != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          getTranslated('payment_status_title', context) ?? '',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                      ),

                      Text((refundModel?.order?.paymentStatus != null && refundModel!.order!.paymentStatus!.isNotEmpty) ?
                      getTranslated(refundModel?.order?.paymentStatus, context) ?? refundModel!.order!.paymentStatus!
                          : 'Digital Payment',
                          style: titilliumSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: refundModel?.order?.paymentStatus == 'paid' ?
                              Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error
                          )
                      )
                    ],
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                if(refundModel?.order?.paymentMethod != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          getTranslated('payment_method', context) ?? '',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)
                      ),

                      Text(refundModel!.order!.paymentMethod!.replaceAll('_', ' ').capitalize(),
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
                      )
                    ],
                  ),

              ]) : const SizedBox(),
            );
          }),
    );
  }
}