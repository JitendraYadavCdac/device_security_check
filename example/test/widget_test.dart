import 'package:flutter_test/flutter_test.dart';
import 'package:device_security_scan/device_security_scan.dart';

void main() {
  test('DeviceSecurityCheck can be called', () async {
    final result = await DeviceSecurityCheck.check();

    expect(result, isNotNull);
  });
}