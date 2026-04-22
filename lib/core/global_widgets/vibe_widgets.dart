import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../theme/vibe_theme.dart';

/// A premium glassmorphism card used throughout the app.
/// Wraps glass_kit with Vibe design tokens.
class VibeGlassCard extends StatelessWidget {
  const VibeGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(VibeSpacing.md),
    this.borderRadius = VibeRadius.xl,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.elevation = 0,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer.frostedGlass(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(borderRadius),
        blur: 12,
        alignment: Alignment.center,
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (borderColor ?? Colors.white).withOpacity(0.25),
            (borderColor ?? Colors.white).withOpacity(0.05),
          ],
        ),
        borderWidth: 1.0,
        // isFrostedGlass: true,
        frostedOpacity: 0.02,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A subtle inner glow container used for active/selected states
class VibeGlowContainer extends StatelessWidget {
  const VibeGlowContainer({
    super.key,
    required this.child,
    this.glowColor = VibeColors.primaryPurple,
    this.borderRadius = VibeRadius.xl,
    this.padding = const EdgeInsets.all(VibeSpacing.md),
  });

  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glowColor.withOpacity(0.15),
            glowColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: glowColor.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Gradient button used for primary CTAs
class VibePrimaryButton extends StatefulWidget {
  const VibePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final bool isLoading;

  @override
  State<VibePrimaryButton> createState() => _VibePrimaryButtonState();
}

class _VibePrimaryButtonState extends State<VibePrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.width ?? double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: VibeColors.glowGradient,
            borderRadius: BorderRadius.circular(VibeRadius.full),
            boxShadow: [
              BoxShadow(
                color: VibeColors.primaryPurple.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: VibeSpacing.sm),
                      ],
                      Text(
                        widget.label,
                        style: VibeTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class VibeOutlinedButton extends StatelessWidget {
  const VibeOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VibeRadius.full),
          border: Border.all(
            color: VibeColors.glassBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: VibeTypography.labelLarge.copyWith(
              color: VibeColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
