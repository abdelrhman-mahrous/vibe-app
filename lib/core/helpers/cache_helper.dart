import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class CacheHelper {
  CacheHelper._();

  // initial flutter secure storage to save data
  static late SharedPreferences _sharedPreferences;

  // initial flutter secure storage to save the sensitive data
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> remove(String key) async {
    return await _sharedPreferences.remove(key);
  }

  static Future<bool> clearAllData() async {
    return await _sharedPreferences.clear();
  }

  /// Saves a [value] with a [key] in the SharedPreferences.
  static Future<bool> setData(String key, value) async {
    switch (value) {
      case String _:
        return await _sharedPreferences.setString(key, value);
      case int _:
        return await _sharedPreferences.setInt(key, value);
      case bool _:
        return await _sharedPreferences.setBool(key, value);
      case double _:
        return await _sharedPreferences.setDouble(key, value);
      default:
        return false;
    }
  }

  static bool? getBool(String key) => _sharedPreferences.getBool(key);

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _sharedPreferences.getDouble(key) ?? defaultValue;
  }

  static int? getInt(String key) => _sharedPreferences.getInt(key);

  static String? getString(String key) => _sharedPreferences.getString(key);

  /// Saves a [value] with a [key] in the [FlutterSecureStorage].
  static setSecuredString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecuredString(String key) async {
    try {
      // ...
      final value = await _secureStorage.read(key: key);
      return value;
    } on PlatformException catch (e) {
      if (e.message != null && e.message!.contains('BadPaddingException')) {
        await clearSecured();
        await clearAllData();
        return null;
      }
      rethrow;
    }
  }

  /// Removes all keys and values in the FlutterSecureStorage
  static Future<void> clearSecured() async {
    await _secureStorage.deleteAll();
  }
}
