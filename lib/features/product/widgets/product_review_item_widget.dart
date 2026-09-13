import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/review/domain/models/review_model.dart';
import 'package:sixvalley_vendor_app/features/review/screens/review_reply_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/rating_bar_widget.dart';

class ProductReviewItemWidget extends StatelessWidget {
  final ReviewModel reviewModel;
  final int index;
  final int productId;
  const ProductReviewItemWidget({super.key, required this.reviewModel, required this.index, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          boxShadow: [
            BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:0.10), offset: const Offset(0, 6), blurRadius: 15, spreadRadius: -3),
          ],
        ),

        child: Column(mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Container(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).cardColor,
            //     borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            //     boxShadow: const [
            //      BoxShadow(
            //       color: Color(0x0D000000),
            //       offset: Offset(0, 3),
            //       blurRadius: 6,
            //       spreadRadius: -3,
            //     ),
            //     ],
            //   ),
            //   padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            //               decoration: BoxDecoration(
            //                 color: Theme.of(context).primaryColor.withValues(alpha:0.02),
            //                 borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            //               ),
            //
            //
            //               child: Row(mainAxisSize: MainAxisSize.min, children: [
            //                 Text(getTranslated('review_id', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).primaryColor)),
            //                 Text(' ${reviewModel.id}', style: titilliumBold),
            //               ],
            //               ),
            //             ),
            //             const SizedBox(height: Dimensions.paddingSizeSmall),
            //
            //
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),



            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(reviewModel.customer != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraLarge)),
                    child: SizedBox(width: Dimensions.productImageSize,
                      height: Dimensions.productImageSize,
                      child: CustomImageWidget(image:"${reviewModel.customer?.imageFullUrl?.path}"),),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if(reviewModel.customer != null)
                    Text("${reviewModel.customer!.fName!} ${reviewModel.customer!.lName!}",
                      style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, overflow: TextOverflow.ellipsis, fontSize: 13),
                      maxLines: 1,
                    ),
                    if(reviewModel.customer == null)
                      Text(getTranslated('customer_not_available', context)!,
                      style: robotoMedium.copyWith(),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      children: [
                      FittedBox(child: RatingBar(rating: reviewModel.rating, size: 15)),

                      Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                        child: Text(reviewModel.rating.toString(),
                        style: robotoRegular.copyWith(color: Theme.of(context).hintColor))),
                      ],
                    )
                  ])),
                  const SizedBox(width: Dimensions.paddingSizeSmall,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          reviewModel.orderId != null ?
                          Text('${getTranslated('order', context)!}#${reviewModel.orderId}', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),

                          Consumer<ProductReviewController>(
                              builder: (context, productReviewController, child) {
                                return SizedBox(
                                  height: 30, width: 15,
                                  child: PopupMenuButton<int>(
                                    padding: EdgeInsetsGeometry.all(0),
                                    icon:  SizedBox(
                                      height: 35, width: 15,
                                      child: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyLarge?.color),
                                    ),
                                    onSelected: (value) {},
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(getTranslated('statuss', context)!,
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                            ),
                                            const SizedBox(width: 25),

                                            Consumer<ProductReviewController>(
                                                builder: (context, productReviewController, child) {
                                                  return FlutterSwitch(
                                                    width: 40, height: 22, toggleSize: 18,
                                                    padding: 2,
                                                    value: productReviewController.productReviewList[index].status == 1 ? true : false,
                                                    onToggle: (bool value) {
                                                      if(value) {
                                                        Provider.of<ProductReviewController>(context, listen: false).reviewStatusOnOff(context, reviewModel.id, 1, index, fromProduct: true);
                                                      } else {
                                                        Provider.of<ProductReviewController>(context, listen: false).reviewStatusOnOff(context, reviewModel.id, 0, index, fromProduct: true);
                                                      }
                                                    },
                                                  );
                                                }
                                            )
                                          ],
                                        ),
                                      ),




                                      if(Provider.of<SplashController>(context, listen: false).configModel!.reviewReplyStatus == true)...[
                                        PopupMenuItem(
                                          value: 3,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Provider.of<SplashController>(context, listen: false).configModel!.reviewReplyStatus == true ?
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_)=> ReviewReplyScreen(reviewModel: reviewModel, index: index, productId: productId,)));
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: Dimensions.paddingSizeExtraSmall),
                                                  decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                                                      color: Theme.of(context).cardColor
                                                  ),
                                                  child: Text( reviewModel.reply != null ? getTranslated('view_reply', context)!  :getTranslated('review_reply', context)!, style : robotoBold.copyWith(color: reviewModel.reply != null ?  Theme.of(context).colorScheme.primary : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                                ),
                                              ) : const SizedBox()
                                            ],
                                          ),
                                        ),
                                      ]



                                    ],
                                  ),
                                );
                              }
                            ),

                          ]),

                      reviewModel.createdAt != null?
                      Text(DateConverter.formatTimeDateShort(DateTime.parse(reviewModel.createdAt!)),style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall),) : const SizedBox(),
                    ],
                  )

                ],
              ),
            ),

            (reviewModel.comment != null && reviewModel.comment!.isNotEmpty) ?
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: ReadMoreText(
                reviewModel.comment ?? '',
                trimMode: TrimMode.Line,
                trimLines: 3,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
                colorClickableText: Theme.of(context).colorScheme.surfaceTint.withValues(alpha:0.05),
                preDataTextStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.surfaceTint.withValues(alpha:0.05)),
                moreStyle: TextStyle(color : Theme.of(context).colorScheme.surfaceTint),
                lessStyle: TextStyle(color : Theme.of(context).colorScheme.surfaceTint),
                trimCollapsedText: getTranslated('view_more', context)!,
                trimExpandedText: ' ${getTranslated('view_less', context)!}',
                delimiter: ' ... ',
                delimiterStyle: TextStyle(color : Theme.of(context).colorScheme.surfaceTint),
              ),
            ) : const SizedBox(),

            (reviewModel.attachmentFullUrl != null && reviewModel.attachmentFullUrl!.isNotEmpty) ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: reviewModel.attachmentFullUrl!.length,
                  itemBuilder: (context, index) {
                    String imageUrl = '${reviewModel.attachmentFullUrl![index].path}';
                    return InkWell(
                      onTap: () => showDialog(context: context, builder: (ctx) =>
                        ImageDialogWidget(imageUrl:imageUrl), ),
                      child: Container(
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: FadeInImage.assetNetwork(
                            placeholder: Images.placeholderImage, height: 45, width: 45, fit: BoxFit.cover,
                            image: imageUrl,
                            imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage, height: 40, width: 40, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ) : const SizedBox(),

          ],
        ),
      ),
    );
  }
}
