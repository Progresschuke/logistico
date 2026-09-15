import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Provide Google Maps iOS API Key
    let apiKey = getEnvVar("GOOGLE_MAPS_IOS_API_KEY")
      ?? getEnvVar("GOOGLE_MAPS_DIRECTIONS_API_KEY")
      ?? ""

    GMSServices.provideAPIKey(apiKey)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getEnvVar(_ key: String) -> String? {
    // 1. Process environment variable
    if let envVal = ProcessInfo.processInfo.environment[key], !envVal.isEmpty {
      return envVal
    }

    // 2. Search bundle and Flutter asset paths for .env
    let possiblePaths: [String?] = [
      Bundle.main.path(forResource: ".env", ofType: nil),
      Bundle.main.path(forResource: ".env", ofType: nil, inDirectory: "flutter_assets"),
      Bundle.main.path(forResource: ".env", ofType: nil, inDirectory: "Frameworks/App.framework/flutter_assets"),
      Bundle.main.bundlePath + "/flutter_assets/.env",
      Bundle.main.bundlePath + "/Frameworks/App.framework/flutter_assets/.env"
    ]

    for path in possiblePaths {
      guard let path = path, FileManager.default.fileExists(atPath: path) else { continue }
      if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        for line in contents.components(separatedBy: .newlines) {
          let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
          if trimmed.isEmpty || trimmed.hasPrefix("#") || !trimmed.contains("=") {
            continue
          }
          let parts = trimmed.components(separatedBy: "=")
          let currentKey = parts[0].trimmingCharacters(in: .whitespaces)
          if currentKey == key {
            let val = parts.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespaces)
            if !val.isEmpty { return val }
          }
        }
      }
    }

    return nil
  }
}