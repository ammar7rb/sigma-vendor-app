import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/order/screens/edit_address_screen.dart';
import 'package:sixvalley_vendor_app/features/order/widgets/icon_with_text_row_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/show_on_map_dialog_widget.dart';

// class ShippingAndBillingWidget extends StatelessWidget {
//   final Order? orderModel;
//   final bool? onlyDigital;
//   final String orderType;
//   const ShippingAndBillingWidget({super.key, this.orderModel, this.onlyDigital, required this.orderType});
//
//   @override
//   Widget build(BuildContext context) {
//     bool showEditButton = (orderModel?.orderStatus == 'out_for_delivery' || orderModel?.orderStatus == 'delivered' || orderModel?.orderStatus == 'returned');
//
//     return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(Images.mapBg), fit: BoxFit.cover)),
//       child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           if(!onlyDigital!)Container(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall).copyWith(bottom: 0),
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               boxShadow: ThemeShadow.getShadow(context),
//               borderRadius: BorderRadius.vertical(
//                 top : Radius.circular(Dimensions.paddingSizeSmall),
//                 bottom: (orderModel!.billingAddressData == null) ? Radius.circular(Dimensions.paddingSizeSmall) : Radius.circular(0) ,
//               )
//             ),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//
//                 Row(children: [
//                   SizedBox(width: 20, child: Image.asset(Images.shippingIcon)),
//                   Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//                       child: Text('${getTranslated('address_info', context)}'))
//                 ]),
//
//                 orderType != 'POS' || !onlyDigital!?
//                 Provider.of<SplashController>(context, listen: false).configModel!.mapApiStatus == 1 ?
//                 Consumer<OrderDetailsController>(
//                   builder:  (context, resProvider, child) {
//                     return GestureDetector(onTap: (){
//                       showDialog(context: context, builder: (_) {
//                         BillingAddressData billingAddressData = resProvider.getAddressForMap(orderModel!.shippingAddressData!, orderModel!.billingAddressData);
//                         Provider.of<OrderDetailsController>(context, listen: false).setMarker(billingAddressData);
//                         return  ShowOnMapDialogWidget(billingAddressData: billingAddressData);
//                       });
//                     },
//                       child: Row(children: [
//                         Text('${getTranslated('show_on_map', context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
//                         const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                         Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                             child: Image.asset(Images.showOnMap, width: Dimensions.iconSizeDefault)),
//                       ]),
//                     );
//                   }
//                 ) : const SizedBox() : const SizedBox(),
//               ]),
//               Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.30), thickness: 1),
//
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Text(getTranslated('shipping_address', context) ?? '', style: robotoMedium.copyWith(
//                   fontSize: Dimensions.fontSizeSmall,
//                   color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
//                 )),
//
//                 !showEditButton ?
//                 InkWell(onTap: (){
//                   Navigator.push(context, MaterialPageRoute(builder: (_)=>
//                       EditAddressScreen(isBilling: false,
//                         orderId: orderModel?.id.toString(),
//                         address: orderModel!.shippingAddressData?.address,
//                         city: orderModel!.shippingAddressData?.city,
//                         zip: orderModel!.shippingAddressData?.zip,
//                         name: orderModel!.shippingAddressData?.contactPersonName,
//                         number: orderModel!.shippingAddressData?.phone,
//                         email: orderModel!.shippingAddressData?.email,
//                         lat: orderModel!.shippingAddressData?.latitude??'0',
//                         lng: orderModel!.shippingAddressData?.longitude??'0',
//                       )));
//                 },
//                     child: SizedBox(width: 20, child: Image.asset(Images.edit,color: Theme.of(context).primaryColor,))) : const SizedBox(),
//               ]),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               if(orderModel!.shippingAddressData != null)
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.contactPersonName ?? '', icon: Icons.person)),
//
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.phone ?? '', icon: Icons.call)),
//                 ]),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.addressType ?? '', icon: Icons.home)),
//
//                 Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.country ?? '', icon: Icons.flag)),
//               ]),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.city ?? '', icon: Icons.location_city)),
//
//                 Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.zip ?? '', icon: Icons.keyboard)),
//               ]),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               if(orderModel!.shippingAddressData != null && orderModel!.shippingAddressData?.email != null)
//                 IconWithTextRowWidget(text: '${orderModel!.shippingAddressData?.email}',icon: Icons.email),
//
//               if(orderModel!.shippingAddressData != null && orderModel!.shippingAddressData?.email != null)
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               IconWithTextRowWidget(
//                   text: orderModel!.shippingAddressData?.address ?? '',
//                   icon: Icons.location_on,
//                   textColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
//               ),
//               if(orderModel!.billingAddressData != null ||!isBillingSameAsShipping())
//               Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.30), thickness: 1),
//
//               if(orderModel!.billingAddressData == null ||isBillingSameAsShipping())
//               SizedBox(height: Dimensions.paddingSizeSmall),
//
//             ]),
//           ),
//
//
//           if(orderModel!.billingAddressData != null || !isBillingSameAsShipping())
//           Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium).copyWith(top: 0),
//             decoration: BoxDecoration(color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.vertical(
//                   bottom : Radius.circular(Dimensions.paddingSizeSmall),
//                   top: (onlyDigital ?? false) ? Radius.circular(Dimensions.paddingSizeSmall) : Radius.circular(0),
//                 )),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               if(onlyDigital ?? false)
//                 SizedBox(height: Dimensions.paddingSizeSmall),
//               if(orderModel!.billingAddressData != null || !isBillingSameAsShipping())
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Text(getTranslated('billing_address', context)!, style: robotoMedium.copyWith(
//                   fontSize: Dimensions.fontSizeSmall,
//                   color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
//                 )),
//
//                 (orderModel!.billingAddressData != null && !showEditButton) ?
//                 InkWell(
//                   onTap: (){
//                     Navigator.push(context, MaterialPageRoute(builder: (_)=>
//                         EditAddressScreen(isBilling: true,
//                           orderId: orderModel?.id.toString(),
//                           address: orderModel!.billingAddressData?.address??'',
//                           city: orderModel!.billingAddressData?.city??'',
//                           zip: orderModel!.billingAddressData?.zip??'',
//                           name: orderModel!.billingAddressData?.contactPersonName??'',
//                           email: orderModel!.billingAddressData?.email??'',
//                           number: orderModel!.billingAddressData?.phone??'',
//                           lat: orderModel!.billingAddressData?.latitude??'0',
//                           lng: orderModel!.billingAddressData?.longitude??'0',
//                         )));
//                   },
//                   child: SizedBox(width: 20, child: Image.asset(Images.edit,color: Theme.of(context).primaryColor,)),
//                 ) : const SizedBox(),
//               ],
//               ),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//
//               if(!isBillingSameAsShipping())
//                 Container(
//                   width: double.maxFinite,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
//                     borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeExtraSmall),
//                   child: Text(getTranslated('same_as_shipping_address', context)!, style: robotoRegular.copyWith(
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                     fontSize: Dimensions.fontSizeSmall,
//                   )),
//                 )
//               else ...[
//                 if(orderModel!.billingAddressData != null)
//                 Row(children: [
//                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData != null ?
//                  orderModel!.billingAddressData?.contactPersonName?.trim()??''  : '',icon: Icons.person)),
//
//
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData != null ?
//                   orderModel!.billingAddressData?.phone?.trim()??''  : '',icon: Icons.call)),
//                 ]),
//                 if(orderModel!.billingAddressData != null)
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 if(orderModel!.billingAddressData != null)
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.addressType ?? '', icon: Icons.home)),
//
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.country ?? '', icon: Icons.flag)),
//                 ]),
//                 if(orderModel!.billingAddressData != null)
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 if(orderModel!.billingAddressData != null)
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.city ?? '', icon: Icons.location_city)),
//
//                   Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.zip ?? '', icon: Icons.keyboard)),
//                 ]),
//                 if(orderModel!.billingAddressData != null)
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 if(orderModel!.billingAddressData != null)
//                 if(orderModel!.billingAddressData?.email != null)
//                   IconWithTextRowWidget(text: orderModel!.billingAddressData?.email?? '' ,icon: Icons.email),
//
//                 if(orderModel!.billingAddressData != null)
//                   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 if(orderModel!.billingAddressData != null)
//                 IconWithTextRowWidget(
//                   text: orderModel!.billingAddressData != null
//                       ? orderModel!.billingAddressData?.address?.trim() ?? ''
//                       : '', icon: Icons.location_on,
//                   textColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
//                 ),
//               ],
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }

// bool isBillingSameAsShipping() {
//   return orderModel?.shippingAddressData?.contactPersonName != orderModel?.billingAddressData?.contactPersonName ||
//     orderModel?.shippingAddressData?.phone != orderModel?.billingAddressData?.phone ||
//     orderModel?.shippingAddressData?.addressType != orderModel?.billingAddressData?.addressType ||
//     orderModel?.shippingAddressData?.country != orderModel?.billingAddressData?.country ||
//     orderModel?.shippingAddressData?.city != orderModel?.billingAddressData?.city ||
//     orderModel?.shippingAddressData?.zip != orderModel?.billingAddressData?.zip ||
//     orderModel?.shippingAddressData?.email != orderModel?.billingAddressData?.email ||
//     orderModel?.shippingAddressData?.address != orderModel?.billingAddressData?.address;
// }
//}

class ShippingAndBillingWidget extends StatefulWidget {
  final Order? orderModel;
  final bool? onlyDigital;
  final String orderType;
  const ShippingAndBillingWidget(
      {super.key, this.orderModel, this.onlyDigital, required this.orderType});

  @override
  State<ShippingAndBillingWidget> createState() =>
      _ShippingAndBillingWidgetState();
}

class _ShippingAndBillingWidgetState extends State<ShippingAndBillingWidget> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    bool showEditButton =
        (widget.orderModel?.orderStatus == 'out_for_delivery' ||
            widget.orderModel?.orderStatus == 'delivered' ||
            widget.orderModel?.orderStatus == 'returned');

    return widget.orderModel?.orderType == 'POS'
        ? SizedBox()
        : CollapsibleAddressSection(
            onlyDigital: widget.onlyDigital,
            orderType: widget.orderType,
            orderModel: widget.orderModel,
            addressContent: Column(
              children: [
                Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.orderModel?.shippingAddressData != null &&
                                !(widget.onlyDigital ?? false)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              getTranslated(
                                                  'shipping_address', context)!,
                                              style: titilliumSemiBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color)),
                                          !showEditButton
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                EditAddressScreen(
                                                                  isBilling:
                                                                      false,
                                                                  orderId: widget
                                                                      .orderModel
                                                                      ?.id
                                                                      .toString(),
                                                                  address: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.address,
                                                                  city: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.city,
                                                                  zip: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.zip,
                                                                  name: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.contactPersonName,
                                                                  number: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.phone,
                                                                  email: widget
                                                                      .orderModel!
                                                                      .shippingAddressData
                                                                      ?.email,
                                                                  lat: widget
                                                                          .orderModel!
                                                                          .shippingAddressData
                                                                          ?.latitude ??
                                                                      '0',
                                                                  lng: widget
                                                                          .orderModel!
                                                                          .shippingAddressData
                                                                          ?.longitude ??
                                                                      '0',
                                                                )));
                                                  },
                                                  child: SizedBox(
                                                      width: 10,
                                                      child: Image.asset(
                                                        Images.edit,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      )))
                                              : const SizedBox(),
                                        ]),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: IconWithTextRowWidget(
                                            isBold: true,
                                            icon: Icons.person,
                                            text:
                                                '${widget.orderModel?.shippingAddressData != null ? widget.orderModel?.shippingAddressData!.contactPersonName : ''}',
                                          ),
                                        ),
                                        Expanded(
                                          child: IconWithTextRowWidget(
                                            icon: Icons.call,
                                            text:
                                                '${widget.orderModel?.shippingAddressData != null ? widget.orderModel?.shippingAddressData!.phone : ''}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Row(children: [
                                      Expanded(
                                          child: IconWithTextRowWidget(
                                        imageIcon: Images.homeIconAddress,
                                        text:
                                            '${widget.orderModel?.shippingAddressData?.addressType != null ? widget.orderModel?.shippingAddressData!.addressType : ''}',
                                        icon: null,
                                      )),
                                      Expanded(
                                          child: IconWithTextRowWidget(
                                        imageIcon: Images.countryIconAddress,
                                        text: widget
                                                    .orderModel
                                                    ?.shippingAddressData
                                                    ?.country
                                                    .toString()
                                                    .trim() ==
                                                'null'
                                            ? ''
                                            : widget
                                                    .orderModel
                                                    ?.shippingAddressData
                                                    ?.country ??
                                                '',
                                        icon: null,
                                      ))
                                    ]),
                                    if (widget.orderModel?.shippingAddressData
                                                ?.country !=
                                            null ||
                                        widget.orderModel?.shippingAddressData
                                                ?.addressType !=
                                            null)
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                    Row(children: [
                                      Expanded(
                                          child: IconWithTextRowWidget(
                                              imageIcon: Images.cityIconAddress,
                                              icon: Icons.location_city,
                                              text:
                                                  '${widget.orderModel?.shippingAddressData?.city != null ? widget.orderModel?.shippingAddressData!.city : ''}')),
                                      Expanded(
                                          child: IconWithTextRowWidget(
                                              imageIcon: Images.zipIconAddress,
                                              icon: Icons.location_city,
                                              text: widget
                                                      .orderModel
                                                      ?.shippingAddressData
                                                      ?.zip ??
                                                  ''))
                                    ]),
                                    if (widget.orderModel?.shippingAddressData
                                                ?.city !=
                                            null ||
                                        widget.orderModel?.shippingAddressData
                                                ?.zip !=
                                            null)
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on,
                                              color:
                                                  Provider.of<ThemeController>(
                                                              context,
                                                              listen: false)
                                                          .darkTheme
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .hintColor
                                                          .withValues(
                                                              alpha: 0.5),
                                              size: 25),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Expanded(
                                              child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 1),
                                                  child: Text(
                                                      '${widget.orderModel?.shippingAddressData != null ? widget.orderModel?.shippingAddressData!.address : ''}',
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: titilliumRegular
                                                          .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color))))
                                        ]),
                                  ])
                            : const SizedBox(),
                        if (widget.orderModel?.billingAddressData != null &&
                            widget.orderModel?.shippingAddressData != null &&
                            widget.orderModel?.shippingAddressData
                                    ?.contactPersonName !=
                                null &&
                            widget.orderModel!.shippingAddressData!
                                .contactPersonName!
                                .trim()
                                .isNotEmpty)
                          Divider(
                              thickness: .25,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.50)),
                        widget.orderModel?.billingAddressData != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              getTranslated(
                                                  'billing_address', context)!,
                                              style: titilliumSemiBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color)),
                                          (widget.orderModel!
                                                          .billingAddressData !=
                                                      null &&
                                                  !showEditButton)
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                EditAddressScreen(
                                                                  isBilling:
                                                                      true,
                                                                  orderId: widget
                                                                      .orderModel
                                                                      ?.id
                                                                      .toString(),
                                                                  address: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.address ??
                                                                      '',
                                                                  city: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.city ??
                                                                      '',
                                                                  zip: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.zip ??
                                                                      '',
                                                                  name: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.contactPersonName ??
                                                                      '',
                                                                  email: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.email ??
                                                                      '',
                                                                  number: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.phone ??
                                                                      '',
                                                                  lat: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.latitude ??
                                                                      '0',
                                                                  lng: widget
                                                                          .orderModel!
                                                                          .billingAddressData
                                                                          ?.longitude ??
                                                                      '0',
                                                                )));
                                                  },
                                                  child: SizedBox(
                                                      width: 10,
                                                      child: Image.asset(
                                                        Images.edit,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      )),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      if (widget.orderModel?.shippingAddressData
                                              ?.id ==
                                          widget.orderModel?.billingAddressData
                                              ?.id) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withValues(alpha: 0.10),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                  getTranslated(
                                                      'same_as_shipping_address',
                                                      context)!,
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color))
                                            ],
                                          ),
                                        )
                                      ],
                                      if (widget.orderModel?.shippingAddressData
                                              ?.id !=
                                          widget.orderModel?.billingAddressData
                                              ?.id) ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: IconWithTextRowWidget(
                                                  isBold: true,
                                                  icon: Icons.person,
                                                  text:
                                                      '${widget.orderModel?.billingAddressData != null ? widget.orderModel?.billingAddressData!.contactPersonName : ''}'),
                                            ),
                                            Expanded(
                                              child: IconWithTextRowWidget(
                                                  icon: Icons.call,
                                                  text:
                                                      '${widget.orderModel?.billingAddressData != null ? widget.orderModel?.billingAddressData!.phone : ''}'),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Row(children: [
                                          Expanded(
                                              child: IconWithTextRowWidget(
                                            imageIcon: Images.homeIconAddress,
                                            text:
                                                '${widget.orderModel?.billingAddressData?.addressType != null ? widget.orderModel?.billingAddressData!.addressType : ''}',
                                            icon: null,
                                          )),
                                          Expanded(
                                              child: IconWithTextRowWidget(
                                            imageIcon:
                                                Images.countryIconAddress,
                                            text: widget
                                                    .orderModel!
                                                    .billingAddressData!
                                                    .country ??
                                                '',
                                            icon: null,
                                          ))
                                        ]),
                                        if (widget
                                                    .orderModel
                                                    ?.billingAddressData
                                                    ?.country !=
                                                null ||
                                            widget
                                                    .orderModel
                                                    ?.billingAddressData
                                                    ?.addressType !=
                                                null)
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                        Row(children: [
                                          Expanded(
                                              child: IconWithTextRowWidget(
                                                  imageIcon:
                                                      Images.cityIconAddress,
                                                  icon: Icons.location_city,
                                                  text:
                                                      '${widget.orderModel?.billingAddressData?.city != null ? widget.orderModel?.billingAddressData!.city : ''}')),
                                          Expanded(
                                              child: IconWithTextRowWidget(
                                            imageIcon: Images.zipIconAddress,
                                            icon: Icons.location_city,
                                            text: widget.orderModel
                                                    ?.billingAddressData?.zip ??
                                                '',
                                          ))
                                        ]),
                                        if (widget
                                                    .orderModel
                                                    ?.billingAddressData
                                                    ?.city !=
                                                null ||
                                            widget.orderModel
                                                    ?.billingAddressData?.zip !=
                                                null)
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on,
                                                color:
                                                    Provider.of<ThemeController>(
                                                                context,
                                                                listen: false)
                                                            .darkTheme
                                                        ? Colors.white
                                                        : Theme.of(context)
                                                            .hintColor
                                                            .withValues(
                                                                alpha: 0.5)),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeSmall),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 1),
                                              child: Text(
                                                  ' ${widget.orderModel?.billingAddressData != null ? widget.orderModel?.billingAddressData!.address : ''}',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      titilliumRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color)),
                                            )),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                      ]
                                    ]),
                              )
                            : const SizedBox(),
                      ],
                    ))
              ],
            ),
          );
  }
}

class CollapsibleAddressSection extends StatefulWidget {
  final Widget addressContent;
  final bool? onlyDigital;
  final String orderType;
  final Order? orderModel;
  const CollapsibleAddressSection(
      {super.key,
      required this.addressContent,
      this.onlyDigital,
      required this.orderType,
      this.orderModel});

  @override
  State<CollapsibleAddressSection> createState() =>
      _CollapsibleAddressSectionState();
}

class _CollapsibleAddressSectionState extends State<CollapsibleAddressSection>
    with SingleTickerProviderStateMixin {
  bool isExpand = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              spreadRadius: 1.5,
              blurRadius: 3)
        ],
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Address',
                  style: robotoBold.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),

                widget.orderType != 'POS' || !widget.onlyDigital!
                    ? Provider.of<SplashController>(context, listen: false)
                                .configModel!
                                .mapApiStatus ==
                            1
                        ? Consumer<OrderDetailsController>(
                            builder: (context, resProvider, child) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      BillingAddressData billingAddressData =
                                          resProvider.getAddressForMap(
                                              widget.orderModel!
                                                  .shippingAddressData!,
                                              widget.orderModel!
                                                  .billingAddressData);
                                      Provider.of<OrderDetailsController>(
                                              context,
                                              listen: false)
                                          .setMarker(billingAddressData);
                                      return ShowOnMapDialogWidget(
                                          billingAddressData:
                                              billingAddressData);
                                    });
                              },
                              child: Row(children: [
                                Text('${getTranslated('show_on_map', context)}',
                                    style: robotoRegular.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeSmall)),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                    child: Image.asset(Images.showOnMap,
                                        width: Dimensions.iconSizeDefault)),
                              ]),
                            );
                          })
                        : const SizedBox()
                    : const SizedBox(),

                // InkWell(
                //   onTap: () {
                //     setState(() {
                //       isExpand = !isExpand;
                //     });
                //   },
                //   child: AnimatedRotation(
                //     turns: isExpand ? 0 : 0.5,
                //     duration: const Duration(milliseconds: 200),
                //     child: const Icon(Icons.keyboard_arrow_down),
                //   ),
                // ),
              ],
            ),
          ),

          Divider(
            thickness: 0.2,
            height: 1,
            color: Theme.of(context).hintColor.withValues(alpha: 0.65),
          ),

          // Smooth transition for expanded content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpand
                ? Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeSmall,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeDefault,
                    ),
                    child: widget.addressContent,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
