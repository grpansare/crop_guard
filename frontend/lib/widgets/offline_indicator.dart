import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/offline_service.dart';

class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final bool showSyncButton;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
    this.showSyncButton = true,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final OfflineService _offlineService = OfflineService();
  bool _isOnline = true;
  int _syncQueueSize = 0;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _startStatusMonitoring();
  }

  void _updateStatus() {
    setState(() {
      _isOnline = _offlineService.isOnline;
      _syncQueueSize = _offlineService.syncQueueSize;
    });
  }

  void _startStatusMonitoring() {
    // Update status every 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _updateStatus();
        _startStatusMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showBanner && !_isOnline)
          Positioned(top: 0, left: 0, right: 0, child: _buildOfflineBanner()),
        if (widget.showSyncButton && _syncQueueSize > 0)
          Positioned(bottom: 16, right: 16, child: _buildSyncButton()),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Some features may be limited.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_syncQueueSize > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_syncQueueSize pending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return FloatingActionButton.small(
      onPressed: _isOnline ? _forceSync : null,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(Icons.sync, color: Colors.white, size: 20),
    );
  }

  Future<void> _forceSync() async {
    if (!_isOnline) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            const Text('Syncing data...'),
          ],
        ),
      ),
    );

    try {
      await _offlineService.forceSync();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _updateStatus();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class OfflineStatusWidget extends StatelessWidget {
  const OfflineStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineService>(
      builder: (context, offlineService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: offlineService.isOnline
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: offlineService.isOnline
                  ? Colors.green.shade300
                  : Colors.orange.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offlineService.isOnline ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: offlineService.isOnline
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                offlineService.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: offlineService.isOnline
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
              if (offlineService.syncQueueSize > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${offlineService.syncQueueSize}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Consumer widget for OfflineService
class Consumer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    // This is a simplified consumer - in a real app, you'd use Provider or Riverpod
    return builder(context, OfflineService() as T, child);
  }
}
