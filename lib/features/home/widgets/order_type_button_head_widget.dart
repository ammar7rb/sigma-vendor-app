import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';

class OrderTypeButtonHeadWidget extends StatelessWidget {
  final String? text;
  final String? subText;
  final Color? color;
  final Color? circleColor;
  final int index;
  final Function? callback;
  final int? numberOfOrder;
  final String? image;
  const OrderTypeButtonHeadWidget(
      {super.key,
      required this.text,
      this.subText,
      this.color,
      required this.index,
      required this.callback,
      required this.numberOfOrder,
      required this.circleColor,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<OrderController>(context, listen: false)
            .setIndex(context, index);
        callback?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: circleColor?.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12)),
                child: CustomAssetImageWidget(image!, color: circleColor)),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: Theme.of(context).hintColor),
          ]),
          const Spacer(),
          Text(numberOfOrder.toString(),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
              [text, subText].where((e) => e != null && e.isNotEmpty).join(' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).hintColor)),
        ]),
      ),
    );
  }
}
