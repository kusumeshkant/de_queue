import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../src/constants/app_config.dart';
import '../analytics_events.dart';
import '../analytics_service.dart';
import '../crashlytics_service.dart';

/// Thresholds for frame timing classification (wall-clock milliseconds).
const _kSlowMs = 16;     // misses 60 fps target
const _kJankyMs = 32;    // misses 30 fps target
const _kSevereMs = 100;  // < 10 fps — severe jank

/// Number of frames to buffer before computing and possibly reporting stats.
const _kWindowSize = 120;

/// Minimum jank rate (0–1) required before reporting to analytics.
/// Suppresses noise on healthy devices.
const _kReportThreshold = 0.05;

/// Instruments Flutter frame rendering via [SchedulerBinding.addTimingsCallback].
///
/// Aggregates every [_kWindowSize] frames, then:
///   • Logs slow/severe frame warnings to Crashlytics breadcrumbs
///   • Reports analytics event when jank rate exceeds [_kReportThreshold]
///
/// No-ops in dev builds to keep the debug console clean.
class FramePerformanceTracker extends GetxService {
  final List<int> _totalMs = [];
  int _slowCount = 0;
  int _jankyCount = 0;

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
      _totalMs.add(totalMs);

      if (totalMs >= _kSlowMs) _slowCount++;
      if (totalMs >= _kJankyMs) _jankyCount++;

      if (totalMs >= _kSevereMs) {
        _breadcrumb('severe_frame: ${totalMs}ms build=${t.buildDuration.inMilliseconds}ms');
      }
    }

    if (_totalMs.length >= _kWindowSize) {
      _flushWindow();
    }
  }

  void _flushWindow() {
    if (_totalMs.isEmpty) return;

    final count = _totalMs.length;
    final jankRate = _jankyCount / count;
    final maxMs = _totalMs.reduce(max);
    final avgMs = _totalMs.reduce((a, b) => a + b) ~/ count;

    if (jankRate >= _kReportThreshold) {
      _breadcrumb(
        'frame_window: count=$count jank=${(_jankyCount)} '
        'rate=${(jankRate * 100).toStringAsFixed(1)}% '
        'max=${maxMs}ms avg=${avgMs}ms',
      );
      _logFrameEvent(
        jankyCount: _jankyCount,
        slowCount: _slowCount,
        totalCount: count,
        maxMs: maxMs,
        avgMs: avgMs,
      );
    }

    _totalMs.clear();
    _slowCount = 0;
    _jankyCount = 0;
  }

  void _breadcrumb(String message) {
    if (!Get.isRegistered<CrashlyticsService>()) return;
    Get.find<CrashlyticsService>().log(message);
  }

  void _logFrameEvent({
    required int jankyCount,
    required int slowCount,
    required int totalCount,
    required int maxMs,
    required int avgMs,
  }) {
    if (!Get.isRegistered<AnalyticsService>()) return;
    // fire-and-forget — frame timing callbacks must stay fast
    Get.find<AnalyticsService>().logEvent(
      AnalyticsEvents.frameJankDetected,
      parameters: <String, Object>{
        AnalyticsParams.jankyFrameCount: jankyCount,
        AnalyticsParams.slowFrameCount: slowCount,
        AnalyticsParams.totalFrameCount: totalCount,
        AnalyticsParams.maxFrameMs: maxMs,
        AnalyticsParams.avgFrameMs: avgMs,
        AnalyticsParams.flavor: AppConfig.flavor,
      },
    );
  }
}
