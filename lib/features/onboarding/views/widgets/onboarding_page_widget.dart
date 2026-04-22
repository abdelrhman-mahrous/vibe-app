import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/vibe_theme.dart';
import '../../data/models/onboarding_data_model.dart';

/// A single onboarding page. Fully reusable and data-driven.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.isActive,
  });

  final OnboardingPageData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradientColors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Spacer(flex: 2),
            _OnboardingIllustration(
              emoji: data.iconEmoji,
              accentColor: data.accentColor,
              isActive: isActive,
            ),

            SizedBox(height: VibeSpacing.xl),
            // const Spacer(flex: 1),
            _OnboardingTextSection(data: data, isActive: isActive),

            // const Spacer(flex: 1),
            SizedBox(height: VibeSpacing.xl),

            _OnboardingFeatureChips(
              features: data.features,
              accentColor: data.accentColor,
              isActive: isActive,
            ),

            SizedBox(height: 66.h),

            // SizedBox(height: VibeSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatefulWidget {
  const _OnboardingIllustration({
    required this.emoji,
    required this.accentColor,
    required this.isActive,
  });

  final String emoji;
  final Color accentColor;
  final bool isActive;

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child:
          Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.accentColor.withOpacity(0.15),
                          widget.accentColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // Middle ring
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.accentColor.withOpacity(0.2),
                          widget.accentColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Inner emoji circle
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor.withOpacity(0.3),
                          widget.accentColor.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                ],
              )
              .animate(target: widget.isActive ? 1 : 0)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .fadeIn(),
    );
  }
}

class _OnboardingTextSection extends StatelessWidget {
  const _OnboardingTextSection({required this.data, required this.isActive});

  final OnboardingPageData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
              data.subtitle,
              style: VibeTypography.labelLarge.copyWith(
                color: data.accentColor,
                // letterSpacing: 2,
                fontSize: 13,
              ),
              textDirection: TextDirection.rtl,
            )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: VibeSpacing.sm),
        Text(
              data.title,
              style: VibeTypography.displayMedium,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: VibeSpacing.md),
        Text(
              data.description,
              style: VibeTypography.bodyLarge.copyWith(
                height: 1.8,
                color: VibeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}

class _OnboardingFeatureChips extends StatelessWidget {
  const _OnboardingFeatureChips({
    required this.features,
    required this.accentColor,
    required this.isActive,
  });

  final List<String> features;
  final Color accentColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: VibeSpacing.sm,
      runSpacing: VibeSpacing.sm,
      alignment: WrapAlignment.center,
      children: features.asMap().entries.map((entry) {
        return _FeatureChip(label: entry.value, accentColor: accentColor)
            .animate(target: isActive ? 1 : 0)
            .fadeIn(delay: (500 + entry.key * 100).ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      }).toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VibeSpacing.md,
        vertical: VibeSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VibeRadius.full),
        color: accentColor.withOpacity(0.12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: VibeTypography.labelMedium.copyWith(
          color: accentColor.withOpacity(0.9),
          fontSize: 12,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
