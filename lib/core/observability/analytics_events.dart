/// Centralized event name constants for Firebase Analytics — dq_app.
///
/// All event names must be snake_case and ≤ 40 characters (Firebase limit).
/// All parameter names must be snake_case and ≤ 40 characters.
///
/// Never hardcode event names as strings elsewhere in the codebase.
/// Always import and use these constants.
abstract final class AnalyticsEvents {
  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String loginSuccess   = 'login_success';
  static const String loginFailed    = 'login_failed';
  static const String logout         = 'logout';
  static const String sessionExpired = 'session_expired';

  // ── Scanning ─────────────────────────────────────────────────────────────────
  static const String itemScanned   = 'item_scanned';
  static const String scanFailed    = 'scan_failed';
  static const String scannerOpened = 'scanner_opened';

  // ── Cart ─────────────────────────────────────────────────────────────────────
  static const String cartItemAdded   = 'cart_item_added';
  static const String cartItemRemoved = 'cart_item_removed';
  static const String cartCleared     = 'cart_cleared';

  // ── Checkout / Payment ────────────────────────────────────────────────────────
  static const String checkoutStarted    = 'checkout_started';
  static const String paymentInitiated   = 'payment_initiated';
  static const String paymentSuccess     = 'payment_success';
  static const String paymentFailed      = 'payment_failed';
  static const String orderPlaced        = 'order_placed';

  // ── Orders ───────────────────────────────────────────────────────────────────
  static const String orderViewed   = 'order_viewed';
  static const String orderReviewed = 'order_reviewed';

  // ── Navigation ───────────────────────────────────────────────────────────────
  static const String screenView = 'screen_view';

  // ── Errors ───────────────────────────────────────────────────────────────────
  static const String apiError     = 'api_error';
  static const String networkError = 'network_error';

  // ── Performance ──────────────────────────────────────────────────────────────
  static const String frameJankDetected = 'frame_jank_detected';
  static const String anrDetected       = 'anr_detected';
  static const String slowStartup       = 'slow_startup';
}

/// Centralized parameter name constants for Firebase Analytics — dq_app.
abstract final class AnalyticsParams {
  static const String screenName    = 'screen_name';
  static const String userId        = 'user_id';
  static const String storeId       = 'store_id';
  static const String orderId       = 'order_id';
  static const String productId     = 'product_id';
  static const String quantity      = 'quantity';
  static const String amountRupees  = 'amount_rupees';
  static const String paymentMethod = 'payment_method';
  static const String errorCode     = 'error_code';
  static const String errorMessage  = 'error_message';
  static const String operationName    = 'operation_name';
  static const String flavor           = 'flavor';
  static const String correlationId    = 'cid';

  // ── Performance parameters ────────────────────────────────────────────────────
  static const String jankyFrameCount  = 'janky_frames';
  static const String slowFrameCount   = 'slow_frames';
  static const String totalFrameCount  = 'total_frames';
  static const String maxFrameMs       = 'max_frame_ms';
  static const String avgFrameMs       = 'avg_frame_ms';
  static const String startupMs             = 'startup_ms';
  static const String sessionId             = 'session_id';
  static const String severity              = 'severity';
  static const String consecutiveJankyFrames = 'consecutive_janky_frames';
}
