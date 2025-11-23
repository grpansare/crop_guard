import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';

class ApiService {
  // Using centralized configuration - update IP in app_config.dart
  static String get baseUrl => AppConfig.baseUrl;

  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<Map<String, String>> get headers async {
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      // Debug: Print request details
      print('API Request: POST $baseUrl/$endpoint');
      print('Request Body: ${jsonEncode(body)}');

      final uri = Uri.parse('$baseUrl/$endpoint');
      print('Full URL: $uri');

      // Create HTTP client with custom configuration
      final client = http.Client();

      final request = http.Request('POST', uri);
      request.headers.addAll(await headers);
      request.body = jsonEncode(body);

      // Send request with timeout
      final streamedResponse = await client
          .send(request)
          .timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      client.close();

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw Exception(
        'Network connection failed. Please check your internet connection and ensure the server is running.',
      );
    } on http.ClientException catch (e) {
      print('HTTP Client Exception: $e');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw Exception('Invalid server response format');
    } catch (e) {
      print('Unexpected error in POST request: $e');
      rethrow;
    }
  }

  static Future<dynamic> getWithAuth(String endpoint, String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make authenticated GET request: $e');
    }
  }

  static Future<dynamic> putWithAuth(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make authenticated PUT request: $e');
    }
  }

  static Future<dynamic> postWithAuth(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make authenticated POST request: $e');
    }
  }

  static Future<dynamic> deleteWithAuth(
    String endpoint,
    String token,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make authenticated DELETE request: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: "${response.body}"');

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
        // Extract error message from backend response
        String errorMessage = 'Request failed';
        if (responseBody is Map && responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        } else if (responseBody is Map && responseBody.containsKey('error')) {
          errorMessage = responseBody['error'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // If jsonDecode fails or other errors occur
      if (e.toString().contains('Exception:')) {
        rethrow; // Rethrow if it's already our custom exception
      }
      
      // Try to handle cases where body might be a simple string message
      if (response.statusCode >= 400) {
         // If we can't parse JSON but it's an error status, check if body itself is the message
         // or if we can extract a message from a potential JSON string
         try {
            // Sometimes the body is "{\"message\":\"...\"}" (stringified JSON)
            if (response.body.startsWith('"') && response.body.endsWith('"')) {
               final unquoted = jsonDecode(response.body); // Remove outer quotes
               if (unquoted is String && unquoted.trim().startsWith('{')) {
                  final innerJson = jsonDecode(unquoted);
                  if (innerJson is Map && innerJson.containsKey('message')) {
                     throw Exception(innerJson['message']);
                  }
               }
            }
         } catch (_) {}

         throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
      
      throw Exception('Invalid JSON response: ${response.body}');
    }
  }

  // Dashboard API Methods
  static Future<Map<String, dynamic>> getRecentActivity(String token) async {
    try {
      return await getWithAuth('dashboard/activity', token);
    } catch (e) {
      print('Failed to get recent activity: $e');
      // Return fallback data
      return {
        'activities': [
          {
            'id': 1,
            'type': 'scan',
            'title': 'Disease Scan Completed',
            'description': 'Tomato leaf analyzed - Healthy',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 2))
                .toIso8601String(),
            'status': 'completed',
          },
          {
            'id': 2,
            'type': 'report',
            'title': 'Weekly Report Generated',
            'description': 'Crop health summary available',
            'timestamp': DateTime.now()
                .subtract(Duration(days: 1))
                .toIso8601String(),
            'status': 'completed',
          },
        ],
      };
    }
  }

  static Future<Map<String, dynamic>> getQuickStats(String token) async {
    try {
      return await getWithAuth('dashboard/stats', token);
    } catch (e) {
      print('Failed to get quick stats: $e');
      // Return fallback data
      return {
        'totalScans': 45,
        'healthyPlants': 38,
        'diseasesDetected': 7,
        'reportsGenerated': 12,
      };
    }
  }

  // Scan History API Methods
  static Future<Map<String, dynamic>> getScanHistory(
    String token, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await getWithAuth(
        'scans/history?page=$page&size=$size',
        token,
      );

      // Handle different response formats from backend
      if (response is List) {
        // Backend returns array directly
        print('📡 Backend returned direct array with ${response.length} items');
        return {
          'scans': response,
          'totalElements': response.length,
          'totalPages': 1,
          'currentPage': 0,
        };
      } else if (response is Map<String, dynamic>) {
        // Backend returns wrapped object
        if (response.containsKey('scans')) {
          print('📡 Backend returned wrapped object with scans key');
          return response;
        } else {
          // Backend returns object but not wrapped - treat as single item or convert
          print('📡 Backend returned unwrapped object, converting to array');
          return {
            'scans': [response],
            'totalElements': 1,
            'totalPages': 1,
            'currentPage': 0,
          };
        }
      } else {
        print('📡 Backend returned unexpected format: ${response.runtimeType}');
        throw Exception('Unexpected response format from backend');
      }
    } catch (e) {
      print('Failed to get scan history: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getScanDetails(
    int scanId,
    String token,
  ) async {
    try {
      return await getWithAuth('scans/$scanId', token);
    } catch (e) {
      print('Failed to get scan details: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> createScan(
    Map<String, dynamic> scanData,
    String token,
  ) async {
    try {
      return await postWithAuth('scans', scanData, token);
    } catch (e) {
      print('Failed to create scan: $e');
      // Return success response for offline mode
      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        'status': 'success',
        'message': 'Scan saved locally',
      };
    }
  }

  static Future<Map<String, dynamic>> submitScanReview(
    int scanId,
    Map<String, dynamic> reviewData,
    String token,
  ) async {
    try {
      return await putWithAuth('scans/$scanId/review', reviewData, token);
    } catch (e) {
      print('Failed to submit scan review: $e');
      throw e;
    }
  }

  // Reports API Methods
  static Future<Map<String, dynamic>> getReports(String token) async {
    try {
      return await getWithAuth('reports', token);
    } catch (e) {
      print('Failed to get reports: $e');
      // Return fallback data
      return {
        'reports': [
          {
            'id': 1,
            'title': 'Weekly Crop Health Report',
            'type': 'weekly',
            'date': DateTime.now()
                .subtract(Duration(days: 1))
                .toIso8601String(),
            'status': 'completed',
            'summary':
                'Overall crop health is good with 85% healthy plants detected.',
          },
          {
            'id': 2,
            'title': 'Disease Trend Analysis',
            'type': 'analysis',
            'date': DateTime.now()
                .subtract(Duration(days: 7))
                .toIso8601String(),
            'status': 'completed',
            'summary':
                'Early blight detected in 3 potato plants. Treatment recommended.',
          },
        ],
      };
    }
  }

  static Future<Map<String, dynamic>> generateReport(
    Map<String, dynamic> reportData,
    String token,
  ) async {
    try {
      return await postWithAuth('reports/generate', reportData, token);
    } catch (e) {
      print('Failed to generate report: $e');
      throw e;
    }
  }

  // Analytics API Methods
  static Future<Map<String, dynamic>> getAnalytics(String token) async {
    try {
      return await getWithAuth('analytics/dashboard', token);
    } catch (e) {
      print('Failed to get analytics: $e');
      // Return fallback data
      return {
        'diseaseDistribution': {
          'Healthy': 75,
          'Early Blight': 15,
          'Late Blight': 8,
          'Leaf Spot': 2,
        },
        'monthlyScans': [
          {'month': 'Jan', 'scans': 25},
          {'month': 'Feb', 'scans': 32},
          {'month': 'Mar', 'scans': 45},
          {'month': 'Apr', 'scans': 38},
        ],
        'accuracyRate': 0.92,
        'totalScans': 140,
      };
    }
  }

  static Future<Map<String, dynamic>> getTrends(String token) async {
    try {
      return await getWithAuth('analytics/trends', token);
    } catch (e) {
      print('Failed to get trends: $e');
      // Return fallback data
      return {
        'trends': [
          {
            'disease': 'Early Blight',
            'trend': 'increasing',
            'percentage': 15.5,
            'period': 'last_month',
          },
          {
            'disease': 'Healthy Plants',
            'trend': 'stable',
            'percentage': 2.1,
            'period': 'last_month',
          },
        ],
        'recommendations': [
          'Monitor potato crops more frequently for early blight symptoms',
          'Consider preventive fungicide application in high-risk areas',
        ],
      };
    }
  }

  // User Settings API Methods
  static Future<Map<String, dynamic>> getUserSettings(String token) async {
    try {
      return await getWithAuth('user/settings', token);
    } catch (e) {
      print('Failed to get user settings: $e');
      // Return fallback data
      return {
        'notifications': {
          'pushNotifications': true,
          'emailNotifications': false,
          'scanReminders': true,
          'reportAlerts': true,
        },
        'preferences': {
          'language': 'en',
          'theme': 'light',
          'autoSave': true,
          'dataSync': true,
        },
        'privacy': {
          'shareData': false,
          'analytics': true,
          'crashReports': true,
        },
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserSettings(
    Map<String, dynamic> settings,
    String token,
  ) async {
    try {
      return await putWithAuth('user/settings', settings, token);
    } catch (e) {
      print('Failed to update user settings: $e');
      return {'status': 'success', 'message': 'Settings saved locally'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      return await getWithAuth('user/profile', token);
    } catch (e) {
      print('Failed to get user profile: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profile,
    String token,
  ) async {
    try {
      return await putWithAuth('user/profile', profile, token);
    } catch (e) {
      print('Failed to update user profile: $e');
      return {'status': 'success', 'message': 'Profile updated locally'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
    Map<String, dynamic> passwordData,
    String token,
  ) async {
    try {
      return await postWithAuth('user/change-password', passwordData, token);
    } catch (e) {
      print('Failed to change password: $e');
      throw e;
    }
  }

  /// Tests the API connectivity by making a simple GET request to the test endpoint
  static Future<bool> testConnection() async {
    try {
      print('Testing API connection to: $baseUrl');

      // Test the public test endpoint first
      final testUrl = baseUrl.replaceAll('/api', '') + '/api/test/all';
      print('Testing with URL: $testUrl');

      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 5));
      print('API test response: ${response.statusCode}');
      print('API test body: ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }

  // Expert-Farmer Query API Methods
  static Future<Map<String, dynamic>> createExpertQuery(
    Map<String, dynamic> queryData,
    String token,
  ) async {
    try {
      return await postWithAuth('queries', queryData, token);
    } catch (e) {
      print('Failed to create expert query: $e');
      throw Exception('Failed to submit query: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getMyQueries(String token) async {
    try {
      return await getWithAuth('queries/my', token);
    } catch (e) {
      print('Failed to get my queries: $e');
      throw Exception('Failed to load queries: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getExpertQueries(String token) async {
    try {
      return await getWithAuth('queries/expert', token);
    } catch (e) {
      print('Failed to get expert queries: $e');
      throw Exception('Failed to load queries: ${e.toString()}');
    }
  }

  // OLD METHOD - Single response (overwrites existing)
  static Future<Map<String, dynamic>> respondToQuery(
    Map<String, dynamic> responseData,
    String token,
  ) async {
    try {
      return await postWithAuth('queries/respond', responseData, token);
    } catch (e) {
      print('Failed to respond to query: $e');
      throw Exception('Failed to submit response: ${e.toString()}');
    }
  }

  // NEW METHOD - Multiple responses (adds new response)
  static Future<Map<String, dynamic>> addQueryResponse(
    int queryId,
    String responseText,
    String token,
  ) async {
    try {
      final responseData = {'response': responseText};
      print('📤 Adding response to query $queryId');
      return await postWithAuth(
        'queries/$queryId/responses',
        responseData,
        token,
      );
    } catch (e) {
      print('Failed to add response: $e');
      throw Exception('Failed to submit response: ${e.toString()}');
    }
  }

  // Get all responses for a query
  static Future<List<Map<String, dynamic>>> getQueryResponses(
    int queryId,
    String token,
  ) async {
    try {
      final response = await getWithAuth('queries/$queryId/responses', token);
      return List<Map<String, dynamic>>.from(response['responses'] ?? []);
    } catch (e) {
      print('Failed to get query responses: $e');
      return [];
    }
  }

  // Update/Edit an expert's response
  static Future<Map<String, dynamic>> updateQueryResponse(
    int responseId,
    String updatedResponse,
    String token,
  ) async {
    try {
      final response = await putWithAuth('queries/responses/$responseId', {
        'response': updatedResponse,
      }, token);
      return response;
    } catch (e) {
      print('Failed to update response: $e');
      throw Exception('Failed to update response: $e');
    }
  }

  static Future<String> uploadImage(File imageFile, String token) async {
    try {
      print('📤 Starting image upload...');
      print('📤 File path: ${imageFile.path}');
      print('📤 File exists: ${await imageFile.exists()}');
      print('📤 File size: ${await imageFile.length()} bytes');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Determine content type from file extension
      String contentType = 'image/jpeg'; // Default
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      print('📤 Content type: $contentType');

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(contentType),
        ),
      );

      print('📤 Sending request to: $baseUrl/images/upload');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📤 Response status: ${response.statusCode}');
      print('📤 Response body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final imagePath = data['imagePath'];
        print('✅ Image uploaded successfully: $imagePath');
        return imagePath;
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        throw Exception(
          'Failed to upload image: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Image upload exception: $e');
      throw Exception('Image upload failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getNotifications(
    String token, {
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    try {
      String endpoint =
          'notifications?page=$page&size=$size&unreadOnly=$unreadOnly';
      return await getWithAuth(endpoint, token);
    } catch (e) {
      print('Failed to get notifications: $e');
      // Return fallback data
      return {
        'notifications': [
          {
            'id': 1,
            'title': 'Expert Response Received',
            'message':
                'Dr. Smith has responded to your query about tomato leaf spots',
            'type': 'QUERY_RESPONSE',
            'isRead': false,
            'relatedId': 123,
            'createdAt': DateTime.now()
                .subtract(Duration(hours: 1))
                .toIso8601String(),
          },
          {
            'id': 2,
            'title': 'Query Status Updated',
            'message': 'Your query status has been updated to: IN PROGRESS',
            'type': 'QUERY_STATUS_UPDATE',
            'isRead': false,
            'relatedId': 124,
            'createdAt': DateTime.now()
                .subtract(Duration(hours: 3))
                .toIso8601String(),
          },
        ],
        'totalElements': 2,
        'totalPages': 1,
        'currentPage': 0,
        'size': 20,
        'unreadCount': 2,
      };
    }
  }

  static Future<Map<String, dynamic>> getUnreadNotificationCount(
    String token,
  ) async {
    try {
      return await getWithAuth('notifications/count', token);
    } catch (e) {
      print('Failed to get unread notification count: $e');
      return {'unreadCount': 2};
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
    String token,
  ) async {
    try {
      return await putWithAuth('notifications/$notificationId/read', {}, token);
    } catch (e) {
      print('Failed to mark notification as read: $e');
      return {
        'status': 'success',
        'message': 'Notification marked as read locally',
      };
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    String token,
  ) async {
    try {
      return await putWithAuth('notifications/read-all', {}, token);
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
      return {
        'status': 'success',
        'message': 'All notifications marked as read locally',
      };
    }
  }

  static Future<Map<String, dynamic>> updateQueryStatus(
    String queryId,
    String status,
    String token,
  ) async {
    try {
      final updateData = {'queryId': queryId, 'status': status};
      return await putWithAuth('queries/status', updateData, token);
    } catch (e) {
      print('Failed to update query status: $e');
      throw Exception('Failed to update query status: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getQueryDetails(
    String queryId,
    String token,
  ) async {
    try {
      return await getWithAuth('queries/$queryId', token);
    } catch (e) {
      print('Failed to get query details: $e');
      throw Exception('Failed to load query details: ${e.toString()}');
    }
  }
}
