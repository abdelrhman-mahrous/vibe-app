import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../../core/constants/app_images.dart';
import '../../data/repos/app_config_repo.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../core/global_widgets/app_loading_widget.dart';
import '../../data/models/app_config_model.dart';
import 'force_update_screen.dart';
import 'maintenance_screen.dart';

class AppGateScreen extends StatefulWidget {
  final Widget child;
  const AppGateScreen({super.key, required this.child});

  @override
  State<AppGateScreen> createState() => _AppGateScreenState();
}

class _AppGateScreenState extends State<AppGateScreen> {
  bool _checked = false;
  bool _isMaintenance = false;
  bool _isForceUpdate = false;
  AppConfigModel? _config;

  @override
  void initState() {
    super.initState();
    _initNotificationsIfLoggedIn();
    _checkAppConfig();
  }

  void _initNotificationsIfLoggedIn() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    // هنا ممكن تضيف استدعاء الـ Cubit لو حبيت لاحقاً
  }

  Future<void> _checkAppConfig() async {
    final config = await AppConfigRepo.fetchConfig();
    if (config == null) {
      setState(() => _checked = true);
      return;
    }

    _config = config;

    // تحقق من الصيانة
    if (config.maintenanceEnabled) {
      setState(() {
        _isMaintenance = true;
        _checked = true;
      });
      return;
    }

    // تحقق من الـ Force Update
    if (config.forceUpdateEnabled) {
      final currentVersion = await AppConfigRepo.getCurrentVersion();
      if (AppConfigRepo.isUpdateRequired(currentVersion, config.minVersion)) {
        setState(() {
          _isForceUpdate = true;
          _checked = true;
        });
        return;
      }
    }

    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    // استخدمنا AnimatedSwitcher لضمان انتقال ناعم (Fade transition) بين حالات التطبيق
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _buildCurrentState(),
    );
  }

  Widget _buildCurrentState() {
    if (!_checked) {
      return Scaffold(
        key: const ValueKey('loading'),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أنيميشن بسيط للوجو عند التحميل
              TweenAnimationBuilder(
                duration: const Duration(seconds: 1),
                tween: Tween<double>(begin: 0.8, end: 1.0),
                builder: (context, double value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Image.asset(
                  AppImages.appLogo,
                  width: 200,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              AppLoadingWidget(),
            ],
          ),
        ),
      );
    }

    if (_isMaintenance) {
      return MaintenanceScreen(
        key: const ValueKey('maintenance'),
        config: _config!,
      );
    }

    if (_isForceUpdate) {
      return ForceUpdateScreen(key: const ValueKey('update'), config: _config!);
    }

    return widget.child;
  }
}
