import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_details_model.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/features/refund/widgets/refund_attachment_list_widget.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/refund/controllers/refund_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/refund/widgets/approve_reject_widget.dart';
import 'package:sixvalley_vendor_app/features/refund/widgets/refund_pricing_widget.dart';

class RefundDetailWidget extends StatefulWidget {
  final RefundModel? refundModel;
  final int? orderDetailsId;
  final String? variation;
  const RefundDetailWidget(
      {super.key,
      required this.refundModel,
      required this.orderDetailsId,
      this.variation});
  @override
  RefundDetailWidgetState createState() => RefundDetailWidgetState();
}

class RefundDetailWidgetState extends State<RefundDetailWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedMaxScroll = false;

  @override
  void initState() {
    Provider.of<RefundController>(context, listen: false)
        .setInitialResetButton();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  bool showButton = false;

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if scroll position is at the bottom
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_hasReachedMaxScroll) {
        setState(() {
          _hasReachedMaxScroll = true;
        });
      }
    } else if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (_hasReachedMaxScroll) {
        setState(() {
          _hasReachedMaxScroll = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Consumer<RefundController>(builder: (context, refundReq, _) {
              if (refundReq.refundDetailsModel != null) {
                List<RefundStatus>? status = [];

                if (refundReq.refundDetailsModel?.refundRequest != null &&
                    refundReq.refundDetailsModel!.refundRequest!.isNotEmpty) {
                  status = refundReq
                      .refundDetailsModel?.refundRequest![0].refundStatus;
                  widget.refundModel?.status =
                      refundReq.refundDetailsModel?.refundRequest![0].status;
                }

                String changeBy = '';
                for (RefundStatus action in status!) {
                  if (kDebugMode) {
                    print('=====>${action.changeBy}');
                  }
                  if (action.changeBy == 'admin') {
                    changeBy = 'admin';
                    showButton = false;
                  }
                }

                if (changeBy != 'admin') {
                  showButton = true;
                }
              }

              return Consumer<RefundController>(builder: (context, refund, _) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      RefundDataWidget(refundModel: widget.refundModel),

                      if (widget.refundModel?.product != null)
                        SizedBox(height: Dimensions.paddingSizeSmall),

                      widget.refundModel?.product != null
                          ? Container(
                              color: Theme.of(context).cardColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: Dimensions.paddingSizeDefault),
                                      Image.asset(Images.productListIcon,
                                          height: 20, width: 20),
                                      SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Text(
                                        getTranslated('product_list', context)!,
                                        style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  SizedBox(
                                      height: 1,
                                      child: Divider(
                                          thickness: .200,
                                          color: Theme.of(context)
                                              .hintColor
                                              .withValues(alpha: 0.45))),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                        vertical: Dimensions.paddingSizeSmall,
                                        horizontal:
                                            Dimensions.paddingSizeDefault),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions
                                                    .paddingSizeExtraSmall),
                                            border: Border.all(
                                                width: .5,
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: .125))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical:
                                                Dimensions.paddingSizeSmall),
                                        child: Column(
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Stack(children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .paddingSizeExtraSmall),
                                                        border: Border.all(
                                                            width: .5,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha:
                                                                        .125)),
                                                      ),
                                                      height:
                                                          Dimensions.imageSize,
                                                      width:
                                                          Dimensions.imageSize,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: CustomImageWidget(
                                                              height: Dimensions
                                                                  .imageSize,
                                                              width: Dimensions
                                                                  .imageSize,
                                                              image:
                                                                  '${widget.refundModel?.product?.thumbnailFullUrl?.path}')),
                                                    ),
                                                    if ((widget
                                                                .refundModel
                                                                ?.product
                                                                ?.discount ??
                                                            0) >
                                                        0)
                                                      Positioned(
                                                          top: 10,
                                                          left: 0,
                                                          child: Container(
                                                            height: 20,
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                  PriceConverter
                                                                      .percentageCalculation(
                                                                    context,
                                                                    widget
                                                                        .refundModel
                                                                        ?.product
                                                                        ?.unitPrice,
                                                                    widget
                                                                        .refundModel
                                                                        ?.product
                                                                        ?.discount,
                                                                    widget
                                                                        .refundModel
                                                                        ?.product
                                                                        ?.discountType,
                                                                  ),
                                                                  style: titilliumRegular
                                                                      .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                  )),
                                                            ),
                                                          )),
                                                  ]),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeDefault),
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              widget
                                                                      .refundModel
                                                                      ?.product
                                                                      ?.name ??
                                                                  '',
                                                              style: robotoRegular.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeDefault,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                PriceConverter.convertPrice(
                                                                    context,
                                                                    refund
                                                                        .refundDetailsModel!
                                                                        .productPrice!,
                                                                    discount: refund
                                                                        .refundDetailsModel!
                                                                        .productTotalDiscount,
                                                                    discountType: widget
                                                                        .refundModel
                                                                        ?.product
                                                                        ?.discountType),
                                                                style: titilliumSemiBold.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor),
                                                              ),
                                                            ],
                                                          ),
                                                          (widget.refundModel?.orderDetails
                                                                          ?.variant !=
                                                                      null &&
                                                                  widget
                                                                      .refundModel!
                                                                      .orderDetails!
                                                                      .variant!
                                                                      .isNotEmpty)
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              0.0),
                                                                  child: Text(
                                                                      widget
                                                                          .refundModel!
                                                                          .orderDetails!
                                                                          .variant!,
                                                                      style: robotoRegular.copyWith(
                                                                          fontSize: Dimensions
                                                                              .fontSizeSmall,
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .titleLarge
                                                                              ?.color)),
                                                                )
                                                              : const SizedBox(),
                                                          if (widget
                                                                      .refundModel
                                                                      ?.orderDetails
                                                                      ?.variant !=
                                                                  null &&
                                                              widget
                                                                  .refundModel!
                                                                  .orderDetails!
                                                                  .variant!
                                                                  .isNotEmpty)
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                          Row(children: [
                                                            Text(
                                                                getTranslated(
                                                                    'qty',
                                                                    context)!,
                                                                style: titilliumRegular.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headlineLarge
                                                                        ?.color)),
                                                            Text(
                                                                ': ${refund.refundDetailsModel?.quntity}',
                                                                style: titilliumRegular.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headlineLarge
                                                                        ?.color))
                                                          ]),
                                                        ]),
                                                  ),
                                                ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        color: Theme.of(context).cardColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                              children: [
                                SizedBox(width: Dimensions.paddingSizeDefault),
                                Image.asset(Images.refundResonIcon,
                                    height: 20, width: 20),
                                SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(
                                  getTranslated('refund_reason', context)!,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.paddingSizeSmall),
                            SizedBox(
                                height: 1,
                                child: Divider(
                                    thickness: .200,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.45))),
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                  vertical: Dimensions.paddingSizeSmall,
                                  horizontal: Dimensions.paddingSizeDefault),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.refundModel!.refundReason ?? '',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.color,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  if (widget.refundModel?.images != null &&
                                      widget.refundModel!.images!.isNotEmpty)
                                    RefundAttachmentListWidget(
                                        refundModel: widget.refundModel),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      RefundPricingWidget(refundModel: widget.refundModel),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // _hasReachedMaxScroll ?
                      // ApprovedAndRejectWidget(refundModel: widget.refundModel, orderDetailsId: widget.orderDetailsId) : SizedBox(),
                    ]);
              });
            }),
          ),
        ),
        Consumer<RefundController>(builder: (context, refundReq, _) {
          return refundReq.refundDetailsModel?.refundRequest != null &&
                  refundReq.refundDetailsModel!.refundRequest!.isNotEmpty &&
                  refundReq
                          .refundDetailsModel!.refundRequest?[0].refundStatus !=
                      null &&
                  refundReq.refundDetailsModel!.refundRequest![0].refundStatus!
                      .isNotEmpty &&
                  refundReq
                          .refundDetailsModel!
                          .refundRequest![0]
                          .refundStatus![(refundReq.refundDetailsModel!
                                      .refundRequest![0].refundStatus?.length ??
                                  0) -
                              1]
                          .changeBy !=
                      'admin'
              ? ApprovedAndRejectWidget(
                  refundModel: widget.refundModel,
                  orderDetailsId: widget.orderDetailsId)
              : const SizedBox();
        }),
      ],
    );
  }
}

class ProductCalculationItem extends StatelessWidget {
  final String? title;
  final double? price;
  final bool isQ;
  final int? qty;
  final bool isNegative;
  final bool isPositive;
  const ProductCalculationItem(
      {super.key,
      this.title,
      this.price,
      this.isQ = false,
      this.isNegative = false,
      this.isPositive = false,
      this.qty});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isQ
            ? Text('${getTranslated(title, context)} (x$qty)',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorHelper.blendColors(Colors.white,
                      Theme.of(context).textTheme.headlineLarge!.color!, 0.7),
                ))
            : Text('${getTranslated(title, context)}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorHelper.blendColors(Colors.white,
                      Theme.of(context).textTheme.headlineLarge!.color!, 0.7),
                )),
        const Spacer(),
        isNegative
            ? Text('- ${PriceConverter.convertPrice(context, price)}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ))
            : isPositive
                ? Text('+ ${PriceConverter.convertPrice(context, price)}',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ))
                : Text(PriceConverter.convertPrice(context, price),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
      ],
    );
  }
}
