import 'package:flutter/material.dart';
import '../../constants/app_constant.dart';

Future<bool> onWillPop() async {
  final shouldPop = await showDialog<bool>(
    context: AppConstant.navigatorKey.currentState!.context,
    builder: (context) => AlertDialog(
      title: Text('تنبيه'),
      content: Text('هل تريد إغلاق التطبيق؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('لا'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('نعم'),
        ),
      ],
    ),
  );
  return shouldPop ?? false;
}
