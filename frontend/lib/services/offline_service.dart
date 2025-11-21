import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static const String _offlineDataKey = 'offline_data';
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync';

  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  List<Map<String, dynamic>> _syncQueue = [];

  // Getters
  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get syncQueue => List.unmodifiable(_syncQueue);
  int get syncQueueSize => _syncQueue.length;

  // Initialize offline service
  Future<void> initialize() async {
    await _loadSyncQueue();
    await _checkConnectivity();
    _startConnectivityMonitoring();
  }

  // Check internet connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;

      if (_isOnline) {
        await _syncPendingData();
      }
    } catch (e) {
      _isOnline = false;
      debugPrint('Connectivity check failed: $e');
    }
  }

  // Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOffline = !_isOnline;
      _isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      if (wasOffline && _isOnline) {
        // Came back online, sync pending data
        _syncPendingData();
      }
    });
  }

  // Save data for offline use
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineData = await getOfflineData();
      offlineData[key] = data;

      await prefs.setString(_offlineDataKey, jsonEncode(offlineData));
      debugPrint('Offline data saved for key: $key');
    } catch (e) {
      debugPrint('Failed to save offline data: $e');
    }
  }

  // Get offline data
  Future<Map<String, dynamic>> getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_offlineDataKey);

      if (dataString != null) {
        return Map<String, dynamic>.from(jsonDecode(dataString));
      }
      return {};
    } catch (e) {
      debugPrint('Failed to get offline data: $e');
      return {};
    }
  }

  // Get specific offline data by key
  Future<Map<String, dynamic>?> getOfflineDataByKey(String key) async {
    final offlineData = await getOfflineData();
    return offlineData[key];
  }

  // Queue data for sync when online
  Future<void> queueForSync(String action, Map<String, dynamic> data) async {
    final syncItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };

    _syncQueue.add(syncItem);
    await _saveSyncQueue();

    debugPrint('Queued for sync: $action');

    // Try to sync immediately if online
    if (_isOnline) {
      await _syncPendingData();
    }
  }

  // Load sync queue from storage
  Future<void> _loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueString = prefs.getString(_syncQueueKey);

      if (queueString != null) {
        final queueData = jsonDecode(queueString) as List;
        _syncQueue = queueData
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load sync queue: $e');
      _syncQueue = [];
    }
  }

  // Save sync queue to storage
  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_syncQueueKey, jsonEncode(_syncQueue));
    } catch (e) {
      debugPrint('Failed to save sync queue: $e');
    }
  }

  // Sync pending data when online
  Future<void> _syncPendingData() async {
    if (!_isOnline || _syncQueue.isEmpty) return;

    debugPrint('Starting sync of ${_syncQueue.length} items...');

    final List<Map<String, dynamic>> failedItems = [];

    for (final item in _syncQueue) {
      try {
        final success = await _syncItem(item);
        if (!success) {
          item['retryCount'] = (item['retryCount'] ?? 0) + 1;
          if (item['retryCount'] < 3) {
            failedItems.add(item);
          }
        }
      } catch (e) {
        debugPrint('Sync failed for item ${item['id']}: $e');
        item['retryCount'] = (item['retryCount'] ?? 0) + 1;
        if (item['retryCount'] < 3) {
          failedItems.add(item);
        }
      }
    }

    _syncQueue = failedItems;
    await _saveSyncQueue();

    if (failedItems.isEmpty) {
      await _updateLastSyncTime();
      debugPrint('All data synced successfully');
    } else {
      debugPrint('${failedItems.length} items failed to sync');
    }
  }

  // Sync individual item
  Future<bool> _syncItem(Map<String, dynamic> item) async {
    try {
      final action = item['action'] as String;
      final data = item['data'] as Map<String, dynamic>;

      switch (action) {
        case 'create_scan':
          // Implement scan creation sync
          return await _syncScanCreation(data);
        case 'create_query':
          // Implement query creation sync
          return await _syncQueryCreation(data);
        case 'respond_to_query':
          // Implement query response sync
          return await _syncQueryResponse(data);
        case 'update_profile':
          // Implement profile update sync
          return await _syncProfileUpdate(data);
        default:
          debugPrint('Unknown sync action: $action');
          return false;
      }
    } catch (e) {
      debugPrint('Sync item failed: $e');
      return false;
    }
  }

  // Sync scan creation
  Future<bool> _syncScanCreation(Map<String, dynamic> data) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Synced scan creation: ${data['id']}');
    return true;
  }

  // Sync query creation
  Future<bool> _syncQueryCreation(Map<String, dynamic> data) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Synced query creation: ${data['id']}');
    return true;
  }

  // Sync query response
  Future<bool> _syncQueryResponse(Map<String, dynamic> data) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Synced query response: ${data['queryId']}');
    return true;
  }

  // Sync profile update
  Future<bool> _syncProfileUpdate(Map<String, dynamic> data) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Synced profile update: ${data['userId']}');
    return true;
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Failed to update last sync time: $e');
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncKey);

      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get last sync time: $e');
      return null;
    }
  }

  // Clear offline data
  Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineDataKey);
      await prefs.remove(_syncQueueKey);
      await prefs.remove(_lastSyncKey);

      _syncQueue.clear();
      debugPrint('Offline data cleared');
    } catch (e) {
      debugPrint('Failed to clear offline data: $e');
    }
  }

  // Get offline storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final offlineData = await getOfflineData();
      final lastSync = await getLastSyncTime();

      return {
        'isOnline': _isOnline,
        'offlineDataSize': offlineData.length,
        'syncQueueSize': _syncQueue.length,
        'lastSyncTime': lastSync?.toIso8601String(),
        'storageUsed': await _getStorageUsed(),
      };
    } catch (e) {
      debugPrint('Failed to get storage info: $e');
      return {
        'isOnline': _isOnline,
        'offlineDataSize': 0,
        'syncQueueSize': 0,
        'lastSyncTime': null,
        'storageUsed': 0,
      };
    }
  }

  // Get storage used in bytes
  Future<int> _getStorageUsed() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync(recursive: true);

      int totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Failed to calculate storage used: $e');
      return 0;
    }
  }

  // Force sync
  Future<void> forceSync() async {
    if (_isOnline) {
      await _syncPendingData();
    }
  }

  // Check if data is available offline
  Future<bool> isDataAvailableOffline(String key) async {
    final offlineData = await getOfflineData();
    return offlineData.containsKey(key);
  }

  // Get offline data with fallback
  Future<Map<String, dynamic>> getDataWithFallback(
    String key,
    Future<Map<String, dynamic>> onlineData,
  ) async {
    if (_isOnline) {
      try {
        final data = await onlineData;
        // Save for offline use
        await saveOfflineData(key, data);
        return data;
      } catch (e) {
        debugPrint('Online data failed, trying offline: $e');
        // Fall back to offline data
        final offlineData = await getOfflineDataByKey(key);
        if (offlineData != null) {
          return offlineData;
        }
        rethrow;
      }
    } else {
      // Use offline data
      final offlineData = await getOfflineDataByKey(key);
      if (offlineData != null) {
        return offlineData;
      }
      throw Exception('No offline data available for $key');
    }
  }
}
