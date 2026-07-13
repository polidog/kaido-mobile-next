import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Google Maps の API キーは Dart 側から dart-define（GOOGLE_API_KEY_IOS）の値を
    // MethodChannel 経由で受け取る（configureGoogleMapsApiKey / kaido_ui）。
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KaidoGoogleMaps") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "kaido/google_maps",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setApiKey":
        guard let apiKey = call.arguments as? String, !apiKey.isEmpty else {
          result(FlutterError(
            code: "invalid_argument",
            message: "API key must be a non-empty String",
            details: nil
          ))
          return
        }
        GMSServices.provideAPIKey(apiKey)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
