import 'package:just_audio/just_audio.dart';

/// Immutable snapshot of a currently loaded sound.
/// The [player] is mutable (just_audio), but the metadata is not.
class ActiveSound {
  const ActiveSound({
    required this.id,
    required this.name,
    required this.emoji,
    required this.player,
    required this.volume,
    required this.isPlaying,
  });

  final String id;
  final String name;
  final String emoji;
  final AudioPlayer player;
  final double volume;
  final bool isPlaying;

  ActiveSound copyWith({
    String? id,
    String? name,
    String? emoji,
    AudioPlayer? player,
    double? volume,
    bool? isPlaying,
  }) {
    return ActiveSound(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      player: player ?? this.player,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveSound &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isPlaying == other.isPlaying &&
          volume == other.volume;

  @override
  int get hashCode => id.hashCode ^ isPlaying.hashCode ^ volume.hashCode;
}
