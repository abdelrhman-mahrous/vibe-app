import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../core/theme/vibe_theme.dart';
import '../../core/global_widgets/vibe_widgets.dart';
import '../home/views/widgets/animated_background.dart';

class ExternalAudioScreen extends StatefulWidget {
  const ExternalAudioScreen({super.key});

  @override
  State<ExternalAudioScreen> createState() => _ExternalAudioScreenState();
}

class _ExternalAudioScreenState extends State<ExternalAudioScreen> {
  final _ytController = TextEditingController();
  final _podcastController = TextEditingController();

  @override
  void dispose() {
    _ytController.dispose();
    _podcastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            VibeSpacing.lg,
            VibeSpacing.lg,
            VibeSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ExternalHeader().animate().fadeIn(),
              const SizedBox(height: VibeSpacing.xl),
              _AudioSourceCard(
                title: 'YouTube',
                subtitle: 'أضف رابط فيديو',
                emoji: '📺',
                controller: _ytController,
                placeholder: 'الصق رابط YouTube هنا...',
                onAdd: () => _handleAdd('youtube', _ytController.text),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: VibeSpacing.md),
              _AudioSourceCard(
                title: 'بودكاست',
                subtitle: 'أضف رابط حلقة',
                emoji: '🎙️',
                controller: _podcastController,
                placeholder: 'الصق رابط البودكاست هنا...',
                onAdd: () => _handleAdd('podcast', _podcastController.text),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: VibeSpacing.md),
              _LocalFileCard()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAdd(String type, String url) {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال رابط صحيح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: VibeColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibeRadius.md),
          ),
        ),
      );
      return;
    }
    // TODO: integrate with audio player
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة الرابط', textDirection: TextDirection.rtl),
        backgroundColor: VibeColors.success.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
        ),
      ),
    );
  }
}

class _ExternalHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الصوت الخارجي',
          style: VibeTypography.headlineLarge,
          textDirection: TextDirection.rtl,
        ),
        Text(
          'أضف مصادر صوتية من الخارج',
          style: VibeTypography.bodyMedium,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _AudioSourceCard extends StatelessWidget {
  const _AudioSourceCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.controller,
    required this.placeholder,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.frostedGlass(
      width: 200,
      height: 40,
      borderRadius: BorderRadius.circular(VibeRadius.xl),
      blur: 14,
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.07),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderWidth: 1,
      frostedOpacity: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(VibeSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: VibeTypography.headlineMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      subtitle,
                      style: VibeTypography.bodyMedium,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(width: VibeSpacing.md),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: VibeColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VibeSpacing.md),
            Row(
              children: [
                const SizedBox(width: VibeSpacing.sm),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VibeSpacing.md,
                      vertical: VibeSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VibeRadius.md),
                      gradient: VibeColors.primaryGradient,
                    ),
                    child: Text(
                      'إضافة',
                      style: VibeTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: VibeSpacing.sm),
                Expanded(
                  child: _VibeTextField(
                    controller: controller,
                    placeholder: placeholder,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VibeTextField extends StatelessWidget {
  const _VibeTextField({required this.controller, required this.placeholder});
  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.ltr,
      style: VibeTypography.bodyMedium.copyWith(color: VibeColors.textPrimary),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: VibeTypography.bodyMedium.copyWith(
          color: VibeColors.textMuted,
          fontSize: 12,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VibeSpacing.md,
          vertical: VibeSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VibeRadius.md),
          borderSide: BorderSide(
            color: VibeColors.accentViolet.withOpacity(0.6),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _LocalFileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer.frostedGlass(
      width: 200,
      height: 40,
      borderRadius: BorderRadius.circular(VibeRadius.xl),
      blur: 14,
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.07),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderWidth: 1,
      frostedOpacity: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(VibeSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ملف محلي',
                      style: VibeTypography.headlineMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'ارفع ملف صوتي من جهازك',
                      style: VibeTypography.bodyMedium,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(width: VibeSpacing.md),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(
                    Icons.upload_rounded,
                    color: VibeColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: VibeSpacing.md),
            VibePrimaryButton(
              label: 'انقر لاختيار ملف صوتي',
              icon: Icons.audio_file_rounded,
              onPressed: () {
                // TODO: file picker integration
              },
            ),
          ],
        ),
      ),
    );
  }
}
