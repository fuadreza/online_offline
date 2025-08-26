part of '../online_offline.dart';

class OnlineOffline extends StatefulWidget {
  /// The service that provides connection status updates.
  final ConnectionService connectionService;

  /// Widget to display when the connection is online.
  final Widget onlineWidget;

  /// Widget to display when the connection is offline.
  final Widget? offlineWidget;

  /// Optional callback triggered when the connection status changes.
  final ValueChanged<bool>? onConnectionChange;

  const OnlineOffline({
    super.key,
    required this.connectionService,
    required this.onlineWidget,
    this.offlineWidget,
    this.onConnectionChange,
  });

  @override
  State<OnlineOffline> createState() => _OnlineOfflineState();
}

class _OnlineOfflineState extends State<OnlineOffline> {
  late bool _isOnline;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.connectionService.isOnline.value;
    widget.connectionService.isOnline.addListener(_handleConnectionChange);
  }

  void _handleConnectionChange() {
    final isOnline = widget.connectionService.isOnline.value;
    if (_isOnline != isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
      widget.onConnectionChange?.call(isOnline);
    }
  }

  @override
  void dispose() {
    widget.connectionService.isOnline.removeListener(_handleConnectionChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return widget.onlineWidget;
    } else {
      return widget.offlineWidget != null
          ? widget.offlineWidget!
          : widget.onlineWidget;
    }
  }
}
