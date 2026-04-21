import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe/core/helpers/navigation/router/app_router.dart';

import '../../../core/constants/app_constant.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/helpers/navigation/router/app_router_path.dart';
import 'spash_gate/views/screens/app_gate_screen.dart';

class VibeApp extends StatelessWidget {
  const VibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          scaffoldMessengerKey: AppConstant.snackbarKey,
          navigatorKey: AppConstant.navigatorKey,
          title: 'vibe',
          supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('ar', 'EG'),
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.backgroundColor,
            brightness: Brightness.dark,
            fontFamily: AppConstant.fontFamily,
          ),
          initialRoute: 
               AppRoutes.bottomNavBar,
          onGenerateRoute: AppRouter().generatRoute,

          builder: (context, child) {
            return AppGateScreen(child: child!);
          },
        );
      },
    );
  }
}
