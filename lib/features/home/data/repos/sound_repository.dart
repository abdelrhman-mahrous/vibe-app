import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/network_info.dart';
import '../models/sound_model.dart';

abstract class SoundRepository {
  Future<List<SoundModel>> getSounds();
  Future<List<SoundModel>> getSoundsByCategory(String category);
}

class SoundRepositoryImpl with NetworkAware implements SoundRepository {
  SoundRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _cacheKey = 'vibe_sounds_cache';
  static const _cacheTimeKey = 'vibe_sounds_cache_time';
  static const _cacheDurationHours = 24;

  @override
  Future<List<SoundModel>> getSounds() async {
    // Try cache first
    final cached = await _getCachedSounds();
    if (cached != null) return cached;

    // Check connectivity
    final connected = await isConnected;
    if (!connected) {
      return SoundModel.fallbackSounds;
    }

    try {
      final response = await _client
          .from('sounds')
          .select()
          .order('category')
          .order('name');

      final sounds = (response as List)
          .map((json) => SoundModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _cacheSounds(sounds);
      return sounds;
    } catch (_) {
      final cached = await _getCachedSounds(ignoreExpiry: true);
      return cached ?? SoundModel.fallbackSounds;
    }
  }

  @override
  Future<List<SoundModel>> getSoundsByCategory(String category) async {
    final all = await getSounds();
    return all.where((s) => s.category == category).toList();
  }

  Future<List<SoundModel>?> _getCachedSounds({bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimeStr = prefs.getString(_cacheTimeKey);
      if (cacheTimeStr == null) return null;

      if (!ignoreExpiry) {
        final cacheTime = DateTime.parse(cacheTimeStr);
        final diff = DateTime.now().difference(cacheTime);
        if (diff.inHours >= _cacheDurationHours) return null;
      }

      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr == null) return null;

      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((j) => SoundModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheSounds(List<SoundModel> sounds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(sounds.map((s) => s.toJson()).toList());
      await prefs.setString(_cacheKey, jsonStr);
      await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }
}
