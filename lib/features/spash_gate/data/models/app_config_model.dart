class AppConfigModel {
  final bool appEnabled; 
  final bool forceUpdateEnabled;
  final String forceUpdateStoreUrl;
  final String minVersion;
  final bool maintenanceEnabled;
  final String maintenanceMessage;
  final String maintenanceExpectedTime;

  AppConfigModel({
    required this.appEnabled,
    required this.forceUpdateEnabled,
    required this.forceUpdateStoreUrl,
    required this.minVersion,
    required this.maintenanceEnabled,
    required this.maintenanceMessage,
    required this.maintenanceExpectedTime,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      appEnabled: json['app_enabled'] ?? true, // افتراضياً شغال
      forceUpdateEnabled: json['force_update_enabled'] ?? false,
      forceUpdateStoreUrl: json['force_update_store_url'] ?? '',
      minVersion: json['min_version'] ?? '1.0.0',
      maintenanceEnabled: json['maintenance_enabled'] ?? false,
      maintenanceMessage: json['maintenance_message'] ?? '',
      maintenanceExpectedTime: json['maintenance_expected_time'] ?? '',
    );
  }
}
