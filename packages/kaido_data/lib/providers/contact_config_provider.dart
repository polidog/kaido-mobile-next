import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the contact form's destination email address, injected via
/// `--dart-define-from-file` as `CONTACT_EMAIL`.
final contactEmailProvider = Provider<String>(
  (ref) => const String.fromEnvironment('CONTACT_EMAIL'),
);
