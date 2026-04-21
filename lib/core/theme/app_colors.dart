import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- الأساسيات (النصوص والأبيض) ---
  static const Color white = Color(0xffFFFFFF); // النص الأساسي والعناوين
  static const Color offWhite = Color(0xffE2E8F0); // النصوص الفرعية (مثل "ابدأ رحلتك")
  static const Color greyText = Color(0xff94A3B8); // النصوص الباهتة ووقت الملخصات
  
  // --- الخلفيات (التي لم يتم تعديلها بناءً على طلبك) ---
  static const Color indigoColor = Color(0xff191C31); 
  static const Color backgroundColor = indigoColor;
  static const Color cardColor = Color(0xff1E2235); // لون الكروت الصغيرة (شفافية بسيطة)

  // --- ألوان الأيقونات والإحصائيات (Accents) ---
  static const Color iconBlueColor = Color(0xff3B82F6);   // أيقونة الملخصات
  static const Color iconPurpleColor = Color(0xffA855F7); // أيقونة الشروحات الصوتية
  static const Color iconTealColor = Color(0xff06B6D4);   // أيقونة الاختبارات (اللبني/التيل)
  static const Color iconGoldColor = Color(0xffF59E0B);   // أيقونة معدل النجاح والعملات

  // --- التدرجات (Gradients) ---
  // التدرج الخاص بالبانر الكبير (جاهز للتعلم؟)
  static const List<Color> primaryGradient = [
    Color(0xff002ED3), // أزرق صريح
    Color(0xff5500D3), // بنفسجي غامق
  ];

  // --- عناصر الواجهة (UI Elements) ---
  static const Color buttonDarkColor = Color(0xff0F172A); // زر "ابدأ الآن" الأسود/الكحلي
  static const Color successCheckColor = Color(0xff22D3EE); // علامة الصح (Cyan)
  static const Color goldCurrency = Color(0xffFFD700); // لون رصيد العملات (250)

  // --- الألوان الوظيفية (Error/Disable) ---
  static const Color iconDisableColor = Color(0xff64748B);
  static const Color errorColor = Color(0xffEF4444);
}
