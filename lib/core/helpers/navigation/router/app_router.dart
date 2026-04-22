import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/bottom_nav/main_shell.dart';
import '../../../../features/onboarding/views/screens/onboarding_screen.dart';
import 'app_router_path.dart';

class AppRouter {
  Route? generatRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Onboarding (new user registration flow) ──────────────────────────
      case AppRoutes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.bottomNavBar:
        return MaterialPageRoute(builder: (_) => const MainShell());
      // case AppRoutes.homeScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (_) => getIt<HomeCubit>(),
      //       child: const HomeScreen(),
      //     ),
      //   );

      // ── Fallback ─────────────────────────────────────────────────────────
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }
}
