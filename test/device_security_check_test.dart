import 'package:device_security_check/device_security_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unsupported result is safe', () {
    const result = SecurityCheckResult.unsupported();
    expect(result.supported, isFalse);
    expect(result.isCompromised, isFalse);
  });
}
