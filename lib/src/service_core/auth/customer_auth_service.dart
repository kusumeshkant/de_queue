import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dq_app/src/constants/app_roles.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';

// ── Typed error ───────────────────────────────────────────────────────────────

/// Machine-readable reason for a customer-access denial.
/// Add new values here when new role types (vendor, delivery, franchise) land.
enum AuthAccessHint {
  /// Account exists as staff only — needs customer signup.
  staffNoCustomer,

  /// Account exists as admin only — needs customer signup.
  adminNoCustomer,

  /// Network timeout or connection failure.
  network,

  /// Backend denial with an unrecognised hint, or a logic error.
  unknown,
}

/// Thrown whenever a Firebase-authenticated user is denied access to the
/// customer app. Carries a user-facing [userMessage] and a machine-readable
/// [hint] so the UI layer can show the correct dialog or action without
/// parsing strings.
class AccessDeniedException implements Exception {
  final String userMessage;
  final AuthAccessHint hint;

  const AccessDeniedException(this.userMessage, this.hint);

  @override
  String toString() => userMessage;
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Centralised customer-app auth validator.
///
/// Both [LoginController] and [SignupController] delegate all post-Firebase
/// validation here so the logic lives in exactly one place and cannot drift.
///
/// **Why direct client calls instead of [GraphQLService.performQuery]?**
/// [GraphQLService._handleException] re-throws ANY GraphQL error (including
/// FORBIDDEN) as a generic [Exception], discarding the structured `hint`
/// extension that the backend sends. Auth validation needs that hint to show
/// the right UI path, so it calls [GraphQLClientProvider.client] directly and
/// inspects the result before deciding what to throw.
class CustomerAuthService {
  static const _kTimeout = Duration(seconds: 20);

  // ─── GraphQL documents ────────────────────────────────────────────────────

  static final _validateQuery = '''
    query ValidateCustomerAccess {
      validateAppAccess(appId: "${AppId.customer}") { id roles }
    }
  ''';

  static const _registerMutation = r'''
    mutation RegisterAsCustomer {
      registerAsCustomer { id roles }
    }
  ''';

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Validates that the currently signed-in Firebase user has (or is eligible
  /// for) the 'customer' role on the DQ backend.
  ///
  /// Behaviour by account state:
  /// - New account (UID not in DB) → auto-created as customer → success
  /// - Existing customer            → validated → success
  /// - Staff-only / admin-only      → signs out Firebase, throws [AccessDeniedException]
  /// - Network failure / timeout    → signs out Firebase, throws [AccessDeniedException]
  ///
  /// The caller must NOT catch [AccessDeniedException] broadly — let it
  /// propagate to the UI so the correct dialog is shown.
  static Future<void> validateCustomerAccess() async {
    final result = await _executeQuery(_validateQuery);

    if (result.hasException) {
      await _signOut();
      final gqlError = result.exception?.graphqlErrors.firstOrNull;
      final rawHint = gqlError?.extensions?['hint'] as String?;
      final msg = gqlError?.message
          ?? 'Access denied. Please sign up on the DQ App to continue.';
      throw AccessDeniedException(msg, _parseHint(rawHint));
    }
  }

  /// Adds the 'customer' role to the currently signed-in user on the backend.
  ///
  /// Called by the signup flow when a staff or admin Google account wants to
  /// also use DQ as a customer. Idempotent — safe to call if already a customer.
  ///
  /// Throws [AccessDeniedException] on network failure or backend error.
  static Future<void> registerAsCustomer() async {
    final result = await _executeMutation(_registerMutation);

    if (result.hasException) {
      await _signOut();
      throw const AccessDeniedException(
        'Failed to set up your customer profile. Please try again.',
        AuthAccessHint.unknown,
      );
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  static Future<QueryResult> _executeQuery(String query) async {
    try {
      return await GraphQLClientProvider.client
          .query(QueryOptions(
            document: gql(query),
            fetchPolicy: FetchPolicy.networkOnly,
          ))
          .timeout(
            _kTimeout,
            onTimeout: () => throw const AccessDeniedException(
              'Connection timed out. Please check your network and try again.',
              AuthAccessHint.network,
            ),
          );
    } on AccessDeniedException {
      rethrow;
    } catch (_) {
      await _signOut();
      throw const AccessDeniedException(
        'Unable to reach the server. Please check your connection and try again.',
        AuthAccessHint.network,
      );
    }
  }

  static Future<QueryResult> _executeMutation(String mutation) async {
    try {
      return await GraphQLClientProvider.client
          .mutate(MutationOptions(document: gql(mutation)))
          .timeout(
            _kTimeout,
            onTimeout: () => throw const AccessDeniedException(
              'Connection timed out. Please try again.',
              AuthAccessHint.network,
            ),
          );
    } on AccessDeniedException {
      rethrow;
    } catch (_) {
      await _signOut();
      throw const AccessDeniedException(
        'Unable to reach the server. Please try again.',
        AuthAccessHint.network,
      );
    }
  }

  static AuthAccessHint _parseHint(String? raw) => switch (raw) {
        RoleHint.staffNoCustomer => AuthAccessHint.staffNoCustomer,
        RoleHint.adminNoCustomer => AuthAccessHint.adminNoCustomer,
        _ => AuthAccessHint.unknown,
      };

  static Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
