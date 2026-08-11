import 'package:flutter/material.dart';
import 'package:mediahub/app.dart';
import 'package:mediahub/core/constants/animation.dart';

void main() {
  AnimationConfig.applyGlobalSpeed();
  runApp(const App());
}
