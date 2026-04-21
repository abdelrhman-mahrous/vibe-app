import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe/vibe_app.dart';

import 'core/constants/supabase_integration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await Supabase.initialize(
    url: SupabaseIntegration.supabaseUrl,
    anonKey: SupabaseIntegration.anonKey,
  );

  runApp(const VibeApp());
}
