import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/vibe_theme.dart';
import '../../domain/active_sound.dart';
import '../providers/sound_player_provider.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// FloatingMiniPlayer
/// - Appears with slide+fade when sounds become active
/// - Tap the waveform icon to expand the mixer panel
/// - Mixer shows per-sound volume sliders + individual stop buttons
/// ════════════════════════════════════════════════════════════════════════════
class FloatingMiniPlayer extends StatefulWidget {
  const FloatingMiniPlayer({super.key});

  @override
  State<FloatingMiniPlayer> createState() => _FloatingMiniPlayerState();
}

class _FloatingMiniPlayerState extends State<FloatingMiniPlayer>
    with SingleTickerProviderStateMixin {
  bool _mixerExpanded = false;

  void _toggleMixer() => setState(() => _mixerExpanded = !_mixerExpanded);

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundPlayerProvider>(
      builder: (context, provider, _) {
        final hasActive = provider.hasActiveSounds;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1.5),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: hasActive
              ? _PlayerBody(
                  key: const ValueKey('player'),
                  provider: provider,
                  mixerExpanded: _mixerExpanded,
                  onToggleMixer: _toggleMixer,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        );
      },
    );
  }
}

// ── Player body ───────────────────────────────────────────────────────────────

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({
    super.key,
    required this.provider,
    required this.mixerExpanded,
    required this.onToggleMixer,
  });

  final SoundPlayerProvider provider;
  final bool mixerExpanded;
  final VoidCallback onToggleMixer;

  @override
  Widget build(BuildContext context) {
    final sounds = provider.activeSounds;
    final isAnyPlaying = sounds.any((s) => s.isPlaying);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VibeSpacing.md,
        vertical: VibeSpacing.sm,
      ),
      child: Container(
        constraints: BoxConstraints(
          // maxWidth: 400.w,
          maxHeight: mixerExpanded ? 200.h : 80.h,
        ),
        child: GlassContainer.frostedGlass(
          // height: 120.h,
          // width: double.infinity,
          borderRadius: BorderRadius.circular(VibeRadius.xl),
          blur: 24,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              VibeColors.primaryPurple.withOpacity(0.28),
              VibeColors.deepPurple.withOpacity(0.18),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              VibeColors.accentViolet.withOpacity(0.55),
              VibeColors.primaryPurple.withOpacity(0.2),
            ],
          ),
          borderWidth: 1,
          frostedOpacity: 0.02,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Compact bar ──────────────────────────────────────────────────
              SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VibeSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Emoji stack
                      _EmojiStack(sounds: sounds.take(3).toList()),
                      const SizedBox(width: VibeSpacing.sm),

                      // Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sounds.map((s) => s.name).join(' • '),
                              style: VibeTypography.labelMedium.copyWith(
                                color: VibeColors.textPrimary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${sounds.length} ${sounds.length == 1 ? 'صوت نشط' : 'أصوات نشطة'}',
                              style: VibeTypography.caption.copyWith(
                                color: VibeColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Mixer toggle
                      _IconBtn(
                        icon: mixerExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.tune_rounded,
                        active: mixerExpanded,
                        onTap: onToggleMixer,
                        tooltip: 'المزج',
                      ),
                      const SizedBox(width: 6),

                      // Play / Pause all
                      _PlayPauseBtn(
                        isPlaying: isAnyPlaying,
                        onTap: () => isAnyPlaying
                            ? provider.pauseAll()
                            : provider.resumeAll(),
                      ),
                      const SizedBox(width: 6),

                      // Stop all
                      _IconBtn(
                        icon: Icons.close_rounded,
                        onTap: provider.stopAll,
                        tooltip: 'إيقاف الكل',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Mixer panel (expandable) ─────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: mixerExpanded
                    ? _MixerPanel(provider: provider)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mixer panel ───────────────────────────────────────────────────────────────

class _MixerPanel extends StatelessWidget {
  const _MixerPanel({required this.provider});
  final SoundPlayerProvider provider;

  @override
  Widget build(BuildContext context) {
    final sounds = provider.activeSounds;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibeSpacing.md,
        0,
        VibeSpacing.md,
        VibeSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: VibeSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  VibeColors.accentViolet.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          Text(
            'المزج',
            style: VibeTypography.caption.copyWith(
              color: VibeColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: VibeSpacing.sm),

          // Per-sound rows
          ...sounds.map((sound) => _MixerRow(sound: sound, provider: provider)),
        ],
      ),
    );
  }
}

class _MixerRow extends StatelessWidget {
  const _MixerRow({required this.sound, required this.provider});
  final ActiveSound sound;
  final SoundPlayerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Emoji + play/pause
          GestureDetector(
            onTap: () {
              if (sound.isPlaying) {
                provider.pauseSound(sound.id);
              } else {
                provider.resumeSound(sound.id);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: sound.isPlaying
                    ? VibeColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: sound.isPlaying
                      ? Text(
                          sound.emoji,
                          key: const ValueKey('emoji'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          key: const ValueKey('play'),
                          color: VibeColors.textMuted,
                          size: 18,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: VibeSpacing.sm),

          // Name
          SizedBox(
            width: 60,
            child: Text(
              sound.name,
              style: VibeTypography.caption.copyWith(
                color: VibeColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: VibeSpacing.xs),

          // Volume slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: VibeColors.accentViolet,
                inactiveTrackColor: Colors.white.withOpacity(0.08),
                thumbColor: VibeColors.glowPurple,
                overlayColor: VibeColors.primaryPurple.withOpacity(0.15),
              ),
              child: Slider(
                value: sound.volume,
                onChanged: (v) => provider.setVolume(sound.id, v),
                min: 0,
                max: 1,
              ),
            ),
          ),

          // Volume percentage
          SizedBox(
            width: 30,
            child: Text(
              '${(sound.volume * 100).round()}%',
              style: VibeTypography.caption.copyWith(
                color: VibeColors.textMuted,
                fontSize: 10,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 4),

          // Remove this sound
          GestureDetector(
            onTap: () => provider.toggleSound(
              soundId: sound.id,
              soundName: sound.name,
              audioUrl: '', // already active, toggleSound will remove it
              emoji: sound.emoji,
            ),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: VibeColors.textMuted.withOpacity(0.6),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Emoji stack ───────────────────────────────────────────────────────────────

class _EmojiStack extends StatelessWidget {
  const _EmojiStack({required this.sounds});
  final List<ActiveSound> sounds;

  @override
  Widget build(BuildContext context) {
    if (sounds.isEmpty) return const SizedBox(width: 32, height: 36);
    final width = 18.0 * (sounds.length - 1) + 32.0;
    return SizedBox(
      width: width,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: sounds.asMap().entries.map((e) {
          return Positioned(
            left: e.key * 18.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VibeColors.surfaceVariant,
                border: Border.all(color: VibeColors.glassBorder, width: 1.5),
              ),
              child: Center(
                child: Text(
                  e.value.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Play/Pause button ─────────────────────────────────────────────────────────

class _PlayPauseBtn extends StatelessWidget {
  const _PlayPauseBtn({required this.isPlaying, required this.onTap});
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: VibeColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: VibeColors.primaryPurple.withOpacity(0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ── Generic icon button ───────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? VibeColors.primaryPurple.withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          border: active
              ? Border.all(
                  color: VibeColors.accentViolet.withOpacity(0.5),
                  width: 1,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: active ? VibeColors.accentViolet : VibeColors.textMuted,
          size: 16,
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
