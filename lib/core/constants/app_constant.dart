import 'package:flutter/material.dart';

abstract class AppConstant {

  // for show the snakbar without passing context
  static final GlobalKey<ScaffoldMessengerState> snackbarKey =
      GlobalKey<ScaffoldMessengerState>();


  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

 static final String fontFamily = "IBM";

      
}
