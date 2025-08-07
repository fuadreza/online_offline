import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:online_offline/online_offline.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('ConnectionService', () {

    late ConnectionService service;

    setUp(() {
      service = ConnectionService(
        host: '8.8.8.8',
        port: 80,
        timeoutDuration: Duration(milliseconds: 100),
        checkInterval: Duration(milliseconds: 200),
        enableDebugLogging: true,
      );
    });

    // tearDown(() {
    //   service.dispose();
    // });

    test('initially offline', () {
      expect(service.isOnline.value, false);
    });

    test('isOnline updates after check', () async {
      // Wait for the first check to complete
      await Future.delayed(Duration(milliseconds: 300));
      // The result depends on actual network, so just check type
      expect(service.isOnline.value, isA<bool>());
      expect(service.isOnline.value, true);
    });
  });
}
