import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconEmoji,
    required this.gradientColors,
    required this.accentColor,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String description;
  final String iconEmoji;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<String> features;

  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'مرحباً بك في Vibe',
      subtitle: 'عالمك الهادئ',
      description:
          'اكتشف تجربة استرخاء فريدة مصممة لتمنحك السكينة والتركيز العميق في أي وقت وأي مكان.',
      iconEmoji: '🌊',
      gradientColors: [Color(0xFF0D0D2B), Color(0xFF1A0A3D)],
      accentColor: Color(0xFF9D4EDD),
      features: ['أصوات الطبيعة', 'تجربة مخصصة', 'واجهة أنيقة'],
    ),
    OnboardingPageData(
      title: 'أصوات تُريحك',
      subtitle: 'مزيج مثالي',
      description:
          'شغّل أكثر من صوت في آنٍ واحد — المطر مع الغابة، الريح مع المحيط. اصنع بيئتك المثالية.',
      iconEmoji: '🎵',
      gradientColors: [Color(0xFF0A0A2E), Color(0xFF160B3A)],
      accentColor: Color(0xFF7B2FBE),
      features: ['مزج الأصوات', 'تحكم في الحجم', 'تشغيل في الخلفية'],
    ),
    OnboardingPageData(
      title: 'ركّز وأنجز',
      subtitle: 'تقنية بومودورو',
      description:
          'استخدم تقنية بومودورو لتحقيق أقصى إنتاجية. فترات تركيز مصحوبة باسترخاء مخطط له.',
      iconEmoji: '⏱️',
      gradientColors: [Color(0xFF08082A), Color(0xFF1E0D3A)],
      accentColor: Color(0xFFBB86FC),
      features: ['مؤقت التركيز', 'فترات راحة', 'إحصائيات يومية'],
    ),
    OnboardingPageData(
      title: 'نظّم يومك',
      subtitle: 'قائمة المهام',
      description:
          'أضف مهامك، حدد مواعيد تذكيرها، وتابع إنجازاتك اليومية بأسلوب أنيق وبسيط.',
      iconEmoji: '✨',
      gradientColors: [Color(0xFF0A0A1E), Color(0xFF150B35)],
      accentColor: Color(0xFFD4AAFF),
      features: ['قائمة مهام', 'تذكيرات ذكية', 'تتبع التقدم'],
    ),
  ];
}
