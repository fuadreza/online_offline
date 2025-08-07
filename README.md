# Online Offline Flutter Package

[![pub.dev](https://img.shields.io/pub/v/online_offline.svg)](https://pub.dev/packages/online_offline)
[![GitHub stars](https://img.shields.io/github/stars/fuadreza/online_offline.svg?style=social)](https://github.com/fuadreza/online_offline)

## Description

A robust Flutter package for monitoring internet connectivity in real-time. 
Unlike traditional connectivity checkers that only verify network interface status, 
`online_offline` performs actual socket connections to ensure true internet availability.

This package:
- Uses socket connections to verify real internet connectivity (not just network interface status)
- Efficiently manages resources by pausing checks when the app is in background
- Provides easy-to-use widgets for handling online/offline UI states
- Offers customizable check intervals, timeouts, and hosts

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  online_offline: ^latest_version
```

Then run:

```bash
flutter pub get
```

Or using command line:

```bash
flutter pub add online_offline
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:online_offline/online_offline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a connection service instance
    final connectionService = ConnectionService();
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Online Offline Demo')),
        body: Center(
          child: OnlineOffline(
            connectionService: connectionService,
            onlineWidget: const Text('You are online!', style: TextStyle(color: Colors.green, fontSize: 24)),
            offlineWidget: const Text('You are offline!', style: TextStyle(color: Colors.red, fontSize: 24)),
            onConnectionChange: (isOnline) {
              // Handle connection status changes
              print('Connection status changed: ${isOnline ? 'Online' : 'Offline'}');
            },
          ),
        ),
      ),
    );
  }
}
```

### Customizing Connection Service

```dart
// Create a custom connection service with specific configuration
final connectionService = ConnectionService(
  host: 'google.com',  // Google Domain (default: 8.8.8.8)
  port: 80,         // TCP port (default: 53)
  timeoutDuration: const Duration(seconds: 3),
  checkInterval: const Duration(seconds: 10),
  enableDebugLogging: true,
);
```

### Accessing Connection Status Directly

```dart
// Check current status
bool currentStatus = connectionService.isOnline.value;

// Listen for changes
connectionService.isOnline.addListener(() {
  print('Connection changed: ${connectionService.isOnline.value}');
});

// Remember to dispose the service when no longer needed
@override
void dispose() {
  connectionService.dispose();
  super.dispose();
}
```

## Complete example link

For a comprehensive demonstration of all features, check out the [example project](https://pub.dev/packages/online_offline/example)

## Contributing

Contributions are welcome! If you'd like to contribute, please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

