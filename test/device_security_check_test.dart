import 'package:device_security_scan/device_security_scan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unsupported result is safe', () {
    const result = SecurityCheckResult.unsupported();
    expect(result.supported, isFalse);
    expect(result.isCompromised, isFalse);
  });
}
