import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/domain/models/coupon_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/coupon/controllers/coupon_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/screens/add_new_coupon_screen.dart';

class CouponCardWidget extends StatefulWidget {
  final Coupons? coupons;
  final int? index;
  const CouponCardWidget({super.key, this.coupons, this.index});

  @override
  State<CouponCardWidget> createState() => _CouponCardWidgetState();
}

class _CouponCardWidgetState extends State<CouponCardWidget> {

  @override
  Widget build(BuildContext context) {
    bool adminCoupon = false;
    if ((widget.coupons!.addedBy == 'seller' || (widget.coupons!.addedBy == 'admin' && widget.coupons!.couponBearer == 'seller' &&
       widget.coupons!.sellerId == Provider.of<ProfileController>(context, listen: false).userId))) {
      adminCoupon = false;
    } else {
      adminCoupon = true;
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2)
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
                      Image.asset(Images.couponIcon, width: 20, height: 20),
                      SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Text(widget.coupons!.title ?? '',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Consumer<CouponController>(
                        builder: (context, couponProvider, _) {
                          return SizedBox(
                            height: 25, width: 25,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                              icon: Icon(Icons.more_vert, size: 20, color: Theme.of(context).hintColor),
                              onSelected: (String result) async {
                                if (result == 'delete') {
                                  if(!adminCoupon) {
                                    showDialog(context: context, builder: (ctx) => const CustomLoaderWidget());
                                    await Provider.of<CouponController>(context, listen: false).deleteCoupon(context, widget.coupons!.id);
                                    Navigator.of(Get.context!).pop();
                                  } else {
                                    showCustomSnackBarWidget(getTranslated('coupon_tooltip', context), context);
                                  }
                                } else if (result == 'edit') {
                                  if(!adminCoupon) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddNewCouponScreen(coupons: widget.coupons)));
                                  } else {
                                    showCustomSnackBarWidget(getTranslated('coupon_tooltip', context), context);
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'status',
                                  enabled: false,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (adminCoupon) {
                                        showCustomSnackBarWidget(getTranslated('coupon_tooltip', context), context);
                                      } else {
                                        couponProvider.updateCouponStatus(context, widget.coupons!.id, widget.coupons!.status == 1 ? 0 : 1, widget.index);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(getTranslated('statuss', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                        SizedBox(width: Dimensions.paddingSizeExtraLarge),

                                        FlutterSwitch(
                                          width: 40.0, height: 20.0, toggleSize: 18.0, padding: 2.0,
                                          value: widget.coupons!.status == 1,
                                          activeColor: Theme.of(context).primaryColor,
                                          onToggle: (bool isActive) {
                                            Navigator.pop(context);
                                            if (adminCoupon) {
                                              showCustomSnackBarWidget(getTranslated('coupon_tooltip', context), context);
                                            } else {
                                              couponProvider.updateCouponStatus(context, widget.coupons!.id, isActive ? 1 : 0, widget.index);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Opacity(
                                    opacity: adminCoupon ? 0.5 : 1,
                                    child: Row(
                                      children: [
                                        Image.asset(Images.editCouponIcon, width: 20, height: 20, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        Text(getTranslated('edit', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                      ],
                                    ),
                                  ),
                                ),

                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Opacity(
                                    opacity: adminCoupon ? 0.5 : 1,
                                    child: Row(
                                      children: [
                                        Image.asset(Images.deleteCouponIcon, width: 20, height: 20, color: Theme.of(context).colorScheme.error),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        Text(getTranslated('delete', context)!, style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),


                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    children: [
                      Text(widget.coupons!.couponType == 'free_delivery' ? ""
                        : widget.coupons!.discountType == 'percentage'
                        ? '${widget.coupons!.discount}% ${getTranslated('off', context)}'
                        : '\$${widget.coupons!.discount} ${getTranslated('off', context)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),


                      if(widget.coupons!.couponType != 'free_delivery')...[
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Container(height: 12, width: 1, color: Theme.of(context).textTheme.headlineLarge?.color),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      ],

                      Text(
                        widget.coupons!.couponType == 'free_delivery'
                          ? getTranslated('free_delivery', context)!
                          : '${getTranslated('discount_on_purchase', context)}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.headlineLarge?.color
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Container(height: 12, width: 1, color: Theme.of(context).hintColor),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Expanded(
                        child: Text(
                          '${getTranslated('limit_for', context)} ${widget.coupons!.limit} ${getTranslated('user', context)}',
                          style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.headlineLarge?.color
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateConverter.localDateToIsoStringDate(DateTime.parse(widget.coupons!.startDate!))} - ${DateConverter.localDateToIsoStringDate(DateTime.parse(widget.coupons!.expireDate!))}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                           color: Theme.of(context).textTheme.headlineLarge?.color
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.coupons!.code ?? ''));
                          showCustomSnackBarWidget(getTranslated('coupon_code_copied', context), context, isError: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Row(
                            children: [
                              Text(widget.coupons!.code ?? '',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              CustomAssetImageWidget(Images.copyIcon, height: 16, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
