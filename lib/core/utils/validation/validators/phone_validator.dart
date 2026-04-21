import 'package:flutter/services.dart';

abstract class PhoneValidator {
  // الرقم المصري الدولي (20) يتبعه 10 أرقام (مثال: 201012345678)
  static const int validDigitsAfter20 = 10;

  /// ✅ Normalize رقم الهاتف المصري لأي صيغة إلى صيغة دولية (201XXXXXXXXX)
  static String normalizeEgyptPhoneNumber(String phone) {
    // تنظيف المسافات والزائد
    phone = phone.replaceAll(' ', '').replaceFirst('+', '');

    // استبدال 0020 بـ 20
    if (phone.startsWith('0020')) {
      phone = phone.replaceFirst('0020', '20');
    }

    // لو الرقم بادئ بـ 01 (زي 010 أو 011 أو 012 أو 015) -> نشيل الـ 0 ونضيف 20
    if (phone.startsWith('01')) {
      phone = '20${phone.substring(1)}';
    }

    // تأكد من أن الرقم يبدأ بـ 20 وليس 200 (لأن الصفر الأول في 01x يُحذف دولياً)
    if (phone.startsWith('2001')) {
      phone = phone.replaceFirst('2001', '201');
    }

    return phone;
  }

  /// ✅ فحص صلاحية الرقم المصري بعد التنظيف
  static bool isPhoneNumberValid(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    final normalized = normalizeEgyptPhoneNumber(phone);

    // الأرقام بعد الـ 20 (يجب أن تبدأ بـ 1 وبعدها 0 أو 1 أو 2 أو 5)
    final digitsAfter20 = normalized.replaceFirst('20', '');

    return normalized.startsWith('20') &&
        digitsAfter20.length == validDigitsAfter20 &&
        RegExp(r'^1[0125]\d+$').hasMatch(digitsAfter20);
  }

  static bool isWhatsAppValid(String phone) => isPhoneNumberValid(phone);

  /// RegExp للأرقام الإنجليزية فقط (يدعم بداية 01 أو +20 أو 20 أو 0020)
  /// مسموح بـ 10 أرقام بعد الـ 1 (إجمالي 11 للرقم المحلي)
  static RegExp phoneInputRegExp = RegExp(
    r'^(?:\+201[0125]\d{0,8}|01[0125]\d{0,8}|00201[0125]\d{0,8}|201[0125]\d{0,8})$',
  );

  /// RegExp للأرقام الإنجليزية والعربية
  static RegExp phoneInputBothNumbersRegExp = RegExp(
    r'^(?:\+201[0125][0-9٠-٩]{0,8}|01[0125][0-9٠-٩]{0,8}|00201[0125][0-9٠-٩]{0,8}|201[0125][0-9٠-٩]{0,8})$',
  );

  static List<TextInputFormatter> phoneInputFormatters = [
    FilteringTextInputFormatter.allow(phoneInputRegExp),
  ];

  static List<TextInputFormatter> phoneInputFormattersBothNumbers = [
    FilteringTextInputFormatter.allow(phoneInputBothNumbersRegExp),
  ];
}
