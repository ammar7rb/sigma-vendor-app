import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class BottomCartWidget extends StatefulWidget {
  final ProductDetails? product;
  const BottomCartWidget({super.key, required this.product});

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget> {
  bool vacationIsOn = false;
  bool temporaryClose = false;

  @override
  void initState() {
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    return Container(height: 70,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          boxShadow: [BoxShadow(color: Theme.of(context).hintColor, blurRadius: .5, spreadRadius: .1)]),
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Stack(children: [
              InkWell(
                onTap: () {

                },
                child: Image.asset(Images.arrow, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              Positioned.fill(
                  child: Container(
                    transform: Matrix4.translationValues(10, -3, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Consumer<CartController>(builder: (context, cart, child) {
                        return Container(height: 20, width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).textTheme.bodyMedium?.color),
                          child: Center(
                            child: Text(cart.cartList.length.toString(),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                    color:Theme.of(context).highlightColor)),
                          ),
                        );}),
                    ),
                  ))])),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Expanded(child: InkWell(onTap: () {
          if(vacationIsOn || temporaryClose ) {
            showCustomSnackBarWidget(getTranslated('this_shop_is_close_now', context), context, sanckBarType: SnackBarType.error);
          }else{
            // showModalBottomSheet(context: context, isScrollControlled: true,
            //   backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0),
            //   builder: (con) => CartBottomSheetWidget(product: widget.product , callback: (){
            //     showCustomSnackBarWidget(getTranslated('added_to_cart', context), context, sanckBarType: SnackBarType.success);
            //   },)
            // );
          }},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor),
            child: Text(getTranslated('add_to_cart', context)!,
              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                Theme.of(context).hintColor : Theme.of(context).highlightColor)
            ),
          ),

        )),
      ]),
    );
  }
}
