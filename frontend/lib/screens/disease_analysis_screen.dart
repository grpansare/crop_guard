// Create: lib/screens/disease_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/disease_analysis_api_service.dart';
import 'package:crop_disease_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

class DiseaseAnalysisScreen extends StatefulWidget {
  const DiseaseAnalysisScreen({super.key});

  @override
  State<DiseaseAnalysisScreen> createState() => _DiseaseAnalysisScreenState();
}

class _DiseaseAnalysisScreenState extends State<DiseaseAnalysisScreen> {
  Map<String, dynamic> _analyticsData = {};
  Map<String, dynamic> _trendsData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedTimeRange = 'Last 30 Days';
  bool _isExpert = false;

  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _checkUserRole();
    await _loadAnalyticsData();
  }

  Future<void> _checkUserRole() async {
    try {
      final profile = await AuthService.getProfile();
      setState(() {
        _isExpert = profile?['role'] == 'EXPERT';
      });
      print(
        '👤 User Role Check: isExpert = $_isExpert, role = ${profile?['role']}',
      );
    } catch (e) {
      print('Failed to get user profile: $e');
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      print(
        '🔄 Loading analytics for: ${_isExpert ? "EXPERT (system-wide)" : "FARMER (user-specific)"}',
      );

      final results = await Future.wait([
        _isExpert
            ? DiseaseAnalysisApiService.getExpertDiseaseAnalytics(token)
            : DiseaseAnalysisApiService.getDiseaseAnalytics(token),
        _isExpert
            ? DiseaseAnalysisApiService.getExpertDiseaseTrends(token)
            : DiseaseAnalysisApiService.getDiseaseTrends(token),
      ]);

      print('📊 Disease Analysis - Analytics Data: ${results[0]}');
      print('📊 Disease Analysis - Trends Data: ${results[1]}');

      setState(() {
        _analyticsData = results[0];
        _trendsData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Disease Analysis Error: $e');
      setState(() {
        _errorMessage =
            'Failed to load analytics: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _debugDatabase() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/analytics/debug/scans'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total scans in database: ${data['totalScansInDatabase']}',
                  ),
                  Text('Recent scans found: ${data['recentScansCount']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent scans:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...((data['recentScans'] as List? ?? []).map(
                    (scan) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        '${scan['plantType']} - ${scan['disease']} (${scan['user']})',
                      ),
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Debug failed: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isExpert ? 'System Disease Analysis' : 'Disease Analysis'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugDatabase,
            tooltip: 'Debug Database',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadAnalyticsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 20),
                    _buildOverviewCards(),
                    const SizedBox(height: 20),
                    _buildDiseaseDistributionChart(),
                    const SizedBox(height: 20),
                    _buildTrendsSection(),
                    const SizedBox(height: 20),
                    _buildRecommendationsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAnalyticsData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Time Range:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedTimeRange,
                isExpanded: true,
                items: _timeRanges.map((range) {
                  return DropdownMenuItem(value: range, child: Text(range));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                  });
                  _loadAnalyticsData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalScans = _analyticsData['totalScans'] ?? 0;
    final accuracyRate = (_analyticsData['accuracyRate'] ?? 0.0) * 100;
    final diseaseCount =
        (_analyticsData['diseaseDistribution'] as Map?)?.length ?? 0;

    print('🔍 Building Overview Cards:');
    print('   - _analyticsData: $_analyticsData');
    print('   - totalScans: $totalScans');
    print('   - accuracyRate: $accuracyRate');
    print('   - diseaseCount: $diseaseCount');

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Scans',
            totalScans.toString(),
            Icons.scanner,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Accuracy',
            '${accuracyRate.toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Diseases',
            diseaseCount.toString(),
            Icons.bug_report,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDistributionChart() {
    final distributionData = _analyticsData['diseaseDistribution'];
    final distribution = distributionData != null
        ? Map<String, dynamic>.from(distributionData as Map)
        : <String, dynamic>{};

    if (distribution.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.pie_chart, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No disease data available',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(distribution),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(distribution),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, dynamic> distribution,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    int index = 0;

    return distribution.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: (entry.value as num).toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, dynamic> distribution) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    int index = 0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: distribution.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(entry.key, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrendsSection() {
    final trends = _trendsData['trends'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (trends.isEmpty)
              const Center(child: Text('No trend data available'))
            else
              ...trends.map((trend) => _buildTrendItem(trend)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(Map<String, dynamic> trend) {
    final disease = trend['disease'] ?? 'Unknown';
    final trendDirection = trend['trend'] ?? 'stable';
    final percentage = trend['percentage'] ?? 0.0;

    IconData trendIcon;
    Color trendColor;

    switch (trendDirection) {
      case 'increasing':
        trendIcon = Icons.trending_up;
        trendColor = Colors.red;
        break;
      case 'decreasing':
        trendIcon = Icons.trending_down;
        trendColor = Colors.green;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              disease,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(color: trendColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _trendsData['recommendations'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              const Center(child: Text('No recommendations available'))
            else
              ...recommendations
                  .map((rec) => _buildRecommendationItem(rec))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recommendation, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
