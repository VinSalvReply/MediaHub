import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mediahub/app.dart';
import 'package:mediahub/core/constants/animation.dart';

void main() {
  // Enable detailed tracking for Performance panel
  debugProfileBuildsEnabled = true;
  debugProfileBuildsEnabledUserWidgets = true;
  debugProfileLayoutsEnabled = true;
  debugProfilePaintsEnabled = true;

  // Must run before runApp so timeDilation is set before the first frame.
  AnimationConfig.applyGlobalSpeed();

  runApp(const App());
}
