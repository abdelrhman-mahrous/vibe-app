import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/cache/vibe_cache.dart';
import '../../../../../core/services/network_info.dart';
import '../../../../../core/theme/vibe_theme.dart';
import '../../data/models/sound_model.dart';
import '../../data/repos/sound_repository.dart';
import '../widgets/animated_background.dart';
import '../widgets/sound_card.dart';
import '../widgets/streak_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with NetworkAware {
  late final SoundRepository _repository;
  List<SoundModel> _sounds = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _selectedCategory = 'all';

  final _categories = const [
    ('all', 'الكل'),
    ('nature', 'طبيعة'),
    ('noise', 'ضوضاء'),
    ('favorites', 'مفضلة'),
  ];

  @override
  void initState() {
    super.initState();
    _repository = SoundRepositoryImpl();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final connected = await isConnected;
    setState(() => _isOffline = !connected);

    final sounds = await _repository.getSounds();
    if (mounted) {
      setState(() {
        _sounds = sounds;
        _isLoading = false;
      });
    }
  }

  List<SoundModel> get _filteredSounds {
    if (_selectedCategory == 'favorites') {
      return _sounds
          .where((s) => VibeCache.instance.isSoundFavorite(s.id))
          .toList();
    }
    if (_selectedCategory == 'all') return _sounds;
    return _sounds.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _HomeHeader(isOffline: _isOffline),
          _CategoryFilter(
            categories: _categories,
            selected: _selectedCategory,
            onSelect: (cat) => setState(() => _selectedCategory = cat),
          ),
          Expanded(
            child: _isLoading
                ? const _LoadingGrid()
                : _SoundsGrid(sounds: _filteredSounds),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibeSpacing.lg,
        VibeSpacing.lg,
        VibeSpacing.lg,
        VibeSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StreakIndicator(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _greeting,
                    style: VibeTypography.caption.copyWith(
                      color: VibeColors.textMuted,
                      letterSpacing: 1,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    'استرخِ وركّز',
                    style: VibeTypography.headlineLarge,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
          if (isOffline) ...[
            const SizedBox(height: VibeSpacing.sm),
            _OfflineBanner(),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 18) return 'مساء النور 🌤️';
    return 'مساء النجوم 🌙';
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VibeSpacing.md,
        vertical: VibeSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VibeRadius.sm),
        color: VibeColors.warning.withOpacity(0.15),
        border: Border.all(color: VibeColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: VibeColors.warning, size: 14),
          const SizedBox(width: VibeSpacing.xs),
          Text(
            'وضع عدم الاتصال - عرض البيانات المحفوظة',
            style: VibeTypography.caption.copyWith(color: VibeColors.warning),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<(String, String)> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: VibeSpacing.sm),
        itemBuilder: (_, i) {
          final (id, label) = categories[i];
          final isSelected = id == selected;
          return GestureDetector(
            onTap: () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: VibeSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VibeRadius.full),
                gradient: isSelected ? VibeColors.primaryGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: VibeColors.primaryPurple.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: VibeTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : VibeColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _SoundsGrid extends StatelessWidget {
  const _SoundsGrid({required this.sounds});
  final List<SoundModel> sounds;

  @override
  Widget build(BuildContext context) {
    if (sounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: VibeSpacing.md),
            Text(
              'لا توجد أصوات',
              style: VibeTypography.bodyMedium,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        VibeSpacing.lg,
        VibeSpacing.md,
        VibeSpacing.lg,
        120,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: VibeSpacing.md,
        mainAxisSpacing: VibeSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: sounds.length,
      itemBuilder: (_, i) => SoundCard(sound: sounds[i], index: i),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(VibeSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: VibeSpacing.md,
        mainAxisSpacing: VibeSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => _ShimmerCard(index: i),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.index});
  final int index;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VibeRadius.xl),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.04 + _controller.value * 0.04),
              Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
      ),
    ).animate(delay: (widget.index * 60).ms).fadeIn();
  }
}
