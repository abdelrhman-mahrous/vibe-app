import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/active_sound.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// RULES enforced in this provider:
///  1. NEVER call notifyListeners() inside a getter — getters are pure.
///  2. ALWAYS update _activeSounds BEFORE calling notifyListeners().
///  3. ALWAYS use try/catch/finally — never let _pendingIds leak a soundId.
///  4. State is updated optimistically (UI first, then audio engine).
///  5. No sound can be toggled while it is pending (_pendingIds guard).
/// ════════════════════════════════════════════════════════════════════════════
class SoundPlayerProvider extends ChangeNotifier {
  SoundPlayerProvider();

  // ── Internal state ──────────────────────────────────────────────────────────
  final Map<String, ActiveSound> _sounds = {};
  final Set<String> _pending = {};

  // ── Public read-only API ────────────────────────────────────────────────────

  /// Immutable snapshot — never expose the internal map directly.
  List<ActiveSound> get activeSounds =>
      List.unmodifiable(_sounds.values.toList());

  bool get hasActiveSounds => _sounds.isNotEmpty;

  /// Pure getters — NO side effects, NO notifyListeners.
  bool isSoundActive(String id) => _sounds.containsKey(id);
  bool isSoundPlaying(String id) => _sounds[id]?.isPlaying ?? false;
  bool isSoundPending(String id) => _pending.contains(id); // ← pure, no notify
  double getSoundVolume(String id) => _sounds[id]?.volume ?? 0.7;

  ActiveSound? getActiveSound(String id) =>
      _sounds[id]; // for passing full sound to widgets
  // ── Toggle (add / remove) ───────────────────────────────────────────────────

  Future<void> toggleSound({
    required String soundId,
    required String soundName,
    required String audioUrl,
    required String emoji,
  }) async {
    // Guard: ignore double-taps while operation is in flight
    if (_pending.contains(soundId)) return;

    _pending.add(soundId);
    _notify(); // UI: show loading spinner

    try {
      if (_sounds.containsKey(soundId)) {
        await _removeSound(soundId);
      } else {
        await _addSound(
          soundId: soundId,
          soundName: soundName,
          audioUrl: audioUrl,
          emoji: emoji,
        );
      }
    } catch (e, st) {
      debugPrint('[SoundPlayer] toggleSound failed for $soundId: $e\n$st');
    } finally {
      // ALWAYS clear pending, even on error
      _pending.remove(soundId);
      _notify(); // UI: hide loading spinner
    }
  }

  // ── Private: add ────────────────────────────────────────────────────────────

  Future<void> _addSound({
    required String soundId,
    required String soundName,
    required String audioUrl,
    required String emoji,
  }) async {
    final player = AudioPlayer();

    try {
      // Step 1 — configure player (sequential, order matters)
      await player.setUrl(audioUrl);
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0.7);

      // Step 2 — register in map as NOT yet playing, then notify
      //          → FloatingMiniPlayer appears, card shows active state
      _sounds[soundId] = ActiveSound(
        id: soundId,
        name: soundName,
        emoji: emoji,
        player: player,
        volume: 0.7,
        isPlaying: false,
      );
      _notify();

      // Step 3 — actually start playback
      await player.play();

      // Step 4 — confirm isPlaying: true only after play() resolves
      //          → play button flips to pause, mini-player play icon flips
      if (_sounds.containsKey(soundId)) {
        _sounds[soundId] = _sounds[soundId]!.copyWith(isPlaying: true);
        _notify();
      }
    } catch (e, st) {
      debugPrint('[SoundPlayer] _addSound error for $soundId: $e\n$st');
      // Clean up on failure
      _sounds.remove(soundId);
      await player.dispose();
      _notify();
      rethrow; // let toggleSound's catch/finally handle _pending cleanup
    }
  }

  // ── Private: remove ─────────────────────────────────────────────────────────

  Future<void> _removeSound(String soundId) async {
    final active = _sounds.remove(soundId);
    _notify(); // remove from UI immediately, then dispose in background
    if (active != null) {
      try {
        await active.player.stop();
        await active.player.dispose();
      } catch (e) {
        debugPrint('[SoundPlayer] dispose error for $soundId: $e');
      }
    }
  }

  // ── Pause / Resume (single sound) ──────────────────────────────────────────

  Future<void> pauseSound(String soundId) async {
    final active = _sounds[soundId];
    if (active == null || !active.isPlaying) return;

    // Optimistic update first → UI responds instantly
    _sounds[soundId] = active.copyWith(isPlaying: false);
    _notify();

    try {
      await active.player.pause();
    } catch (e) {
      // Rollback on failure
      _sounds[soundId] = active.copyWith(isPlaying: true);
      _notify();
      debugPrint('[SoundPlayer] pauseSound error: $e');
    }
  }

  Future<void> resumeSound(String soundId) async {
    final active = _sounds[soundId];
    if (active == null || active.isPlaying) return;

    _sounds[soundId] = active.copyWith(isPlaying: true);
    _notify();

    try {
      await active.player.play();
    } catch (e) {
      _sounds[soundId] = active.copyWith(isPlaying: false);
      _notify();
      debugPrint('[SoundPlayer] resumeSound error: $e');
    }
  }

  // ── Volume ──────────────────────────────────────────────────────────────────

  Future<void> setVolume(String soundId, double volume) async {
    final active = _sounds[soundId];
    if (active == null) return;

    final v = volume.clamp(0.0, 1.0);
    _sounds[soundId] = active.copyWith(volume: v);
    _notify();

    try {
      await active.player.setVolume(v);
    } catch (e) {
      debugPrint('[SoundPlayer] setVolume error: $e');
    }
  }

  // ── Bulk: pause all ─────────────────────────────────────────────────────────

  Future<void> pauseAll() async {
    final playingIds = _sounds.values
        .where((s) => s.isPlaying)
        .map((s) => s.id)
        .toList();
    if (playingIds.isEmpty) return;

    // Optimistic: mark all as paused
    for (final id in playingIds) {
      final s = _sounds[id];
      if (s != null) _sounds[id] = s.copyWith(isPlaying: false);
    }
    _notify();

    // Parallel pause
    await Future.wait(
      playingIds.map((id) async {
        try {
          await _sounds[id]?.player.pause();
        } catch (e) {
          debugPrint('[SoundPlayer] pauseAll error for $id: $e');
        }
      }),
    );
  }

  // ── Bulk: resume all ────────────────────────────────────────────────────────

  Future<void> resumeAll() async {
    final pausedIds = _sounds.values
        .where((s) => !s.isPlaying)
        .map((s) => s.id)
        .toList();
    if (pausedIds.isEmpty) return;

    for (final id in pausedIds) {
      final s = _sounds[id];
      if (s != null) _sounds[id] = s.copyWith(isPlaying: true);
    }
    _notify();

    await Future.wait(
      pausedIds.map((id) async {
        try {
          await _sounds[id]?.player.play();
        } catch (e) {
          debugPrint('[SoundPlayer] resumeAll error for $id: $e');
        }
      }),
    );
  }

  // ── Bulk: stop all ──────────────────────────────────────────────────────────

  Future<void> stopAll() async {
    final players = _sounds.values.map((s) => s.player).toList();
    _sounds.clear();
    _pending.clear();
    _notify();

    await Future.wait(
      players.map((p) async {
        try {
          await p.stop();
          await p.dispose();
        } catch (e) {
          debugPrint('[SoundPlayer] stopAll dispose error: $e');
        }
      }),
    );
  }

  // ── Set volume for a specific sound (used by mixer) ─────────────────────────

  List<ActiveSound> get mixerSounds => activeSounds;

  // ── Dispose ─────────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    final players = _sounds.values.map((s) => s.player).toList();
    _sounds.clear();
    _pending.clear();

    await Future.wait(
      players.map((p) async {
        try {
          await p.dispose();
        } catch (_) {}
      }),
    );

    super.dispose();
  }

  // ── Internal helper ─────────────────────────────────────────────────────────

  /// Single place to call notifyListeners — easier to trace in debug.
  void _notify() {
    // Guard: don't notify after dispose
    if (!hasListeners) return;
    notifyListeners();
  }
}
