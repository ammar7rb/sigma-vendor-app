import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/features/refund/widgets/refund_attachment_list_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_details_screen.dart';

class RefundWidget extends StatelessWidget {
  final RefundModel? refundModel;
  final bool isDetails;
  final bool isLast;
  const RefundWidget({super.key, required this.refundModel, this.isDetails = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDetails ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RefundDetailsScreen(
          refundModel: refundModel, orderDetailsId: refundModel!.orderDetailsId,
          variation: refundModel!.orderDetails!.variant))),
      child: Padding(
        padding: isDetails ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(!isDetails)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeMedium),
                    child: Text(
                        DateConverter.isoStringToLocalDateAndTime(refundModel!.createdAt!),
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall
                        )
                    ),
                  ),


                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${getTranslated('refund', context)} ',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.headlineLarge?.color)
                                        ),
                                        TextSpan(
                                          text: '#${refundModel!.id}',
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                        ),
                                      ]
                                    )
                                  ),
                                ),


                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: refundModel!.status?.toLowerCase() == 'pending'
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                        : (refundModel?.status?.toLowerCase() == 'approved' || refundModel?.status?.toLowerCase() == 'refunded')
                                        ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.1)
                                        : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Text(
                                      getTranslated(refundModel!.status, context)!,
                                      style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: refundModel!.status?.toLowerCase() == 'pending'
                                              ? Theme.of(context).primaryColor
                                              : (refundModel!.status?.toLowerCase() == 'approved' || refundModel!.status?.toLowerCase() == 'refunded')
                                              ? Theme.of(context).colorScheme.onTertiaryContainer
                                              : Theme.of(context).colorScheme.error
                                      )
                                  ),
                                ),
                              ],
                            ),



                            Text(
                              PriceConverter.convertPrice(context, refundModel!.amount),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).primaryColor
                              )
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(
                              children: [
                                SizedBox(
                                  height: 16, width: 16,
                                  child: CustomAssetImageWidget(
                                    refundModel!.order!.paymentMethod == 'cash_on_delivery' ? Images.cashPaymentIcon :
                                    refundModel!.order!.paymentMethod == 'pay_by_wallet' ? Images.payByWalletIcon : Images.digitalPaymentIcon
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  refundModel!.order != null ? getTranslated(refundModel!.order!.paymentMethod, context) ?? '' : '',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).textTheme.bodyLarge?.color
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                            Container(
                              width: MediaQuery.of(context).size.width -130,
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${getTranslated('reason', context)}: ',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: refundModel!.refundReason ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.headlineLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,                     // ← Only one line
                                overflow: TextOverflow.ellipsis, // ← Add overflow dots
                              ),
                            ),



                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if(isDetails && (refundModel?.images?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    child: RefundAttachmentListWidget(refundModel: refundModel),
                  ),

                if(isLast) const SizedBox(height: Dimensions.paddingSizeSmall)
              ]
            ),



            if (refundModel!.product != null)
              Positioned(
                bottom: isLast ? 20 : 10, right: 10,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImageWidget(
                          image: '${refundModel!.product!.thumbnailFullUrl?.path}',
                          fit: BoxFit.cover
                      )
                  )
                ),
              ),



          ],
        ),
      ),
    );
  }
}
