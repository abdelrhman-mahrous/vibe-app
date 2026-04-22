import 'package:shared_preferences/shared_preferences.dart';

/// Manages all local cache and preferences for the app.
/// Single source of truth for persisted non-domain data.
class VibeCache {
  VibeCache._();
  static final VibeCache instance = VibeCache._();

  static const _keyOnboardingDone = 'vibe_onboarding_done';
  static const _keyFocusStreak = 'vibe_focus_streak';
  static const _keyLastFocusDate = 'vibe_last_focus_date';
  static const _keyFavoriteSounds = 'vibe_favorite_sounds';
  static const _keyTheme = 'vibe_theme';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'VibeCache.init() must be called before use.');
    return _prefs!;
  }

  // ── Onboarding ──────────────────────────────────────────────────────────────

  bool get hasSeenOnboarding => _p.getBool(_keyOnboardingDone) ?? false;

  Future<void> markOnboardingDone() async {
    await _p.setBool(_keyOnboardingDone, true);
  }

  Future<void> resetOnboarding() async {
    await _p.setBool(_keyOnboardingDone, false);
  }

  // ── Focus Streak ─────────────────────────────────────────────────────────────

  int get focusStreak => _p.getInt(_keyFocusStreak) ?? 0;

  Future<void> incrementFocusStreak() async {
    final today = _todayDateString;
    final lastDate = _p.getString(_keyLastFocusDate);

    if (lastDate == today) return; // already counted today

    final yesterday = _yesterdayDateString;
    final newStreak = lastDate == yesterday ? focusStreak + 1 : 1;

    await _p.setInt(_keyFocusStreak, newStreak);
    await _p.setString(_keyLastFocusDate, today);
  }

  Future<void> resetStreak() async {
    await _p.setInt(_keyFocusStreak, 0);
    await _p.remove(_keyLastFocusDate);
  }

  // ── Favorites ────────────────────────────────────────────────────────────────

  List<String> get favoriteSoundIds {
    return _p.getStringList(_keyFavoriteSounds) ?? [];
  }

  Future<void> toggleFavoriteSound(String soundId) async {
    final favorites = List<String>.from(favoriteSoundIds);
    if (favorites.contains(soundId)) {
      favorites.remove(soundId);
    } else {
      favorites.add(soundId);
    }
    await _p.setStringList(_keyFavoriteSounds, favorites);
  }

  bool isSoundFavorite(String soundId) => favoriteSoundIds.contains(soundId);

  // ── Private helpers ──────────────────────────────────────────────────────────

  String get _todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get _yesterdayDateString {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  // ── Full reset (dev/testing) ──────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _p.clear();
  }
}
