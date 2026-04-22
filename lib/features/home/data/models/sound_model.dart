class SoundModel {
  const SoundModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.audioUrl,
    required this.category,
    this.description = '',
  });

  final String id;
  final String name;
  final String emoji;
  final String audioUrl;
  final String category;
  final String description;

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🎵',
      audioUrl: json['audio_url'] as String,
      category: json['category'] as String? ?? 'nature',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'audio_url': audioUrl,
    'category': category,
    'description': description,
  };

  SoundModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? audioUrl,
    String? category,
    String? description,
  }) {
    return SoundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      audioUrl: audioUrl ?? this.audioUrl,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  // Fallback local sounds when offline
  static List<SoundModel> get fallbackSounds => const [
    SoundModel(
      id: 'rain',
      name: 'مطر',
      emoji: '🌧️',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'nature',
      description: 'صوت المطر المنعش',
    ),
    SoundModel(
      id: 'white_noise',
      name: 'ضوضاء بيضاء',
      emoji: '🌫️',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'noise',
      description: 'ضوضاء بيضاء هادئة',
    ),
    SoundModel(
      id: 'forest',
      name: 'غابة',
      emoji: '🌲',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'nature',
      description: 'أصوات الغابة الطبيعية',
    ),
    SoundModel(
      id: 'ocean',
      name: 'محيط',
      emoji: '🌊',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'nature',
      description: 'أمواج المحيط الهادئة',
    ),
    SoundModel(
      id: 'fire',
      name: 'نار',
      emoji: '🔥',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'nature',
      description: 'صوت الموقد المريح',
    ),
    SoundModel(
      id: 'wind',
      name: 'رياح',
      emoji: '💨',
      audioUrl:
          'https://cdn.pixabay.com/download/audio/2024/01/16/audio_2ac16305e9.mp3?filename=floraphonic-pleasant-violin-notification-10-186547.mp3',
      category: 'nature',
      description: 'نسيم الرياح الخفيف',
    ),
  ];
}
