import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _trends = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Load all data concurrently
      final results = await Future.wait([
        _loadReports(token),
        _loadAnalytics(token),
        _loadTrends(token),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load reports data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Using offline data. ${e.toString().replaceAll('Exception: ', '')}';
        _loadFallbackData();
      });
    }
  }

  Future<void> _loadReports(String token) async {
    try {
      final reportsData = await ApiService.getReports(token);
      setState(() {
        _reports = List<Map<String, dynamic>>.from(
          reportsData['reports'] ?? [],
        );
      });
    } catch (e) {
      print('Failed to load reports: $e');
      setState(() {
        _reports = _getFallbackReports();
      });
    }
  }

  Future<void> _loadAnalytics(String token) async {
    try {
      final analyticsData = await ApiService.getAnalytics(token);
      setState(() {
        _analytics = analyticsData;
      });
    } catch (e) {
      print('Failed to load analytics: $e');
      setState(() {
        _analytics = _getFallbackAnalytics();
      });
    }
  }

  Future<void> _loadTrends(String token) async {
    try {
      final trendsData = await ApiService.getTrends(token);
      setState(() {
        _trends = trendsData;
      });
    } catch (e) {
      print('Failed to load trends: $e');
      setState(() {
        _trends = _getFallbackTrends();
      });
    }
  }

  void _loadFallbackData() {
    _reports = _getFallbackReports();
    _analytics = _getFallbackAnalytics();
    _trends = _getFallbackTrends();
  }

  List<Map<String, dynamic>> _getFallbackReports() {
    return [
      {
        'id': '1',
        'title': 'Weekly Disease Analysis',
        'type': 'Weekly Report',
        'date': '2025-09-19',
        'status': 'Completed',
        'summary': 'Analysis of 15 plant scans this week',
        'diseaseCount': 8,
        'healthyCount': 7,
        'criticalIssues': 2,
        'recommendations': 5,
      },
      {
        'id': '2',
        'title': 'Tomato Crop Assessment',
        'type': 'Crop Report',
        'date': '2025-09-18',
        'status': 'Completed',
        'summary': 'Comprehensive analysis of tomato plants',
        'diseaseCount': 3,
        'healthyCount': 12,
        'criticalIssues': 1,
        'recommendations': 3,
      },
      {
        'id': '3',
        'title': 'Monthly Farm Overview',
        'type': 'Monthly Report',
        'date': '2025-09-01',
        'status': 'Completed',
        'summary': 'Complete farm health assessment',
        'diseaseCount': 25,
        'healthyCount': 45,
        'criticalIssues': 5,
        'recommendations': 12,
      },
    ];
  }

  Map<String, dynamic> _getFallbackAnalytics() {
    return {
      'totalScans': 70,
      'diseasesDetected': 36,
      'healthyPlants': 34,
      'criticalIssues': 8,
      'treatmentSuccess': 85,
      'mostCommonDisease': 'Early Blight',
      'riskLevel': 'Medium',
    };
  }

  Map<String, dynamic> _getFallbackTrends() {
    return {
      'monthlyComparison': {
        'diseaseDetection': '+15%',
        'healthyPlants': '+8%',
        'treatmentSuccess': '+12%',
        'criticalIssues': '-5%',
      },
      'seasonalPatterns': [
        'Early Blight peaks in humid conditions',
        'Fungal diseases increase during monsoon',
        'Pest activity highest in summer months',
        'Plant health improves with proper irrigation',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Reports'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
            tooltip: 'Export Reports',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportsTab(),
                _buildAnalyticsTab(),
                _buildTrendsTab(),
              ],
            ),
    );
  }

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _viewReport(report),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getReportIcon(report['type']),
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['title'] ?? 'Unknown Report',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                report['type'] ?? 'Unknown Type',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            report['status'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report['summary'] ?? 'No summary available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.bug_report,
                          '${report['diseaseCount']} diseases',
                          Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.eco,
                          '${report['healthyCount']} healthy',
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.warning,
                          '${report['criticalIssues']} critical',
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report['date'] ?? 'Unknown date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${report['recommendations']} recommendations',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Health Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildAnalyticsCard(
                'Total Scans',
                '${_analytics['totalScans']}',
                Icons.camera_alt,
                Colors.blue,
              ),
              _buildAnalyticsCard(
                'Diseases Found',
                '${_analytics['diseasesDetected']}',
                Icons.bug_report,
                Colors.red,
              ),
              _buildAnalyticsCard(
                'Healthy Plants',
                '${_analytics['healthyPlants']}',
                Icons.eco,
                Colors.green,
              ),
              _buildAnalyticsCard(
                'Critical Issues',
                '${_analytics['criticalIssues']}',
                Icons.warning,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInsightRow(
                    'Treatment Success Rate',
                    '${_analytics['treatmentSuccess']}%',
                    Colors.green,
                  ),
                  _buildInsightRow(
                    'Most Common Disease',
                    _analytics['mostCommonDisease'],
                    Colors.orange,
                  ),
                  _buildInsightRow(
                    'Current Risk Level',
                    _analytics['riskLevel'],
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disease Trends',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month vs Last Month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTrendRow(
                    'Disease Detection',
                    _trends['monthlyComparison']['diseaseDetection'],
                    _trends['monthlyComparison']['diseaseDetection'].startsWith(
                      '-',
                    ),
                  ),
                  _buildTrendRow(
                    'Healthy Plants',
                    _trends['monthlyComparison']['healthyPlants'],
                    _trends['monthlyComparison']['healthyPlants'].startsWith(
                      '-',
                    ),
                  ),
                  _buildTrendRow(
                    'Treatment Success',
                    _trends['monthlyComparison']['treatmentSuccess'],
                    _trends['monthlyComparison']['treatmentSuccess'].startsWith(
                      '-',
                    ),
                  ),
                  _buildTrendRow(
                    'Critical Issues',
                    _trends['monthlyComparison']['criticalIssues'],
                    _trends['monthlyComparison']['criticalIssues'].startsWith(
                      '-',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seasonal Patterns',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._trends['seasonalPatterns']
                      .map((pattern) => Text(pattern))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String label, String change, bool isNegative) {
    final color = isNegative ? Colors.red : Colors.green;
    final icon = isNegative ? Icons.trending_down : Icons.trending_up;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            change,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getReportIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'weekly report':
        return Icons.calendar_view_week;
      case 'monthly report':
        return Icons.calendar_view_month;
      case 'crop report':
        return Icons.agriculture;
      default:
        return Icons.article;
    }
  }

  void _viewReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(report['title'] ?? 'Report Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Type: ${report['type']}'),
                const SizedBox(height: 8),
                Text('Date: ${report['date']}'),
                const SizedBox(height: 8),
                Text('Summary: ${report['summary']}'),
                const SizedBox(height: 12),
                Text(
                  'Statistics:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('• Diseases detected: ${report['diseaseCount']}'),
                Text('• Healthy plants: ${report['healthyCount']}'),
                Text('• Critical issues: ${report['criticalIssues']}'),
                Text('• Recommendations: ${report['recommendations']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadReport(report);
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  void _exportReports() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Reports'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportAs('PDF');
              },
              child: const Text('PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportAs('Excel');
              },
              child: const Text('Excel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _downloadReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${report['title']}...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    // TODO: Implement actual download functionality
  }

  void _exportAs(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting reports as $format...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    // TODO: Implement actual export functionality
  }
}
