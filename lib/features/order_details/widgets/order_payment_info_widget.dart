import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class OrderPaymentInfoWidget extends StatelessWidget {
  const OrderPaymentInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsController>(
        builder: (context, orderProvider, child) {
      ConfigModel? configModel =
          Provider.of<SplashController>(context, listen: false).configModel;

      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                spreadRadius: 1.5,
                blurRadius: 3)
          ],
          color: Theme.of(context).cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (configModel?.orderVerification == 1 &&
                  orderProvider.orderDetails?.first.order?.orderType !=
                      'POS') ...[
                Container(
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          getTranslated('order_verification_code', context) ??
                              '',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color)),
                      Text(
                          orderProvider.orderDetails?.first.order
                                  ?.verificationCode ??
                              '',
                          style: robotoBold.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ],
                  ),
                ),
                if (configModel?.orderVerification == 1 &&
                    orderProvider.orderDetails?.first.order?.orderType != 'POS')
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                    height: 1,
                    child: Divider(
                        thickness: .200,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.45))),
              ],

              if (configModel?.orderVerification == 1 &&
                  orderProvider.orderDetails?.first.order?.orderType != 'POS')
                const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getTranslated('order_date_details', context) ?? '',
                      style: robotoRegular.copyWith(
                          color:
                              Theme.of(context).textTheme.titleMedium?.color)),
                  Text(
                      DateConverter.localDateToIsoStringAMPMOrder(
                          DateTime.parse(orderProvider
                              .orderDetails!.first.order!.createdAt!)),
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeDefault)),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                  height: 1,
                  child: Divider(
                      thickness: .200,
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.45))),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getTranslated('order_type', context) ?? '',
                      style: robotoRegular.copyWith(
                          color:
                              Theme.of(context).textTheme.titleMedium?.color)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.paddingSizeSmall),
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.10),
                    ),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Text(
                        orderProvider.orderDetails?.first.order?.orderType ==
                                'POS'
                            ? getTranslated('pos_order_small', context) ?? ''
                            : getTranslated('regular', context) ?? ' ',
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeSmall)),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              /// Todo: payment method remove
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       getTranslated('payment_method', context) ?? '',
              //       style: robotoRegular.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)
              //     ),
              //
              //     Text((orderProvider.orderDetails?.first.order?.paymentStatus != null && orderProvider.orderDetails!.first.order!.paymentStatus!.isNotEmpty) ?
              //     getTranslated(orderProvider.orderDetails?.first.order?.paymentStatus, context) ?? orderProvider.orderDetails!.first.order!.paymentStatus!
              //       : 'Digital Payment',
              //       style: titilliumSemiBold.copyWith(
              //         fontSize: Dimensions.fontSizeDefault,
              //         color: orderProvider.orderDetails?.first.order?.paymentStatus == 'paid' ?
              //         Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error
              //       )
              //     )
              //   ],
              // ),

              // const SizedBox(height: Dimensions.paddingSizeSmall),
              // SizedBox(height: 1, child: Divider(thickness: .200, color: Theme.of(context).hintColor.withValues(alpha: 0.45))),
              // const SizedBox(height: Dimensions.paddingSizeSmall),
              //
              //
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       getTranslated('payment_method', context) ?? '',
              //       style: robotoRegular.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)
              //     ),
              //
              //     Text(orderProvider.orderDetails!.first.order!.paymentMethod!.replaceAll('_', ' ').capitalize(),
              //         style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
              //     )
              //   ],
              // ),
              // const SizedBox(height: Dimensions.paddingSizeSmall),
              // SizedBox(height: 1, child: Divider(thickness: .200, color: Theme.of(context).hintColor.withValues(alpha: 0.45))),

              if (orderProvider.orderDetails?.first.order
                          ?.bringChangeAmountCurrency !=
                      null &&
                  (double.tryParse(orderProvider.orderDetails!.first.order!
                              .bringChangeAmountCurrency
                              .toString()) ??
                          0) >
                      0) ...[
                SizedBox(
                    height: 1,
                    child: Divider(
                        thickness: .200,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.45))),
                Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.2),
                            spreadRadius: 3,
                            blurRadius: 3)
                      ],
                      color: Theme.of(context).cardColor,
                    ),
                    padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated('change_request', context) ?? '',
                            style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color)),
                        SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall)),
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text: getTranslated('please_bring', context),
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: PriceConverter.convertPrice(
                                  context,
                                  (double.tryParse(orderProvider
                                          .orderDetails!
                                          .first
                                          .order!
                                          .bringChangeAmountCurrency
                                          .toString()) ??
                                      0)),
                              style: titilliumBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: getTranslated(
                                  'in_change_when_making_the_delivery',
                                  context),
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ])),
                        )
                      ],
                    )),
                SizedBox(height: Dimensions.paddingSizeDefault),
              ]
            ],
          ),
        ),
      );
    });
  }
}
