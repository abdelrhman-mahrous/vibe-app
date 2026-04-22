import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import '../../../../../core/cache/vibe_cache.dart';
import '../../../../../core/theme/vibe_theme.dart';
import '../../../player/views/providers/sound_player_provider.dart';
import '../../data/models/sound_model.dart';

class SoundCard extends StatefulWidget {
  const SoundCard({super.key, required this.sound, required this.index});

  final SoundModel sound;
  final int index;

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // Reads state at call-time → always current, never stale
  Future<void> _handleTap(SoundPlayerProvider provider) async {
    final isPending = provider.isSoundPending(widget.sound.id);
    final isActive = provider.isSoundActive(widget.sound.id);
    final isPlaying = provider.isSoundPlaying(widget.sound.id);

    if (isPending) return;

    if (isActive) {
      if (isPlaying) {
        await provider.pauseSound(widget.sound.id);
      } else {
        await provider.resumeSound(widget.sound.id);
      }
    } else {
      await provider.toggleSound(
        soundId: widget.sound.id,
        soundName: widget.sound.name,
        audioUrl: widget.sound.audioUrl,
        emoji: widget.sound.emoji,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundPlayerProvider>(
      builder: (context, provider, _) {
        // ── Single source of truth: read everything fresh ──────────────────
        final bool isActive = provider.isSoundActive(widget.sound.id);
        final bool isPlaying = provider.isSoundPlaying(widget.sound.id);
        final bool isPending = provider.isSoundPending(widget.sound.id);
        final double volume = provider.getSoundVolume(widget.sound.id);

        return AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: isPlaying ? _pulseAnim.value : 1.0,
            child: child,
          ),
          child:
              AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: isActive
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(VibeRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: VibeColors.primaryPurple.withOpacity(
                                  0.28,
                                ),
                                blurRadius: 20,
                              ),
                            ],
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(VibeSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Row 1: emoji + favourite ───────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SoundEmoji(
                                emoji: widget.sound.emoji,
                                isActive: isActive,
                                isPending: isPending,
                              ),
                              _FavoriteButton(soundId: widget.sound.id),
                            ],
                          ),
                          const SizedBox(height: VibeSpacing.sm),

                          // ── Row 2: name ───────────────────────────────────────
                          Text(
                            widget.sound.name,
                            style: VibeTypography.labelLarge.copyWith(
                              color: isActive
                                  ? VibeColors.textPrimary
                                  : VibeColors.textSecondary,
                              fontSize: 15,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: VibeSpacing.sm),

                          // ── Row 3: volume (only when active) ──────────────────
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isActive
                                ? _VolumeSlider(
                                    volume: volume,
                                    onChanged: (v) =>
                                        provider.setVolume(widget.sound.id, v),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: VibeSpacing.sm),

                          // ── Row 4: play / pause ───────────────────────────────
                          // ALL state passed as plain primitives — no nullable objects
                          _PlayButton(
                            isActive: isActive,
                            isPlaying: isPlaying,
                            isPending: isPending,
                            onTap: () => _handleTap(provider),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (widget.index * 80).ms)
                  .fadeIn()
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
        );
      },
    );
  }
}

// ── Emoji ─────────────────────────────────────────────────────────────────────

class _SoundEmoji extends StatelessWidget {
  const _SoundEmoji({
    required this.emoji,
    required this.isActive,
    required this.isPending,
  });

  final String emoji;
  final bool isActive;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? VibeColors.primaryGradient
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: VibeColors.primaryPurple.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isPending
              ? const SizedBox(
                  key: ValueKey('spinner'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              : Text(
                  emoji,
                  key: const ValueKey('emoji'),
                  style: const TextStyle(fontSize: 24),
                ),
        ),
      ),
    );
  }
}

// ── Favourite ─────────────────────────────────────────────────────────────────

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.soundId});
  final String soundId;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = VibeCache.instance.isSoundFavorite(widget.soundId);
  }

  Future<void> _toggle() async {
    await VibeCache.instance.toggleFavoriteSound(widget.soundId);
    if (mounted) setState(() => _isFav = !_isFav);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Icon(
          _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(_isFav),
          color: _isFav ? VibeColors.neonPurple : VibeColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}

// ── Volume slider ─────────────────────────────────────────────────────────────

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.volume, required this.onChanged});

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.volume_down_rounded,
          color: VibeColors.textMuted,
          size: 16,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: VibeColors.accentViolet,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: VibeColors.glowPurple,
              overlayColor: VibeColors.primaryPurple.withOpacity(0.2),
            ),
            child: Slider(value: volume, onChanged: onChanged, min: 0, max: 1),
          ),
        ),
        const Icon(
          Icons.volume_up_rounded,
          color: VibeColors.textMuted,
          size: 16,
        ),
      ],
    );
  }
}

// ── Play button ───────────────────────────────────────────────────────────────
// Takes ONLY plain booleans — zero nullable access, zero ambiguity.
//
// State matrix (evaluated top-down, first match wins):
//   isPending              → spinner + "جاري التحميل..."
//   !isActive              → play icon + "تشغيل"
//   isActive && isPlaying  → pause icon + "إيقاف"        ✅ synced with mini-player
//   isActive && !isPlaying → play icon  + "استئناف"      ✅ synced with mini-player

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isActive,
    required this.isPlaying,
    required this.isPending,
    required this.onTap,
  });

  final bool isActive;
  final bool isPlaying;
  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ── Resolve label + icon from state matrix ────────────────────────────
    final IconData icon;
    final String label;

    if (isPending) {
      icon = Icons.hourglass_top_rounded;
      label = 'جاري التحميل...';
    } else if (!isActive) {
      icon = Icons.play_arrow_rounded;
      label = 'تشغيل';
    } else if (isPlaying) {
      icon = Icons.pause_rounded; // ✅ playing  → show Pause
      label = 'إيقاف';
    } else {
      icon = Icons.play_arrow_rounded; // ✅ paused   → show Play
      label = 'استئناف';
    }

    return GestureDetector(
      onTap: isPending ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle icon button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
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
                duration: const Duration(milliseconds: 180),
                child: isPending
                    ? const SizedBox(
                        key: ValueKey('spin'),
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white54,
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        key: ValueKey(icon.codePoint), // unique key per icon
                        size: 16,
                        color: isActive ? Colors.white : VibeColors.textMuted,
                      ),
              ),
            ),
          ),

          const SizedBox(width: VibeSpacing.xs),

          // Label — animates style change smoothly
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: VibeTypography.caption.copyWith(
              color: isActive ? VibeColors.textAccent : VibeColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
