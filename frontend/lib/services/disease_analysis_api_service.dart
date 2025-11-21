import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class DiseaseAnalysisApiService {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Get disease analytics data for experts (system-wide)
  static Future<Map<String, dynamic>> getExpertDiseaseAnalytics(
    String token,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/dashboard/expert'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Expert Analytics Response: $data');
        print('✅ Total Scans: ${data['totalScans']}');
        return data;
      } else {
        throw Exception(
          'Failed to load expert analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Failed to get expert analytics: $e');
      // Return minimal fallback data to encourage real backend usage
      return {
        'totalScans': 0,
        'accuracyRate': 0.0,
        'totalDiseases': 0,
        'criticalCases': 0,
        'diseaseDistribution': {},
        'message': 'Connect to backend to see real expert data',
      };
    }
  }

  // Get disease analytics data for farmers (user-specific)
  static Future<Map<String, dynamic>> getDiseaseAnalytics(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/dashboard'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Farmer Analytics Response: $data');
        print('✅ Total Scans: ${data['totalScans']}');
        return data;
      } else {
        throw Exception(
          'Failed to load disease analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Failed to get disease analytics: $e');
      // Return minimal fallback data to encourage real backend usage
      return {
        'totalScans': 0,
        'accuracyRate': 0.0,
        'totalDiseases': 0,
        'criticalCases': 0,
        'diseaseDistribution': {},
        'message': 'Connect to backend to see real data',
      };
    }
  }

  // Get disease trends data for experts (system-wide)
  static Future<Map<String, dynamic>> getExpertDiseaseTrends(
    String token,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/trends/expert'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load expert trends: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get expert trends: $e');
      // Return minimal fallback data to encourage real backend usage
      return {
        'trends': [],
        'recommendations': ['Start backend server to see real expert trends'],
        'message': 'Connect to backend to see real expert data',
      };
    }
  }

  // Get disease trends data for farmers (user-specific)
  static Future<Map<String, dynamic>> getDiseaseTrends(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/trends'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load disease trends: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to get disease trends: $e');
      // Return minimal fallback data to encourage real backend usage
      return {
        'trends': [],
        'recommendations': ['Start backend server to see real trends'],
        'message': 'Connect to backend to see real data',
      };
    }
  }

  // Get disease statistics by time range
  static Future<Map<String, dynamic>> getDiseaseStatsByTimeRange(
    String token,
    String timeRange,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/stats?timeRange=$timeRange'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load disease stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get disease stats: $e');
      // Return mock data based on time range
      return _getMockStatsByTimeRange(timeRange);
    }
  }

  // Get disease outbreak predictions
  static Future<Map<String, dynamic>> getDiseaseOutbreakPredictions(
    String token,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/analytics/predictions'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load predictions: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get disease predictions: $e');
      return _getMockPredictionsData();
    }
  }

  // Mock analytics data
  static Map<String, dynamic> _getMockAnalyticsData() {
    return {
      'totalScans': 1847,
      'accuracyRate': 0.923,
      'totalDiseases': 12,
      'criticalCases': 23,
      'diseaseDistribution': {
        'Tomato Late Blight': 156,
        'Wheat Rust': 134,
        'Corn Leaf Spot': 98,
        'Rice Blast': 87,
        'Potato Early Blight': 76,
        'Cotton Bollworm': 65,
        'Soybean Rust': 54,
        'Apple Scab': 43,
        'Grape Downy Mildew': 32,
        'Healthy Plants': 1202,
      },
      'monthlyScans': [
        {'month': 'Jan', 'scans': 145, 'diseases': 23},
        {'month': 'Feb', 'scans': 167, 'diseases': 31},
        {'month': 'Mar', 'scans': 198, 'diseases': 45},
        {'month': 'Apr', 'scans': 234, 'diseases': 52},
        {'month': 'May', 'scans': 289, 'diseases': 67},
        {'month': 'Jun', 'scans': 314, 'diseases': 78},
        {'month': 'Jul', 'scans': 278, 'diseases': 71},
        {'month': 'Aug', 'scans': 256, 'diseases': 63},
        {'month': 'Sep', 'scans': 223, 'diseases': 54},
        {'month': 'Oct', 'scans': 198, 'diseases': 47},
        {'month': 'Nov', 'scans': 176, 'diseases': 38},
        {'month': 'Dec', 'scans': 163, 'diseases': 29},
      ],
      'topAffectedCrops': [
        {'crop': 'Tomato', 'cases': 234, 'severity': 'High'},
        {'crop': 'Wheat', 'cases': 198, 'severity': 'Medium'},
        {'crop': 'Corn', 'cases': 156, 'severity': 'Medium'},
        {'crop': 'Rice', 'cases': 134, 'severity': 'High'},
        {'crop': 'Potato', 'cases': 112, 'severity': 'Low'},
      ],
    };
  }

  // Mock trends data
  static Map<String, dynamic> _getMockTrendsData() {
    return {
      'trends': [
        {
          'disease': 'Tomato Late Blight',
          'trend': 'increasing',
          'percentage': 18.7,
          'severity': 'critical',
          'affectedRegions': ['North', 'Central'],
        },
        {
          'disease': 'Wheat Rust',
          'trend': 'decreasing',
          'percentage': -12.3,
          'severity': 'moderate',
          'affectedRegions': ['South', 'East'],
        },
        {
          'disease': 'Corn Leaf Spot',
          'trend': 'stable',
          'percentage': 3.2,
          'severity': 'low',
          'affectedRegions': ['West'],
        },
        {
          'disease': 'Rice Blast',
          'trend': 'increasing',
          'percentage': 15.8,
          'severity': 'high',
          'affectedRegions': ['East', 'South'],
        },
        {
          'disease': 'Potato Early Blight',
          'trend': 'decreasing',
          'percentage': -8.9,
          'severity': 'moderate',
          'affectedRegions': ['North'],
        },
      ],
      'recommendations': [
        'Immediate action required for Tomato Late Blight - increase fungicide applications',
        'Continue current Wheat Rust management strategies - showing positive results',
        'Monitor Rice Blast closely - consider preventive treatments in affected regions',
        'Weather conditions favor disease development - increase field monitoring',
        'Update farmer advisory on early detection techniques',
        'Coordinate with agricultural extension services for rapid response',
        'Consider resistant varieties for next planting season',
        'Implement integrated pest management practices',
      ],
      'weatherImpact': {
        'humidity': 'High humidity increasing disease pressure',
        'temperature': 'Optimal temperatures for pathogen development',
        'rainfall': 'Excessive rainfall promoting fungal diseases',
      },
      'seasonalForecast': {
        'nextMonth': 'Increased disease activity expected',
        'nextSeason': 'Moderate to high disease pressure predicted',
        'riskLevel': 'High',
      },
    };
  }

  // Mock stats by time range
  static Map<String, dynamic> _getMockStatsByTimeRange(String timeRange) {
    switch (timeRange) {
      case 'Last 7 Days':
        return {
          'totalScans': 89,
          'accuracyRate': 0.934,
          'diseaseDistribution': {
            'Tomato Late Blight': 12,
            'Wheat Rust': 8,
            'Healthy Plants': 69,
          },
        };
      case 'Last 30 Days':
        return {
          'totalScans': 347,
          'accuracyRate': 0.923,
          'diseaseDistribution': {
            'Tomato Late Blight': 45,
            'Wheat Rust': 32,
            'Corn Leaf Spot': 23,
            'Healthy Plants': 247,
          },
        };
      case 'Last 3 Months':
        return {
          'totalScans': 1234,
          'accuracyRate': 0.918,
          'diseaseDistribution': {
            'Tomato Late Blight': 156,
            'Wheat Rust': 134,
            'Corn Leaf Spot': 98,
            'Rice Blast': 87,
            'Healthy Plants': 759,
          },
        };
      default:
        return _getMockAnalyticsData();
    }
  }

  // Mock predictions data
  static Map<String, dynamic> _getMockPredictionsData() {
    return {
      'outbreakRisk': {
        'level': 'High',
        'confidence': 0.87,
        'timeframe': 'Next 2 weeks',
      },
      'predictions': [
        {
          'disease': 'Tomato Late Blight',
          'probability': 0.82,
          'regions': ['North', 'Central'],
          'timeframe': '7-14 days',
        },
        {
          'disease': 'Rice Blast',
          'probability': 0.67,
          'regions': ['East'],
          'timeframe': '14-21 days',
        },
      ],
      'preventiveMeasures': [
        'Apply protective fungicides in high-risk areas',
        'Increase field monitoring frequency',
        'Prepare rapid response teams',
        'Alert farmers in predicted outbreak zones',
      ],
    };
  }
}
