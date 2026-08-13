import 'package:flutter/scheduler.dart';

class AnimationConfig {
  // Values > 1.0 slow down animations globally, values < 1.0 speed them up.
  static const double speedMultiplier = 1.35;

  // Global Hero route timings for popup transitions.
  static const Duration heroForwardDuration = Duration(seconds: 6);
  static const Duration heroReverseDuration = Duration(seconds: 6);

  // Shared fixed animation durations.
  static const Duration hoverDuration = Duration(milliseconds: 200);
  static const Duration statusPulseDuration = Duration(milliseconds: 250);
  static const Duration scrollToTopDuration = Duration(milliseconds: 320);
  static const Duration dashboardIntroDuration = Duration(milliseconds: 700);
  static const Duration shimmerCycleDuration = Duration(milliseconds: 1200);
  static const Duration dialogScaleDuration = Duration(milliseconds: 550);
  static const Duration dialogStartDelayDuration = Duration(milliseconds: 220);
  static const Duration dialogStartShortDelayDuration = Duration(
    milliseconds: 120,
  );

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
    final int extra = (index * 35).clamp(0, 260);
    return Duration(milliseconds: 700 + extra);
  }

  static void applyGlobalSpeed() {
    timeDilation = speedMultiplier;
  }
}
