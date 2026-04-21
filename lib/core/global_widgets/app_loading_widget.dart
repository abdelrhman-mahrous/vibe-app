import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/app_colors.dart';

class AppLoadingWidget extends StatefulWidget {
  const AppLoadingWidget({super.key});

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return SpinKitDoubleBounce(
      color: AppColors.iconBlueColor,
      size: MediaQuery.widthOf(context) / 4,
      duration: Duration(milliseconds: 1200),
    );
  }
}
