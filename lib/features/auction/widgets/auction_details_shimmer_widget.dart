import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AuctionDetailsProductShimmer extends StatelessWidget {
  const AuctionDetailsProductShimmer({super.key});

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
            // Status row
            _ShimmerCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Block(width: 140, height: 14),
                  _Block(width: 100, height: 28, radius: 14),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Product card
            _ShimmerCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 90, height: 90, radius: Dimensions.radiusDefault),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Block(height: 14, radius: 4),
                        const SizedBox(height: 8),
                        _Block(width: 120, height: 14, radius: 4),
                        const SizedBox(height: 10),
                        _Block(height: 10, radius: 4),
                        const SizedBox(height: 6),
                        _Block(width: 140, height: 10, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Product details card (title + description lines + video placeholder)
            _ShimmerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 160, height: 14, radius: 4),
                  const SizedBox(height: 12),
                  _Block(height: 10, radius: 4),
                  const SizedBox(height: 6),
                  _Block(height: 10, radius: 4),
                  const SizedBox(height: 6),
                  _Block(width: double.infinity, height: 10, radius: 4),
                  const SizedBox(height: 6),
                  _Block(width: 200, height: 10, radius: 4),
                  const SizedBox(height: 16),
                  _Block(height: 180, radius: Dimensions.radiusDefault),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Info section — Product Info (5 rows)
            _InfoSectionShimmer(rowCount: 5),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Info section — Shipping & Return (2 rows)
            _InfoSectionShimmer(rowCount: 2),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Timeline card (3 entries)
            _ShimmerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 120, height: 14, radius: 4),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  ...List.generate(3, (i) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(width: 160, height: 10, radius: 4),
                      const SizedBox(height: 6),
                      _Block(width: 100, height: 10, radius: 4),
                      if (i < 2) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                      ],
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}

class AuctionDetailsBiddingShimmer extends StatelessWidget {
  const AuctionDetailsBiddingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
      highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
      child: _ShimmerCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Block(width: 100, height: 14, radius: 4),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            const Divider(height: 1),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...List.generate(5, (i) => Column(
              children: [
                Row(
                  children: [
                    _Block(width: 20, height: 10, radius: 4),
                    const SizedBox(width: Dimensions.paddingEye),
                    _Block(width: 30, height: 30, radius: 15),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Block(width: 120, height: 10, radius: 4),
                          const SizedBox(height: 4),
                          _Block(width: 80, height: 10, radius: 4),
                        ],
                      ),
                    ),
                    _Block(width: 60, height: 14, radius: 4),
                  ],
                ),
                if (i < 4) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  const Divider(height: 1),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class _InfoSectionShimmer extends StatelessWidget {
  final int rowCount;
  const _InfoSectionShimmer({required this.rowCount});

  @override
  Widget build(BuildContext context) {
    return _ShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(width: 140, height: 14, radius: 4),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...List.generate(rowCount, (i) => Column(
            children: [
              Row(
                children: [
                  _Block(width: 80, height: 10, radius: 4),
                  const SizedBox(width: 8),
                  _Block(width: 8, height: 10, radius: 4),
                  const SizedBox(width: 8),
                  _Block(width: 120, height: 10, radius: 4),
                ],
              ),
              if (i < rowCount - 1) const SizedBox(height: 12),
            ],
          )),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Widget child;
  const _ShimmerCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Block extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Block({
    this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
