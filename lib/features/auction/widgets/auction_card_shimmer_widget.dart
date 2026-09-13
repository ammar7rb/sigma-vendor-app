import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AuctionCardShimmerWidget extends StatelessWidget {
  final bool fromRequest;

  const AuctionCardShimmerWidget({super.key, this.fromRequest = false});

  @override
  Widget build(BuildContext context) {
    final baseColor  = Theme.of(context).hintColor.withValues(alpha: 0.18);
    final hlColor    = Theme.of(context).hintColor.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingEye),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSize),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: hlColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AuctionCardHeaderShimmer(),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    const Divider(height: 1),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    _AuctionCardBodyShimmer(),
                  ],
                ),
              ),
              if (fromRequest) _AuctionStatsRowShimmer(context: context),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuctionCardHeaderShimmer extends StatelessWidget {
  const _AuctionCardHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBlock(
          width: 45, height: 45,
          borderRadius: Dimensions.paddingSizeExtraSmall,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBlock(height: 14, widthFactor: 0.7),
              const SizedBox(height: Dimensions.paddingSizeOrder),

              Row(
                children: [
                  _ShimmerBlock(width: 70, height: 11),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  _ShimmerBlock(width: 55, height: 11),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeOrder),

              _ShimmerBlock(width: 64, height: 18, borderRadius: Dimensions.paddingSizeOrder),
            ],
          ),
        ),

        const SizedBox(width: 35, height: 35),
      ],
    );
  }
}

class _AuctionCardBodyShimmer extends StatelessWidget {
  const _AuctionCardBodyShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeOrder),
          child: _PriceRowShimmer(),
        ),
      ),
    );
  }
}

class _PriceRowShimmer extends StatelessWidget {
  const _PriceRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ShimmerBlock(width: 90, height: 12),
        const Spacer(),
        _ShimmerBlock(width: 55, height: 12),
      ],
    );
  }
}

class _AuctionStatsRowShimmer extends StatelessWidget {
  final BuildContext context;

  const _AuctionStatsRowShimmer({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSize,
        right: Dimensions.paddingSize,
        bottom: Dimensions.paddingSizeExtraSmall,
        top: Dimensions.paddingSizeExtraSmall,
      ),
      color: ColorHelper.blendColors(
        Theme.of(context).cardColor,
        Theme.of(context).hintColor,
        0.10,
      ),
      child: Row(
        children: [
          // Views icon + count
          _ShimmerBlock(width: 16, height: 16, isCircle: true),
          const SizedBox(width: Dimensions.paddingSizeOrder),
          _ShimmerBlock(width: 24, height: 12),

          const Spacer(),

          // Total participate label + value
          _ShimmerBlock(width: 110, height: 12),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double? width;
  final double widthFactor;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const _ShimmerBlock({
    this.width,
    this.widthFactor = 1.0,
    required this.height,
    this.borderRadius = 6,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );

    if (width == null) {
      return FractionallySizedBox(widthFactor: widthFactor, child: block);
    }

    return block;
  }
}