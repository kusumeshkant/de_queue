import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../src/constants/app_config.dart';
import 'crashlytics_service.dart';
import 'models/crash_category.dart';

/// Structured, environment-aware logger for dq_app.
///
/// Dev   → dart:developer.log() with ANSI color channels
/// Prod  → Crashlytics breadcrumbs for errors; suppresses verbose logs
///
/// Log channels (name field in dart:developer):
///   GQL:REQ / GQL:RES / GQL:ERR  — GraphQL request lifecycle
///   AUTH                          — session / token events
///   NAV                           — navigation / routing
///   APP:INFO / APP:WARN / APP:ERR — general application logs
///
/// PII policy: mask tokens, emails, phone numbers before logging.
/// Use [maskToken] for auth tokens; never log raw Firebase ID tokens.
class AppLogger {
  static const _reset   = '\x1B[0m';
  static const _cyan    = '\x1B[36m';
  static const _green   = '\x1B[32m';
  static const _red     = '\x1B[31m';
  static const _yellow  = '\x1B[33m';
  static const _blue    = '\x1B[34m';
  static const _magenta = '\x1B[35m';

  // ── GraphQL ─────────────────────────────────────────────────────────────────

  static void logRequest({
    required String operationName,
    required String query,
    Map<String, dynamic>? variables,
  }) {
    if (!AppConfig.isDev) return;
    dev.log(
      '$_cyan🚀 GQL REQUEST [$operationName]'
      '${variables != null ? '\n  vars: $variables' : ''}$_reset',
      name: 'GQL:REQ', level: 500,
    );
  }

  static void logResponse(dynamic data) {
    if (!AppConfig.isDev) return;
    dev.log('$_green✅ GQL RESPONSE  data: $data$_reset',
        name: 'GQL:RES', level: 500);
  }

  static void logError(dynamic error) {
    _log(level: 1000, color: _red, channel: 'GQL:ERR',
        msg: '❌ GQL ERROR  $error');
    _breadcrumb('gql_error: $error');
  }

  static void logNetwork(String msg) {
    _log(level: 1000, color: _red, channel: 'NETWORK', msg: '🔴 NETWORK: $msg');
    _breadcrumb('net: $msg');
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  static void logFirebaseInit({required bool success, String? error}) {
    if (success) {
      _log(level: 500, color: _green, channel: 'AUTH', msg: '🔥 FIREBASE OK');
    } else {
      _log(level: 1000, color: _red, channel: 'AUTH', msg: '🔥 FIREBASE FAILED: $error');
    }
  }

  static void logGoogleSignIn(String stage, {String? detail}) {
    final icon = switch (stage) {
      'started'     => '🟡',
      'cancelled'   => '⬜',
      'token_ok'    => '🟢',
      'firebase_ok' => '✅',
      'failed'      => '🔴',
      _             => '🔵',
    };
    _log(
      level: stage == 'failed' ? 1000 : 500,
      color: _magenta,
      channel: 'AUTH',
      msg: '$icon GOOGLE SIGN-IN [$stage]${detail != null ? ' — $detail' : ''}',
    );
  }

  static void logTokenRetrieval({required bool success, String? truncatedToken, String? error}) {
    if (success && truncatedToken != null) {
      _log(level: 500, color: _green, channel: 'AUTH',
          msg: '🔑 TOKEN OK — ${maskToken(truncatedToken)}');
    } else {
      _log(level: 1000, color: _red, channel: 'AUTH',
          msg: '🔑 TOKEN FAILED — ${error ?? "no user"}');
    }
  }

  static void logValidateAccess(String stage, {String? hint, String? error}) {
    final icon = switch (stage) {
      'started' => '🔍', 'granted' => '✅', 'denied' => '🚫',
      'timeout' => '⏱',  'error'   => '❌', _ => '🔵',
    };
    final extra = [
      if (hint != null) 'hint=$hint',
      if (error != null) 'error=$error',
    ].join(', ');
    _log(
      level: (stage == 'denied' || stage == 'error' || stage == 'timeout') ? 1000 : 500,
      color: _yellow,
      channel: 'AUTH',
      msg: '$icon VALIDATE ACCESS [$stage]${extra.isNotEmpty ? ' — $extra' : ''}',
    );
  }

  static void logGraphQLAuth({required bool tokenAttached, String? uid}) {
    _log(
      level: tokenAttached ? 500 : 800,
      color: tokenAttached ? _green : _red,
      channel: 'AUTH',
      msg: '${tokenAttached ? '🔒 GQL AUTH ATTACHED' : '🔓 GQL AUTH SKIPPED'}${uid != null ? ' uid=$uid' : ''}',
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  static void nav(String route) {
    _log(level: 500, color: _blue, channel: 'NAV', msg: '→ $route');
    _breadcrumb('nav: $route');
  }

  // ── General ─────────────────────────────────────────────────────────────────

  static void info(String tag, String message) {
    _log(level: 500, color: _blue, channel: 'APP:INFO', msg: '[$tag] $message');
  }

  static void warning(String tag, String message) {
    _log(level: 900, color: _yellow, channel: 'APP:WARN', msg: '[$tag] $message');
  }

  static void error(String tag, dynamic err, [StackTrace? stack]) {
    _log(level: 1000, color: _red, channel: 'APP:ERR',
        msg: '[$tag] $err', error: err, stackTrace: stack);
    _recordError(err, stack, tag: tag);
  }

  // ── Token masking (PII safety) ───────────────────────────────────────────────

  static String maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }

  // ── Internal helpers ─────────────────────────────────────────────────────────

  static void _log({
    required int level,
    required String color,
    required String channel,
    required String msg,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    dev.log('$color$msg$_reset',
        name: channel, level: level, error: error, stackTrace: stackTrace);
  }

  static void _breadcrumb(String message) {
    if (!Get.isRegistered<CrashlyticsService>()) return;
    Get.find<CrashlyticsService>().log(message);
  }

  static void _recordError(dynamic err, StackTrace? stack, {required String tag}) {
    if (!Get.isRegistered<CrashlyticsService>()) {
      if (kDebugMode) debugPrint('[AppLogger] CrashlyticsService not registered');
      return;
    }
    Get.find<CrashlyticsService>().recordError(
      err, stack,
      category: CrashCategory.unknown,
      reason: tag,
    );
  }
}
