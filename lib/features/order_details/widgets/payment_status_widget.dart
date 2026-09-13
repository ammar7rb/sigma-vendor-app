import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_screen.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class PaymentStatusWidget extends StatefulWidget {
  final Order? orderModel;
  final OrderController? order;
  final OrderDetailsModel? orderDetailsModel;
  const PaymentStatusWidget(
      {super.key, this.orderModel, this.order, this.orderDetailsModel});

  @override
  State<PaymentStatusWidget> createState() => _PaymentStatusWidgetState();
}

class _PaymentStatusWidgetState extends State<PaymentStatusWidget> {
  bool showWholeInfo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              spreadRadius: 1.5,
              blurRadius: 3)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimensions.paddingSizeSmall),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimensions.paddingSizeDefault),
            child: Text(getTranslated('payment', context)!,
                style: robotoMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeLarge)),
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Divider(
              thickness: 0.2,
              height: 1,
              color: Theme.of(context).hintColor.withValues(alpha: .65)),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${getTranslated('payment_method', context)} : ',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color)),
                      Text(
                          getTranslated(
                              widget.orderModel!.paymentMethod, context)!,
                          style: robotoMedium.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${getTranslated('order_amount', context)} : ',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              PriceConverter.convertPrice(
                                  context, widget.orderModel!.initOrderAmount!),
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color)),
                          SizedBox(width: Dimensions.paddingSizeSmall),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                color:
                                    widget.orderModel!.paymentStatus == 'paid'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.1)),
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: Text(
                                getTranslated(
                                    widget.orderModel!.paymentStatus, context)!,
                                style: robotoBold.copyWith(
                                    color: widget.orderModel!.paymentStatus ==
                                            'paid'
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error)),
                          ),
                        ],
                      ),
                    ]),
                SizedBox(height: Dimensions.paddingSizeSmall),
                if (widget.orderModel?.offlinePayments != null) ...[
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${getTranslated('customer_payment_info', context)}',
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color)),
                            ],
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget
                                .orderModel?.offlinePayments?.infoKey?.length,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              String key = widget
                                  .orderModel?.offlinePayments?.infoKey?[index];
                              String fittedKey = key.replaceAll('_', ' ');
                              return fittedKey != 'method id'
                                  ? PaymentItemCard(
                                      leftValue: fittedKey.capitalize(),
                                      rightValue:
                                          '${widget.orderModel?.offlinePayments?.infoValue?[index]}')
                                  : SizedBox();
                            }),
                      ],
                    ),
                  ),
                  if (widget.orderModel!.paymentStatus != 'paid' &&
                      widget.orderModel!.paymentMethod ==
                          'offline_payment') ...[
                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault)),
                      child: Row(
                        children: [
                          CustomAssetImageWidget(Images.infoIcon,
                              height: 15, width: 15),
                          SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Text(
                                getTranslated(
                                    'this_payment_has_not_been_verified_yet',
                                    context)!,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color)),
                          )
                        ],
                      ),
                    )
                  ]
                ],
                if (widget.orderDetailsModel?.editOrderPaymentHistory != null &&
                    widget.orderDetailsModel!.editOrderPaymentHistory!
                        .isNotEmpty) ...[
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text('${getTranslated('another_payment_info', context)} : ',
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeLarge)),
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget
                          .orderDetailsModel?.editOrderPaymentHistory?.length,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final paymentHistory = widget
                            .orderDetailsModel!.editOrderPaymentHistory![index];
                        return Padding(
                            padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeSmall),
                            child: Column(
                              children: [
                                if (paymentHistory.orderDueAmount != null &&
                                    paymentHistory.orderDueAmount! > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          paymentHistory
                                                      .orderDuePaymentStatus ==
                                                  'unpaid'
                                              ? '${getTranslated('due', context)} '
                                              : '${getTranslated('pay_by', context)} ',
                                          style: robotoRegular.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color)),
                                      if (paymentHistory
                                              .orderDuePaymentMethod !=
                                          null)
                                        Text(
                                            '(${getTranslated(paymentHistory.orderDuePaymentMethod!, context)!}) : ',
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color)),
                                      Text(
                                          PriceConverter.convertPrice(context,
                                              paymentHistory.orderDueAmount!),
                                          style: robotoMedium.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color)),
                                      SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            color: paymentHistory
                                                        .orderDuePaymentStatus ==
                                                    'paid'
                                                ? Colors.green
                                                    .withValues(alpha: 0.1)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error
                                                    .withValues(alpha: 0.1)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Text(
                                            getTranslated(
                                                paymentHistory
                                                    .orderDuePaymentStatus,
                                                context)!,
                                            style: robotoBold.copyWith(
                                                color: paymentHistory
                                                            .orderDuePaymentStatus ==
                                                        'paid'
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .error)),
                                      ),
                                    ],
                                  ),
                                if (paymentHistory.orderDuePaymentInfo !=
                                    null) ...[
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  Container(
                                    padding: EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  Dimensions.paddingSizeSmall),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${getTranslated('receiving_account_details', context)}',
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color)),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: paymentHistory
                                                .orderDuePaymentInfo
                                                ?.infoKey
                                                ?.length,
                                            padding: EdgeInsets.zero,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              String key = paymentHistory
                                                  .orderDuePaymentInfo
                                                  ?.infoKey?[index];
                                              String fittedKey =
                                                  key.replaceAll('_', ' ');
                                              return fittedKey != 'method id'
                                                  ? PaymentItemCard(
                                                      leftValue: fittedKey
                                                          .capitalize(),
                                                      rightValue:
                                                          '${paymentHistory.orderDuePaymentInfo?.infoValue?[index]}')
                                                  : SizedBox();
                                            }),
                                      ],
                                    ),
                                  ),
                                  if (paymentHistory.orderDuePaymentMethod ==
                                          'offline_payment' &&
                                      paymentHistory.orderDuePaymentStatus !=
                                          'paid') ...[
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Container(
                                      padding: EdgeInsets.all(
                                          Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault)),
                                      child: Row(
                                        children: [
                                          CustomAssetImageWidget(
                                              Images.infoIcon,
                                              height: 15,
                                              width: 15),
                                          SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Expanded(
                                            child: Text(
                                                getTranslated(
                                                    'this_payment_has_not_been_verified_yet',
                                                    context)!,
                                                style: robotoRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color)),
                                          )
                                        ],
                                      ),
                                    )
                                  ]
                                ],
                                if (paymentHistory.orderReturnAmount != null &&
                                    paymentHistory.orderReturnAmount! > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          paymentHistory
                                                      .orderReturnPaymentStatus ==
                                                  'paid'
                                              ? '${getTranslated('paid_by', context)} '
                                              : '${getTranslated('pay_by', context)} ',
                                          style: robotoRegular.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color)),
                                      if (paymentHistory
                                              .orderReturnPaymentMethod !=
                                          null)
                                        Text(
                                            '(${getTranslated(paymentHistory.orderReturnPaymentMethod!, context)!}) : ',
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color)),
                                      Text(
                                          PriceConverter.convertPrice(
                                              context,
                                              paymentHistory
                                                  .orderReturnAmount!),
                                          style: robotoMedium.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color)),
                                      SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            color: paymentHistory
                                                        .orderReturnPaymentStatus ==
                                                    'returned'
                                                ? Colors.green
                                                    .withValues(alpha: 0.1)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error
                                                    .withValues(alpha: 0.1)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Text(
                                            getTranslated(
                                                paymentHistory
                                                    .orderReturnPaymentStatus,
                                                context)!,
                                            style: robotoBold.copyWith(
                                                color: paymentHistory
                                                            .orderReturnPaymentStatus ==
                                                        'returned'
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .error)),
                                      ),
                                    ],
                                  ),
                                if (paymentHistory.orderReturnPaymentInfo !=
                                    null) ...[
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  Container(
                                    padding: EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  Dimensions.paddingSizeSmall),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${getTranslated('sending_account_details', context)}',
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color)),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: paymentHistory
                                                .orderReturnPaymentInfo
                                                ?.infoKey
                                                ?.length,
                                            padding: EdgeInsets.zero,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              String key = paymentHistory
                                                  .orderReturnPaymentInfo
                                                  ?.infoKey?[index];
                                              String fittedKey =
                                                  key.replaceAll('_', ' ');
                                              return fittedKey != 'method id'
                                                  ? PaymentItemCard(
                                                      leftValue: fittedKey
                                                          .capitalize(),
                                                      rightValue:
                                                          '${paymentHistory.orderReturnPaymentInfo?.infoValue?[index]}')
                                                  : SizedBox();
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ));
                      }),
                ],
              ],
            ),
          )

          // ToDo: Offline payment info display logic is currently disabled. Enable it
          //   Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          //
          //
          //     InkWell(onTap: (){
          //       setState(() {
          //         showWholeInfo = !showWholeInfo;
          //       });
          //     },
          //       child: Row(children: [
          //           Text('${getTranslated('payment_method', context)}'),
          //           if(widget.orderModel?.offlinePayments != null)
          //              Icon(showWholeInfo?  Icons.keyboard_arrow_up: Icons.keyboard_arrow_down),
          //         ],
          //       ),
          //     ),
          //     if(widget.orderModel!.paymentMethod != null)
          //     Text(widget.orderModel!.paymentMethod!.replaceAll('_', ' ').capitalize(),
          //       style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
          //   ],
          //   ),
          // ),
          //
          //   if(widget.orderModel?.offlinePayments != null && showWholeInfo)
          //     Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          //       Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //         child: Divider(color: Theme.of(context).primaryColor.withValues(alpha:.5),),
          //       ),
          //       Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          //         child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          //           Text('${getTranslated('my_payment_info', context)}',style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),),
          //           Text('${getTranslated('bank_info', context)}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor),),
          //         ],),
          //       ),
          //       ListView.builder(
          //           shrinkWrap: true,
          //           itemCount: widget.orderModel?.offlinePayments?.infoKey?.length,
          //           padding: EdgeInsets.zero,
          //           physics: const NeverScrollableScrollPhysics(),
          //           itemBuilder: (context, index){
          //             String key = widget.orderModel?.offlinePayments?.infoKey?[index];
          //             String fittedKey = key.replaceAll('_', ' ');
          //             return PaymentItemCard(leftValue: fittedKey.capitalize(),rightValue: '${widget.orderModel?.offlinePayments?.infoValue?[index]}');
          //           }),
          //
          //
          //       PaymentItemCard(leftValue: '${getTranslated('note', context)}',rightValue: ''),
          //
          //       Text(widget.orderModel?.paymentNote ??'', style: robotoRegular.copyWith(color: Theme.of(context).hintColor),)
          //
          //
          //     ]),
        ],
      ),
    );
  }
}

class PaymentItemCard extends StatelessWidget {
  final String leftValue;
  final String rightValue;
  const PaymentItemCard(
      {super.key, required this.leftValue, required this.rightValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$leftValue  : ',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color)),
          Expanded(
              child: Text(
            rightValue,
            style: robotoMedium.copyWith(
                color: ColorHelper.blendColors(Colors.white,
                    Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                fontSize: Dimensions.fontSizeDefault),
          )),
        ],
      ),
    );
  }
}
