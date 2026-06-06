import Flutter
import Metal
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

    // mylarium/device: report the GPU max 2D texture dimension so the reader can
    // decode the focused page sharper on capable hardware. Metal has no direct
    // property; it is defined by GPU family (Apple3 / A9+ = 16384, earlier 8192).
    let deviceChannel = FlutterMethodChannel(
      name: "mylarium/device", binaryMessenger: messenger)
    deviceChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "maxTextureSize":
        guard let device = MTLCreateSystemDefaultDevice() else {
          result(8192)
          return
        }
        result(device.supportsFamily(.apple3) ? 16384 : 8192)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
