import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_config_model.dart';

class AppConfigRepo {
  static Future<AppConfigModel?> fetchConfig() async {
    try {
      final response = await Supabase.instance.client
          .from('app_config')
          .select()
          .limit(1)
          .single();
      return AppConfigModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static bool isUpdateRequired(String currentVersion, String minVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final minimum = minVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final c = i < current.length ? current[i] : 0;
      final m = i < minimum.length ? minimum[i] : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }

  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
