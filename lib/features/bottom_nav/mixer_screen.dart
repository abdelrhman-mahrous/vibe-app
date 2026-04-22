import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/vibe_theme.dart';
import '../home/data/models/sound_model.dart';
import '../home/data/repos/sound_repository.dart';
import '../home/views/widgets/animated_background.dart';
import '../player/domain/active_sound.dart';
import '../player/views/providers/sound_player_provider.dart';

class MixerScreen extends StatefulWidget {
  const MixerScreen({super.key});

  @override
  State<MixerScreen> createState() => _MixerScreenState();
}

class _MixerScreenState extends State<MixerScreen> {
  late final SoundRepository _repo;
  List<SoundModel> _sounds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = SoundRepositoryImpl();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    final sounds = await _repo.getSounds();
    if (mounted)
      setState(() {
        _sounds = sounds;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MixerHeader().animate().fadeIn(),
            const SizedBox(height: VibeSpacing.md),
            Consumer<SoundPlayerProvider>(
              builder: (_, provider, __) {
                if (!provider.hasActiveSounds) return const SizedBox.shrink();
                return _ActiveMixPanel(
                  provider: provider,
                ).animate().fadeIn().slideY(begin: -0.1);
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: VibeColors.accentViolet,
                      ),
                    )
                  : _SoundPicker(sounds: _sounds),
            ),
          ],
        ),
      ),
    );
  }
}

class _MixerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibeSpacing.lg,
        VibeSpacing.lg,
        VibeSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'المزج',
            style: VibeTypography.headlineLarge,
            textDirection: TextDirection.rtl,
          ),
          Text(
            'امزج أصواتك المفضلة معاً',
            style: VibeTypography.bodyMedium,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _ActiveMixPanel extends StatelessWidget {
  const _ActiveMixPanel({required this.provider});
  final SoundPlayerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.lg),
      child: GlassContainer.frostedGlass(
        width: 200,
        height: 50,
        borderRadius: BorderRadius.circular(VibeRadius.xl),
        blur: 14,
        gradient: LinearGradient(
          colors: [
            VibeColors.primaryPurple.withOpacity(0.15),
            VibeColors.deepPurple.withOpacity(0.08),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            VibeColors.accentViolet.withOpacity(0.4),
            VibeColors.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderWidth: 1,
        // isFrostedGlass: true,
        frostedOpacity: 0.01,
        child: Padding(
          padding: const EdgeInsets.all(VibeSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${provider.activeSounds.length} أصوات نشطة',
                    style: VibeTypography.caption.copyWith(
                      color: VibeColors.textMuted,
                    ),
                  ),
                  Text(
                    'يعزف الآن',
                    style: VibeTypography.labelLarge.copyWith(
                      color: VibeColors.accentViolet,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(height: VibeSpacing.sm),
              ...provider.activeSounds.map(
                (s) => _ActiveSoundRow(sound: s, provider: provider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSoundRow extends StatelessWidget {
  const _ActiveSoundRow({required this.sound, required this.provider});
  final ActiveSound sound;
  final SoundPlayerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VibeSpacing.xs),
      child: Row(
        children: [
          // Remove
          GestureDetector(
            onTap: () => provider.toggleSound(
              soundId: sound.id,
              soundName: sound.name,
              audioUrl: '',
              emoji: sound.emoji,
            ),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VibeColors.error.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: VibeColors.error,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: VibeSpacing.sm),
          // Volume
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: VibeColors.accentViolet,
                inactiveTrackColor: Colors.white.withOpacity(0.08),
                thumbColor: VibeColors.glowPurple,
                overlayColor: VibeColors.primaryPurple.withOpacity(0.2),
              ),
              child: Slider(
                value: sound.volume,
                onChanged: (v) => provider.setVolume(sound.id, v),
                min: 0,
                max: 1,
              ),
            ),
          ),
          const SizedBox(width: VibeSpacing.sm),
          // Name + emoji
          Text(sound.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: VibeSpacing.xs),
          Text(
            sound.name,
            style: VibeTypography.labelMedium.copyWith(
              color: VibeColors.textPrimary,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _SoundPicker extends StatelessWidget {
  const _SoundPicker({required this.sounds});
  final List<SoundModel> sounds;

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundPlayerProvider>(
      builder: (_, provider, __) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          VibeSpacing.lg,
          VibeSpacing.md,
          VibeSpacing.lg,
          120,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: VibeSpacing.sm,
          mainAxisSpacing: VibeSpacing.sm,
          childAspectRatio: 1.0,
        ),
        itemCount: sounds.length,
        itemBuilder: (_, i) {
          final s = sounds[i];
          final isActive = provider.isSoundActive(s.id);
          return GestureDetector(
            onTap: () => provider.toggleSound(
              soundId: s.id,
              soundName: s.name,
              audioUrl: s.audioUrl,
              emoji: s.emoji,
            ),
            child:
                AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VibeRadius.lg),
                        gradient: isActive
                            ? VibeColors.primaryGradient
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.07),
                                  Colors.white.withOpacity(0.03),
                                ],
                              ),
                        border: Border.all(
                          color: isActive
                              ? VibeColors.accentViolet.withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: VibeColors.primaryPurple.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: VibeSpacing.xs),
                          Text(
                            s.name,
                            style: VibeTypography.caption.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : VibeColors.textMuted,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 20,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    .animate(delay: (i * 40).ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.8, 0.8)),
          );
        },
      ),
    );
  }
}
