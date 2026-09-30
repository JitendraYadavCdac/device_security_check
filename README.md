# device_security_check

Basic Flutter device-security signals for Android and iOS.

> **Important:** This plugin is a local signal collector, not a complete security boundary. Root/jailbreak detection can be bypassed. For high-risk decisions, combine local signals with server-side attestation such as Google Play Integrity on Android and App Attest/DeviceCheck on Apple platforms.

## Checks

| Check | Android | iOS |
|---|---:|---:|
| Root detection | Yes | — |
| Jailbreak detection | — | Yes |
| Developer options | Yes | Not exposed by public API |
| USB debugging / ADB | Yes | — |
| Emulator / simulator | Yes | Yes |
| Debugger attached | Yes | Yes |
| Debuggable app build | Yes | — |
| Suspicious paths | Yes | Yes |

## Installation

```yaml
dependencies:
  device_security_check: ^0.1.0
```

## Usage

```dart
import 'package:device_security_check/device_security_check.dart';

final security = await DeviceSecurityCheck.check();

if (security.isCompromised) {
  // Decide what your application should do.
}

print(security.toMap());
```

Individual checks are also available:

```dart
final compromised = await DeviceSecurityCheck.isRootedOrJailbroken();
final developerOptions = await DeviceSecurityCheck.isDeveloperOptionsEnabled();
final emulator = await DeviceSecurityCheck.isEmulator();
final debugger = await DeviceSecurityCheck.isDebuggerAttached();
```

## Result example

```text
SecurityCheckResult({
  supported: true,
  platform: android,
  isCompromised: false,
  rooted: false,
  jailbroken: false,
  developerOptionsEnabled: true,
  usbDebuggingEnabled: false,
  emulator: false,
  debuggerAttached: false,
  debuggableBuild: false,
  suspiciousPathsFound: []
})
```

## Security notes

- No root/jailbreak detector is guaranteed to identify every compromised device.
- A developer-options flag is not proof that a device is compromised.
- Do not block users solely because of one weak signal unless that is appropriate for your threat model.
- For backend authorization, enforce security server-side and use platform attestation where appropriate.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

Before publishing, replace the placeholder homepage/repository/issue URLs and author information in `pubspec.yaml` and the iOS podspec.
