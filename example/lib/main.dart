import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_offline/online_offline.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: OnlineOffline(
            connectionService: ConnectionService(
              host: 'google.com',
              port: 80,
              timeoutDuration: const Duration(seconds: 2),
              checkInterval: const Duration(seconds: 2),
              enableDebugLogging: true,
            ),
            onlineWidget: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green.shade300,
              ),
              child: const Center(child: Text('Online')),
            ),
            offlineWidget: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.shade300,
              ),
              child: const Center(child: Text('Offline')),
            ),
            onConnectionChange: (isOnline) {
              if (kDebugMode) {
                print('Connection status changed: $isOnline');
              }
            },
          ),
        ),
      ),
    ),
  );
}
