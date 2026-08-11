import 'package:flutter/scheduler.dart';

class AnimationConfig {
  // Values > 1.0 slow down animations globally, values < 1.0 speed them up.
  static const double speedMultiplier = 1.35;

  // Global Hero route timings for popup transitions.
  static const Duration heroForwardDuration = Duration(seconds: 6);
  static const Duration heroReverseDuration = Duration(seconds: 6);

  // Shared fixed animation durations.
  static const Duration hoverFast = Duration(milliseconds: 140);
  static const Duration hoverQuick = Duration(milliseconds: 150);
  static const Duration hoverStandard = Duration(milliseconds: 160);
  static const Duration hoverSmooth = Duration(milliseconds: 180);
  static const Duration hoverCard = Duration(milliseconds: 200);
  static const Duration hoverPanel = Duration(milliseconds: 220);
  static const Duration statusPulse = Duration(milliseconds: 250);
  static const Duration scrollToTop = Duration(milliseconds: 320);
  static const Duration dashboardIntro = Duration(milliseconds: 700);
  static const Duration shimmerCycle = Duration(milliseconds: 1200);
  static const Duration dialogScale = Duration(milliseconds: 550);
  static const Duration dialogStartDelay = Duration(milliseconds: 220);
  static const Duration dialogStartShortDelay = Duration(milliseconds: 120);

  // Dynamic durations centralization.
  static Duration listFadeDuration(int index) {
    return Duration(milliseconds: 300 + (index * 50));
  }

  static Duration gridEntryDuration(int index) {
    return Duration(milliseconds: 400 + (index * 60));
  }

  static Duration detailListEntryDuration(int index) {
    return Duration(milliseconds: 220 + (index * 40));
  }

  static Duration detailEventsEntryDuration(int index) {
    return Duration(milliseconds: 220 + (index * 50));
  }

  static Duration reorderDuration(int index) {
    final extra = (index * 35).clamp(0, 260);
    return Duration(milliseconds: 700 + extra);
  }

  static void applyGlobalSpeed() {
    timeDilation = speedMultiplier;
  }
}
