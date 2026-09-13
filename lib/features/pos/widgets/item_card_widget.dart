import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/cart_model.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';

class ItemCartWidget extends StatefulWidget {
  final CartModel? cartModel;
  final int? index;
  final void Function() onChanged;
  const ItemCartWidget({super.key, this.cartModel, this.index, required this.onChanged});

  @override
  State<ItemCartWidget> createState() => _ItemCartWidgetState();
}

class _ItemCartWidgetState extends State<ItemCartWidget> {
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    double? price;
    if (widget.cartModel?.variation != null) {
      price = widget.cartModel?.variation?.price;
    } else if (widget.cartModel?.varientKey != null) {
      price = widget.cartModel?.digitalVariationPrice;
    } else {
      price = widget.cartModel?.price;
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (DismissDirection direction) {
          Provider.of<CartController>(context, listen: false).removeFromCart(widget.index!);
          widget.onChanged();
          Provider.of<CartController>(context, listen: false).getTaxAmount();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            // borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
              )
            ]
          ),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
                        Expanded(
                          child: Text(
                            '${widget.cartModel!.product!.name}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Provider.of<CartController>(context, listen: false).removeFromCart(widget.index!);
                            widget.onChanged();
                            Provider.of<CartController>(context, listen: false).getTaxAmount();
                          },
                          child: Icon(Icons.close, size: 20, color: Theme.of(context).hintColor),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),


                    Text(
                      PriceConverter.convertPrice(context, price!),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        // Text(
                        //   getTranslated('tax_included', context) ?? 'Tax Included',
                        //   style: robotoRegular.copyWith(
                        //       fontSize: Dimensions.fontSizeSmall,
                        //       color: Theme.of(context).hintColor
                        //   ),
                        // ),

                        Consumer<CartController>(
                          builder: (context, cartController, _) {
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    cartController.setQuantity(context, false, widget.index, showToaster: true);
                                    widget.onChanged();
                                    _debounce.run(() => cartController.getTaxAmount());
                                  },
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).cardColor,
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
                                  onTap: () {
                                    cartController.setQuantity(context, true, widget.index, showToaster: true);
                                    widget.onChanged();
                                    _debounce.run(() => cartController.getTaxAmount());
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
      ),
    );
  }
}
