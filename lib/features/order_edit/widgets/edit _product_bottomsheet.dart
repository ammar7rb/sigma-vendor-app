import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_directionality_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/order_edit/controllers/order_edit_controller.dart';
import 'package:sixvalley_vendor_app/features/order_edit/domain/models/order_edit_cart_model.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/helper/product_helper.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../localization/app_localization.dart';
import '../../../main.dart';

class EditProductCartBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final int? orderId;
  const EditProductCartBottomSheetWidget({super.key, required this.product, this.orderId});

  @override
  EditProductCartBottomSheetWidgetState createState() => EditProductCartBottomSheetWidgetState();
}

class EditProductCartBottomSheetWidgetState extends State<EditProductCartBottomSheetWidget> {
  Future<void> route(bool isRoute, String message) async {
    if (isRoute) {
      showCustomSnackBarWidget(message, context, isError: false);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showCustomSnackBarWidget(message, context);
    }
  }

  int qty = 0;
  bool isNotSetQty = true;

  @override
  void initState() {
     Provider.of<OrderEditController>(context, listen: false).initData(widget.product!,widget.product!.minimumOrderQty, context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(widget.product);
    double? startingPrice = priceRange.start;
    double? endingPrice = priceRange.end;


    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        child: Consumer<OrderEditController>(
            builder: (ctx, cartController, child) {
              return Consumer<OrderEditController>(
                builder: (ctx, productProvider, child) {


                  List<String> variationFileType = [];
                  List<List<String>> extentions = [];
                  String? variantKey;
                  Variation? variationModel;

                  String? colorWiseSelectedImage = '';



                  String? variantName = widget.product!.colors!.isNotEmpty ? widget.product!.colors![productProvider.variantIndex!].name : null;
                  List<String> variationList = [];
                  for(int index=0; index < widget.product!.choiceOptions!.length; index++) {
                    variationList.add(widget.product!.choiceOptions![index].options![productProvider.variationIndex![index]].trim());
                  }
                  String variationType = '';
                  if(variantName != null) {
                    variationType = variantName;
                    for (var variation in variationList) {
                      variationType = '$variationType-$variation';
                    }
                  }else {
                    bool isFirst = true;
                    for (var variation in variationList) {
                      if(isFirst) {
                        variationType = '$variationType$variation';
                        isFirst = false;
                      }else {
                        variationType = '$variationType-$variation';
                      }
                    }
                  }

                  if(widget.product?.digitalProductExtensions != null){
                    widget.product?.digitalProductExtensions?.keys.forEach((key) {
                      variationFileType.add(key);
                      extentions.add(widget.product?.digitalProductExtensions?[key]);
                    }
                    );
                  }

                  double? price = widget.product!.unitPrice;
                  int? stock = widget.product!.currentStock;
                  variationType = variationType.replaceAll(' ', '');
                  for(Variation variation in widget.product!.variation!) {
                    if(variation.type == variationType) {
                      price = variation.price;
                      variationModel = variation;
                      stock = variation.qty;
                      break;
                    }
                  }

                  int isUpdate = getIsExistInCart(cartController.cartList, widget.product!, variationType);


                  if(isUpdate != -1 && productProvider.isUpdateQuantity) {
                    productProvider.setQuantity(isUpdate, cartController.cartList[isUpdate].quantity ?? 1, isUpdate: false);
                    productProvider.updateQuantity(false, isUpdate : false);
                    isNotSetQty = false;
                  } else if(productProvider.isUpdateQuantity) {
                    // print('---Inside-Else----');
                    // productProvider.setQuantity(1, isUpdate: false);
                    // productProvider.updateQuantity(true, isUpdate : false);
                    // isNotSetQty = false;
                  }


                  double priceWithDiscount = PriceConverter.convertWithDiscount(context, price,
                      widget.product?.clearanceSale != null ?
                      widget.product!.clearanceSale!.discountAmount :
                      widget.product!.discount,

                      widget.product?.clearanceSale != null ?
                      widget.product!.clearanceSale!.discountType :
                      widget.product!.discountType
                  )!;


                  double priceWithQuantity = priceWithDiscount * productProvider.quantity!;

                  double total = 0, avg = 0;
                  for (var review in widget.product!.reviews!) {
                    total += review.rating!;
                  }
                  avg = total /widget.product!.reviews!.length;


                  String ratting = widget.product!.reviews != null && widget.product!.reviews!.isNotEmpty?
                  avg.toString() : "0";

                  if(widget.product != null && widget.product!.colorImagesFullUrl != null && widget.product!.colorImagesFullUrl!.isNotEmpty){
                    for(int i=0; i< widget.product!.colorImagesFullUrl!.length; i++){
                      if(widget.product!.colorImagesFullUrl![i].color == '${widget.product!.colors?[productProvider.variantIndex??0].code?.substring(1, 7)}'){
                        colorWiseSelectedImage = widget.product!.colorImagesFullUrl![i].imageName?.path;
                      }
                    }
                  }


                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Align(alignment: Alignment.centerRight, child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.cancel, color: Theme.of(context).hintColor, size: 30),
                    )),

                    Column(children: [
                      Stack(children: [
                        Container(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                Stack(children: [
                                  Container(width: 100, height: 100,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                                      border: Border.all(width: .5,color: Theme.of(context).primaryColor.withValues(alpha:.20))),
                                    child: ClipRRect(borderRadius: BorderRadius.circular(5),
                                      child: CustomImageWidget(image: (widget.product!.colors != null && widget.product!.colors!.isNotEmpty &&
                                        widget.product!.imagesFullUrl != null && widget.product!.imagesFullUrl!.isNotEmpty) ?
                                      '$colorWiseSelectedImage':
                                      '${widget.product!.thumbnailFullUrl?.path}'))
                                  ),
                                ]),
                              ]),
                              const SizedBox(width: Dimensions.paddingSizeLarge),

                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.product!.name ?? '',
                                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  if((widget.product?.reviewsCount ?? 0) < 0 || double.parse(ratting) > 0 )...[
                                    Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      Icon(Icons.star, color: Provider.of<ThemeController>(context).darkTheme ?
                                      Colors.white : Colors.orange, size: 15),

                                      Text(double.parse(ratting).toStringAsFixed(1),
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                      ),

                                      Text('(${ widget.product?.reviewsCount ?? '0'})', style:
                                      robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).hintColor)),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  ],
                                  if((widget.product?.reviewsCount ?? 0) < 0 || double.parse(ratting) > 0 )
                                    const SizedBox(height:  Dimensions.paddingSizeSmall),


                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    (widget.product?.discount != null && (widget.product?.discount ?? 0) > 0) || (widget.product?.clearanceSale?.discountAmount ?? 0) > 0 ?
                                    CustomDirectionalityWidget(
                                      child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
                                          '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                                          style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
                                              decoration: TextDecoration.lineThrough,
                                              fontSize: Dimensions.fontSizeLarge
                                          )
                                      ),
                                    ) : const SizedBox(),
                                    SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    CustomDirectionalityWidget(
                                      child: Text('${startingPrice != null ? PriceConverter.convertPrice(
                                        context, startingPrice,
                                        discount: (widget.product?.clearanceSale?.discountAmount ?? 0) > 0
                                            ? widget.product?.clearanceSale?.discountAmount
                                            : widget.product?.discount,
                                        discountType: (widget.product?.clearanceSale?.discountAmount ?? 0) > 0
                                            ? widget.product?.clearanceSale?.discountType
                                            : widget.product?.discountType,
                                      ):''}' '${endingPrice !=null ? ' - ${PriceConverter.convertPrice(
                                        context, endingPrice,
                                        discount: (widget.product?.clearanceSale?.discountAmount ?? 0) > 0
                                            ? widget.product?.clearanceSale?.discountAmount
                                            : widget.product?.discount,
                                        discountType: widget.product?.discountType,
                                      )}' : ''}', style: titilliumSemiBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                      )),
                                    ),
                                  ]),
                                ],
                              )),
                            ],
                          ),
                        ),

                        widget.product !=null && widget.product!.discount != null &&
                            ((widget.product!.discount! > 0) || (widget.product?.clearanceSale?.discountAmount ?? 0) > 0)  ?
                        DiscountTagWidget(
                            productModel: widget.product!,
                            positionedTop: 0,
                            topLeftBorderRadius: Dimensions.radiusDefault,
                            bottomRightBorderRadius: Dimensions.radiusDefault
                        ) : const SizedBox.shrink(),
                      ]),
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      // Row(children: [
                      //   widget.product!.discount! > 0 || (widget.product?.clearanceSale != null && widget.product!.clearanceSale!.discountAmount! > 0) ?
                      //   Container(margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      //     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                      //     alignment: Alignment.center,
                      //     decoration: BoxDecoration(color:Theme.of(context).primaryColor,
                      //       borderRadius: BorderRadius.circular(8)),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(PriceConverter.percentageCalculation(context, price,
                      //         widget.product?.clearanceSale != null ?
                      //         widget.product!.clearanceSale!.discountAmount
                      //             : widget.product!.discount,
                      //
                      //         widget.product?.clearanceSale != null ?
                      //         widget.product!.clearanceSale!.discountType :
                      //         widget.product!.discountType
                      //       ),
                      //         style: titilliumRegular.copyWith(color: Theme.of(context).cardColor,
                      //             fontSize: Dimensions.fontSizeDefault)
                      //       )
                      //     ),
                      //   ) : const SizedBox(width: 93),
                      //
                      //
                      //
                      //
                      //
                      //
                      //   const SizedBox(width: Dimensions.paddingSizeDefault),
                      //   widget.product!.discount! > 0 || (widget.product?.clearanceSale != null && widget.product!.clearanceSale!.discountAmount! > 0) ?
                      //   Text(PriceConverter.convertPrice(context, price),
                      //       style: titilliumRegular.copyWith(color: Theme.of(context).colorScheme.error,
                      //           decoration: TextDecoration.lineThrough)) : const SizedBox(),
                      //
                      //   const SizedBox(width: Dimensions.paddingSizeDefault),
                      //   Text(PriceConverter.convertPrice(context, price,
                      //       discountType:
                      //       widget.product?.clearanceSale != null ?
                      //       widget.product!.clearanceSale!.discountType :
                      //       widget.product!.discountType,
                      //
                      //       discount:
                      //       widget.product?.clearanceSale != null ?
                      //       widget.product!.clearanceSale!.discountAmount :
                      //       widget.product!.discount
                      //   ),
                      //       style: titilliumRegular.copyWith(color: Theme.of(context).primaryColor,
                      //           fontSize: Dimensions.fontSizeExtraLarge)),
                      // ]),


                    ],),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    if((widget.product!.colors != null && widget.product!.colors!.isNotEmpty) || (widget.product!.choiceOptions != null && widget.product!.choiceOptions!.isNotEmpty) || (variationFileType.isNotEmpty))
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            (widget.product!.colors != null && widget.product!.colors!.isNotEmpty) ?
                            ColorSelectionWidget(product: widget.product!, detailsController: productProvider) : const SizedBox(),

                            (widget.product!.colors != null && widget.product!.colors!.isNotEmpty) ?
                            const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                            // Variation
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.product!.choiceOptions!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ctx, index) {
                                  final choice = widget.product!.choiceOptions![index];

                                  return Column(
                                    children: [
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${widget.product!.choiceOptions![index].title?.toCapitalized()} ',
                                                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.titleMedium?.color)
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                            /// Grid of options
                                            Expanded(
                                              child:  Wrap(
                                                spacing: 8, // horizontal spacing between options
                                                runSpacing: 8, // vertical spacing between rows
                                                children: List.generate(choice.options!.length, (i) {
                                                  final option = choice.options![i].trim();
                                                  final isSelected = productProvider.variationIndex![index]  == i;

                                                  return InkWell(
                                                    onTap: () => productProvider.setCartVariationIndex(widget.product!.minimumOrderQty, index, i, context),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(50),
                                                        color: isSelected
                                                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                                            : Theme.of(context).hintColor.withAlpha(30),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        option,
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions.fontSizeDefault,
                                                          color: isSelected
                                                              ? Theme.of(context).primaryColor
                                                              : Theme.of(context).textTheme.titleMedium?.color,
                                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,                                               ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ]
                                      ),

                                      if(((widget.product!.choiceOptions?.length ?? 0) - 1) > index)
                                        SizedBox(height: Dimensions.paddingSizeLarge),

                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                          ],
                        ),
                      ),
                    SizedBox(height: Dimensions.paddingSizeSmall),


                    // Quantity
                    Row(children: [
                      Text(getTranslated('quantity', context)!, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      // productProvider.quantity == 1 ? const SizedBox() :
                      QuantityButton( disable: productProvider.quantity == 1 ,  isIncrement: false, quantity: productProvider.quantity,
                        stock: stock, minimumOrderQuantity: 1,
                        digitalProduct: widget.product!.productType == "digital"),

                      Text((productProvider.quantity).toString(), style: titilliumSemiBold),

                      QuantityButton(isIncrement: true, quantity: productProvider.quantity, stock: stock,
                        minimumOrderQuantity: 1,
                        digitalProduct: widget.product!.productType == "digital"),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(getTranslated('total_price', context)!, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(PriceConverter.convertPrice(context, priceWithQuantity),
                        style: titilliumBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Consumer<CartController>(
                      builder: (ctx, cartController, child) {
                        return CustomButtonWidget(
                        buttonHeight: 45,
                        btnTxt: getTranslated(stock! < widget.product!.minimumOrderQty! && widget.product!.productType == "physical"? 'out_of_stock':
                        isUpdate != -1 ? 'update_cart'  : 'add_to_cart', context),
                          onTap: stock < widget.product!.minimumOrderQty!  &&  widget.product!.productType == "physical" ? null : () async {
                            if(stock! >= widget.product!.minimumOrderQty!  || widget.product!.productType == "digital") {

                              String colorCode = '';
                              Map<String?, dynamic>? choice = {};

                              if (widget.product!.colors != null && widget.product!.colors!.isNotEmpty) {
                                colorCode = widget.product!.colors![productProvider.variantIndex!].code!;
                              }

                              for(int index=0; index < widget.product!.choiceOptions!.length; index++) {
                                choice.addAll({
                                  widget.product!.choiceOptions![index].name : widget.product!.choiceOptions![index].options![productProvider.variationIndex![index]]
                                });
                              }



                              Provider.of<OrderEditController>(context, listen: false).addToCart(
                                null,
                                orderEditCartModel: OrderEditCartModel(
                                  widget.product!.id,
                                  price,
                                  0,
                                  productProvider.quantity!,
                                  0,
                                  variationType,
                                  widget.product,
                                  null,
                                  false,
                                  colorCode,
                                  choice,
                                ),
                              );

                              Navigator.pop(context);

                              showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget(), barrierDismissible: false);
                              await Provider.of<OrderEditController>(context, listen: false).editOrderValidation(widget.orderId ?? 0);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(Get.context!).pop();
                              });


                            }
                          });
                      }
                    ),


                    const SizedBox(width: Dimensions.paddingSizeDefault),
                  ]);
                },
              );
            }
        ),
      ),
    ],
    );
  }


  int getIsExistInCart(List<OrderEditCartModel>? currentCartModel, Product product, String variantKey) {
    int index = -1;

    for (int i = 0; i < (currentCartModel?.length ?? 0); i++) {
      if(currentCartModel![i].product!.id == product.id && (variantKey == '')) {
        index = i;
        return i;
      } else if (currentCartModel[i].product!.id == product.id && (variantKey != ''))  {
        String cartVariantKey = getVariantKey(currentCartModel[i]);

        if (cartVariantKey == variantKey) {
          index = i;
          return index;
        }
      }
    }

    return index;
  }

  String getVariantKey(OrderEditCartModel cartModel) {
    String variantKey = '';

    if (cartModel.variant != null && cartModel.variant != '') {
      return cartModel.variant!;
    }
    return variantKey;
  }

}


class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final int? minimumOrderQuantity;
  final bool digitalProduct;
  final bool disable;

  const QuantityButton({super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    this.isCartWidget = false,required this.minimumOrderQuantity,required this.digitalProduct,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: disable ? null :  () {
        if (!isIncrement && quantity! > 1 ) {
          if(quantity! > minimumOrderQuantity! ) {
            Provider.of<OrderEditController>(context, listen: false).setQuantityBottomSheet(quantity! - 1, isUpdate: true);
          }else{

          }
        } else if (isIncrement && quantity! < stock! || digitalProduct) {
          Provider.of<OrderEditController>(context, listen: false).setQuantityBottomSheet(quantity! + 1, isUpdate: true);
        }
      },
      icon: Container(
        width: 40,height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
          color:  (isIncrement && quantity! >= stock! && !digitalProduct) ?
          Theme.of(context).hintColor : (!isIncrement && quantity ==1) ?
          Theme.of(context).hintColor :
          isIncrement ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.30),
        ),

        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: (quantity! >= stock! && !digitalProduct) ?
          Provider.of<ThemeController>(context).darkTheme ?
          Theme.of(context).cardColor.withValues(alpha: 0.50) :
          Theme.of(context).disabledColor :
          isIncrement ? Theme.of(context).cardColor :
          Theme.of(context).cardColor,

          size: isCartWidget ? 26: 20,
        ),
      ),
    );
  }
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
                bottomRight: Radius.circular(isLtr ? bottomRightBorderRadius ?? Dimensions.paddingSizeSmall : 0),
                topRight: Radius.circular(isLtr ? 0 : topLeftBorderRadius ?? Dimensions.paddingSizeSmall),
                bottomLeft: Radius.circular(isLtr ? 0 : topLeftBorderRadius ?? Dimensions.paddingSizeSmall),
                topLeft: Radius.circular(isLtr ? topLeftBorderRadius ?? Dimensions.paddingSizeSmall : 0),
              )
          ),
          child: Center(
              child: Directionality(textDirection: TextDirection.ltr,
                child: Text(
                  productModel.clearanceSale != null ?
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.clearanceSale?.discountAmount, productModel.clearanceSale?.discountType) :
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.discount, productModel.discountType),
                  style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                ),
              )
          ),
        )
    );
  }
}

class ColorSelectionWidget extends StatefulWidget {
  final Product product;
  final OrderEditController detailsController;
  const ColorSelectionWidget({super.key, required this.product, required this.detailsController});

  @override
  State<ColorSelectionWidget> createState() => _ColorSelectionWidgetState();
}

class _ColorSelectionWidgetState extends State<ColorSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${getTranslated('color', context)} ',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.titleMedium?.color)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Expanded(
            child: GridView.builder(
              itemCount: widget.product.colors!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // expand instead of scroll
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // 6 colors per row
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1, // square cells
              ),
              itemBuilder: (ctx, index) {
                String colorString = '0xff${widget.product.colors![index].code!.substring(1, 7)}';
                return InkWell(
                  onTap: () {
                    Provider.of<OrderEditController>(context, listen: false).setCartVariantIndex(widget.product.minimumOrderQty, index, context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(1), // smaller padding
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: widget.detailsController.variantIndex == index
                      ? Border.all(
                        width: 2, // smaller border
                        color: Theme.of(context).primaryColor,
                      )
                          : Border.all(
                        width: 2,
                        color: Theme.of(context).hintColor.withAlpha(60),
                      ),
                    ),
                    child: Container(
                      height: 25, // smaller circle
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(int.parse(colorString)),
                      ),
                    ),
                  ),
                );
              },
            ),
          )

        ])
    );
  }
}