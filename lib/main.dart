import 'package:flutter/material.dart';
import 'package:mediahub/app.dart';
import 'package:mediahub/core/constants/animation.dart';

void main() {
  // Must run before runApp so timeDilation is set before the first frame.
  AnimationConfig.applyGlobalSpeed();

  runApp(const App());
}
