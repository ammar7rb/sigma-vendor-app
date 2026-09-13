import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_details_screen.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';


enum AuctionMenuAction {view, edit, delete, toggleStatus, recreate, cancel}

class AuctionCardWidget extends StatelessWidget {
  final AuctionProduct? auctionProduct;
  final String imageUrl;
  final String title;
  final String auctionId;
  final AuctionStatus status;
  final bool isActive;
  final void Function(AuctionMenuAction action)? onMenuSelected;
  final String? reason;
  final String? duration;
  final String? startDate;
  final String? endDate;
  final String? timeLabel;
  final double? startingPrice;
  final double? minIncrement;
  final double? maxDecrement;
  final double? highestBid;
  final int? views;
  final int? bidCount;
  final int? totalParticipate;
  final String? claimedByName;
  final String? claimedByAvatarUrl;
  final bool formAuctionList;
  final AuctionStatus? showAuctionStatus;
  final String? claimRemainingDuration;
  final bool showDelete;
  final bool showCancel;

  const AuctionCardWidget({
    super.key,
    this.auctionProduct,
    required this.imageUrl,
    required this.title,
    required this.auctionId,
    required this.status,
    this.isActive = true,
    this.onMenuSelected,
    this.duration,
    this.timeLabel,
    this.startingPrice,
    this.minIncrement,
    this.maxDecrement,
    this.views,
    this.totalParticipate,
    this.highestBid,
    this.bidCount,
    this.claimedByName,
    this.claimedByAvatarUrl,
    this.reason,
    this.formAuctionList = false,
    this.startDate,
    this.endDate,
    this.showAuctionStatus,
    this.claimRemainingDuration,
    this.showDelete = true,
    this.showCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AuctionDetailsScreen(fromNotification: false, auctionId: int.tryParse(auctionId) ?? 0, auctionProduct: auctionProduct))),
      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingEye),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.paddingSize),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
              )
            ]
          ),

          child: Slidable(
            key: ValueKey(auctionId),
            endActionPane: status.isEditableStatus ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.22,
              children: [
                CustomSlidableAction(
                  onPressed: (_) {},
                  backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showDelete) ...[
                        ActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                          onTap: () {
                            Slidable.of(context)?.close();
                            onMenuSelected?.call(AuctionMenuAction.delete);
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(width: 36, height: 1, color: Theme.of(context).cardColor),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],

                      ActionButton(
                        icon: Icons.edit_outlined,
                        color: Theme.of(context).primaryColor,
                        onTap: () {
                          Slidable.of(context)?.close();
                          onMenuSelected?.call(AuctionMenuAction.edit);
                        },
                      ),

                    ],
                  ),
                ),
              ],
            ) : null,

            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuctionCardHeader(
                            imageUrl: imageUrl,
                            title: title,
                            auctionId: auctionId,
                            timeLabel: timeLabel,
                            onMenuSelected: onMenuSelected,
                            startDate: startDate,
                            endDate: endDate,
                            showAuctionStatus: showAuctionStatus,
                            claimRemainingDuration: claimRemainingDuration,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.15)),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          AuctionCardBody(
                            status: status,
                            duration: duration,
                            reason: reason,
                            startingPrice: startingPrice,
                            minIncrement: minIncrement,
                            maxDecrement: maxDecrement,
                            highestBid: highestBid,
                            claimedByName: claimedByName,
                            claimedByAvatarUrl: claimedByAvatarUrl,
                          ),
                        ],
                      ),
                    ),

                    AuctionStatsRow(
                      status: status,
                      views: views,
                      bidCount: bidCount,
                      totalParticipate: totalParticipate,
                    )



                  ],
                ),

                Positioned.directional(
                  textDirection: Directionality.of(context),
                  end: 0,
                  child: PopupMenuButton<AuctionMenuAction>(
                    icon: SizedBox(
                      height: 35, width: 35,
                      child: const Icon(Icons.more_vert)
                    ),
                    onSelected: onMenuSelected,
                    offset: const Offset(0, 40),

                    itemBuilder: (context) => [

                      if(formAuctionList && status.isEditableStatus)
                      PopupMenuItem(
                        value: AuctionMenuAction.toggleStatus,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isActive ? (getTranslated('active', context) ?? 'active')
                                : (getTranslated('inactive', context) ?? 'In Active'),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(width: 25),

                            FlutterSwitch(width: 40.0, height: 20.0, toggleSize: 18.0,
                              value: isActive,
                              borderRadius: 20.0,
                              activeColor: Theme.of(context).primaryColor,
                              padding: 1.0,
                              onToggle:(bool isActive) {
                                Navigator.pop(context);
                                onMenuSelected?.call(AuctionMenuAction.toggleStatus);
                              },
                            ),
                          ],
                        ),
                      ),

                      PopupMenuItem(
                        value: AuctionMenuAction.view,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated('view', context)!,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                            ),
                            const SizedBox(width: 50),

                            Icon(Icons.remove_red_eye, color: Theme.of(context).primaryColor),
                          ],
                        ),
                      ),

                      if (status.isLive && showCancel)
                        PopupMenuItem(
                          value: AuctionMenuAction.cancel,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getTranslated('cancel_auction', context) ?? 'Cancel Auction',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 50),
                              Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                            ],
                          ),
                        ),

                      if (status.isUnsold) ...[
                        PopupMenuItem(
                          value: AuctionMenuAction.recreate,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getTranslated('re_create', context) ?? 'Recreate',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 50),
                              Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                        if (showDelete)
                          PopupMenuItem(
                            value: AuctionMenuAction.delete,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated('delete', context)!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 50),
                                CustomAssetImageWidget(Images.delete, color: Theme.of(context).colorScheme.error),
                              ],
                            ),
                          ),
                      ],

                      if (status.isRejected) ...[
                        PopupMenuItem(
                          value: AuctionMenuAction.recreate,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getTranslated('re_create', context) ?? 'Recreate',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 50),
                              Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                        if (showDelete)
                          PopupMenuItem(
                            value: AuctionMenuAction.delete,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated('delete', context)!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 50),
                                CustomAssetImageWidget(Images.delete, color: Theme.of(context).colorScheme.error),
                              ],
                            ),
                          ),
                      ],

                      if (status.isCanceled) ...[
                        PopupMenuItem(
                          value: AuctionMenuAction.edit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslated('edit', context) ?? 'Edit',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                              const SizedBox(width: 50),
                              Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                        if (showDelete)
                          PopupMenuItem(
                            value: AuctionMenuAction.delete,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(getTranslated('delete', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                                ),
                                const SizedBox(width: 50),
                                CustomAssetImageWidget(Images.delete, color: Theme.of(context).colorScheme.error),
                              ],
                            ),
                          ),
                      ],

                      if (status.isEditableStatus) ...[
                        PopupMenuItem(
                          value: AuctionMenuAction.edit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslated('edit', context) ?? 'Edit',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                              ),
                              const SizedBox(width: 50),
                              Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),

                        if (showDelete)
                          PopupMenuItem(
                            value: AuctionMenuAction.delete,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(getTranslated('delete', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                ),
                                const SizedBox(width: 50),
                                CustomAssetImageWidget(Images.delete, color: Theme.of(context).colorScheme.error),
                              ],
                            ),
                          ),
                      ],

                    ],
                  )
                ),

              ],
            ),

          ),
        ),
      ),
    );
  }
}

class AuctionCardHeader extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String auctionId;
  final String? timeLabel;
  final String? startDate;
  final String? endDate;
  final void Function(AuctionMenuAction action)? onMenuSelected;
  final AuctionStatus? showAuctionStatus;
  final String? claimRemainingDuration;

  const AuctionCardHeader({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.auctionId,
    this.timeLabel,
    this.onMenuSelected,
    this.startDate,
    this.endDate,
    this.showAuctionStatus,
    this.claimRemainingDuration,
  });

  String? _timePrefix(BuildContext context) {
    switch (showAuctionStatus) {
      case AuctionStatus.upcoming:
        return getTranslated('start_in', context) ?? "";
      case AuctionStatus.live:
        return getTranslated('end_in', context) ?? "";
      default:
        return null;
    }
  }

  String? _time() {
    switch (showAuctionStatus) {
      case AuctionStatus.upcoming:
        return startDate;
      case AuctionStatus.live:
        return endDate;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          child: CustomImageWidget(image: imageUrl, height: 45, width: 45, fit: BoxFit.cover),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
              const SizedBox(height: Dimensions.paddingSizeOrder),

              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${getTranslated('auction_id', context)}',
                        style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color),
                      ),

                      Text(
                        ' #$auctionId',
                        style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),

                  if (_timePrefix(context) != null && (showAuctionStatus == AuctionStatus.live || showAuctionStatus == AuctionStatus.upcoming)) ...[
                    const SizedBox(width: Dimensions.paddingSizeOrder),
                    const Text('·'),

                    const SizedBox(width: Dimensions.paddingSizeOrder),
                    Text('${_timePrefix(context)} ${getRemainingDuration(_time())}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))
                  ],

                  if (showAuctionStatus == AuctionStatus.readyToClaim && claimRemainingDuration != null &&
                      claimRemainingDuration!.isNotEmpty) ...[
                    const SizedBox(width: Dimensions.paddingSizeOrder),
                    const Text('·'),
                    const SizedBox(width: Dimensions.paddingSizeOrder),
                    Text(
                      '${getTranslated('claim_remaining', context) ?? 'Claim remaining'} $claimRemainingDuration',
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeOrder),

              if (showAuctionStatus != null)
                SellerCreatedAuctionStatusBadge(status: showAuctionStatus!),
            ],
          ),
        ),
      ],
    );
  }

  String getRemainingDuration(String? end) {
    if (end == null) return '';

    try {
      final now = DateTime.now();
      final endDate = DateTime.parse(end).toLocal();

      final diff = endDate.difference(now);

      if (diff.isNegative) return '';

      final days = diff.inDays;

      if (days > 0) {
        return '$days day${days > 1 ? 's' : ''}';
      }

      final minutes = diff.inMinutes;

      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } catch (_) {
      return '';
    }
  }

}

class AuctionCardBody extends StatelessWidget {
  final AuctionStatus status;
  final String? duration;
  final String? reason;

  final double? startingPrice;
  final double? minIncrement;
  final double? maxDecrement;
  final double? highestBid;

  final String? claimedByName;
  final String? claimedByAvatarUrl;

  const AuctionCardBody({
    super.key,
    required this.status,
    this.duration,
    this.reason,
    this.startingPrice,
    this.minIncrement,
    this.maxDecrement,
    this.highestBid,
    this.claimedByName,
    this.claimedByAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AuctionStatus.scheduled:
        return ScheduledAuctionBody(duration: duration, reason: reason);

      case AuctionStatus.pending:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );

      case AuctionStatus.live:
        return LiveAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );

      case AuctionStatus.complete:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
        );
      case AuctionStatus.upcoming:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
      case AuctionStatus.rejected:
        return ScheduledAuctionBody(duration: duration, reason: reason);
      case AuctionStatus.approved:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
      case AuctionStatus.unsold:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
      case AuctionStatus.readyToClaim:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
          showClaimedBy: false,
        );
      case AuctionStatus.readyToDelivery:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
        );
      case AuctionStatus.onTheWay:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
        );
      case AuctionStatus.delivered:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
        );
      case AuctionStatus.purchaseComplete:
        return CompleteAuctionBody(
          startingPrice: startingPrice,
          highestBid: highestBid,
          claimedByName: claimedByName,
          claimedByAvatarUrl: claimedByAvatarUrl,
        );
      case AuctionStatus.all:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
      case AuctionStatus.canceled:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
      case AuctionStatus.recreated:
        return PendingAuctionBody(
          startingPrice: startingPrice,
          minIncrement: minIncrement,
          maxDecrement: maxDecrement,
        );
    }
  }
}

class ScheduledAuctionBody extends StatelessWidget {
  final String? duration;
  final String? reason;

  const ScheduledAuctionBody({super.key, this.duration, this.reason});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated('duration', context) ?? "",
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),

          Text(
            " $duration",
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),

      const SizedBox(height: Dimensions.paddingEye),
      if (reason != null && reason!.isNotEmpty)
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingEye),
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              children: [
                TextSpan(
                  text: getTranslated('reason:', context) ?? "",
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                TextSpan(text: reason,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
    ]);
  }
}

class PendingAuctionBody extends StatelessWidget {
  final double? startingPrice;
  final double? minIncrement;
  final double? maxDecrement;

  const PendingAuctionBody({super.key, this.startingPrice, this.minIncrement, this.maxDecrement});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PriceRow(label: getTranslated('starting_price', context) ?? "", amount: startingPrice),
      PriceRow(label: getTranslated('min_increment', context) ?? "", amount: minIncrement),
      PriceRow(label: getTranslated('max_decrement', context) ?? "", amount: maxDecrement),
    ]);
  }
}

class LiveAuctionBody extends StatelessWidget {
  final double? startingPrice;
  final double? highestBid;
  final double? minIncrement;
  final double? maxDecrement;

  const LiveAuctionBody({super.key, this.startingPrice, this.highestBid, this.minIncrement, this.maxDecrement});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PriceRow(label: getTranslated('starting_price', context) ?? "", amount: startingPrice),
      PriceRow(label: getTranslated('highest_bid', context) ?? "", amount: highestBid),
      PriceRow(label: getTranslated('min_increment', context) ?? "", amount: minIncrement),
      PriceRow(label: getTranslated('max_decrement', context) ?? "", amount: maxDecrement),
    ]);
  }
}

class CompleteAuctionBody extends StatelessWidget {
  final double? startingPrice;
  final double? highestBid;
  final String? claimedByName;
  final String? claimedByAvatarUrl;
  final bool showClaimedBy;

  const CompleteAuctionBody({super.key, this.startingPrice, this.highestBid, this.claimedByName, this.claimedByAvatarUrl, this.showClaimedBy = true});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PriceRow(label: getTranslated('starting_price', context) ?? "", amount: startingPrice),

      PriceRow(label: getTranslated('highest_bid', context) ?? "", amount: highestBid),

      if (showClaimedBy) ...[
        const SizedBox(height: Dimensions.paddingEye),
        Row(children: [
          Text(getTranslated('claimed_by', context) ?? "", style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          ClipOval(child: CustomImageWidget(image: claimedByAvatarUrl ?? '', height: 20, width: 20, fit: BoxFit.cover)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Expanded(child: Text(claimedByName ?? '', overflow: TextOverflow.ellipsis, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color))),
        ]),
      ],
    ]);
  }
}

class AuctionStatsRow extends StatelessWidget {
  final AuctionStatus status;
  final int? views;
  final int? bidCount;
  final int? totalParticipate;
  const AuctionStatsRow({super.key, required this.status, this.views, this.bidCount, this.totalParticipate});

  @override
  Widget build(BuildContext context) {
    if (status == AuctionStatus.scheduled ||
        status == AuctionStatus.complete) {
      return const SizedBox();
    }

    return StatsRow(views: views, bidCount: bidCount, totalParticipate: totalParticipate, showBidCount: status == AuctionStatus.live || status == AuctionStatus.readyToClaim || status == AuctionStatus.readyToDelivery || status == AuctionStatus.onTheWay || status == AuctionStatus.delivered || status == AuctionStatus.unsold);
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final double? amount;

  const PriceRow({super.key, required this.label, this.amount});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Row(children: [
      Text(label, style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color)),
      const Spacer(),
      Text(amount != null ? PriceConverter.convertPrice(context, amount) : '-', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color))
    ]);
  }
}

class StatsRow extends StatelessWidget {
  final int? views;
  final int? bidCount;
  final int? totalParticipate;
  final bool showBidCount;

  const StatsRow({super.key, this.views, this.bidCount, this.totalParticipate, this.showBidCount = false});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: Dimensions.paddingSize, right: Dimensions.paddingSize, bottom: Dimensions.paddingSizeExtraSmall),
      color: ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).hintColor, 0.10),

      child: Row(children: [
        Icon(Icons.remove_red_eye, size: Dimensions.paddingSizeMedium, color: Theme.of(context).hintColor),
        const SizedBox(width: Dimensions.paddingSizeOrder),

        Text('${views ?? 0}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
        if (showBidCount) ...[
          const SizedBox(width: Dimensions.paddingSizeMedium),

          CustomAssetImageWidget(Images.gavelGreyIcon, height: Dimensions.paddingSizeMedium),
          const SizedBox(width: Dimensions.paddingSizeOrder),

          Text('${bidCount ?? 0}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color))
        ],
        const Spacer(),

        Row(
          children: [
            Text(getTranslated('total_participate', context) ?? "", style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color)),
            Text(' ${totalParticipate ?? 0}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),

      ]),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final AuctionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {



    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeVeryTiny),
      decoration: BoxDecoration(color: getAuctionStatusColor(status, context).withValues(alpha: .15), borderRadius: BorderRadius.circular(Dimensions.paddingSizeOrder)),
      child: Text(getTranslated(status.label, context) ?? '',
        style: TextStyle(color: getAuctionStatusColor(status, context), fontSize: 10),
      ),
    );
  }
}

class SellerCreatedAuctionStatusBadge extends StatelessWidget {
  final AuctionStatus status;

  const SellerCreatedAuctionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getSellerCreatedAuctionStatusColor(status, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeVeryTiny),
      decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(Dimensions.paddingSizeOrder)),
      child: Text(
        getTranslated(status.label, context) ?? status.label,
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}

Color getSellerCreatedAuctionStatusColor(AuctionStatus status, BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  switch (status) {
    case AuctionStatus.upcoming:
    case AuctionStatus.approved:
    case AuctionStatus.scheduled:
    case AuctionStatus.all:
      return colors.primary;
    case AuctionStatus.live:
    case AuctionStatus.readyToClaim:
      return colors.secondary;
    case AuctionStatus.pending:
      return colors.tertiary;
    case AuctionStatus.purchaseComplete:
    case AuctionStatus.complete:
    case AuctionStatus.delivered:
      return colors.onTertiaryContainer;
    case AuctionStatus.readyToDelivery:
    case AuctionStatus.onTheWay:
      return colors.outline;
    case AuctionStatus.rejected:
    case AuctionStatus.unsold:
      return colors.error;
    case AuctionStatus.canceled:
      return colors.tertiary;
    case AuctionStatus.recreated:
      return colors.primary;
  }
}

Color getAuctionStatusColor(
    AuctionStatus status,
    BuildContext context,
    ) {
  final colors = Theme.of(context).colorScheme;

  switch (status) {
    case AuctionStatus.complete:
    case AuctionStatus.purchaseComplete:
      return colors.onTertiaryContainer;

    case AuctionStatus.live:
    case AuctionStatus.readyToClaim:
      return colors.secondary;

    case AuctionStatus.pending:
      return colors.tertiary;

    case AuctionStatus.rejected:
    case AuctionStatus.unsold:
      return colors.error;

    case AuctionStatus.all:
    case AuctionStatus.scheduled:
    case AuctionStatus.upcoming:
    case AuctionStatus.approved:
      return colors.primary;

    case AuctionStatus.readyToDelivery:
    case AuctionStatus.onTheWay:
      return colors.outline;

    case AuctionStatus.delivered:
      return colors.onTertiaryContainer;
    case AuctionStatus.canceled:
      return colors.tertiary;
    case AuctionStatus.recreated:
      return colors.primary;
  }
}