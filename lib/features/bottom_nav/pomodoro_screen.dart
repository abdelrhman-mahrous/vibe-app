import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../core/cache/vibe_cache.dart';
import '../../../core/theme/vibe_theme.dart';
import '../../core/global_widgets/vibe_widgets.dart';
import '../home/views/widgets/animated_background.dart';

enum _PomodoroMode { focus, shortBreak, longBreak }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  _PomodoroMode _mode = _PomodoroMode.focus;
  bool _isRunning = false;
  late int _secondsLeft;
  late AnimationController _ringController;

  static const _durations = {
    _PomodoroMode.focus: 25 * 60,
    _PomodoroMode.shortBreak: 5 * 60,
    _PomodoroMode.longBreak: 15 * 60,
  };

  int get _totalSeconds => _durations[_mode]!;
  double get _progress => 1 - (_secondsLeft / _totalSeconds);

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _tick() {
    if (!_isRunning) return;
    if (_secondsLeft > 0) {
      setState(() => _secondsLeft--);
      Future.delayed(const Duration(seconds: 1), _tick);
    } else {
      _onTimerComplete();
    }
  }

  void _onTimerComplete() {
    HapticFeedback.heavyImpact();
    setState(() => _isRunning = false);
    if (_mode == _PomodoroMode.focus) {
      VibeCache.instance.incrementFocusStreak();
    }
  }

  void _start() {
    setState(() => _isRunning = true);
    _ringController.forward(from: 0);
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _pause() => setState(() => _isRunning = false);

  void _reset() {
    setState(() {
      _isRunning = false;
      _secondsLeft = _totalSeconds;
    });
    _ringController.reverse();
  }

  void _setMode(_PomodoroMode mode) {
    setState(() {
      _mode = mode;
      _isRunning = false;
      _secondsLeft = _totalSeconds;
    });
  }

  String get _timeDisplay {
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: SafeArea(
        child: Column(
          children: [
            _PomodoroHeader().animate().fadeIn(),
            const SizedBox(height: VibeSpacing.lg),
            _ModeSelector(mode: _mode, onSelect: _setMode)
                .animate()
                .fadeIn(delay: 100.ms),
            const Spacer(),
            _CircularTimer(
              progress: _progress,
              timeDisplay: _timeDisplay,
              mode: _mode,
              isRunning: _isRunning,
            ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(delay: 200.ms),
            const Spacer(),
            _PomodoroControls(
              isRunning: _isRunning,
              onStart: _start,
              onPause: _pause,
              onReset: _reset,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _PomodoroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VibeSpacing.lg, VibeSpacing.lg, VibeSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('بومودورو',
              style: VibeTypography.headlineLarge,
              textDirection: TextDirection.rtl),
          Text('وقت التركيز والإنجاز',
              style: VibeTypography.bodyMedium,
              textDirection: TextDirection.rtl),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onSelect});
  final _PomodoroMode mode;
  final ValueChanged<_PomodoroMode> onSelect;

  static const _modes = [
    (_PomodoroMode.focus, 'تركيز'),
    (_PomodoroMode.shortBreak, 'راحة قصيرة'),
    (_PomodoroMode.longBreak, 'راحة طويلة'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer.frostedGlass(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: VibeSpacing.lg),
      borderRadius: BorderRadius.circular(VibeRadius.full),
      blur: 10,
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.06),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _modes.map((m) {
          final isSelected = m.$1 == mode;
          return GestureDetector(
            onTap: () => onSelect(m.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                  horizontal: VibeSpacing.md, vertical: VibeSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VibeRadius.full),
                gradient: isSelected ? VibeColors.primaryGradient : null,
              ),
              child: Text(
                m.$2,
                style: VibeTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : VibeColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CircularTimer extends StatelessWidget {
  const _CircularTimer({
    required this.progress,
    required this.timeDisplay,
    required this.mode,
    required this.isRunning,
  });

  final double progress;
  final String timeDisplay;
  final _PomodoroMode mode;
  final bool isRunning;

  String get _modeLabel {
    switch (mode) {
      case _PomodoroMode.focus:
        return 'وقت التركيز';
      case _PomodoroMode.shortBreak:
        return 'راحة قصيرة';
      case _PomodoroMode.longBreak:
        return 'راحة طويلة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          if (isRunning)
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: VibeColors.primaryPurple.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          // Progress arc
          CustomPaint(
            size: const Size(240, 240),
            painter: _RingPainter(progress: progress),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeDisplay,
                style: VibeTypography.displayLarge.copyWith(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: VibeSpacing.xs),
              Text(
                _modeLabel,
                style: VibeTypography.bodyMedium.copyWith(
                  color: VibeColors.textMuted,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 8.0;
    const startAngle = -math.pi / 2;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final shader = const SweepGradient(
        colors: [Color(0xFF9D4EDD), Color(0xFF7B2FBE), Color(0xFFBB86FC)],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final progressPaint = Paint()
        ..shader = shader
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progress * 2 * math.pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _PomodoroControls extends StatelessWidget {
  const _PomodoroControls({
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.xl),
      child: Row(
        children: [
          // Reset button
          GestureDetector(
            onTap: onReset,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: VibeColors.textMuted,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: VibeSpacing.md),
          // Main button
          Expanded(
            child: VibePrimaryButton(
              label: isRunning ? 'إيقاف مؤقت' : 'ابدأ',
              icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              onPressed: isRunning ? onPause : onStart,
            ),
          ),
        ],
      ),
    );
  }
}
