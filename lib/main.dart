import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe/core/cache/vibe_cache.dart';
import 'package:vibe/vibe_app.dart';

import 'core/constants/supabase_integration.dart';
import 'core/services/notification_service.dart';
import 'features/todo/data/models/todo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Hive CE init
  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>('todos');

  // Cache
  await VibeCache.instance.init();

  // Notifications
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await Supabase.initialize(
    url: SupabaseIntegration.supabaseUrl,
    anonKey: SupabaseIntegration.anonKey,
  );

  runApp(const VibeApp());
}
