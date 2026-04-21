import 'package:flutter/material.dart';
import '../constants/app_constant.dart';
import '../theme/app_colors.dart';


void showSnackBarEror(String message, {int? errorCode}) {
    final snackBar =  SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.errorColor,
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.white),
            SizedBox(width: 8),
            snackBarTextWidget(message),
          ],
        ),
      );
    AppConstant.snackbarKey.currentState?.showSnackBar(snackBar);
}

void showSnackBarBlue(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,

      content: Row(
        children: [
          Icon(Icons.done, color: AppColors.white),
          snackBarTextWidget(message),
        ],
      ),
      backgroundColor: AppColors.indigoColor,
    ),
  );
}

void showSnackBarNetworkError() {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: Row(
        children: [
          Icon(Icons.portable_wifi_off, color: AppColors.white),
          SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(maxWidth: 300),

            child: Text("في مشكلة في الإتصال بالإنترنت عندك", maxLines: 2),
          ),
        ],
      ),
    ),
    backgroundColor: AppColors.errorColor,
  );
  AppConstant.snackbarKey.currentState?.showSnackBar(snackBar);
}


ConstrainedBox snackBarTextWidget(String text) => ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 250),
  child: Text(
    text,
    maxLines: 3,
    style: TextStyle(fontFamily: 'IBM', color:  AppColors.white),
  ),
);
