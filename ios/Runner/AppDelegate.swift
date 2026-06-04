import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // mylarium/fs: exclude downloaded media from iCloud/iTunes backup.
    let messenger = engineBridge.applicationRegistrar.messenger()
    let fsChannel = FlutterMethodChannel(
      name: "mylarium/fs", binaryMessenger: messenger)
    fsChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "excludeFromBackup":
        guard
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
        else {
          result(
            FlutterError(
              code: "bad_args", message: "expected {path}", details: nil))
          return
        }
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
          try url.setResourceValues(values)
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "exclude_failed",
              message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
