import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class SellerAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;

  const SellerAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          width: compact ? 210 : 250,
          height: compact ? 70 : 82,
          child: Center(
            child: dark
                ? ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Image.asset(Images.sigmaLogoTransparent,
                        width: compact ? 204 : 242,
                        alignment: Alignment.center,
                        fit: BoxFit.contain),
                  )
                : Image.asset(Images.sigmaLogoTransparent,
                    width: compact ? 204 : 242,
                    alignment: Alignment.center,
                    fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: compact ? 10 : 15),
        Text(title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor, height: 1.55)),
      ],
    );
  }
}

class SellerAuthPage extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const SellerAuthPage({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          PositionedDirectional(
            top: -110,
            end: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, gradient: AppDesign.brandGradient),
            ),
          ),
          PositionedDirectional(
            bottom: -150,
            start: -130,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppDesign.primary.withValues(alpha: .06)),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
