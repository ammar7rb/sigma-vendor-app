import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/order_edit/controllers/order_edit_controller.dart';
import 'package:sixvalley_vendor_app/features/order_edit/domain/models/order_edit_cart_model.dart';
import 'package:sixvalley_vendor_app/features/order_edit/widgets/cart_item_widget.dart';
import 'package:sixvalley_vendor_app/features/order_edit/widgets/edit_product_search_suggestion.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../main.dart';

class EditProductScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetails;
  const EditProductScreen({super.key, required this.orderDetails});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  @override
  void initState() {
    Provider.of<OrderEditController>(Get.context!, listen: false).setProductToCart(widget.orderDetails);
    Provider.of<OrderEditController>(Get.context!, listen: false).editOrderValidation(widget.orderDetails[0].orderId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  PreferredSize(
        preferredSize: const Size(double.maxFinite, 50),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0) :
            Theme.of(context).primaryColor.withValues(alpha:.10),
              offset: const Offset(0, 2.0), blurRadius: 4.0,
            )
          ]),

          child: AppBar(
            surfaceTintColor: Theme.of(context).cardColor,
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(getTranslated('edit_product', context)!,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                ),

                Text("${getTranslated('order', context)!} #${widget.orderDetails[0].orderId}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),
              ],
            ),
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: Dimensions.iconSizeDefault),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () => Navigator.pop(context)
            ),
          ),
        ),
      ),




      body: Consumer<OrderEditController>(
        builder:(context, orderEditController, child){
          return Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    EditProductSearchSuggestion(id: widget.orderDetails[0].orderId),

                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),
                      child: Row(
                        children: [
                          CustomAssetImageWidget(Images.infoIcon, height: 15, width: 15),
                          SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Text(getTranslated('after_editing_the_price_will_be_updated_to_the_latest', context)!,
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                            ),
                          )
                        ],
                      ),
                    ),


                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Row(
                        children: [
                          Text(
                            getTranslated('products_list', context)!,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color
                            ),
                          ),
                          SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Container(
                            padding:  EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).hintColor.withValues(alpha: 0.5)
                            ),
                            child: Text(
                              '${orderEditController.cartList.length}',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ListView.builder(
                      reverse: false,
                      itemCount: orderEditController.cartList.length,
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ItemCartWidget(
                          orderId: widget.orderDetails[0].orderId,
                          cartModel: orderEditController.cartList[index],
                          index: index,
                          onChanged: () {

                          },
                        );
                      },
                    ),
                  ]),
                )
              ),

              Opacity(
                opacity: 1.0,
                child: AbsorbPointer(
                  absorbing: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)
                      ],
                    ),
                    height: 100,
                    child:  Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  getTranslated('total_amount_text', context)!,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color
                                  )
                                ),
                                SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  getTranslated('vat_tax_others', context)!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).textTheme.bodyLarge?.color
                                  )
                                ),
                              ],
                            ),

                            Text(
                              PriceConverter.convertPrice(context, orderEditController.orderAmount),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(children: [
                          Expanded(child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: CustomButtonWidget(
                              isColor: true,
                              btnTxt: '${getTranslated('cancel', context)}',
                              backgroundColor: Theme.of(context).cardColor,
                              fontColor: Theme.of(context).colorScheme.error,
                              borderColor: Theme.of(context).colorScheme.error,
                            ),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: orderEditController.isUpdateCartLoading ?
                            const Center(
                              child: SizedBox(
                                height:  30, width: 30,
                                child: CircularProgressIndicator(),
                              ),
                            ) : CustomButtonWidget(
                              btnTxt:  getTranslated('update_cart', context),
                              onTap: orderEditController.isLoading ? null : () {
                                List<dynamic> cartList = [];

                                for(OrderEditCartModel order in orderEditController.cartList) {
                                  cartList.add(order.toJson());
                                }

                                orderEditController.editOrderSubmit(
                                  {'order_id' : widget.orderDetails[0].orderId.toString(), 'products' : jsonEncode(cartList)}
                                ).then((response) {
                                  if(response.response?.statusCode == 200) {
                                    Navigator.of(Get.context!).pop();
                                  }
                                });
                              },
                            )
                          ),


                        ]),

                      ],
                    ),

                  ),
                ),
              )

            ],
          );
        }
      ),
    );

  }
}
