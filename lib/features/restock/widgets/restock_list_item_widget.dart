import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/features/restock/domain/models/restock_product_model.dart';
import 'package:sixvalley_vendor_app/features/restock/widgets/quantity_update_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/restock/widgets/restock_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class RestockListItemWidget extends StatefulWidget {
  final Product? product;
  final double? ratting;
  final Data? data;
  final int index;
  const RestockListItemWidget({super.key, this.product, this.ratting, this.data, required this.index});

  @override
  State<RestockListItemWidget> createState() => _RestockListItemWidgetState();
}

class _RestockListItemWidgetState extends State<RestockListItemWidget> {
  late TextEditingController? _stockQuantityController;

  @override
  void initState() {
    _stockQuantityController = TextEditingController(text: widget.product?.currentStock.toString() ?? '0');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 55, width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImageWidget(image: widget.product?.thumbnailFullUrl?.path ?? '', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product?.name ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),

                      Consumer<RestockController>(
                        builder: (context, restockProvider, _) {
                          return InkWell(
                            onTap: () async {
                              showDialog(context: context, builder: (ctx) => const CustomLoaderWidget());
                              await restockProvider.deleteRestockListItem(widget.data!.id!, widget.index);
                              Navigator.of(Get.context!).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 0),
                              child: Icon(Icons.close, size: 20, color: Theme.of(context).hintColor),
                            ),
                          );
                        }
                      ),
                    ],
                  ),

                  Text(
                    PriceConverter.convertPrice(context, widget.product?.unitPrice, discountType: widget.product?.discountType, discount: widget.product?.discount),
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor // Blue Color
                    ),
                  ),

                  Row(
                    children: [
                      if(widget.data?.variant != null && widget.data!.variant!.isNotEmpty) ...[
                        Text(
                          widget.data?.variant ?? '',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
                        ),

                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          '|',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                      ],

                      Text(
                        '${getTranslated('total_request', context)} : ',
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall),
                      ),
                      Text(
                        '${widget.data?.restockProductCustomersCount ?? 0}',
                        style: robotoBold.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontSize: Dimensions.fontSizeDefault), // Green Color
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          '${getTranslated('last_request', context)} : ${DateConverter.isoStringToLocalDateAndTime(widget.data!.updatedAt!)}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Consumer<RestockController>(
                          builder: (context, restockProvider, _) {
                            return Consumer<AddProductController>(
                                builder: (context, productProvider, _) {
                                  return Consumer<VariationController>(
                                      builder: (context, variationController, _) {
                                        return InkWell(
                                          onTap: () {
                                            if (widget.product!.variation != null && widget.product!.variation!.isNotEmpty) {
                                              _stockQuantityController!.text = widget.product?.currentStock.toString() ?? '0';
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (con) => RestockSheetWidget(
                                                  stockQuantityController: _stockQuantityController,
                                                  product: widget.product,
                                                  title: getTranslated('product_variations', context),
                                                  variantKeys: widget.data?.variantKeys ?? [],
                                                  onYesPressed: () {
                                                    bool isEmpty = false;
                                                    if(variationController.variantTypeList.isNotEmpty){
                                                      for (int i=0; i< variationController.variantTypeList.length; i++) {
                                                        if(variationController.variantTypeList[i].qtyController.text == '' && !isEmpty) {
                                                          isEmpty = true;
                                                        }
                                                      }
                                                    }
                                                    if(isEmpty) {
                                                      showCustomSnackBarWidget('variation_quantity_is_required', sanckBarType: SnackBarType.error, context);
                                                    } else if(_stockQuantityController!.text.toString().isEmpty){
                                                      showCustomSnackBarWidget('product_quantity_is_required', context);
                                                    } else {
                                                      restockProvider.updateRestockProductQuantity(context, widget.product?.id, int.parse(_stockQuantityController!.text.toString()), widget.product!.variation!, index: widget.index);
                                                    }
                                                  }
                                                ),
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return QuantityUpdateDialogWidget (
                                                      stockQuantityController: _stockQuantityController,
                                                      product: widget.product,
                                                      title: getTranslated('product_variations', context),
                                                      onYesPressed: () {
                                                        if(_stockQuantityController!.text.toString().isEmpty){
                                                          showCustomSnackBarWidget('product_quantity_is_required', context);
                                                        } else {
                                                          productProvider.updateRestockProductQuantity(context, widget.product?.id, int.parse(_stockQuantityController!.text.toString()), widget.product!.variation!, index: widget.index);
                                                        }
                                                      }
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 32, width: 32,
                                            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                              border: Border.all(color: Theme.of(context).primaryColor),
                                              color: Theme.of(context).cardColor
                                            ),
                                            child: Image.asset(Images.updateQuantityIcon, color: Theme.of(context).primaryColor),
                                          ),
                                        );
                                      }
                                  );
                                }
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
}
