import 'package:flutter/material.dart';

/// A tween animation that preserves the current animated value when the widget
/// is rebuilt with new configuration.
///
/// This is useful when a view updates its target values while keeping the
/// animation state continuous, instead of restarting from the initial value.
class PreservedTweenAnimationBuilder extends StatefulWidget {
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;
  final ValueWidgetBuilder<double> builder;
  final Widget? child;

  const PreservedTweenAnimationBuilder({
    super.key,
    required this.begin,
    required this.end,
    required this.duration,
    this.curve = Curves.linear,
    required this.builder,
    this.child,
  });

  @override
  State<PreservedTweenAnimationBuilder> createState() =>
      _PreservedTweenAnimationBuilderState();
}

class _PreservedTweenAnimationBuilderState
    extends State<PreservedTweenAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late CurvedAnimation _curved;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.begin;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      animationBehavior: AnimationBehavior.preserve,
    );
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(_curved)..addListener(_syncCurrent);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PreservedTweenAnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;

    final bool shouldRetween =
        oldWidget.begin != widget.begin ||
        oldWidget.end != widget.end ||
        oldWidget.curve != widget.curve;

    if (!shouldRetween) {
      return;
    }

    _rebuildAnimation();
    _controller
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _animation.removeListener(_syncCurrent);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, _) {
        return widget.builder(context, _animation.value, widget.child);
      },
    );
  }

  void _syncCurrent() {
    _currentValue = _animation.value;
  }

  /// Rebuilds the underlying tween using the last known animated value as the
  /// new start point. This avoids jumping back to the original begin value when
  /// the widget is updated.
  void _rebuildAnimation() {
    _animation.removeListener(_syncCurrent);

    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _animation = Tween<double>(
      begin: _currentValue,
      end: widget.end,
    ).animate(_curved)..addListener(_syncCurrent);
  }
}
