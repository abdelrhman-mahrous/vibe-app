import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Slow-moving gradient orbs that create an ambient atmosphere
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0D2B), Color(0xFF070714)],
            ),
          ),
        ),
        // Animated orb 1
        AnimatedBuilder(
          animation: _controller1,
          builder: (_, __) => Positioned(
            top: -80 + (_controller1.value * 60),
            right: -60 + (_controller1.value * 40),
            child: _Orb(
              size: 280,
              color: const Color(0xFF7B2FBE),
              opacity: 0.12 + _controller1.value * 0.06,
            ),
          ),
        ),
        // Animated orb 2
        AnimatedBuilder(
          animation: _controller2,
          builder: (_, __) => Positioned(
            bottom: 100 + (_controller2.value * 80),
            left: -80 + (_controller2.value * 50),
            child: _Orb(
              size: 240,
              color: const Color(0xFF3A0D8F),
              opacity: 0.15 + _controller2.value * 0.07,
            ),
          ),
        ),
        // Animated orb 3 (small, middle)
        AnimatedBuilder(
          animation: _controller3,
          builder: (_, __) {
            final angle = _controller3.value * math.pi * 2;
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.35 +
                  math.sin(angle) * 30,
              left: MediaQuery.of(context).size.width * 0.5 +
                  math.cos(angle) * 50 -
                  60,
              child: _Orb(
                size: 120,
                color: const Color(0xFF9D4EDD),
                opacity: 0.08 + _controller3.value * 0.04,
              ),
            );
          },
        ),
        // Content on top
        widget.child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
