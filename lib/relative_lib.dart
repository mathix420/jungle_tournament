import 'package:flutter/material.dart';

double relativeDouble(BuildContext context, double originalDouble) {
  double defaultRatio = 812 / 375;
  double currentRatio = MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
  return currentRatio * originalDouble / defaultRatio;
}