import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionStatusWidget extends StatelessWidget {
  final String auctionId;
  final AuctionStatus status;

  const AuctionStatusWidget({
    super.key,
    required this.auctionId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getAuctionStatusColor(status, context);
    return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${getTranslated('auction_id', context)} #$auctionId',
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeOrder),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeOrder)),
            ),
            child: Text(getTranslated(status.label, context) ?? status.label,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

Color _getAuctionStatusColor(AuctionStatus status, BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  switch (status) {
    case AuctionStatus.complete:
    case AuctionStatus.purchaseComplete:
    case AuctionStatus.delivered:
      return colors.onTertiaryContainer;
    case AuctionStatus.live:
    case AuctionStatus.readyToClaim:
      return colors.secondary;
    case AuctionStatus.pending:
      return colors.tertiary;
    case AuctionStatus.rejected:
    case AuctionStatus.unsold:
      return colors.error;
    case AuctionStatus.readyToDelivery:
    case AuctionStatus.onTheWay:
      return colors.outline;
    case AuctionStatus.all:
    case AuctionStatus.scheduled:
    case AuctionStatus.upcoming:
    case AuctionStatus.approved:
      return colors.primary;
    case AuctionStatus.canceled:
      return colors.tertiary;
    case AuctionStatus.recreated:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}