import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/order_edit/controllers/order_edit_controller.dart';
import 'package:sixvalley_vendor_app/features/order_edit/domain/models/order_edit_cart_model.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../main.dart';
import '../../product/domain/models/product_model.dart';

class ItemCartWidget extends StatefulWidget {
  final OrderEditCartModel? cartModel;
  final int? index;
  final int? orderId;
  final void Function() onChanged;
  const ItemCartWidget({super.key, this.cartModel, this.index, required this.onChanged, this.orderId});

  @override
  State<ItemCartWidget> createState() => _ItemCartWidgetState();
}

class _ItemCartWidgetState extends State<ItemCartWidget> {
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);

  DigitalVariation? digitalVariation;
  Variation? variation;

  @override
  Widget build(BuildContext context) {

    if(widget.cartModel?.variant != null && widget.cartModel!.variant!.isNotEmpty && widget.cartModel!.product!.productType == 'digital') {
      for(DigitalVariation dv in widget.cartModel!.product!.digitalVariation ?? []) {
        if(dv.variantKey == widget.cartModel?.variant){
          digitalVariation = dv;
        }
      }
    }

    if (widget.cartModel!.product!.productType ==  'physical' && widget.cartModel!.product!.variation != null && widget.cartModel!.product!.variation!.isNotEmpty) {
      for(Variation v in widget.cartModel?.product?.variation ?? []) {
        if(v.type == widget.cartModel?.variant){
          variation = v;
        }
      }
    }


    double? price;
    price = widget.cartModel?.price;



    return IgnorePointer(
      ignoring: widget.cartModel?.product?.productType == 'digital' ? true : false,
      child: Opacity(
        opacity: widget.cartModel?.product?.productType == 'digital' ? 0.6 : 1,
        child: Stack(
          children: [
            Consumer<OrderEditController>(
              builder: (context, clearanceController, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall,
                    horizontal: Dimensions.paddingSizeSmall
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (widget.cartModel?.isOrderProduct ?? false) ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.6) : Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
                        )
                      ],
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50, width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImageWidget(
                              image: '${widget.cartModel!.product!.thumbnailFullUrl?.path}',
                              placeholder: Images.placeholderImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${widget.cartModel!.product!.name}',
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.bodyLarge?.color
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: Dimensions.paddingSizeExtraSmall)
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              (widget.cartModel?.variant  != null && widget.cartModel!.variant!.isNotEmpty) ?
                              Padding(padding: const EdgeInsets.only(top: 0.0),
                                child: Text(widget.cartModel?.variant ?? '',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,)
                               ),
                              ) : const SizedBox(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(PriceConverter.convertPrice(context, widget.cartModel?.price,
                                        discountType: (widget.cartModel?.product?.clearanceSale?.discountAmount ?? 0)  > 0
                                          ? widget.cartModel?.product?.clearanceSale?.discountType
                                          : widget.cartModel?.product?.discountType,
                                        discount: (widget.cartModel?.product?.clearanceSale?.discountAmount ?? 0)  > 0
                                          ? widget.cartModel?.product?.clearanceSale?.discountAmount
                                          : widget.cartModel?.product?.discount
                                        ),
                                        style: robotoBold.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                      ((widget.cartModel?.product?.discount ?? 0) > 0 || (widget.cartModel?.product?.clearanceSale?.discountAmount ?? 0) > 0) ?
                                      Text(
                                        PriceConverter.convertPrice(context, widget.cartModel?.price),
                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineMedium?.color,
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: Dimensions.fontSizeSmall
                                        ),
                                      ) : const SizedBox.shrink(),

                                    ],
                                  ),

                                  Consumer<CartController>(
                                    builder: (context, cartController, _) {
                                      return Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if(widget.cartModel?.product?.minimumOrderQty !=  null && widget.cartModel!.quantity! <= widget.cartModel!.product!.minimumOrderQty!) {
                                                showCustomSnackBarWidget('${getTranslated('minimum_order_quantity_is', context)!} ${widget.cartModel!.product!.minimumOrderQty}', context, sanckBarType: SnackBarType.error);
                                              } else if (widget.cartModel!.quantity! > 1) {
                                                clearanceController.setQuantity(widget.index!, widget.cartModel!.quantity! - 1);

                                                showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget());
                                                await clearanceController.editOrderValidation(widget.orderId ?? 0);
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  Navigator.of(Get.context!).pop();
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: widget.cartModel!.quantity! > 1 ? Theme.of(context).hintColor.withValues(alpha: 0.1) : Theme.of(context).hintColor.withValues(alpha: 0.5) ,
                                                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                                              ),
                                              child: Icon(Icons.remove, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                                            ),
                                          ),

                                          SizedBox(
                                            width: 30,
                                            child: Center(
                                              child: Text(
                                                widget.cartModel!.quantity.toString(),
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeLarge,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color
                                                )
                                              ),
                                            ),
                                          ),

                                          InkWell(

                                            onTap: () async {
                                              if(widget.cartModel!.product!.currentStock == widget.cartModel!.quantity) {
                                                showCustomSnackBarWidget(getTranslated('out_of_stock', context)!, context, sanckBarType: SnackBarType.error);
                                              } else {
                                                clearanceController.setQuantity(widget.index!, widget.cartModel!.quantity!+1);

                                                showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget(), barrierDismissible: false);
                                                await clearanceController.editOrderValidation(widget.orderId ?? 0);
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  Navigator.of(Get.context!).pop();
                                                });
                                              }
                                            },

                                            child: Container(
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                                            ),
                                          ),

                                        ],
                                      );
                                    }
                                  ),


                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),

            Positioned(
              top: 0, right: 2,
              child:  Consumer<OrderEditController>(
                builder:(context, orderEditController, child){
                  return InkWell(
                    onTap: () {
                      if(orderEditController.cartList.length == 1) {
                        showCustomSnackBarWidget(getTranslated('cannot_delete_all_product', context)!, context, sanckBarType: SnackBarType.error);
                      } else {
                        orderEditController.removeFormCart(widget.index!);
                      }
                    },
                    child: Container(
                      height: 25, width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).colorScheme.error, 0.1),
                        border: Border.all(color: Theme.of(context).cardColor, width: 2)
                      ),
                      child: Icon(Icons.close, size: 17, color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
              )
            ),


          ],
        ),
      ),
    );
  }
}