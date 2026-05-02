// Centralised role protocol constants for the DQ customer app.
//
// SINGLE SOURCE OF TRUTH for strings sent to / received from the backend.
// Never hardcode these values in query strings, mutation strings, or hint
// comparisons — always import from here.
//
// The UI layer uses [AuthAccessHint] (in customer_auth_service.dart) for
// type-safe branching — these constants only appear at the GraphQL boundary.

/// App identifiers for the validateAppAccess(appId) gate.
/// Values must match [AppId] in backend/src/constants/roles.js exactly.
abstract final class AppId {
  static const customer = 'CUSTOMER';
  static const staff    = 'STAFF';
  static const admin    = 'ADMIN';

  // Future apps — uncomment when the Flutter client for that role is built:
  // static const vendor   = 'VENDOR';
  // static const delivery = 'DELIVERY';
}

/// Hint strings carried in FORBIDDEN error extensions.
/// Values must match [RoleHint] in backend/src/constants/roles.js exactly.
abstract final class RoleHint {
  static const staffNoCustomer = 'STAFF_NO_CUSTOMER';
  static const adminNoCustomer = 'ADMIN_NO_CUSTOMER';
  static const noCustomer      = 'NO_CUSTOMER';

  // Future hints — add when new role types are introduced:
  // static const vendorNoCustomer   = 'VENDOR_NO_CUSTOMER';
  // static const deliveryNoCustomer = 'DELIVERY_NO_CUSTOMER';
}
