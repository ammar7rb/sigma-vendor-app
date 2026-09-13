import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTransactionShimmerWidget extends StatelessWidget {
  const AuctionTransactionShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
      highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: Dimensions.paddingSizeExtraSmall,
          bottom: Dimensions.paddingSizeDefault,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => const _TransactionTileShimmer(),
      ),
    );
  }
}

class _TransactionTileShimmer extends StatelessWidget {
  const _TransactionTileShimmer();

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: ThemeShadow.getShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              _Block(width: 90, height: Dimensions.fontSizeExtraLargeTwenty),

              const Spacer(),

              _Block(width: 100, height: Dimensions.fontSizeSmall),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(
            children: [
              _Block(width: 130, height: Dimensions.fontSizeSmall),
              const Spacer(),
              _Block(width: 40, height: Dimensions.fontSizeSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;

  const _Block({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
