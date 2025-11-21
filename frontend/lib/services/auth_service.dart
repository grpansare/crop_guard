import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await ApiService.changePassword({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }, token);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<Map<String, dynamic>> login(
    String mobile,
    String password,
  ) async {
    try {
      print('Sending login request for mobile: $mobile');

      final response = await ApiService.post('auth/signin', {
        'mobile': mobile,
        'password': password,
      });

      print('Login response received: $response');

      // Save the token if login is successful
      if (response['token'] != null) {
        await setToken(response['token']);
      } else {
        throw Exception('No token received from server');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(
    String fullName,
    String mobile,
    String password, [
    String? role,
    String? specialization,
    String? email,
    File? documentFile,
  ]) async {
    try {
      final requestData = {
        'fullName': fullName,
        'mobile': mobile,
        'password': password,
      };

      if (role != null && role.isNotEmpty) {
        requestData['role'] = role;
      }

      if (role == 'EXPERT' && specialization != null) {
        requestData['specialization'] = specialization;
      }

      if (role == 'EXPERT' && email != null) {
        requestData['email'] = email;
      }

      // Convert document file to Base64 if provided
      if (role == 'EXPERT' && documentFile != null) {
        try {
          final bytes = await documentFile.readAsBytes();
          final base64String = base64Encode(bytes);
          requestData['verificationDocument'] = base64String;
          print('📄 Document encoded to Base64: ${base64String.length} chars');
        } catch (e) {
          print('⚠️ Failed to encode document: $e');
          // Continue registration without document if encoding fails
        }
      }

      print('📤 Sending registration request...');
      final response = await ApiService.post('auth/signup', requestData);
      print('✅ Registration response: $response');

      return response;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token found');

      final response = await ApiService.getWithAuth('auth/profile', token);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await deleteToken();
  }
}
