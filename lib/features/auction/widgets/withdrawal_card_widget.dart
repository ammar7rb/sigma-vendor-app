import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum WithdrawState { pending, requested, approved, denied }

class WithdrawalCardWidget extends StatelessWidget {
  final WithdrawState state;
  final double amount;
  final Map<String, dynamic>? withdrawInfo;
  final String? adminNote;
  final String? claimPaymentMethod;
  final bool adminCommissionGiven;
  final VoidCallback? onWithdrawPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onPayNowPressed;

  const WithdrawalCardWidget({
    super.key,
    required this.state,
    required this.amount,
    this.withdrawInfo,
    this.adminNote,
    this.claimPaymentMethod,
    this.adminCommissionGiven = false,
    this.onWithdrawPressed,
    this.onEditPressed,
    this.onPayNowPressed,
  });

  bool get _isApproved => state == WithdrawState.approved;
  bool get _isDenied => state == WithdrawState.denied;
  bool get _isCOD => claimPaymentMethod == 'cash_on_delivery';
  bool get _isPaid => _isCOD && adminCommissionGiven;
  bool get _showNote => !_isCOD && (_isApproved || _isDenied);
  bool get _showInfoCard => !_isCOD && (state == WithdrawState.requested || state == WithdrawState.approved || state == WithdrawState.denied);
  bool get _showButton => !_isPaid && (state == WithdrawState.pending || state == WithdrawState.denied || _isCOD);

  Color _titleColor(BuildContext context) {
    if (_isPaid) return Theme.of(context).colorScheme.onTertiaryContainer;
    return _isApproved || _isCOD ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error;
  }

  String _title(BuildContext context) {
    if (_isPaid) return getTranslated('amount_paid', context) ?? "Amount Paid";
    if (_isCOD) return getTranslated('pay_to_admin', context) ?? "Pay to admin";
    return _isApproved ? getTranslated('payment_received_from_admin', context) ?? "" : getTranslated('amount_paid_by_admin', context) ?? "";
  }

  String _subtitle(BuildContext context) {
    if (_isPaid) return getTranslated('successfully_completed_the_payment', context) ?? "Successfully completed the payment";
    if (_isCOD) return getTranslated('admin_commission_for_cod', context) ?? "Admin commission for COD";
    return _isApproved ? getTranslated('admin_has_completed_payment', context) ?? "" : getTranslated('auction_earnings_transferred', context) ?? "" + (_isDenied ? ' .' : '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: []),
          if (_showNote) NoteBanner(state: state, note: adminNote),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Text(_title(context),
                  textAlign: TextAlign.center,
                  style: titilliumSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: _titleColor(context),
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  PriceConverter.convertPrice(context, amount),
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeWithdrawableAmount,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeSmall),
                Text(_subtitle(context),
                  textAlign: TextAlign.center,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                    height: 1.5,
                  ),
                ),
                if (_showInfoCard && withdrawInfo != null) ...[
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  WithdrawInfoCard(
                    info: withdrawInfo!,
                    showEditButton: state != WithdrawState.approved,
                    onEditPressed: onEditPressed,
                  ),
                ],
                if (_showButton) ...[
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  if (_isCOD)
                    WithdrawButton(onPressed: onPayNowPressed, text: getTranslated('pay_now', context) ?? "Pay now")
                  else
                    WithdrawButton(onPressed: onWithdrawPressed),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoteBanner extends StatelessWidget {
  final WithdrawState state;
  final String? note;

  const NoteBanner({super.key, required this.state, this.note});

  bool get _isApproved => state == WithdrawState.approved;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isApproved ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.15) : Theme.of(context).colorScheme.error.withAlpha(50);
    final Color textColor = _isApproved ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error.withAlpha(150);
    final String label = _isApproved ? getTranslated('approve_note', context) ?? "" : getTranslated('denied_note', context) ?? "";
    final String message = note ?? (_isApproved ? getTranslated('approve_note_default', context) ?? "" : getTranslated('denied_note_default', context) ?? "");

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingEye),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
            Text(message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class WithdrawInfoCard extends StatelessWidget {
  final Map<String, dynamic> info;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const WithdrawInfoCard({
    super.key, 
    required this.info,
    required this.showEditButton,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Extract method name if present, or use default
    String methodName = info['method_name']?.toString() ?? getTranslated('withdraw_info', context) ?? "";
    
    // Create a list of rows for other fields
    List<Widget> rows = [];
    info.forEach((key, value) {
      if (key != 'method_name') {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: InfoRow(label: _formatLabel(key), value: value?.toString() ?? ""),
        ));
      }
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withAlpha(10),
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                methodName,
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              if (showEditButton)
                EditButton(onPressed: onEditPressed),
            ],
          ),
          SizedBox(height: Dimensions.paddingSizeMedium),
          ...rows,
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    return key.split('_').where((word) => word.isNotEmpty).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
        ),
        Text(': ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        ),
        Expanded(
          child: Text(value,
            style: titilliumSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EditButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: Dimensions.heightWidth50 / 1.4,
        height: Dimensions.heightWidth50 / 1.4,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Icon(Icons.edit, size: Dimensions.iconSizeDefault, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class WithdrawButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const WithdrawButton({super.key, this.onPressed, this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        ),
        child: Text(text ?? getTranslated('withdraw_request', context) ?? "",
          style: titilliumSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            letterSpacing: 0.3,
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}