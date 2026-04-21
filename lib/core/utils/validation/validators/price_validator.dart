import 'package:flutter/services.dart';

class PriceValidator {
  /// Allow only numbers and deny starts with zero
  static List<TextInputFormatter> priceInputFormatters = [
    // Allow only numbers
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    // Deny starts with Zero
    FilteringTextInputFormatter.deny(RegExp(r'^0')),
  ];

  /// Allow only numbers (in both Arabic and English)
  static List<TextInputFormatter> priceInputFormattersBothNumbers = [
    // Allow only numbers (both Arabic and English)
    FilteringTextInputFormatter.allow(RegExp(r'[1-9١-٩][0-9٠-٩]*')),
  ];
}
