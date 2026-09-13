import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';

class OrderWidget extends StatefulWidget {
  final Order orderModel;
  final int? index;
  const OrderWidget({super.key, required this.orderModel, this.index});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    double orderAmount = 0;

    if (widget.orderModel.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;
      double tax = 0;
      double coupon = 0;
      double shipping = 0;
      if (widget.orderModel.orderDetails != null &&
          widget.orderModel.orderDetails!.isNotEmpty) {
        coupon = widget.orderModel.discountAmount!;
        shipping = widget.orderModel.shippingCost!;
        for (var orderDetails in widget.orderModel.orderDetails!) {
          if (orderDetails.productDetails?.productType == "physical") {}
          itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.qty!);
          discount = discount + orderDetails.discount!;
          tax = tax + orderDetails.tax!;
        }
        if (widget.orderModel.orderType == 'POS') {
          if (widget.orderModel.extraDiscountType == 'percent') {
            eeDiscount = itemsPrice * (widget.orderModel.extraDiscount! / 100);
          } else {
            eeDiscount = widget.orderModel.extraDiscount;
          }
        }
      }
      double subTotal = itemsPrice + tax - discount;

      orderAmount = subTotal + shipping - coupon - eeDiscount!;

      // double ? _extraDiscountAnount = 0;
      // if(orderModel.extraDiscount != null){
      //   _extraDiscountAnount = PriceConverter.convertWithDiscount(context, orderModel.totalProductPrice, orderModel.extraDiscount, orderModel.extraDiscountType == 'percent' ? 'percent' : 'amount' );
      //   if(_extraDiscountAnount != null) {
      //     double percentAmount = _extraDiscountAnount!;
      //     _extraDiscountAnount = orderModel.totalProductPrice! - percentAmount;
      //   }
      // }
      //
      // double totalDiscount = (_extraDiscountAnount! + orderModel.totalProductDiscount!);
      // double totalOrderAmount = (orderModel.totalProductPrice! + orderModel.totalTaxAmount!);
      //
      // orderAmount = totalOrderAmount - totalDiscount;
      //
      // orderAmount = orderModel.orderAmount! - orderModel.totalTaxAmount!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(
                          orderId: widget.orderModel.id,
                          accessToken:
                              widget.orderModel.restrictedAccessToken)));
              if (!context.mounted) return;
              final orders = context.read<OrderController>();
              await orders.getOrderList(
                  context, 1, orders.orderType, orders.filterModel);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow:
                      AppDesign.softShadow(Theme.of(context).brightness)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(Dimensions.paddingSizeSmall),
                            topRight:
                                Radius.circular(Dimensions.paddingSizeSmall))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeSmall,
                          left: Dimensions.paddingSizeSmall,
                          right: Dimensions.paddingSizeSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(
                              '${getTranslated('order_no', context)} ',
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                            Text(
                              '${widget.orderModel.maskedOrderReference ?? '#${widget.orderModel.id}'} ${widget.orderModel.orderType == 'POS' ? '(POS)' : ''}',
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                            if (widget.orderModel.editedStatus == 1)
                              Text(
                                '(${getTranslated('edited', context)})',
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.color,
                                    fontSize: Dimensions.fontSizeSmall),
                              ),
                            if (widget.orderModel.queuePosition != null)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  "${getTranslated('seller_queue', context) ?? 'Queue'} #${widget.orderModel.queuePosition}${widget.orderModel.isCurrentQueueOrder == true ? ' - ${getTranslated('current_order', context) ?? 'Current'}' : ''}",
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                              ),
                            SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            if (widget.orderModel.editedStatus == 1 &&
                                ((widget.orderModel.editDueAmount ?? 0) > 0 ||
                                    (widget.orderModel.editReturnAmount ?? 0) >
                                        0))
                              JustTheTooltip(
                                backgroundColor: Colors.black87,
                                controller: tooltipController,
                                preferredDirection: AxisDirection.up,
                                tailLength: 10,
                                tailBaseWidth: 20,
                                content: Container(
                                    width: 250,
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    child: Text(
                                        (widget.orderModel.editDueAmount ?? 0) >
                                                0
                                            ? getTranslated(
                                                'customer_will_pay_due',
                                                context)!
                                            : (widget.orderModel
                                                            .editReturnAmount ??
                                                        0) >
                                                    0
                                                ? getTranslated(
                                                    'contact_the_admin_to_return',
                                                    context)!
                                                : '',
                                        style: robotoRegular.copyWith(
                                            color: Colors.white,
                                            fontSize:
                                                Dimensions.fontSizeDefault))),
                                child: InkWell(
                                  onTap: () => tooltipController.showTooltip(),
                                  child: CustomAssetImageWidget(
                                      (widget.orderModel.editDueAmount ?? 0) > 0
                                          ? Images.orderDueAmountIcon
                                          : (widget.orderModel
                                                          .editReturnAmount ??
                                                      0) >
                                                  0
                                              ? Images.orderReturnAmountIcon
                                              : Images.pendingOrderCardIcon,
                                      height: 16,
                                      width: 16),
                                ),
                              ),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: _getStatusBgColor(
                                  context,
                                  widget.orderModel.detailsLocked
                                      ? widget.orderModel.sellerInsuranceStatus
                                      : widget.orderModel.orderStatus),
                            ),
                            child: Text(
                              getTranslated(
                                      widget.orderModel.detailsLocked
                                          ? widget
                                              .orderModel.sellerInsuranceStatus
                                          : widget.orderModel.orderStatus,
                                      context) ??
                                  (widget.orderModel.sellerInsuranceStatus ??
                                      ''),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: _getStatusTextColor(
                                    context,
                                    widget.orderModel.detailsLocked
                                        ? widget
                                            .orderModel.sellerInsuranceStatus
                                        : widget.orderModel.orderStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft:
                                Radius.circular(Dimensions.paddingSizeSmall),
                            bottomRight:
                                Radius.circular(Dimensions.paddingSizeSmall))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeSmall,
                          0,
                          Dimensions.paddingSizeSmall,
                          Dimensions.paddingSizeSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.orderModel.createdAt != null
                              ? Text(
                                  DateConverter.localDateToIsoStringAMPM(
                                      DateTime.parse(
                                          widget.orderModel.createdAt!)),
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor))
                              : const SizedBox(),
                          if (widget.orderModel.shipmentReference != null)
                            Text(
                                '${getTranslated('shipment_reference', context) ?? 'Shipment'}: ${widget.orderModel.shipmentReference}',
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall)),
                          if (widget.orderModel.detailsLocked)
                            Text(
                                '${getTranslated('insurance_amount', context) ?? 'Insurance'}: ${PriceConverter.convertPrice(context, widget.orderModel.sellerInsuranceAmount ?? 0)}\n${getTranslated('payment_deadline', context) ?? 'Deadline'}: ${widget.orderModel.sellerInsuranceExpiresAt ?? '-'}',
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: Dimensions.iconSizeDefault,
                                    width: Dimensions.iconSizeDefault,
                                    child: CustomAssetImageWidget(
                                        widget.orderModel.paymentMethod ==
                                                'cash_on_delivery'
                                            ? Images.paymentIcon
                                            : widget.orderModel.paymentMethod ==
                                                    'pay_by_wallet'
                                                ? Images.payByWalletIcon
                                                : Images.digitalPaymentIcon),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  if (widget.orderModel.paymentMethod != null &&
                                      widget
                                          .orderModel.paymentMethod!.isNotEmpty)
                                    Text(
                                        widget.orderModel.paymentMethod != null
                                            ? getTranslated(
                                                    widget.orderModel
                                                            .paymentMethod ??
                                                        '',
                                                    context) ??
                                                ''
                                            : '',
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).hintColor)),
                                ],
                              ),
                              Text(
                                  PriceConverter.convertPrice(
                                      context,
                                      widget.orderModel.orderType == 'POS'
                                          ? widget.orderModel.orderAmount
                                          : widget.orderModel.orderAmount ?? 0),
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }

  Color _getStatusBgColor(BuildContext context, String? status) {
    switch (status) {
      case 'delivered':
      case 'confirmed':
        return Theme.of(context)
            .colorScheme
            .onTertiaryContainer
            .withValues(alpha: .1);
      case 'pending':
        return Theme.of(context).primaryColor.withValues(alpha: .1);
      case 'processing':
        return Theme.of(context).colorScheme.outline.withValues(alpha: .1);
      case 'canceled':
      case 'failed':
        return Theme.of(context).colorScheme.error.withValues(alpha: .1);
      default:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: .1);
    }
  }

  Color _getStatusTextColor(BuildContext context, String? status) {
    switch (status) {
      case 'delivered':
      case 'confirmed':
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'pending':
        return Theme.of(context).primaryColor;
      case 'processing':
        return Theme.of(context).colorScheme.outline;
      case 'canceled':
      case 'failed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
