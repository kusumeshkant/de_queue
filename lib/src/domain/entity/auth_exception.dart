/// Thrown when a Google Sign-In redirect has been initiated (web only).
///
/// The browser navigates away immediately after this is thrown.
/// The caller should keep the loading state visible — auth completes
/// when the app restarts and [getRedirectResult] runs in main.dart.
class GoogleSignInRedirectStarted implements Exception {
  const GoogleSignInRedirectStarted();
  @override
  String toString() => 'GoogleSignInRedirectStarted';
}
