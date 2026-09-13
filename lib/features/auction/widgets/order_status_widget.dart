import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum AuctionDeliveryStatus {
  readyToDelivery('ready_to_delivery'),
  onTheWay('on_the_way'),
  delivered('delivered');

  final String label;
  const AuctionDeliveryStatus(this.label);

  static AuctionDeliveryStatus? fromLabel(String value) {
    final matches = AuctionDeliveryStatus.values.where(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
    );
    return matches.isEmpty ? null : matches.first;
  }

  String displayLabel(BuildContext context) {
    switch (this) {
      case AuctionDeliveryStatus.readyToDelivery:
        return getTranslated('ready_to_delivery', context) ?? 'Ready to Delivery';
      case AuctionDeliveryStatus.onTheWay:
        return getTranslated('on_the_way', context) ?? 'On the Way';
      case AuctionDeliveryStatus.delivered:
        return getTranslated('delivered', context) ?? 'Delivered';
    }
  }
}

class OrderStatusWidget extends StatelessWidget {
  final AuctionDeliveryStatus? selectedDeliveryStatus;
  final bool isPaid;
  final bool isPaymentEditable;
  final bool isPaymentStatusUpdating;
  final bool isDeliveryStatusUpdating;
  final ValueChanged<AuctionDeliveryStatus?> onDeliveryStatusChanged;
  final ValueChanged<bool> onPaymentStatusChanged;

  const OrderStatusWidget({
    super.key,
    required this.selectedDeliveryStatus,
    required this.isPaid,
    this.isPaymentEditable = false,
    this.isPaymentStatusUpdating = false,
    this.isDeliveryStatusUpdating = false,
    required this.onDeliveryStatusChanged,
    required this.onPaymentStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated('order', context) ?? 'Order',
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeMedium),
          Divider(height: 1, color: theme.hintColor.withValues(alpha: 0.30)),
          const SizedBox(height: Dimensions.paddingSizeMedium),

          Text(
            getTranslated('payment_status', context) ?? 'Payment Status',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _PaymentStatusRow(
            isPaid: isPaid,
            isEditable: isPaymentEditable,
            isLoading: isPaymentStatusUpdating,
            onChanged: onPaymentStatusChanged,
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            getTranslated('change_delivery_status', context) ?? 'Delivery Status',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          selectedDeliveryStatus == null
              ? _StartDeliveryButton(
                  isLoading: isDeliveryStatusUpdating,
                  onPressed: () => onDeliveryStatusChanged(AuctionDeliveryStatus.readyToDelivery),
                )
              : _DeliveryStatusDropdown(
                  selectedStatus: selectedDeliveryStatus!,
                  isLoading: isDeliveryStatusUpdating,
                  onChanged: onDeliveryStatusChanged,
                ),
        ],
      ),
    );
  }
}

class _DeliveryStatusDropdown extends StatelessWidget {
  final AuctionDeliveryStatus selectedStatus;
  final bool isLoading;
  final ValueChanged<AuctionDeliveryStatus?> onChanged;

  const _DeliveryStatusDropdown({
    required this.selectedStatus,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.hintColor.withValues(alpha: 0.40)),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: theme.cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: isLoading
          ? const SizedBox(
              height: 50,
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<AuctionDeliveryStatus>(
                value: selectedStatus,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.textTheme.bodyLarge?.color,
                  size: Dimensions.iconSizeDefault,
                ),
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                onChanged: onChanged,
                items: AuctionDeliveryStatus.values
                    .map((s) => DropdownMenuItem<AuctionDeliveryStatus>(
                          value: s,
                          child: Text(s.displayLabel(context)),
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class _StartDeliveryButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _StartDeliveryButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
              )
            : Text(
                getTranslated('ready_to_delivery', context) ?? 'Ready to Delivery',
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.colorScheme.primary,
                ),
              ),
      ),
    );
  }
}

class _PaymentStatusRow extends StatelessWidget {
  final bool isPaid;
  final bool isEditable;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _PaymentStatusRow({
    required this.isPaid,
    this.isEditable = false,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.hintColor.withValues(alpha: 0.40)),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: isEditable ? theme.cardColor : theme.hintColor.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeVeryTiny,
      ),
      child: Row(
        children: [
          Text(
            isPaid
                ? getTranslated('paid', context) ?? 'Paid'
                : getTranslated('unpaid', context) ?? 'Unpaid',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isPaid ? theme.colorScheme.onTertiaryContainer : theme.hintColor,
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: isLoading ? 0.35 : 1.0,
            child: Switch(
              value: isPaid,
              onChanged: (isLoading || !isEditable) ? null : onChanged,
              activeThumbColor: theme.cardColor,
              activeTrackColor: theme.colorScheme.primary,
              inactiveThumbColor: theme.cardColor,
              inactiveTrackColor: theme.hintColor.withValues(alpha: 0.30),
            ),
          ),
        ],
      ),
    );
  }
}
