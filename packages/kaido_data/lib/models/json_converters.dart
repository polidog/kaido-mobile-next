/// JSON converters shared by the domain models.
///
/// The new `kaido-web-next` schema uses nanoid TEXT ids while the bundled
/// legacy JSON assets (and old file caches) use integer ids. These helpers
/// accept both so every data source parses through the same models.
library;

/// Converts a JSON id (int or String) to a String id.
String jsonIdToString(Object? value) => value?.toString() ?? '';

/// Converts a nullable JSON id (int or String) to a nullable String id.
String? jsonIdToStringOrNull(Object? value) => value?.toString();
