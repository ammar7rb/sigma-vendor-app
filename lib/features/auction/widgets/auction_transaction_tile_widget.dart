import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

enum TransactionType { credit, debit }

class AuctionTransactionTileWidget extends StatelessWidget {
  final double amount;
  final String auctionNumber;
  final DateTime dateTime;
  final TransactionType type;
  final String? transactionType;

  const AuctionTransactionTileWidget({
    super.key,
    required this.amount,
    required this.auctionNumber,
    required this.dateTime,
    required this.type,
    this.transactionType,
  });

  bool get _isCredit => type == TransactionType.credit;

  String get _formattedAmount => '${_isCredit ? '+' : '-'}\$${amount.toStringAsFixed(0)}';

  String get _formattedDate => DateConverter.formatDateWithComma(dateTime);

  @override
  Widget build(BuildContext context) {
    final accentColor = _isCredit
        ? Theme.of(context).colorScheme.onTertiaryContainer
        : Theme.of(context).colorScheme.secondary;
    final hintColor = Theme.of(context).hintColor;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeMedium,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: ThemeShadow.getShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomAssetImageWidget(
                _isCredit ? Images.creditCoinIcon : Images.debitCoinIcon,
                height: 25, width: 25),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(_formattedAmount,
                style: titilliumSemiBold.copyWith(
                  color: accentColor,
                  fontSize: Dimensions.fontSizeExtraLargeTwenty,
                ),
              ),
              const Spacer(),

              Text(_formattedDate,
                style: robotoSmallTitleRegular.copyWith(
                  color: hintColor,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(
            children: [
              Text(
                '${getTranslated('auction_number', context) ?? 'Auction'} # $auctionNumber',
                style: robotoRegular.copyWith(
                  color: hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              const Spacer(),

              if (transactionType != null) ...[
                Text(
                  getTranslated(transactionType!, context) ?? transactionType!,
                  style: robotoMedium.copyWith(
                    color: hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              ],

              Text(
                _isCredit
                    ? getTranslated('credit', context) ?? 'Credit'
                    : getTranslated('debit', context) ?? 'Debit',
                style: robotoMedium.copyWith(
                  color: accentColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
