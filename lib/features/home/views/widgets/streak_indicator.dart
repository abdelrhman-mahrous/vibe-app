import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../../core/cache/vibe_cache.dart';
import '../../../../../core/theme/vibe_theme.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = VibeCache.instance.focusStreak;

    return Container(
      constraints: BoxConstraints(maxWidth: 150.w, maxHeight: 40.h),
      child: GlassContainer.frostedGlass(
        // width: 120, // أضف عرضاً محدداً هنا
        // height: 44,
        // height: 44,
        borderRadius: BorderRadius.circular(VibeRadius.full),
        blur: 10,
        gradient: LinearGradient(
          colors: [
            VibeColors.primaryPurple.withOpacity(0.2),
            VibeColors.deepPurple.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            VibeColors.accentViolet.withOpacity(0.4),
            VibeColors.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderWidth: 1,
        frostedOpacity: 0.01,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: VibeSpacing.xs),
              Text(
                '$streak أيام',
                style: VibeTypography.labelMedium.copyWith(
                  color: VibeColors.textAccent,
                  fontWeight: FontWeight.w700,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(width: VibeSpacing.md),
              Text(
                'سلسلة التركيز',
                style: VibeTypography.caption.copyWith(
                  color: VibeColors.textMuted,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
