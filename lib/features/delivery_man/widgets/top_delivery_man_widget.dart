import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/domain/model/top_delivery_man.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/screens/delivery_man_details_screen.dart';

class TopDeliveryManWidget extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  const TopDeliveryManWidget({super.key, this.deliveryMan});

  @override
  Widget build(BuildContext context) {

    double ratting = (deliveryMan?.rating?.isNotEmpty ?? false) ?  double.parse('${deliveryMan?.rating?[0].average}') : 0;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DeliveryManDetailsScreen(deliveryMan: deliveryMan))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall),
        child: Column(children: [
            Container(decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme?Theme.of(context).primaryColor.withValues(alpha:0):
                Theme.of(context).primaryColor.withValues(alpha:.125),
                    blurRadius: 1,spreadRadius: 1,offset: const Offset(0,1))]

              ),
              child: Column(children: [
                Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  child: Container(decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.1), width: .5)),
                    width: Provider.of<LocalizationController>(context, listen: false).isLtr?  75: 72,
                    height: Provider.of<LocalizationController>(context, listen: false).isLtr?  75: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CustomImageWidget(image: '${deliveryMan!.imageFullUrl?.path}',
                        height: Dimensions.imageSize,width: Dimensions.imageSize,)

                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Text('${deliveryMan!.fName!} ${deliveryMan!.lName!}',textAlign: TextAlign.center,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSeven),

                  ],),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).primaryColor, 0.15),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeExtraSmall),
                      bottomRight: Radius.circular(Dimensions.paddingSizeExtraSmall)
                    )
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('${getTranslated('order_deliver', context)} : ',
                           style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                          ),

                          Text(NumberFormat.compact().format(deliveryMan?.deliveredOrderCount ?? 0),
                            style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),


                      if(ratting == 0)
                        SizedBox(height: Dimensions.paddingSizeDefault),

                        Row(
                        children: [
                          if(ratting > 0)
                          Text('${getTranslated('rating', context)} : ',
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),),


                          if(ratting > 0) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(ratting.toStringAsFixed(1), style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              )),
                            ),

                            const Icon(Icons.star_rate_rounded, color: Colors.orange, size: Dimensions.paddingSizeDefault),
                          ]),
                        ],
                      ),
                    ],
                  ),
                )
              ],),
            ),
          ],
        ),
      ),
    );
  }
}
