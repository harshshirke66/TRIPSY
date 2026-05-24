import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tripsy/core/theme/colors.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Pure obsidian base
        Container(color: TripsyColors.deepSpace),

        // Shifting aura spot 1 (Rose/Magenta)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * 2 * math.pi;
            final dx = math.sin(angle) * 70;
            final dy = math.cos(angle) * 40;
            return Positioned(
              top: (size.height * 0.12) + dy,
              left: (size.width * 0.05) + dx,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TripsyColors.sunsetOrange.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: TripsyColors.sunsetOrange.withValues(alpha: 0.12),
                      blurRadius: 140,
                      spreadRadius: 70,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Shifting aura spot 2 (Lavender/Purple)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * 2 * math.pi + math.pi; // opposite side
            final dx = math.sin(angle) * 50;
            final dy = math.cos(angle) * 80;
            return Positioned(
              bottom: (size.height * 0.18) + dy,
              right: (size.width * 0.02) + dx,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TripsyColors.skyBlue.withValues(alpha: 0.10),
                  boxShadow: [
                    BoxShadow(
                      color: TripsyColors.skyBlue.withValues(alpha: 0.10),
                      blurRadius: 150,
                      spreadRadius: 80,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Shifting aura spot 3 (Ocean Teal)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * 2 * math.pi + (math.pi / 2);
            final dx = math.cos(angle) * 60;
            final dy = math.sin(angle) * 30;
            return Positioned(
              top: (size.height * 0.42) + dy,
              right: (size.width * 0.1) + dx,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TripsyColors.oceanTeal.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: TripsyColors.oceanTeal.withValues(alpha: 0.08),
                      blurRadius: 130,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Screen overlay texture (subtle radial dark shade)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),

        // The foreground widgets
        widget.child,
      ],
    );
  }
}
