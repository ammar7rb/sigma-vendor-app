import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AddressWidget extends StatelessWidget {
  final AuctionAddressInfo? shippingAddress;
  final AuctionAddressInfo? billingAddress;
  final VoidCallback? onShowOnMap;
  final VoidCallback? onEditShipping;
  final VoidCallback? onEditBilling;
  final bool? isSameBilling;

  const AddressWidget({
    super.key,
    this.shippingAddress,
    this.billingAddress,
    this.onShowOnMap,
    this.onEditShipping,
    this.onEditBilling,
    this.isSameBilling,
  });

  bool get _isSameAddress => isSameBilling ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // boxShadow: [BoxShadow(color: theme.hintColor.withValues(alpha: 0.2), spreadRadius: 1.5, blurRadius: 3)],
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated('address', context) ?? '',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: theme.textTheme.bodyLarge?.color),
                ),
                GestureDetector(
                  onTap: onShowOnMap,
                  child: Row(
                    children: [
                      Text(
                        getTranslated('show_on_map', context) ?? '',
                        style: robotoRegular.copyWith(color: theme.colorScheme.primary, fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Icon(Icons.location_on, color: theme.colorScheme.primary, size: Dimensions.iconSizeDefault),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Divider(thickness: 0.2, height: 1, color: theme.hintColor.withValues(alpha: 0.65)),

          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeSmall,
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated('shipping_address', context) ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color),
                    ),
                    if (onEditShipping != null)
                      InkWell(
                        onTap: onEditShipping,
                        child: SizedBox(width: 20, child: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if (shippingAddress != null)
                  _AddressDetails(address: shippingAddress!),

                Divider(thickness: 0.25, color: theme.colorScheme.primary.withValues(alpha: 0.5)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated('billing_address', context) ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color),
                    ),
                    if (!_isSameAddress && onEditBilling != null)
                      InkWell(
                        onTap: onEditBilling,
                        child: SizedBox(width: 20, child: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if (_isSameAddress)
                  const _SameAddressTag()
                else
                  _AddressDetails(address: billingAddress!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressDetails extends StatelessWidget {
  final AuctionAddressInfo address;

  const _AddressDetails({required this.address});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _InfoTile(icon: Icons.person, value: address.contactPersonName ?? '', isBold: true)),
          Expanded(child: _InfoTile(icon: Icons.call, value: address.phone ?? '')),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(children: [
          Expanded(child: _InfoTile(imageIcon: Images.countryIconAddress, value: address.country ?? '')),
          Expanded(child: _InfoTile(imageIcon: Images.cityIconAddress, value: address.city ?? '')),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(children: [
          Expanded(child: _InfoTile(imageIcon: Images.zipIconAddress, value: address.zip ?? '')),
          if (address.email != null && address.email!.isNotEmpty)
            Expanded(child: _InfoTile(icon: Icons.email_outlined, value: address.email!))
          else
            const Expanded(child: SizedBox()),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: theme.hintColor.withValues(alpha: 0.5), size: 25),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  address.address ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData? icon;
  final String? imageIcon;
  final String value;
  final bool isBold;

  const _InfoTile({this.icon, this.imageIcon, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageIcon != null)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: 20,
              child: Image.asset(imageIcon!, color: theme.hintColor.withValues(alpha: 0.5), height: 25, width: 25),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Icon(icon, color: theme.hintColor.withValues(alpha: 0.5), size: 20),
          ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: isBold
                ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color)
                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color),
          ),
        ),
      ],
    );
  }
}

class _SameAddressTag extends StatelessWidget {
  const _SameAddressTag();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: theme.hintColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            getTranslated('same_as_shipping_address', context) ?? '',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }
}
