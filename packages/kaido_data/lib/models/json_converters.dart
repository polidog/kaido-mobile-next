/// JSON converters shared by the domain models.
///
/// The new `kaido-web-next` schema uses nanoid TEXT ids while the bundled
/// legacy JSON assets (and old file caches) use integer ids. These helpers
/// accept both so every data source parses through the same models.
library;

/// Converts a JSON id (int or String) to a String id.
///
/// Throws a [FormatException] when [value] is null so that records with
/// missing ids are detected at parse time instead of silently colliding
/// on an empty-string id.
String jsonIdToString(Object? value) {
  if (value == null) {
    throw const FormatException('Required id is missing (null)');
  }
  return value.toString();
}

/// Converts a nullable JSON id (int or String) to a nullable String id.
String? jsonIdToStringOrNull(Object? value) => value?.toString();
