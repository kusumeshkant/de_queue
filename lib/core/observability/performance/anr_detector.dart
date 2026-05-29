import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../src/constants/app_config.dart';
import '../analytics_events.dart';
import '../analytics_service.dart';
import '../crashlytics_service.dart';

/// Minimum consecutive janky frames before classifying as a UI stall (warning).
const _kStallFrameThreshold = 8;

/// Consecutive frames that trigger escalation to severe (3× the warning threshold).
const _kSevereFrameThreshold = _kStallFrameThreshold * 3; // 24

/// Single-frame total duration (ms) that constitutes jank (> 32ms = < 30fps).
const _kJankyFrameMs = 32;

/// Detects UI stalls — sustained sequences of janky frames that indicate
/// the main thread is overloaded or blocked.
///
/// This is NOT a replacement for OS-level ANR detection (which Firebase
/// Crashlytics captures automatically on Android). It is a Flutter-layer
/// supplement that catches rendering stalls before they become hard ANRs.
///
/// Reports exactly one breadcrumb + analytics at the warning threshold (8 frames)
/// and one additional pair at the severe threshold (24 frames). Resets all state
/// when frames recover, so subsequent stall episodes are detected independently.
///
/// No-ops in dev builds.
class AnrDetector extends GetxService {
  int _consecutiveJankyFrames = 0;
  bool _warningSent = false;
  bool _severeSent = false;

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
        _onRecovery();
      }
    }
  }

  void _checkForStall(int lastFrameMs) {
    // Write exactly once at the warning threshold — not on every subsequent frame.
    if (_consecutiveJankyFrames == _kStallFrameThreshold && !_warningSent) {
      _warningSent = true;
      _breadcrumb(
        'ui_stall[warning]: $_consecutiveJankyFrames consecutive janky frames '
        'last=${lastFrameMs}ms',
      );
      _logStallEvent('warning');
    }
    // Write once more when escalating to severe.
    if (_consecutiveJankyFrames == _kSevereFrameThreshold && !_severeSent) {
      _severeSent = true;
      _breadcrumb(
        'ui_stall[severe]: $_consecutiveJankyFrames consecutive janky frames '
        'last=${lastFrameMs}ms',
      );
      _logStallEvent('severe');
    }
  }

  void _onRecovery() {
    if (_consecutiveJankyFrames >= _kStallFrameThreshold) {
      _breadcrumb('ui_stall_end: recovered after $_consecutiveJankyFrames frames');
    }
    // Reset fully so the next stall episode is reported independently.
    _consecutiveJankyFrames = 0;
    _warningSent = false;
    _severeSent = false;
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
        AnalyticsParams.severity: severity,
        AnalyticsParams.consecutiveJankyFrames: _consecutiveJankyFrames,
        AnalyticsParams.flavor: AppConfig.flavor,
      },
    );
  }
}
