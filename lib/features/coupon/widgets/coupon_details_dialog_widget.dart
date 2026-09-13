import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/domain/models/coupon_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CouponDetailsDialogWidget extends StatelessWidget {
  final Coupons? coupons;
  const CouponDetailsDialogWidget({super.key, this.coupons});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: SizedBox(
        height: coupons!.couponType != 'free_delivery' ? 240 : 220,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top : Dimensions.paddingSizeSmall,
                        bottom : Dimensions.paddingSizeDefault,
                        left : Dimensions.paddingSizeDefault,
                        right : Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusDefault),
                          bottomLeft: Radius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupons!.title ?? '',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Row(
                            children: [
                              Text(
                                getTranslated(coupons!.couponType, context) ?? '',
                                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: coupons!.code ?? ''));
                                  showCustomSnackBarWidget(getTranslated('coupon_code_copied', context), context, isError: false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        coupons!.code ?? '',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.copy, size: 14, color: Theme.of(context).primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          _buildDetailRow(context, 'min_purchase', PriceConverter.convertPrice(context, coupons!.minPurchase)),
                          if(coupons!.couponType != 'free_delivery')
                          _buildDetailRow(context, 'max_discount', PriceConverter.convertPrice(context, coupons!.maxDiscount)),
                          if(coupons!.customerId == 0)
                          _buildDetailRow(context, 'coupon_for', getTranslated('all_customer', context) ?? 'All Customers'),
                          _buildDetailRow(context, 'user_limit', '${coupons!.limit}'),
                          _buildDetailRow(context, 'start_date', DateConverter.isoStringToLocalDateOnly(coupons!.startDate!)),
                          _buildDetailRow(context, 'expire_date', DateConverter.isoStringToLocalDateOnly(coupons!.expireDate!)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(Dimensions.radiusDefault),
                          bottomRight: Radius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10, right: 10,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.close, size: 16, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Positioned(
              right: (MediaQuery.of(context).size.width * 0.25) - 80,
              bottom: 30,
              child: Container(
                height: 90, width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 1)
                  ]
                ),
                child: Center(
                  child: coupons!.couponType == 'free_delivery'
                      ? Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Image.asset(Images.freeDelivery, width: 40),
                  )
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        coupons!.discountType == 'amount'
                          ? PriceConverter.convertPrice(context, coupons!.discount)
                          : '${coupons!.discount?.toInt()}%',
                        style: robotoBold.copyWith(fontSize: 19, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      Text(
                        getTranslated('off', context) ?? 'Off',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeVeryTiny),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '${getTranslated(key, context)}',
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ),
          const Text(' :  '),
          Expanded(
            child: Text(
              value,
              style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}