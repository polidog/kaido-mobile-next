import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Google Maps API key for iOS, injected via `--dart-define-from-file`
/// as `GOOGLE_API_KEY_IOS`.
const _googleApiKeyIos = String.fromEnvironment('GOOGLE_API_KEY_IOS');

const _channel = MethodChannel('kaido/google_maps');

/// Provides the Google Maps API key to the native iOS Maps SDK.
///
/// On iOS, dart-define values are not visible to the Xcode build, so the
/// key is handed to `GMSServices.provideAPIKey` at startup through a
/// method channel handled in each app's `AppDelegate`. On Android the key
/// is injected into `AndroidManifest.xml` by Gradle (from
/// `GOOGLE_API_KEY_ANDROID`), so this is a no-op.
///
/// Must be called before any map view is created, i.e. before `runApp`.
Future<void> configureGoogleMapsApiKey() async {
  if (kIsWeb || !Platform.isIOS) {
    return;
  }
  if (_googleApiKeyIos.isEmpty) {
    return;
  }
  await _channel.invokeMethod<void>('setApiKey', _googleApiKeyIos);
}
