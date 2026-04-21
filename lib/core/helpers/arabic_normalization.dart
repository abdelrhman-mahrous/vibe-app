String normalizeArabic(String text) {
  return text
      .trim()
      // توحيد الألف بكل أشكالها
      .replaceAll(RegExp(r'[أإآا]'), 'ا')
      // توحيد الياء
      .replaceAll(RegExp(r'[يى]'), 'ي')
      // توحيد التاء المربوطة والهاء
      .replaceAll(RegExp(r'[ةه]'), 'ه')
      // حذف التشكيل كله
      .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
      // تقليص المسافات المتعددة لمسافة واحدة
      .replaceAll(RegExp(r'\s+'), ' ');
}

