import 'package:flutter/material.dart';

class IsBlurred extends InheritedWidget {
  static of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(IsBlurred);

  final bool isBlurred;

  IsBlurred({Key key, @required Widget child, @required this.isBlurred})
      : assert(isBlurred != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(IsBlurred oldWidget) {
    return this.isBlurred != oldWidget.isBlurred;
  }
}