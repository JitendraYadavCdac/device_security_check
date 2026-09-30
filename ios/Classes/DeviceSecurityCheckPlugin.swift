import Flutter
import Foundation
import Darwin
import UIKit

public class DeviceSecurityCheckPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_security_scan", binaryMessenger: registrar.messenger())
    let instance = DeviceSecurityCheckPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "check":
      result(runChecks())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func runChecks() -> [String: Any] {
    let suspicious = jailbreakIndicators()
    let jailbroken = !suspicious.isEmpty
    let emulator = isSimulator()

    return [
      "supported": true,
      "platform": "ios",
      "isCompromised": jailbroken,
      "rooted": false,
      "jailbroken": jailbroken,
      "developerOptionsEnabled": false,
      "usbDebuggingEnabled": false,
      "emulator": emulator,
      "debuggerAttached": isDebuggerAttached(),
      "debuggableBuild": false,
      "suspiciousPathsFound": suspicious
    ]
  }

  private func jailbreakIndicators() -> [String] {
    var found: [String] = []
    let paths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/usr/sbin/sshd",
      "/usr/bin/ssh",
      "/etc/apt",
      "/private/var/lib/apt/",
      "/private/var/lib/cydia",
      "/private/var/stash",
      "/var/jb",
      "/var/binpack",
      "/var/lib/dpkg/"
    ]

    for path in paths where FileManager.default.fileExists(atPath: path) {
      found.append(path)
    }

    let testPath = "/private/" + UUID().uuidString
    do {
      try "security-check".write(toFile: testPath, atomically: true, encoding: .utf8)
      try? FileManager.default.removeItem(atPath: testPath)
      found.append("sandbox-write")
    } catch {
      // Expected on a sandboxed device.
    }

    if let url = URL(string: "cydia://package/com.example.package"),
       UIApplication.shared.canOpenURL(url) {
      found.append("cydia-url-scheme")
    }

    return found
  }

  private func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
  }

  private func isDebuggerAttached() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let result = mib.withUnsafeMutableBufferPointer { buffer in
      sysctl(buffer.baseAddress, u_int(buffer.count), &info, &size, nil, 0)
    }
    guard result == 0 else { return false }
    return (info.kp_proc.p_flag & P_TRACED) != 0
  }
}
