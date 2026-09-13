import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/change_amount_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/due_ampunt_card.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_details_shimmer.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_payment_info_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_setup_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/product_list_widget.dart';
import 'package:sixvalley_vendor_app/features/order_edit/controllers/order_edit_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_divider_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/customer_contact_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/delivery_man_information_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_top_section_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/payment_status_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/shipping_and_biilling_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/third_party_delivery_info_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/seller_order_insurance_gate_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/seller_shipping_assignment_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import '../../../common/basewidgets/custom_confirmation_dialog_widget.dart'
    show CustomConfirmationDialogWidget;

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final String? accessToken;
  final bool fromNotification;
  const OrderDetailsScreen(
      {super.key,
      required this.orderId,
      this.accessToken,
      this.fromNotification = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _loadData(BuildContext context) async {
    if (widget.fromNotification &&
        Provider.of<SplashController>(Get.context!, listen: false)
                .configModel ==
            null) {
      await Provider.of<SplashController>(Get.context!, listen: false)
          .initConfig();
    }
    if (!mounted) return;
    await context
        .read<OrderDetailsController>()
        .getOrderDetails(widget.accessToken ?? widget.orderId.toString());
  }

  bool _onlyDigital = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      final controller = context.read<OrderDetailsController>();
      if (!controller.actionInProgress &&
          controller.sellerOrderInsurance?.insurance?.detailsHidden == true)
        _loadData(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true &&
        !context.read<OrderDetailsController>().actionInProgress)
      _loadData(context);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        Provider.of<OrderDetailsController>(context, listen: false)
            .emptyOrderDetails();
        if (widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const DashboardScreen()),
              (route) => false);
        } else {
          return;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).cardColor,
          toolbarHeight: 80,
          leadingWidth: 0,
          automaticallyImplyLeading: false,
          surfaceTintColor: Theme.of(context).highlightColor,
          title: Consumer<OrderDetailsController>(
              builder: (context, orderDetailsController, _) {
            if (orderDetailsController.orderDetails?.firstOrNull?.order ==
                null) {
              return Row(children: [
                BackButton(onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const DashboardScreen()));
                  }
                }),
                Expanded(child: Text(getTranslated('order', context) ?? '')),
              ]);
            }
            return OrderTopSectionWidget(
                orderModel:
                    orderDetailsController.orderDetails?.firstOrNull?.order,
                fromNotification: widget.fromNotification);
          }),
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadData(context),
          child: Consumer<OrderController>(
              builder: (context, orderController, child) {
            return Consumer<OrderDetailsController>(
                builder: (context, orderDetailsController, child) {
              if (orderDetailsController.loadError != null) {
                return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              getTranslated(orderDetailsController.loadError!,
                                      context) ??
                                  '',
                              textAlign: TextAlign.center)),
                      TextButton.icon(
                          onPressed: () => _loadData(context),
                          icon: const Icon(Icons.refresh),
                          label: Text(getTranslated('refresh', context) ?? '')),
                    ]);
              }
              if (orderDetailsController
                      .sellerOrderInsurance?.insurance?.detailsHidden ==
                  true) {
                return SellerOrderInsuranceGateWidget(
                    orderId: widget.accessToken ?? widget.orderId.toString());
              }
              double itemsPrice = 0;
              double discount = 0;
              double? eeDiscount = 0;
              double tax = 0;
              double coupon = 0;
              double shipping = 0;
              double referAndEarnDiscount = 0;
              bool isFreeShipping = false;

              if (orderDetailsController.orderDetails != null &&
                  orderDetailsController.orderDetails!.isNotEmpty) {
                coupon = orderDetailsController
                    .orderDetails![0].order!.discountAmount!;
                shipping = orderDetailsController
                    .orderDetails![0].order!.shippingCost!;
                isFreeShipping = orderDetailsController
                        .orderDetails?.firstOrNull?.order?.isShippingFree ??
                    false;
                for (var orderDetails in orderDetailsController.orderDetails!) {
                  if (orderDetails.productDetails?.productType == "physical") {
                    _onlyDigital = false;
                  }
                  itemsPrice =
                      itemsPrice + (orderDetails.price! * orderDetails.qty!);
                  discount = discount + orderDetails.discount!;
                }
                tax = orderDetailsController
                        .orderDetails![0].order?.totalTaxAmount ??
                    0;

                if (orderDetailsController.orderDetails![0].order!.orderType ==
                    'POS') {
                  if (orderDetailsController
                          .orderDetails![0].order!.extraDiscountType ==
                      'percent') {
                    eeDiscount = (itemsPrice - coupon - discount) *
                        (orderDetailsController
                                .orderDetails![0].order!.extraDiscount! /
                            100);
                  } else {
                    eeDiscount = orderDetailsController
                        .orderDetails![0].order!.extraDiscount;
                  }
                }

                if (orderDetailsController.orderDetails != null &&
                    orderDetailsController.orderDetails![0].order!.orderType !=
                        'POS') {
                  referAndEarnDiscount = orderDetailsController.orderDetails
                          ?.firstOrNull?.order?.referAndEarnDiscount ??
                      0;
                }
              }
              double subTotal = itemsPrice + tax - discount;

              double totalPrice = subTotal +
                  (isFreeShipping ? 0 : shipping) -
                  coupon -
                  eeDiscount! -
                  referAndEarnDiscount;

              return orderDetailsController.orderDetails != null
                  ? orderDetailsController.orderDetails!.isNotEmpty
                      ? CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                                child: Column(
                              children: [
                                Container(
                                    height: 10,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: .1)),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        boxShadow:
                                            ThemeShadow.getShadow(context)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (orderDetailsController
                                                  .sellerOrderInsurance
                                                  ?.enabled ==
                                              false)
                                            const _NoInsuranceRequiredCard(),
                                          OrderPaymentInfoWidget(),
                                          SellerShippingAssignmentWidget(
                                              order: orderDetailsController
                                                  .orderDetails![0].order!),
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                          if (orderDetailsController
                                                      .orderDetails![0]
                                                      .order
                                                      ?.editedStatus ==
                                                  1 &&
                                              (orderDetailsController
                                                          .orderDetails?[0]
                                                          .latestEditHistory
                                                          ?.orderDueAmount ??
                                                      0) >
                                                  0 &&
                                              orderDetailsController
                                                      .orderDetails![0]
                                                      .latestEditHistory!
                                                      .orderDuePaymentMethod !=
                                                  'cash_on_delivery')
                                            AmountDueCard(
                                              showButton: true,
                                              title: getTranslated(
                                                  'amount_due', context)!,
                                              price:
                                                  PriceConverter.convertPrice(
                                                      context,
                                                      orderDetailsController
                                                          .orderDetails![0]
                                                          .latestEditHistory!
                                                          .orderDueAmount!),
                                              description: getTranslated(
                                                  'after_editing_the_order_amount_has_increased',
                                                  context)!,
                                              buttonText: getTranslated(
                                                  'switch_to_cod', context)!,
                                              onTap: () {
                                                showAnimatedDialogWidget(
                                                    context, Consumer<
                                                            OrderEditController>(
                                                        builder: (context,
                                                            orderEditController,
                                                            child) {
                                                  return CustomConfirmationDialogWidget(
                                                    icon:
                                                        Images.switchToCodIcon,
                                                    title: getTranslated(
                                                            'switch_to_cash_on_delivery',
                                                            context) ??
                                                        '',
                                                    description: getTranslated(
                                                            'before_switching_this_order_to_cash_on_delivery',
                                                            context) ??
                                                        '',
                                                    highlightTexts: [
                                                      getTranslated(
                                                              'cash_on_delivery_cod',
                                                              context) ??
                                                          ''
                                                    ],
                                                    isLoading:
                                                        orderEditController
                                                            .isLoading,
                                                    onYesPressed: () {
                                                      orderEditController
                                                          .switchToCod(
                                                              orderDetailsController
                                                                  .orderDetails![
                                                                      0]
                                                                  .order!
                                                                  .id!)
                                                          .then((response) {
                                                        if (response.response
                                                                ?.statusCode ==
                                                            200) {
                                                          Navigator.of(
                                                                  Get.context!)
                                                              .pop();
                                                        }
                                                      });
                                                    },
                                                  );
                                                }));
                                              },
                                            ),
                                          if (orderDetailsController
                                                      .orderDetails![0]
                                                      .order
                                                      ?.editedStatus ==
                                                  1 &&
                                              (orderDetailsController
                                                          .orderDetails?[0]
                                                          .latestEditHistory
                                                          ?.orderReturnAmount ??
                                                      0) >
                                                  0 &&
                                              orderDetailsController
                                                      .orderDetails![0]
                                                      .latestEditHistory!
                                                      .orderReturnPaymentStatus !=
                                                  'returned')
                                            AmountDueCard(
                                              showButton: false,
                                              title: getTranslated(
                                                  'need_to_return', context)!,
                                              price:
                                                  PriceConverter.convertPrice(
                                                      context,
                                                      orderDetailsController
                                                          .orderDetails![0]
                                                          .latestEditHistory!
                                                          .orderReturnAmount!),
                                              description: getTranslated(
                                                  'the_order_amount_was_reduced_after_editing',
                                                  context)!,
                                              buttonText: '',
                                              onTap: null,
                                            ),
                                          if (orderDetailsController
                                                      .orderDetails![0]
                                                      .order
                                                      ?.editedStatus ==
                                                  1 &&
                                              (orderDetailsController
                                                          .orderDetails?[0]
                                                          .latestEditHistory
                                                          ?.orderDueAmount ??
                                                      0) >
                                                  0 &&
                                              orderDetailsController
                                                      .orderDetails![0]
                                                      .latestEditHistory!
                                                      .orderDuePaymentMethod !=
                                                  'cash_on_delivery')
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                          orderDetailsController
                                                      .orderDetails![0]
                                                      .order!
                                                      .orderType ==
                                                  'POS'
                                              ? const SizedBox()
                                              : ShippingAndBillingWidget(
                                                  orderModel:
                                                      orderDetailsController
                                                          .orderDetails![0]
                                                          .order!,
                                                  onlyDigital: _onlyDigital,
                                                  orderType:
                                                      orderDetailsController
                                                          .orderDetails![0]
                                                          .order!
                                                          .orderType!),
                                          if (orderDetailsController
                                                  .orderDetails![0]
                                                  .order!
                                                  .orderType !=
                                              'POS')
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ProductListWidget(
                                                    orderId:
                                                        orderDetailsController
                                                                .orderDetails![
                                                                    0]
                                                                .order
                                                                ?.id ??
                                                            widget.orderId ??
                                                            0),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),

                                                CustomerContactWidget(
                                                    orderModel:
                                                        orderDetailsController
                                                            .orderDetails![0]
                                                            .order),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),

                                                orderDetailsController
                                                            .orderDetails![0]
                                                            .order!
                                                            .deliveryMan !=
                                                        null
                                                    ? Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            bottom: Dimensions
                                                                .paddingSizeSmall),
                                                        child: DeliveryManContactInformationWidget(
                                                            orderModel:
                                                                orderDetailsController
                                                                    .orderDetails![
                                                                        0]
                                                                    .order,
                                                            orderType:
                                                                orderDetailsController
                                                                    .orderDetails![
                                                                        0]
                                                                    .order!
                                                                    .orderType,
                                                            onlyDigital:
                                                                _onlyDigital),
                                                      )
                                                    : const SizedBox(),

                                                // Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,
                                                //     Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
                                                //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                //     Row(children: [
                                                //       SizedBox(width: 15, child: Image.asset(Images.orderSummery)),
                                                //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                //       Text(getTranslated('order_summery', context)!,
                                                //         style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                                //     ],
                                                //     ),
                                                //     const SizedBox(height: Dimensions.paddingSizeDefault,),
                                                //
                                                //     ListView.builder(
                                                //       padding: const EdgeInsets.all(0),
                                                //       shrinkWrap: true,
                                                //       physics: const NeverScrollableScrollPhysics(),
                                                //       itemCount: orderDetailsController.orderDetails!.length,
                                                //       itemBuilder: (context, index) {
                                                //         return OrderedProductListItemWidget(orderDetailsModel: orderDetailsController.orderDetails![index],
                                                //           paymentStatus: orderController.paymentStatus,orderId: widget.orderId,
                                                //           index: index, length: orderDetailsController.orderDetails!.length,
                                                //         );
                                                //       },
                                                //     ),
                                                //   ],
                                                //   ),
                                                // ),

                                                /// bolling cummery section
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeDefault),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                          spreadRadius: 1.5,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeDefault),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              getTranslated(
                                                                  'billing_summery',
                                                                  context)!,
                                                              style: robotoBold.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeSmall),
                                                      Divider(
                                                          thickness: 0.2,
                                                          height: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor
                                                                  .withValues(
                                                                      alpha:
                                                                          .65)),
                                                      SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeSmall),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeDefault),
                                                        child: Column(
                                                          children: [
                                                            orderDetailsController
                                                                        .orderDetails![
                                                                            0]
                                                                        .order!
                                                                        .editedStatus ==
                                                                    1
                                                                ? Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            Dimensions
                                                                                .paddingSizeSmall,
                                                                        vertical:
                                                                            Dimensions.paddingSizeExtraSmall),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .tertiary
                                                                          .withValues(
                                                                              alpha: 0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.radiusSmall),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .info,
                                                                            color:
                                                                                Theme.of(context).colorScheme.tertiary,
                                                                            size: Dimensions.iconSizeSmall),
                                                                        SizedBox(
                                                                            width:
                                                                                Dimensions.paddingSizeExtraSmall),
                                                                        Text(
                                                                            getTranslated('total_bill_has_been_updated_after', context) ??
                                                                                '',
                                                                            style:
                                                                                titilliumRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge!.color, fontSize: Dimensions.fontSizeSmall))
                                                                      ],
                                                                    ),
                                                                  )
                                                                : SizedBox(),

                                                            orderDetailsController
                                                                        .orderDetails![
                                                                            0]
                                                                        .order!
                                                                        .editedStatus ==
                                                                    1
                                                                ? SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeSmall)
                                                                : SizedBox(),

                                                            // Total
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getTranslated(
                                                                          'sub_total',
                                                                          context)!,
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                  Text(
                                                                      PriceConverter.convertPrice(
                                                                          context,
                                                                          itemsPrice),
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                ]),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),

                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getTranslated(
                                                                          'tax',
                                                                          context)!,
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                  Text(
                                                                      ' + ${PriceConverter.convertPrice(context, tax)}',
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                ]),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),

                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getTranslated(
                                                                          'discount',
                                                                          context)!,
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                  Text(
                                                                      '- ${PriceConverter.convertPrice(context, discount)}',
                                                                      style: titilliumRegular
                                                                          .copyWith(
                                                                        color: ColorHelper.blendColors(
                                                                            Colors.white,
                                                                            Theme.of(context).textTheme.bodyLarge!.color!,
                                                                            0.7),
                                                                      )),
                                                                ]),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),

                                                            if (referAndEarnDiscount >
                                                                0)
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        getTranslated(
                                                                            'referral_discount',
                                                                            context)!,
                                                                        style: titilliumRegular.copyWith(
                                                                            color: ColorHelper.blendColors(
                                                                                Colors.white,
                                                                                Theme.of(context).textTheme.bodyLarge!.color!,
                                                                                0.7))),
                                                                    Text(
                                                                        '- ${PriceConverter.convertPrice(context, referAndEarnDiscount)}',
                                                                        style: titilliumRegular
                                                                            .copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7),
                                                                        )),
                                                                  ]),

                                                            if (referAndEarnDiscount >
                                                                0)
                                                              const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),

                                                            orderDetailsController
                                                                        .orderDetails![
                                                                            0]
                                                                        .order!
                                                                        .orderType ==
                                                                    "POS"
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                        Text(
                                                                            getTranslated('extra_discount',
                                                                                context)!,
                                                                            style:
                                                                                titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                        Text(
                                                                            '- ${PriceConverter.convertPrice(context, eeDiscount)}',
                                                                            style:
                                                                                titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                      ])
                                                                : const SizedBox(),
                                                            SizedBox(
                                                                height: orderDetailsController
                                                                            .orderDetails![
                                                                                0]
                                                                            .order!
                                                                            .orderType ==
                                                                        "POS"
                                                                    ? Dimensions
                                                                        .paddingSizeSmall
                                                                    : 0),

                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getTranslated(
                                                                          'coupon_discount',
                                                                          context)!,
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                  Text(
                                                                      '- ${PriceConverter.convertPrice(context, coupon)}',
                                                                      style: titilliumRegular.copyWith(
                                                                          color: ColorHelper.blendColors(
                                                                              Colors.white,
                                                                              Theme.of(context).textTheme.bodyLarge!.color!,
                                                                              0.7))),
                                                                ]),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),

                                                            if (!_onlyDigital)
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        getTranslated('shipping_fee',
                                                                                context)! +
                                                                            _shippingFreeText(orderDetailsController
                                                                                .orderDetails![
                                                                                    0]
                                                                                .order),
                                                                        style: titilliumRegular.copyWith(
                                                                            color: ColorHelper.blendColors(
                                                                                Colors.white,
                                                                                Theme.of(context).textTheme.bodyLarge!.color!,
                                                                                0.7))),
                                                                    Text(
                                                                        '${(isFreeShipping) ? '' : '+'} ${PriceConverter.convertPrice(context, shipping)}',
                                                                        style: titilliumRegular.copyWith(
                                                                            color: ColorHelper.blendColors(
                                                                                Colors.white,
                                                                                Theme.of(context).textTheme.bodyLarge!.color!,
                                                                                0.7))),
                                                                  ]),

                                                            const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            Dimensions
                                                                                .paddingSizeSmall),
                                                                child:
                                                                    CustomDividerWidget()),

                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      getTranslated(
                                                                          'total_amount',
                                                                          context)!,
                                                                      style: titilliumSemiBold.copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeDefault)),
                                                                  Text(
                                                                    PriceConverter.convertPrice(
                                                                        context,
                                                                        totalPrice),
                                                                    style: titilliumSemiBold.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .fontSizeExtraLarge,
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                ]),

                                                            if (orderDetailsController
                                                                    .orderDetails![
                                                                        0]
                                                                    .order!
                                                                    .orderType ==
                                                                'POS')
                                                              Column(
                                                                children: [
                                                                  const SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall),
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                            getTranslated('paid_amount',
                                                                                context)!,
                                                                            style:
                                                                                titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                        Text(
                                                                            PriceConverter.convertPrice(context,
                                                                                orderDetailsController.orderDetails![0].order!.paidAmount),
                                                                            style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                      ]),
                                                                  const SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall),

                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                            getTranslated('change_amount',
                                                                                context)!,
                                                                            style:
                                                                                titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                        Text(
                                                                            PriceConverter.convertPrice(context,
                                                                                orderDetailsController.orderDetails![0].order!.paidAmount! - double.parse(totalPrice.toStringAsFixed(2))),
                                                                            style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                                      ]),
                                                                  // const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),

                                                orderDetailsController
                                                                .orderDetails![
                                                                    0]
                                                                .order!
                                                                .orderNote !=
                                                            null &&
                                                        orderDetailsController
                                                            .orderDetails![0]
                                                            .order!
                                                            .orderNote!
                                                            .trim()
                                                            .isNotEmpty
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor
                                                                          .withValues(
                                                                              alpha:
                                                                                  .25),
                                                                      spreadRadius:
                                                                          .11,
                                                                      blurRadius:
                                                                          .11,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              2))
                                                                ],
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    bottomLeft: Radius.circular(
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            Dimensions.paddingSizeSmall))),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor
                                                                .withValues(
                                                                    alpha: .07),
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        Dimensions
                                                                            .paddingSizeSmall)),
                                                          ),
                                                          padding: const EdgeInsets
                                                              .fromLTRB(
                                                              Dimensions
                                                                  .paddingSizeDefault,
                                                              Dimensions
                                                                  .paddingSizeDefault,
                                                              Dimensions
                                                                  .paddingSizeDefault,
                                                              Dimensions
                                                                  .paddingSizeDefault),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right: Dimensions
                                                                            .paddingSizeSmall),
                                                                    child: Image.asset(
                                                                        Images
                                                                            .orderNote,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.color,
                                                                        width: Dimensions
                                                                            .iconSizeSmall),
                                                                  ),
                                                                  Text(
                                                                      getTranslated(
                                                                          'order_note',
                                                                          context)!,
                                                                      style: titilliumSemiBold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeLarge,
                                                                        color: ColorHelper.blendColors(
                                                                            Colors.white,
                                                                            Theme.of(context).textTheme.bodyLarge!.color!,
                                                                            0.7),
                                                                      )),
                                                                ]),
                                                                const SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeExtraSmall),
                                                                Text(
                                                                    orderDetailsController.orderDetails![0].order!.orderNote !=
                                                                            null
                                                                        ? orderDetailsController.orderDetails![0].order!.orderNote ??
                                                                            ''
                                                                        : "",
                                                                    style: titilliumRegular.copyWith(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.color)),
                                                              ]),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ]),
                                          PaymentStatusWidget(
                                              order: orderController,
                                              orderModel: orderDetailsController
                                                  .orderDetails![0].order!,
                                              orderDetailsModel:
                                                  orderDetailsController
                                                      .orderDetails![0]),
                                          if (orderDetailsController
                                                      .orderDetails![0]
                                                      .orderEditHistory !=
                                                  null &&
                                              orderDetailsController
                                                  .orderDetails![0]
                                                  .orderEditHistory!
                                                  .isNotEmpty) ...[
                                            SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            Container(
                                              padding:
                                                  EdgeInsetsGeometry.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context)
                                                          .hintColor
                                                          .withValues(
                                                              alpha: 0.2),
                                                      spreadRadius: 1.5,
                                                      blurRadius: 3)
                                                ],
                                                color:
                                                    Theme.of(context).cardColor,
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeDefault),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          getTranslated(
                                                              'edit_log',
                                                              context)!,
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Divider(
                                                      thickness: 0.2,
                                                      height: 1,
                                                      color: Theme.of(context)
                                                          .hintColor
                                                          .withValues(
                                                              alpha: .65)),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  ListView.separated(
                                                    itemCount:
                                                        orderDetailsController
                                                            .orderDetails![0]
                                                            .orderEditHistory!
                                                            .length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeDefault),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    getTranslated(
                                                                        'edit_by',
                                                                        context)!,
                                                                    style: robotoRegular
                                                                        .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault,
                                                                      color: ColorHelper.blendColors(
                                                                          Colors
                                                                              .white,
                                                                          Theme.of(context)
                                                                              .textTheme
                                                                              .headlineLarge!
                                                                              .color!,
                                                                          0.7),
                                                                    )),
                                                                Text(
                                                                  "${orderDetailsController.orderDetails![0].orderEditHistory![index].editBy} (${orderDetailsController.orderDetails![0].orderEditHistory![index].editedUserName})",
                                                                  style: robotoRegular.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.color),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    getTranslated(
                                                                        'date',
                                                                        context)!,
                                                                    style: robotoRegular
                                                                        .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault,
                                                                      color: ColorHelper.blendColors(
                                                                          Colors
                                                                              .white,
                                                                          Theme.of(context)
                                                                              .textTheme
                                                                              .headlineLarge!
                                                                              .color!,
                                                                          0.7),
                                                                    )),
                                                                Text(
                                                                  DateConverter.formatDateWithCommaAnd24Hour(DateTime.parse(orderDetailsController
                                                                      .orderDetails![
                                                                          0]
                                                                      .orderEditHistory![
                                                                          index]
                                                                      .createdAt!)),
                                                                  style: robotoRegular.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.color),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeDefault),
                                                        child: Divider(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.5),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                          ],
                                          ChangeAmountWidget(
                                            amount: orderDetailsController
                                                    .orderDetails![0]
                                                    .order
                                                    ?.bringCashAmount ??
                                                0,
                                            currency: orderDetailsController
                                                    .orderDetails![0]
                                                    .order
                                                    ?.bringChangeAmountCurrency ??
                                                '',
                                          ),
                                          orderDetailsController
                                                      .orderDetails![0]
                                                      .order!
                                                      .thirdPartyServiceName !=
                                                  null
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      bottom: Dimensions
                                                          .paddingSizeSmall),
                                                  child: ThirdPartyDeliveryInfoWidget(
                                                      orderModel:
                                                          orderDetailsController
                                                              .orderDetails![0]
                                                              .order),
                                                )
                                              : const SizedBox.shrink(),
                                          if (orderDetailsController
                                                      .orderDetails !=
                                                  null &&
                                              orderDetailsController
                                                      .orderDetails![0]
                                                      .verificationImages !=
                                                  null &&
                                              orderDetailsController
                                                  .orderDetails![0]
                                                  .verificationImages!
                                                  .isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        Dimensions
                                                            .paddingSizeSmall,
                                                        Dimensions
                                                            .paddingSizeSmall,
                                                        Dimensions
                                                            .paddingSizeSmall,
                                                        Dimensions
                                                            .paddingSizeSmall),
                                                    child: Text(
                                                      '${getTranslated('completed_service_picture', context)}',
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor),
                                                    )),
                                                SizedBox(
                                                  height: 120,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          orderDetailsController
                                                              .orderDetails![0]
                                                              .verificationImages
                                                              ?.length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () => showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  ImageDialogWidget(
                                                                      imageUrl:
                                                                          '${orderDetailsController.orderDetails![0].verificationImages?[index].imageFullUrl?.path}')),
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                left: Dimensions
                                                                    .paddingSizeSmall,
                                                                right: orderDetailsController
                                                                            .orderDetails![
                                                                                0]
                                                                            .verificationImages!
                                                                            .length ==
                                                                        index +
                                                                            1
                                                                    ? Dimensions
                                                                        .paddingSizeSmall
                                                                    : 0),
                                                            child: SizedBox(
                                                              width: 200,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: Theme.of(context).primaryColor.withValues(
                                                                                alpha:
                                                                                    .25),
                                                                            width:
                                                                                .25),
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions
                                                                                .paddingSizeSmall)),
                                                                    child: CustomImageWidget(
                                                                        image:
                                                                            '${orderDetailsController.orderDetails![0].verificationImages?[index].imageFullUrl?.path}')),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                        ])),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                              ],
                            ))
                          ],
                        )
                      : const NoDataScreen()
                  : const OrderDetailsShimmer();
            });
          }),
        ),
        bottomNavigationBar: Consumer<OrderDetailsController>(
            builder: (_, orderDetailsController, __) {
          if (orderDetailsController.orderDetails?.isEmpty ?? true)
            return const SizedBox();
          return orderDetailsController
                      .orderDetails?.firstOrNull?.order?.orderType ==
                  'POS'
              ? const SizedBox()
              : Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: ThemeShadow.getShadow(context)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall),
                  child: CustomButtonWidget(
                    backgroundColor:
                        (orderDetailsController.orderDetails == null)
                            ? Theme.of(context).hintColor
                            : Theme.of(context).primaryColor,
                    borderRadius: Dimensions.paddingSizeExtraSmall,
                    btnTxt: getTranslated('order_setup', context),
                    onTap: (orderDetailsController.orderDetails == null)
                        ? null
                        : () {
                            showModalBottomSheet(
                              backgroundColor: Theme.of(context).cardColor,
                              useSafeArea: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return OrderSetupBottomSheet(
                                  orderModel: orderDetailsController
                                      .orderDetails?.firstOrNull?.order,
                                  onlyDigital: _onlyDigital,
                                  bottomContext: context,
                                );
                              },
                            );
                          },
                  ),
                );
        }),
      ),
    );
  }

  String _shippingFreeText(Order? order) {
    if ((order?.isShippingFree ?? false) &&
        order?.shippingResponsibility == 'inhouse_shipping') {
      return ' (${getTranslated('expense_bearer_admin', context)})';
    } else if ((order?.isShippingFree ?? false) &&
        order?.shippingResponsibility == 'sellerwise_shipping') {
      return ' (${getTranslated('expense_bearer_vendor', context)})';
    }
    return '';
  }
}

class _NoInsuranceRequiredCard extends StatelessWidget {
  const _NoInsuranceRequiredCard();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff16A06A).withValues(alpha: .09),
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          border:
              Border.all(color: const Color(0xff16A06A).withValues(alpha: .28)),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xff16A06A).withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_user_outlined,
                color: Color(0xff11865A)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                getTranslated('no_order_insurance_required', context) ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(getTranslated('no_order_insurance_hint', context) ?? '',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
      );
}
