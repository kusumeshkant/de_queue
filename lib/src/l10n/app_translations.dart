import 'package:get/get.dart';
import 'en_us.dart';
import 'hi_in.dart';

/// GetX Translations class.
/// To add a new language:
///   1. Create a new file, e.g., `mr_in.dart` (Marathi)
///   2. Define a `const Map<String, String> mrIn = { ... }` in that file
///   3. Add the locale entry below: `'mr_IN': mrIn`
///   4. Add the locale to [AppLocales.supported] in language_controller.dart
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'hi_IN': hiIn,
        // Add new languages here ↓
      };
}
