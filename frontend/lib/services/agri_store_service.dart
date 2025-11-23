import 'dart:convert';
import 'package:crop_disease_app/models/agri_store.dart';
import 'package:crop_disease_app/services/api_service.dart';

class AgriStoreService {
  // ==================== ADMIN METHODS ====================

  /// Create a new agri store (Admin only)
  static Future<AgriStore> createStore(
    AgriStore store,
    String token,
  ) async {
    try {
      final response = await ApiService.postWithAuth(
        'admin/agri-stores',
        store.toJson(),
        token,
      );

      if (response['store'] != null) {
        return AgriStore.fromJson(response['store']);
      }

      throw Exception('Failed to create store: Invalid response');
    } catch (e) {
      print('❌ Error creating agri store: $e');
      throw Exception('Failed to create agri store: $e');
    }
  }

  /// Update an existing agri store (Admin only)
  static Future<AgriStore> updateStore(
    int storeId,
    AgriStore store,
    String token,
  ) async {
    try {
      final response = await ApiService.putWithAuth(
        'admin/agri-stores/$storeId',
        store.toJson(),
        token,
      );

      if (response['store'] != null) {
        return AgriStore.fromJson(response['store']);
      }

      throw Exception('Failed to update store: Invalid response');
    } catch (e) {
      print('❌ Error updating agri store: $e');
      throw Exception('Failed to update agri store: $e');
    }
  }

  /// Delete an agri store (Admin only)
  static Future<void> deleteStore(int storeId, String token) async {
    try {
      await ApiService.deleteWithAuth(
        'admin/agri-stores/$storeId',
        token,
      );
      print('✅ Agri store deleted successfully');
    } catch (e) {
      print('❌ Error deleting agri store: $e');
      throw Exception('Failed to delete agri store: $e');
    }
  }

  /// Get all agri stores (Admin only) - includes inactive stores
  static Future<List<AgriStore>> getAllStores(String token) async {
    try {
      final response = await ApiService.getWithAuth(
        'admin/agri-stores',
        token,
      );

      if (response['stores'] != null) {
        final List<dynamic> storesJson = response['stores'];
        return storesJson.map((json) => AgriStore.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error fetching all agri stores: $e');
      throw Exception('Failed to fetch agri stores: $e');
    }
  }

  // ==================== FARMER/PUBLIC METHODS ====================

  /// Get nearby agri stores within a radius
  static Future<List<AgriStore>> getNearbyStores(
    double latitude,
    double longitude,
    double radiusKm,
    String token,
  ) async {
    try {
      final response = await ApiService.getWithAuth(
        'agri-stores/nearby?lat=$latitude&lng=$longitude&radius=$radiusKm',
        token,
      );

      if (response['stores'] != null) {
        final List<dynamic> storesJson = response['stores'];
        return storesJson.map((json) => AgriStore.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error fetching nearby agri stores: $e');
      throw Exception('Failed to fetch nearby agri stores: $e');
    }
  }

  /// Get a single agri store by ID
  static Future<AgriStore> getStoreById(int storeId, String token) async {
    try {
      final response = await ApiService.getWithAuth(
        'agri-stores/$storeId',
        token,
      );

      return AgriStore.fromJson(response);
    } catch (e) {
      print('❌ Error fetching agri store: $e');
      throw Exception('Failed to fetch agri store: $e');
    }
  }

  /// Get all active agri stores
  static Future<List<AgriStore>> getActiveStores(String token) async {
    try {
      final response = await ApiService.getWithAuth(
        'agri-stores',
        token,
      );

      if (response['stores'] != null) {
        final List<dynamic> storesJson = response['stores'];
        return storesJson.map((json) => AgriStore.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error fetching active agri stores: $e');
      throw Exception('Failed to fetch active agri stores: $e');
    }
  }

  /// Get agri stores by type
  static Future<List<AgriStore>> getStoresByType(
    String storeType,
    String token,
  ) async {
    try {
      final response = await ApiService.getWithAuth(
        'agri-stores/type/$storeType',
        token,
      );

      if (response['stores'] != null) {
        final List<dynamic> storesJson = response['stores'];
        return storesJson.map((json) => AgriStore.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error fetching agri stores by type: $e');
      throw Exception('Failed to fetch agri stores by type: $e');
    }
  }
}
