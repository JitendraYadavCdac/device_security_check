import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Basic device security checks for Android and iOS.
///
/// These checks are signals, not a guarantee that a device is secure. A
/// determined attacker can bypass local checks, so use server-side controls
/// such as Play Integrity/App Attest where appropriate.
class DeviceSecurityCheck {
  DeviceSecurityCheck._();

  static const MethodChannel _channel =
      MethodChannel('device_security_scan');

  /// Returns a snapshot of the supported security signals.
  static Future<SecurityCheckResult> check() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return SecurityCheckResult.unsupported();
    }

    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('check');
    return SecurityCheckResult.fromMap(result ?? const {});
  }

  static Future<bool> isRootedOrJailbroken() async =>
      (await check()).isCompromised;

  static Future<bool> isDeveloperOptionsEnabled() async =>
      (await check()).developerOptionsEnabled;

  static Future<bool> isEmulator() async => (await check()).emulator;

  static Future<bool> isDebuggerAttached() async =>
      (await check()).debuggerAttached;
}

class SecurityCheckResult {
  const SecurityCheckResult({
    required this.supported,
    required this.platform,
    required this.isCompromised,
    required this.rooted,
    required this.jailbroken,
    required this.developerOptionsEnabled,
    required this.usbDebuggingEnabled,
    required this.emulator,
    required this.debuggerAttached,
    required this.debuggableBuild,
    required this.suspiciousPathsFound,
  });

  const SecurityCheckResult.unsupported()
      : supported = false,
        platform = 'unsupported',
        isCompromised = false,
        rooted = false,
        jailbroken = false,
        developerOptionsEnabled = false,
        usbDebuggingEnabled = false,
        emulator = false,
        debuggerAttached = false,
        debuggableBuild = false,
        suspiciousPathsFound = const <String>[];

  final bool supported;
  final String platform;
  final bool isCompromised;
  final bool rooted;
  final bool jailbroken;
  final bool developerOptionsEnabled;
  final bool usbDebuggingEnabled;
  final bool emulator;
  final bool debuggerAttached;
  final bool debuggableBuild;
  final List<String> suspiciousPathsFound;

  factory SecurityCheckResult.fromMap(Map<dynamic, dynamic> map) {
    final paths = map['suspiciousPathsFound'];
    return SecurityCheckResult(
      supported: map['supported'] == true,
      platform: map['platform']?.toString() ?? 'unknown',
      isCompromised: map['isCompromised'] == true,
      rooted: map['rooted'] == true,
      jailbroken: map['jailbroken'] == true,
      developerOptionsEnabled: map['developerOptionsEnabled'] == true,
      usbDebuggingEnabled: map['usbDebuggingEnabled'] == true,
      emulator: map['emulator'] == true,
      debuggerAttached: map['debuggerAttached'] == true,
      debuggableBuild: map['debuggableBuild'] == true,
      suspiciousPathsFound: paths is List
          ? paths.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
    );
  }

  Map<String, dynamic> toMap() => {
        'supported': supported,
        'platform': platform,
        'isCompromised': isCompromised,
        'rooted': rooted,
        'jailbroken': jailbroken,
        'developerOptionsEnabled': developerOptionsEnabled,
        'usbDebuggingEnabled': usbDebuggingEnabled,
        'emulator': emulator,
        'debuggerAttached': debuggerAttached,
        'debuggableBuild': debuggableBuild,
        'suspiciousPathsFound': suspiciousPathsFound,
      };

  @override
  String toString() => 'SecurityCheckResult(${toMap()})';
}
