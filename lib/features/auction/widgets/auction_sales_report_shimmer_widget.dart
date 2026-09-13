import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AuctionSalesReportShimmer extends StatelessWidget {
  const AuctionSalesReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
      highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),

            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                itemCount: 6,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: Dimensions.paddingEye),
                itemBuilder: (_, __) => const _StatCardShimmer(),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                child: _DetailCardShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  const _StatCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Block(
              width: Dimensions.iconSizeExtraLarge,
              height: Dimensions.iconSizeExtraLarge,
              radius: Dimensions.radiusSmall),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          const _Block(widthFactor: 0.7, height: 14),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          const _Block(widthFactor: 0.9, height: 10),
          const SizedBox(height: 4),
          const _Block(widthFactor: 0.6, height: 10),
        ],
      ),
    );
  }
}

class _DetailCardShimmer extends StatelessWidget {
  const _DetailCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(
                  width: Dimensions.imageSize,
                  height: Dimensions.imageSize,
                  radius: Dimensions.radiusSmall,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                              child: _Block(widthFactor: 0.55, height: 11)),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          _Block(width: 60, height: 18, radius: 20),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      const _Block(widthFactor: 0.85, height: 13),
                      const SizedBox(height: 4),
                      const _Block(widthFactor: 0.6, height: 13),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      const _Block(widthFactor: 0.7, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(
              children: [
                ...List.generate(6, (_) => const _PriceRowShimmer()),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                const Divider(height: 1),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Block(width: 90, height: 13),
                        const SizedBox(height: 4),
                        _Block(width: 110, height: 10),
                      ],
                    ),
                    const Spacer(),
                    _Block(width: 70, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRowShimmer extends StatelessWidget {
  const _PriceRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.paddingSizeVeryTiny),
      child: Row(
        children: [
          _Block(width: 100, height: 12),
          Spacer(),
          _Block(width: 60, height: 12),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double? width;
  final double widthFactor;
  final double height;
  final double radius;

  const _Block({
    this.width,
    this.widthFactor = 1.0,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    return width == null ? FractionallySizedBox(widthFactor: widthFactor, child: box) : box;
  }
}
