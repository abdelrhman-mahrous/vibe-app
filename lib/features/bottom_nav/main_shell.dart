import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vibe_theme.dart';
import '../home/views/screens/home_screen.dart';
import '../player/views/providers/sound_player_provider.dart';
import '../player/views/widgets/floating_mini_player.dart';
import '../todo/views/screens/todo_screen.dart';
import 'pomodoro_screen.dart';
import 'mixer_screen.dart';
import 'external_audio_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TodoScreen(),
    PomodoroScreen(),
    MixerScreen(),
    ExternalAudioScreen(),
  ];

  final _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.check_circle_outline_rounded, label: 'المهام'),
    _NavItem(icon: Icons.timer_rounded, label: 'بومودورو'),
    _NavItem(icon: Icons.tune_rounded, label: 'المزج'),
    _NavItem(icon: Icons.podcasts_rounded, label: 'خارجي'),
  ];

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Screens
            Directionality(
              textDirection: TextDirection.ltr,
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),

            // Positioned(top: 20, left: 0, right: 0, child: FloatingMiniPlayer()),
            // Bottom overlay: mini player + nav bar
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingMiniPlayer(),
                  // Floating mini player appears above nav
                  // Consumer<SoundPlayerProvider>(
                  //   builder: (_, provider, __) {
                  //     if (!provider.hasActiveSounds) {
                  //       return const SizedBox.shrink();
                  //     }
                  //     return const FloatingMiniPlayer();
                  //   },
                  // ),
                  _VibeBottomNav(
                    items: _navItems,
                    currentIndex: _currentIndex,
                    onTap: _onTabChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _VibeBottomNav extends StatelessWidget {
  const _VibeBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: VibeSpacing.md,
        right: VibeSpacing.md,
        bottom: bottomPadding + VibeSpacing.sm,
      ),
      child: GlassContainer.frostedGlass(
        height: 64.h,
        borderRadius: BorderRadius.circular(VibeRadius.xxl),
        blur: 24,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderWidth: 1,
        // isFrostedGlass: true,
        frostedOpacity: 0.02,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            return _NavBarItem(
              item: entry.value,
              isSelected: entry.key == currentIndex,
              onTap: () => onTap(entry.key),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_NavBarItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 64,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40,
                height: 32,
                decoration: widget.isSelected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(VibeRadius.md),
                        gradient: VibeColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: VibeColors.primaryPurple.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  widget.item.icon,
                  size: 20,
                  color: widget.isSelected
                      ? Colors.white
                      : VibeColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: VibeTypography.caption.copyWith(
                  color: widget.isSelected
                      ? VibeColors.textAccent
                      : VibeColors.textMuted,
                  fontSize: widget.isSelected ? 10 : 9,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
                child: Text(
                  widget.item.label,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
