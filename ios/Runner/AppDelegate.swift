import UIKit
import Flutter
import flutter_downloader
import WebKit


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.hexagone.mynust/webview",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "getCookies",
              let args = call.arguments as? [String: Any],
              let rawUrl = args["url"] as? String,
              let url = URL(string: rawUrl) else {
          result(FlutterMethodNotImplemented)
          return
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
          let header = cookies
            .filter { cookie in
              let domain = cookie.domain.trimmingCharacters(in: CharacterSet(charactersIn: "."))
              return url.host == domain || (url.host?.hasSuffix(".\(domain)") ?? false)
            }
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
          result(header)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
