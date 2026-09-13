import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerContactWidget extends StatefulWidget {
  final Order? orderModel;
  const CustomerContactWidget({super.key, this.orderModel});

  @override
  State<CustomerContactWidget> createState() => _CustomerContactWidgetState();
}

class _CustomerContactWidgetState extends State<CustomerContactWidget> {
  @override
  Widget build(BuildContext context) {
    String? phone = widget.orderModel!.isGuest!
        ? '${widget.orderModel!.shippingAddressData != null ? widget.orderModel!.shippingAddressData?.phone : '${widget.orderModel?.billingAddressData?.phone}'}'
        : '${widget.orderModel!.customer?.phone}';

    String? email = widget.orderModel!.isGuest!
        ? '${widget.orderModel!.shippingAddressData != null ? widget.orderModel!.shippingAddressData?.email : '${widget.orderModel?.billingAddressData?.email}'}'
        : '${widget.orderModel!.customer?.email}';

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              spreadRadius: 1.5,
              blurRadius: 3)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall),
          child: Row(
            children: [
              widget.orderModel!.isGuest!
                  ? Text(
                      '${getTranslated('customer_info', context)} (${getTranslated('guest_customer', context)})',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color))
                  : Text('${getTranslated('customer_info', context)}',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ),
        Divider(
            thickness: 0.2,
            height: 1,
            color: Theme.of(context).hintColor.withValues(alpha: .65)),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CustomImageWidget(
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      image:
                          '${widget.orderModel?.customer?.imageFullPath?.path}')),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        widget.orderModel!.isGuest!
                            ? '${widget.orderModel!.shippingAddressData != null ? widget.orderModel!.shippingAddressData?.contactPersonName : '${widget.orderModel?.billingAddressData?.contactPersonName}'}'
                            : '${widget.orderModel!.customer?.fName ?? ''} '
                                '${widget.orderModel!.customer?.lName ?? ''}',
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (widget.orderModel?.customerId != 0)
                      Flexible(
                        child: Text(
                            widget.orderModel!.isGuest!
                                ? widget.orderModel!.shippingAddressData != null
                                    ? '${widget.orderModel!.shippingAddressData?.city}, ${widget.orderModel!.shippingAddressData?.country}'
                                    : '${widget.orderModel?.billingAddressData?.city}, ${widget.orderModel?.billingAddressData?.country}'
                                : '',
                            style: titilliumRegular.copyWith(
                                color: ColorHelper.blendColors(
                                    Colors.white,
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!,
                                    0.7),
                                fontSize: Dimensions.fontSizeDefault),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              if (widget.orderModel?.customerId != 0)
                InkWell(
                    onTap: () {
                      if (email.isNotEmpty) {
                        sendEmail(email);
                      }
                    },
                    child: CustomAssetImageWidget(Images.email,
                        height: 30, width: 30)),
              if (widget.orderModel?.customerId != 0)
                const SizedBox(width: Dimensions.paddingSizeLarge),
              if (widget.orderModel?.customerId != 0)
                InkWell(
                    onTap: () {
                      if (phone.isNotEmpty) {
                        callPhone(phone);
                      }
                    },
                    child: CustomAssetImageWidget(Images.customerCallIcon,
                        height: 30, width: 30)),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> sendEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Support&body='),
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> callPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
