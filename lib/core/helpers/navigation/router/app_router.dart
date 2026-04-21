import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router_path.dart';

class AppRouter {
  Route? generatRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Onboarding (new user registration flow) ──────────────────────────
      // case AppRoutes.onboardingScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (_) => getIt<OnboardingCubit>(),
      //       child: const OnboardingScreen(),
      //     ),
      //   );
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
