import 'package:flutter/material.dart';

/// Motion helpers shared by the vendor dashboard. Every effect respects the
/// platform "reduce motion" setting (MediaQuery.disableAnimations).
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Fades and slides a child in once, after [index] * [step] (staggered lists).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;
  final Offset from;
  const FadeSlideIn(
      {super.key,
      required this.child,
      this.index = 0,
      this.step = const Duration(milliseconds: 70),
      this.from = const Offset(0, .08)});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const _motion = Duration(milliseconds: 420);
  // The stagger delay is part of the animation (no timers), so the effect
  // stops cleanly with the widget and in tests.
  late final Duration _delay = widget.step * widget.index;
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _delay + _motion);
  late final Animation<double> _curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(
          _delay.inMilliseconds / (_delay + _motion).inMilliseconds, 1,
          curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return widget.child;
    return FadeTransition(
        opacity: _curve,
        child: SlideTransition(
            position: Tween(begin: widget.from, end: Offset.zero).animate(_curve),
            child: widget.child));
  }
}

/// Shrinks slightly while pressed and lifts on hover (web/desktop/mouse).
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius borderRadius;
  final String? semanticLabel;
  const PressableScale(
      {super.key,
      required this.child,
      this.onTap,
      this.pressedScale = .94,
      this.borderRadius = const BorderRadius.all(Radius.circular(16)),
      this.semanticLabel});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false, _hovered = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context);
    final scale = still
        ? 1.0
        : _pressed
            ? widget.pressedScale
            : _hovered
                ? 1.04
                : 1.0;
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
          onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: scale,
            duration: Duration(milliseconds: _pressed ? 90 : 200),
            curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Counts up from zero to [value] the first time it appears and animates
/// between later values.
class AnimatedCount extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String Function(num)? format;
  const AnimatedCount(
      {super.key, required this.value, this.style, this.format});

  @override
  Widget build(BuildContext context) {
    String text(num v) =>
        format?.call(v) ?? (value is int ? '${v.round()}' : v.toStringAsFixed(2));
    if (reduceMotion(context)) return Text(text(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(text(v), style: style),
    );
  }
}
