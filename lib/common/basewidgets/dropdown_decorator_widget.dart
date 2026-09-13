import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class DropdownDecoratorWidget extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isRequired;
  final bool isTitleTransparent;
  const DropdownDecoratorWidget({super.key, this.title, required this.child, this.isRequired = false, this.isTitleTransparent = false});

  @override
  Widget build(BuildContext context) {

    TextStyle style = robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color);

    final bool hasTitle = title?.isNotEmpty ?? false;
    final textWidth = hasTitle ? getTextWidth(getTranslated(title, context) ?? '', style) : 0.0;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: CustomPaint(
            painter: GapBorderPainter(
              color: Theme.of(context).primaryColor.withValues(alpha: .25),
              strokeWidth: .5,
              radius: Dimensions.radiusDefault,
              gapStart: 15,
              gapWidth: hasTitle ? textWidth + 10 : 0,
            ),
            child: Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye),
                child: child,
              ),
            ),
          ),
        ),

        // Title
        if (title?.isNotEmpty ?? false)
          Positioned(
            top: 0,
            left: Dimensions.paddingSizeDefault,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(title, context)!,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (isRequired)
                  Text(' *',
                    style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeDefault,),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }

}


class GapBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double gapStart;
  final double gapWidth;

  GapBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.gapStart,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final r = radius;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path();

    // Left side
    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    // Top line (left part)
    path.lineTo(gapStart, 0);

    // Skip gap (title area)

    // Top line (right part)
    path.moveTo(gapStart + gapWidth, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(
      Offset(size.width, r),
      radius: Radius.circular(r),
    );

    // Right side
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );

    // Bottom
    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: Radius.circular(r),
    );

    // Left side
    path.lineTo(0, r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
