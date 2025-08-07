part of '../online_offline.dart';

/// A singleton service to monitor internet connectivity.
/// It provides a [ValueNotifier<bool>] called [isOnline]
/// that updates every 5 seconds based on the internet status.
///
/// Default version attempts to establish a direct socket connection
/// to a known internet host (Google's DNS 8.8.8.8 on port 53)
/// to determine connectivity, which is more robust than just a DNS lookup.
///
/// It also monitors app lifecycle states to pause/resume monitoring
/// when the app goes to the background/foreground.
class ConnectionService with WidgetsBindingObserver {
  factory ConnectionService({
    String host = '8.8.8.8',
    int port = 53,
    Duration timeoutDuration = const Duration(seconds: 3),
    Duration checkInterval = const Duration(seconds: 5),
    bool enableDebugLogging = false,
  }) {
    _instance ??= ConnectionService._internal(
      host: host,
      port: port,
      timeoutDuration: timeoutDuration,
      checkInterval: checkInterval,
      enableDebugLogging: enableDebugLogging,
    );
    return _instance!;
  }

  ConnectionService._internal({
    required this.host,
    required this.port,
    required this.timeoutDuration,
    required this.checkInterval,
    this.enableDebugLogging = false,
  }) {
    // Initialize the service when the singleton is created
    _init();
    // Add this instance as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  } // Add WidgetsBindingObserver mixin

  // --- Singleton setup ---
  static ConnectionService? _instance;

  final String host;
  final int port;
  final Duration timeoutDuration;
  final Duration checkInterval;
  final bool enableDebugLogging;

  // --- Connectivity monitoring ---
  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(false);
  Timer? _timer;

  /// Initializes the internet monitoring.
  /// Checks initial status and sets up a periodic timer.
  void _init() {
    _checkInternetStatus(); // Check immediately on startup
    _startMonitoring(); // Start periodic checks
  }

  /// Checks the current internet connectivity status by attempting to
  /// establish a direct socket connection to a reliable internet host.
  /// Updates [isOnline] based on the success of this connection.
  Future<void> _checkInternetStatus() async {
    var currentlyOnline = false;
    Socket? socket; // Declare socket outside try-catch for finally block

    try {
      // Attempt to establish a direct socket connection to the test host and port.
      // This is a more definitive check for actual network reachability.
      socket = await Socket.connect(host, port, timeout: timeoutDuration);
      currentlyOnline = true; // If connection succeeds, we are online
    } on SocketException catch (e) {
      // If a SocketException occurs, it means we couldn't reach the host.
      if (enableDebugLogging) {
        // Log the exception if debug logging is enabled
        debugPrint('SocketException during internet check: $e');
      }
      currentlyOnline = false;
    } on TimeoutException catch (_) {
      // If the connection attempt times out.
      if (enableDebugLogging) {
        // Log the timeout if debug logging is enabled
        debugPrint('Timeout during internet check.');
      }
      currentlyOnline = false;
    } catch (e) {
      // Catch any other potential errors during the check.
      if (enableDebugLogging) {
        // Log any other exceptions if debug logging is enabled
        debugPrint('Error checking internet status: $e');
      }
      currentlyOnline = false;
    } finally {
      // Ensure the socket is closed to prevent resource leaks.
      socket?.destroy();
    }

    // Update the ValueNotifier only if the status has changed
    if (isOnline.value != currentlyOnline) {
      isOnline.value = currentlyOnline;
      // Log the status change if debug logging is enabled
      if (enableDebugLogging) {
        debugPrint('Internet status changed: ${isOnline.value ? 'Online' : 'Offline'}');
      }
    }
  }

  /// Starts a periodic timer to check internet status every 5 seconds.
  void _startMonitoring() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(checkInterval, (timer) {
      _checkInternetStatus();
    });

    // Log the start of monitoring if debug logging is enabled
    if (enableDebugLogging) {
      debugPrint('Starting internet monitoring with interval: ${checkInterval.inSeconds} seconds');
    }
  }

  /// Stops the internet monitoring timer.
  void _stopMonitoring() {
    _timer?.cancel();
    _timer = null; // Clear the timer reference

    // Log the stop of monitoring if debug logging is enabled
    if (enableDebugLogging) {
      debugPrint('Stopping internet monitoring.');
    }
  }

  /// Callback for app lifecycle changes.
  /// Resumes monitoring when the app comes to the foreground.
  /// Pauses monitoring when the app goes to the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Log the app lifecycle state change if debug logging is enabled
    if (enableDebugLogging) {
      debugPrint('App lifecycle state changed: $state');
    }
    switch (state) {
      case AppLifecycleState.resumed:
      // App is in the foreground, resume monitoring
        _startMonitoring();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      // App is in the background or terminated, stop monitoring
        _stopMonitoring();
      case AppLifecycleState.hidden:
      // App is hidden (e.g., on web when tab is not active)
        _stopMonitoring();
    }
  }

  /// Stops the internet monitoring timer and disposes resources.
  /// Call this when the app is closing or the service is no longer needed
  /// to prevent memory leaks.
  void dispose() {
    _stopMonitoring(); // Ensure timer is cancelled
    isOnline.dispose(); // Dispose the ValueNotifier
    // Remove this instance as an observer
    WidgetsBinding.instance.removeObserver(this);

    // Log the disposal of the service if debug logging is enabled
    if (enableDebugLogging) {
      debugPrint('Disposing ConnectionService and stopping monitoring.');
    }
  }
}