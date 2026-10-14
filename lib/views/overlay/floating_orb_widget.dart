import 'package:flutter/material.dart';
import '../../models/jarvis_state.dart';
import 'orb_painter.dart';

class FloatingOrbWidget extends StatefulWidget {
  final JarvisState state;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  const FloatingOrbWidget({
    Key? key,
    required this.state,
    required this.onTap,
    this.onDoubleTap,
  }) : super(key: key);

  @override
  State<FloatingOrbWidget> createState() => _FloatingOrbWidgetState();
}

class _FloatingOrbWidgetState extends State<FloatingOrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant FloatingOrbWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // In gaming mode, freeze ticker to free CPU/GPU cycles
    if (widget.state == JarvisState.gamingMode) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == JarvisState.gamingMode) {
      return const SizedBox(width: 0, height: 0);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Subtle breathing scale in Idle state
          double scale = 1.0;
          if (widget.state == JarvisState.idle) {
            scale = 0.96 + (0.04 * (0.5 + 0.5 * (1.0 - (2.0 * (_controller.value - 0.5)).abs())));
          } else if (widget.state == JarvisState.listening) {
            scale = 1.05;
          }

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: OrbPainter(
                  animationValue: _controller.value,
                  state: widget.state,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
