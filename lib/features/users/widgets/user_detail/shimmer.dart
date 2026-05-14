import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFBDBDBD), // base scura
                Color(0xFFE6E6E6), // highlight morbido
                Color(0xFFFFFFFF), // luce forte
                Color(0xFFE6E6E6),
                Color(0xFFBDBDBD),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlidingGradientTransform(controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double progress;

  const _SlidingGradientTransform(this.progress);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final double dx = bounds.width * 2 * progress - bounds.width;

    return Matrix4.translationValues(dx, 0, 0);
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerBar extends StatelessWidget {
  final double width;

  const ShimmerBar({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
