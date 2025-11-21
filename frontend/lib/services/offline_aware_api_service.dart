import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crop_disease_app/services/offline_service.dart';
import '../config/app_config.dart';

class OfflineAwareApiService {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 10);
  final OfflineService _offlineService = OfflineService();

  static Future<Map<String, String>> get headers async {
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  // Offline-aware GET request
  Future<dynamic> getWithOfflineSupport(
    String endpoint,
    String? token, {
    String? offlineKey,
    Map<String, dynamic>? fallbackData,
  }) async {
    try {
      if (_offlineService.isOnline) {
        // Try online request first
        final response = await http
            .get(
              Uri.parse('$baseUrl/$endpoint'),
              headers: token != null
                  ? {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'Bearer $token',
                    }
                  : await headers,
            )
            .timeout(timeoutDuration);

        final data = _handleResponse(response);

        // Save for offline use if offlineKey is provided
        if (offlineKey != null) {
          await _offlineService.saveOfflineData(offlineKey, data);
        }

        return data;
      } else {
        // Use offline data
        if (offlineKey != null) {
          final offlineData = await _offlineService.getOfflineDataByKey(
            offlineKey,
          );
          if (offlineData != null) {
            return offlineData;
          }
        }

        // Use fallback data if provided
        if (fallbackData != null) {
          return fallbackData;
        }

        throw Exception('No offline data available');
      }
    } catch (e) {
      // Fallback to offline data on error
      if (offlineKey != null) {
        final offlineData = await _offlineService.getOfflineDataByKey(
          offlineKey,
        );
        if (offlineData != null) {
          return offlineData;
        }
      }

      if (fallbackData != null) {
        return fallbackData;
      }

      rethrow;
    }
  }

  // Offline-aware POST request
  Future<dynamic> postWithOfflineSupport(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
    String? syncAction,
    Map<String, dynamic>? offlineData,
  }) async {
    try {
      if (_offlineService.isOnline) {
        // Try online request
        final response = await http
            .post(
              Uri.parse('$baseUrl/$endpoint'),
              headers: token != null
                  ? {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'Bearer $token',
                    }
                  : await headers,
              body: jsonEncode(body),
            )
            .timeout(timeoutDuration);

        return _handleResponse(response);
      } else {
        // Queue for sync when online
        if (syncAction != null) {
          await _offlineService.queueForSync(syncAction, body);
        }

        // Return offline data if provided
        if (offlineData != null) {
          return offlineData;
        }

        throw Exception('Offline mode: Request queued for sync');
      }
    } catch (e) {
      // Queue for sync on error
      if (syncAction != null) {
        await _offlineService.queueForSync(syncAction, body);
      }

      if (offlineData != null) {
        return offlineData;
      }

      rethrow;
    }
  }

  // Offline-aware PUT request
  Future<dynamic> putWithOfflineSupport(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
    String? syncAction,
    Map<String, dynamic>? offlineData,
  }) async {
    try {
      if (_offlineService.isOnline) {
        // Try online request
        final response = await http
            .put(
              Uri.parse('$baseUrl/$endpoint'),
              headers: token != null
                  ? {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'Bearer $token',
                    }
                  : await headers,
              body: jsonEncode(body),
            )
            .timeout(timeoutDuration);

        return _handleResponse(response);
      } else {
        // Queue for sync when online
        if (syncAction != null) {
          await _offlineService.queueForSync(syncAction, body);
        }

        // Return offline data if provided
        if (offlineData != null) {
          return offlineData;
        }

        throw Exception('Offline mode: Request queued for sync');
      }
    } catch (e) {
      // Queue for sync on error
      if (syncAction != null) {
        await _offlineService.queueForSync(syncAction, body);
      }

      if (offlineData != null) {
        return offlineData;
      }

      rethrow;
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {}; // Return empty map for successful empty responses
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    }

    try {
      final responseBody = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw Exception('Invalid JSON response: ${response.body}');
    }
  }

  // Upload image with offline support
  Future<String> uploadImageWithOfflineSupport(
    File imageFile,
    String token, {
    String? syncAction,
  }) async {
    try {
      if (_offlineService.isOnline) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/images/upload'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          return data['imagePath'];
        } else {
          throw Exception('Failed to upload image');
        }
      } else {
        // Queue for sync when online
        if (syncAction != null) {
          await _offlineService.queueForSync(syncAction, {
            'imagePath': imageFile.path,
            'fileName': imageFile.path.split('/').last,
          });
        }

        // Return local path for offline use
        return imageFile.path;
      }
    } catch (e) {
      // Queue for sync on error
      if (syncAction != null) {
        await _offlineService.queueForSync(syncAction, {
          'imagePath': imageFile.path,
          'fileName': imageFile.path.split('/').last,
        });
      }

      // Return local path as fallback
      return imageFile.path;
    }
  }

  // Get offline status
  bool get isOnline => _offlineService.isOnline;

  // Get sync queue size
  int get syncQueueSize => _offlineService.syncQueue.length;

  // Force sync
  Future<void> forceSync() async {
    await _offlineService.forceSync();
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    return await _offlineService.getStorageInfo();
  }
}
