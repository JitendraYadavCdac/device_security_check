import 'package:device_security_scan/device_security_scan.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SecurityExampleApp());

class SecurityExampleApp extends StatelessWidget {
  const SecurityExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Security Check')),
          body: Center(
            child: FutureBuilder<SecurityCheckResult>(
              future: DeviceSecurityCheck.check(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final data = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(data.toMap().toString()),
                );
              },
            ),
          ),
        ),
      );
}
