import 'package:crop_disease_app/screens/expert_queries_screen.dart';
import 'package:crop_disease_app/screens/expert_case_review_screen.dart';
import 'package:crop_disease_app/screens/expert_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/screens/disease_analysis_screen.dart';
import 'package:crop_disease_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        AuthService.getProfile(),
        _loadDashboardStats(),
      ]);

      setState(() {
        _userProfile = results[0];
        _dashboardStats = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load dashboard: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _loadDashboardStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Make real API calls to backend
      final results = await Future.wait([
        _getExpertDashboardStats(token),
        _getExpertPerformanceMetrics(token),
      ]);

      final dashboardStats = results[0] as Map<String, dynamic>;
      final performanceMetrics = results[1] as Map<String, dynamic>;

      // Combine both API responses
      return {...dashboardStats, ...performanceMetrics};
    } catch (e) {
      // Return fallback data
      return {
        'totalQueries': 0,
        'pendingQueries': 0,
        'answeredQueries': 0,
        'totalCases': 0,
        'pendingCases': 0,
        'reviewedCases': 0,
        'criticalCases': 0,
        'totalFarmers': 0,
        'activeFarmers': 0,
        'responseTime': 'N/A',
        'satisfactionRating': 0.0,
        'diseasesIdentified': 0,
        'treatmentsProvided': 0,
        'preventionTips': 0,
        'monthlyQueries': [],
        'topDiseases': [],
        'recentActivity': [],
      };
    }
  }

  Future<Map<String, dynamic>> _getExpertDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl.replaceAll('/api', '')}/api/dashboard/expert'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load expert dashboard stats');
      }
    } catch (e) {
      print('Error fetching expert dashboard stats: $e');
      // Return fallback data
      return {
        'totalQueries': 0,
        'pendingQueries': 0,
        'answeredQueries': 0,
        'criticalCases': 0,
        'totalFarmers': 0,
        'activeFarmers': 0,
        'responseTime': 'N/A',
        'satisfactionRating': 0.0,
        'recentActivity': [],
      };
    }
  }

  Future<Map<String, dynamic>> _getExpertPerformanceMetrics(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl.replaceAll('/api', '')}/api/dashboard/expert/performance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load expert performance metrics');
      }
    } catch (e) {
      print('Error fetching expert performance metrics: $e');
      // Return fallback data
      return {
        'diseasesIdentified': 0,
        'treatmentsProvided': 0,
        'preventionTips': 0,
        'monthlyQueries': [],
        'topDiseases': [],
      };
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Welcome, Dr. ${_userProfile?['fullName'] ?? 'Expert'}!',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mobile: ${_userProfile?['mobile'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Crop Disease Expert',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Text(
                    'System Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Expert Tools
                  Text(
                    'Expert Tools',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.analytics,
                        label: 'Disease Analysis',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiseaseAnalysisScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.assignment,
                        label: 'Review Cases',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ExpertCaseReviewScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.people,
                        label: 'Farmer Queries',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExpertQueriesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.settings,
                        label: 'Settings',
                        color: Colors.grey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ExpertSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Expert Activity
                  Text(
                    'Recent Expert Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExpertActivityList(),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Scans',
            _dashboardStats['totalScans']?.toString() ?? '0',
            Icons.qr_code_scanner,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Diseases Detected',
            _dashboardStats['diseasesDetected']?.toString() ?? '0',
            Icons.bug_report,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Healthy Plants',
            _dashboardStats['healthyPlants']?.toString() ?? '0',
            Icons.eco,
            Colors.green,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertActivityList() {
    final activities =
        _dashboardStats['recentActivity'] as List<dynamic>? ?? [];

    if (activities.isEmpty) {
      return const Center(child: Text('No recent expert activities'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        IconData activityIcon;
        Color activityColor;

        switch (activity['type']) {
          case 'query_response':
            activityIcon = Icons.reply;
            activityColor = Colors.orange;
            break;
          case 'case_review':
            activityIcon = Icons.rate_review;
            activityColor = Colors.blue;
            break;
          case 'knowledge_update':
            activityIcon = Icons.update;
            activityColor = Colors.green;
            break;
          case 'trend_analysis':
            activityIcon = Icons.analytics;
            activityColor = Colors.purple;
            break;
          default:
            activityIcon = Icons.work;
            activityColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(activityIcon, color: activityColor),
            title: Text(activity['title'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity['farmer'] != null)
                  Text('Farmer: ${activity['farmer']}'),
                Text(activity['time'] ?? ''),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Handle activity tap
            },
          ),
        );
      },
    );
  }
}
