import 'package:flutter/material.dart';

enum TimelineItemPosition { left, right, random }

class TimelineModel {
  final Icon icon;
  final Color iconBackground;
  final Widget leftChild;
  final Widget rightChild;
  final TimelineItemPosition position;
  bool isFirst;
  bool isLast;

  TimelineModel(this.leftChild, this.rightChild,
      {this.icon,
      this.iconBackground,
      this.position = TimelineItemPosition.random,
      this.isFirst = false,
      this.isLast = false});

  @override
  bool operator ==(o) {
    if (identical(this, o)) return true;
    if (runtimeType != o.runtimeType) return false;
    final TimelineModel typedOther = o;
    return icon == typedOther.icon &&
        iconBackground == typedOther.iconBackground &&
        leftChild == typedOther.leftChild &&
        rightChild == typedOther.rightChild &&
        isFirst == typedOther.isFirst &&
        isLast == typedOther.isLast &&
        position == typedOther.position;
  }

  @override
  int get hashCode =>
      hashValues(icon, iconBackground, leftChild, rightChild, position, isFirst, isLast);

  TimelineModel copyWith(
          {icon, iconBackground, child, position, isFirst, isLast}) =>
      TimelineModel(leftChild ?? this.leftChild, rightChild ?? this.rightChild,
          icon: icon ?? this.icon,
          iconBackground: iconBackground ?? this.iconBackground,
          position: position ?? this.position,
          isFirst: isFirst ?? this.isFirst,
          isLast: isLast ?? this.isLast);
}
