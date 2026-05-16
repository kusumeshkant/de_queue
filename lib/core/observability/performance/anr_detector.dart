import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../src/constants/app_config.dart';
import '../analytics_events.dart';
import '../analytics_service.dart';
import '../crashlytics_service.dart';

/// Minimum consecutive janky frames before classifying as a UI stall.
const _kStallFrameThreshold = 8;

/// Single-frame total duration (ms) that constitutes jank (> 32ms = < 30fps).
const _kJankyFrameMs = 32;

/// Detects UI stalls — sustained sequences of janky frames that indicate
/// the main thread is overloaded or blocked.
///
/// This is NOT a replacement for OS-level ANR detection (which Firebase
/// Crashlytics captures automatically on Android). It is a Flutter-layer
/// supplement that catches rendering stalls before they become hard ANRs.
///
/// Design rationale:
///   True ANR detection requires a secondary Dart isolate heartbeat, but
///   isolates cannot access Firebase services. Instead we classify sustained
///   jank (≥ [_kStallFrameThreshold] consecutive slow frames) as a stall
///   signal and report it as a non-fatal Crashlytics breadcrumb.
///
/// No-ops in dev builds.
class AnrDetector extends GetxService {
  int _consecutiveJankyFrames = 0;
  bool _stallReportedThisSession = false;

  @override
  void onInit() {
    super.onInit();
    if (AppConfig.isDev) return;
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  @override
  void onClose() {
    if (!AppConfig.isDev) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    }
    super.onClose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final totalMs = t.totalSpan.inMilliseconds;

      if (totalMs >= _kJankyFrameMs) {
        _consecutiveJankyFrames++;
        _checkForStall(totalMs);
      } else {
        _consecutiveJankyFrames = 0;
      }
    }
  }

  void _checkForStall(int lastFrameMs) {
    if (_consecutiveJankyFrames < _kStallFrameThreshold) return;

    final severity = _consecutiveJankyFrames >= _kStallFrameThreshold * 3
        ? 'severe'
        : 'warning';

    _breadcrumb(
      'ui_stall[$severity]: '
      '${_consecutiveJankyFrames} consecutive janky frames, '
      'last=${lastFrameMs}ms',
    );

    // Log analytics event once per stall episode to avoid flooding
    if (!_stallReportedThisSession ||
        _consecutiveJankyFrames >= _kStallFrameThreshold * 3) {
      _stallReportedThisSession = true;
      _logStallEvent(severity);
    }
  }

  void _breadcrumb(String message) {
    if (!Get.isRegistered<CrashlyticsService>()) return;
    Get.find<CrashlyticsService>().log(message);
    if (kDebugMode) debugPrint('[AnrDetector] $message');
  }

  void _logStallEvent(String severity) {
    if (!Get.isRegistered<AnalyticsService>()) return;
    Get.find<AnalyticsService>().logEvent(
      AnalyticsEvents.anrDetected,
      parameters: <String, Object>{
        'severity': severity,
        'consecutive_janky_frames': _consecutiveJankyFrames,
        AnalyticsParams.flavor: AppConfig.flavor,
      },
    );
  }
}
