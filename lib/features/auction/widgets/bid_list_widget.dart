import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class BidListItem {
  final int rank;
  final String name;
  final String timeAgo;
  final String bidAmount;
  final String? avatarUrl;
  final bool isLeading;
  final bool isWinner;
  final bool isClaimExpired;
  final bool isCurrentUser;
  final bool isBidUp;
  final bool isWithdrawBid;

  const BidListItem({
    required this.rank,
    required this.name,
    required this.timeAgo,
    required this.bidAmount,
    this.avatarUrl,
    this.isLeading = false,
    this.isWinner = false,
    this.isClaimExpired = false,
    this.isCurrentUser = false,
    this.isBidUp = true,
    this.isWithdrawBid = true,
  });
}

class BidListWidget extends StatefulWidget {
  final List<BidListItem> bids;
  final int? totalSize;
  final int? offset;
  final Function(int? offset) onPaginate;
  final AuctionStatus? auctionStatus;

  const BidListWidget({
    super.key,
    required this.bids,
    required this.onPaginate,
    this.totalSize,
    this.offset,
    this.auctionStatus
  });

  @override
  State<BidListWidget> createState() => _BidListWidgetState();
}

class _BidListWidgetState extends State<BidListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getTranslated('bid_list', context) ?? "", style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
          SizedBox(height: Dimensions.paddingSizeSmall),

          PaginatedListViewWidget(
            scrollController: _scrollController,
            totalSize: widget.totalSize,
            offset: widget.offset,
            onPaginate: widget.onPaginate,
            itemView: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: widget.bids.length,
                separatorBuilder: (_, index) => widget.bids[index].isLeading ? const SizedBox.shrink() : Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                itemBuilder: (_, index) => BidRow(item: widget.bids[index], auctionStatus: widget.auctionStatus),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BidRow extends StatelessWidget {
  final BidListItem item;
  final AuctionStatus? auctionStatus;
  const BidRow({super.key, required this.item, this.auctionStatus});



  @override
  Widget build(BuildContext context) {



    final isReadyToClaim = auctionStatus?.isReadyToClaim;
    final isPurchaseComplete = auctionStatus?.isPurchaseComplete;
    final isOnTheWay = auctionStatus?.isOnTheWay;
    final isReadyToDelivery = auctionStatus?.isReadyToDelivery;

    bool isWinner = item.isLeading && !item.isClaimExpired && (isReadyToClaim == true || isPurchaseComplete == true || isOnTheWay == true || isReadyToDelivery == true);


    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: (isWinner || item.isClaimExpired)
            ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.10)
            : item.isLeading
                ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.10)
                : Theme.of(context).cardColor,
        borderRadius: (item.isLeading || item.isWinner || item.isClaimExpired) ? BorderRadius.circular(Dimensions.radiusDefault) : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: Dimensions.paddingSizeVeryTiny),
          SizedBox(
            width: Dimensions.paddingSizeDefault + Dimensions.paddingSizeSmall,
            child: Text('${item.rank}.',
              style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),

          ClipOval(child: CustomImageWidget(image: item.avatarUrl ?? "", placeholder: Images.personIcon, height: 30, width: 30)),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.name, overflow: TextOverflow.ellipsis,
                        style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    if(item.isWithdrawBid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeVeryTiny),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Text(getTranslated('withdrawn', context) ?? "",
                        style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeVeryTiny),

                Text(item.timeAgo,
                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
                )

              ],
            ),
          ),

          Column(crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(item.bidAmount,
                    style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeVeryTiny),
                  Icon(item.isBidUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: item.isBidUp ? Colors.green : Colors.red,
                    size: Dimensions.iconSizeSmall,
                  ),

                  SizedBox(width: Dimensions.paddingSizeExtraSmall)
                ],
              ),
              if (item.isLeading || item.isWinner || item.isClaimExpired) ...[
                const SizedBox(height: Dimensions.paddingSizeVeryTiny),
                Container(
                  margin: EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: Dimensions.paddingSizeVeryTiny,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [

                      isWinner
                          ? CustomAssetImageWidget(Images.winner, height: Dimensions.iconSizeExtraSmall)
                          : item.isClaimExpired
                              ? Icon(Icons.timer_outlined, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.error)
                              : CustomAssetImageWidget(Images.leadingBidIcon, height: Dimensions.iconSizeExtraSmall),
                      const SizedBox(width: Dimensions.paddingSizeVeryTiny),

                      Text(
                        isWinner
                            ? getTranslated('winner', context) ?? ""
                            : item.isClaimExpired
                                ? getTranslated('claim_expired', context) ?? ""
                                : getTranslated('leading_bid', context) ?? "",
                        style: titilliumSemiBold.copyWith(
                          color: isWinner
                              ? Theme.of(context).colorScheme.onSecondary
                              : item.isClaimExpired
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onTertiaryContainer,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      )

                    ],
                  ),
                ),


              ],

            ],
          ),
        ],
      ),
    );
  }
}