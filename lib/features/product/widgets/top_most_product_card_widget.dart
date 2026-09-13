import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'dart:ui' as ui;


class TopMostProductWidget extends StatelessWidget{
  final Product? productModel;
  final bool isPopular;
  final String? totalSold;
  const TopMostProductWidget({super.key, this.productModel, this.isPopular = false, this.totalSold});

  @override
  Widget build(BuildContext context) {

    double ratting = (productModel?.rating?.isNotEmpty ?? false) ?  double.parse('${productModel?.rating?[0].average}') : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall),
      child: GestureDetector(
        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productModel: productModel))),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme?Theme.of(context).primaryColor.withValues(alpha:0):
            Theme.of(context).primaryColor.withValues(alpha:.125), blurRadius: 1,spreadRadius: 1,offset: const Offset(1,2))]
          ),
          child: Column(children: [
            Stack(
              children: [
                Container(decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:.10),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),),
                  width: MediaQuery.of(context).size.width/2,
                  height: MediaQuery.of(context).size.width/2-50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.paddingSizeExtraSmall),
                      topRight: Radius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                    child: CachedNetworkImage(
                      placeholder: (ctx, url) => Image.asset(Images.placeholderImage,
                        height: Dimensions.imageSize,width: Dimensions.imageSize,fit: BoxFit.cover,),
                      fit: BoxFit.cover,
                      height: Dimensions.imageSize,width: Dimensions.imageSize,
                      errorWidget: (ctx,url,err) => Image.asset(Images.placeholderImage,fit: BoxFit.cover,
                        height: Dimensions.imageSize,width: Dimensions.imageSize,),
                      imageUrl: productModel?.thumbnailFullUrl?.path ?? ''),
                  ),
                ),


                isPopular ? SizedBox() : Positioned(
                  left: 0, right: 0, bottom: 10,
                  child: Center(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)
                    ),
                    child: Text('${NumberFormat.compact().format(double.parse(totalSold!))} ${getTranslated('sold', context)}',
                      style: robotoMedium.copyWith(color: Colors.white),),
                  )),
                ),



               if(hasDiscount())
                 DiscountTagWidget(positionedTop: 5, positionedLeft: 0, positionedRight: 0, productModel: productModel!),


              ],
            ),
            Padding(padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeExtraSmall, 0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall,),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(productModel!.name!.trim(), textAlign: TextAlign.center, style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                if(hasDiscount())
                  Text(PriceConverter.convertPrice(context, productModel?.unitPrice), style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                  )),

                Text(
                  PriceConverter.convertPrice(
                    context, productModel?.unitPrice,
                    discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                      ? productModel?.clearanceSale?.discountType
                      : productModel?.discountType,
                    discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                      ? productModel?.clearanceSale?.discountAmount
                      : productModel?.discount
                  ),
                  style: robotoBold.copyWith(color:  Provider.of<ThemeController>(context).darkTheme ?
                  Theme.of(context).textTheme.bodyLarge?.color :
                  Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeDefault),
                ),


                if(ratting > 0) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.star_rate_rounded, color: Colors.orange, size: Dimensions.paddingSizeDefault),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(ratting.toStringAsFixed(1), style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                  ),

                  Text('(${PriceConverter.longToShortPrice(productModel?.reviewsCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ]),





              ]),
            ),
          ]),
        ),
      ),
    );
  }

  bool hasDiscount() => (productModel?.discount != null && productModel!.discount! > 0) || (productModel?.clearanceSale?.discountAmount ?? 0) > 0;

}



class DiscountTagWidget extends StatelessWidget {
  const DiscountTagWidget({
    super.key,
    required this.productModel,
    this.positionedTop = 10,
    this.positionedLeft = 0,
    this.positionedRight = 0,
    this.topLeftBorderRadius = 0,
    this.bottomRightBorderRadius = 0,
  });

  final Product productModel;
  final double positionedTop;
  final double positionedLeft;
  final double positionedRight;
  final double? topLeftBorderRadius;
  final double? bottomRightBorderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Positioned(
        top: positionedTop, left: isLtr ? positionedLeft : null, right: !isLtr ? positionedRight : null,
        child: Container(
          transform: Matrix4.translationValues(-1, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(isLtr ? Dimensions.paddingSizeSmall : 0),
              topRight: Radius.circular(isLtr ?  Dimensions.paddingSizeSmall : 0),
              bottomLeft: Radius.circular(!isLtr ? Dimensions.paddingSizeSmall : 0),
              topLeft: Radius.circular(!isLtr ? Dimensions.paddingSizeSmall : 0),
            )
          ),
          child: Center(
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  productModel.clearanceSale != null ?
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.clearanceSale?.discountAmount, productModel.clearanceSale?.discountType) :
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.discount, productModel.discountType),
                  style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                ),
              )
          ),
        )
    );
  }
}