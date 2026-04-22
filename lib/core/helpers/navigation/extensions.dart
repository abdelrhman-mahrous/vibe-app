import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Object? arguments, required RoutePredicate predicate}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, arguments: arguments, predicate);
  }

  void pop() => Navigator.of(this).pop();
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}
extension BuildContextExtensions on BuildContext {
  T? safeRead<T>() {
    try {
      return read<T>();
    } catch (e) {
      return null; 
    }
  }
}

extension AppBarExtension on BuildContext {
  PreferredSizeWidget appBarWithArrowBack({
    Widget? leading,
    List<Widget>? actions,
    Color backgroundColor = Colors.white,
    bool centerTitle = true,
    double elevation = 0,
  }) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading ??
          InkWell(
            child: const Icon(Icons.arrow_back_ios_rounded),
            onTap: () {
              Navigator.pop(this);
            },
          ),
      actions: actions,
    );
  }
}
