import 'package:flutter_test/flutter_test.dart';
import 'package:device_security_check/device_security_check.dart';

void main() {
  test('DeviceSecurityCheck can be called', () async {
    final result = await DeviceSecurityCheck.check();

    expect(result, isNotNull);
  });
}