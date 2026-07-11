import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the contact form's destination email address, injected via
/// `--dart-define-from-file` as `CONTACT_EMAIL`.
///
/// Returns the configured email or a fallback empty string that the contact
/// page must guard against before building the mailto URI.
final contactEmailProvider = Provider<String>(
  (ref) {
    const email = String.fromEnvironment('CONTACT_EMAIL');
    assert(email.isNotEmpty, 'CONTACT_EMAIL must be set via --dart-define');
    return email;
  },
);
