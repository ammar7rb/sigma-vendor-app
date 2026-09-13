import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/auction_notification_model.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/auction_notification_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionNotificationItemWidget extends StatelessWidget {
  final AuctionNotificationItem item;
  final int index;
  final List<AuctionNotificationItem> allItems;

  const AuctionNotificationItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.allItems,
  });

  bool _showDateHeader() {
    if (index == 0) return true;
    final current  = DateConverter.isoStringToLocalDateOnly(item.createdAt ?? '');
    final previous = DateConverter.isoStringToLocalDateOnly(allItems[index - 1].createdAt ?? '');
    return current != previous;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showDateHeader()) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              DateConverter.compareDates(item.createdAt ?? ''),
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],

        InkWell(
          onTap: () {
            Provider.of<NotificationController>(context, listen: false).markAuctionNotificationSeen(id: item.id);
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).cardColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              isScrollControlled: true,
              builder: (_) => AuctionNotificationBottomSheetWidget(item: item),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            color: Theme.of(context).cardColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: CustomAssetImageWidget(
                          Images.gavelIcon,
                          width: 24,
                          height: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    if (item.isRead == false)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.typeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titilliumRegular.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          if (item.createdAt != null)
                            Text(
                              DateConverter.customTime(DateTime.parse(item.createdAt!)),
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeVeryTiny),
                      Text(
                        item.message ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
