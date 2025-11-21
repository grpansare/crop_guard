import 'package:crop_disease_app/screens/ask_expert_screen.dart';
import 'package:crop_disease_app/screens/my_queries_screen.dart';
import 'package:crop_disease_app/screens/notifications_screen.dart';
import 'package:crop_disease_app/widgets/notification_badge.dart';
import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';
import 'disease_detection_screen.dart';
import 'scan_history_screen.dart';
import 'my_reports_screen.dart';
import 'settings_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _recentActivity = [];
  Map<String, dynamic> _quickStats = {};
  int _unreadNotificationCount = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadNotificationCount();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Load all dashboard data concurrently
      final results = await Future.wait([
        AuthService.getProfile(),
        _loadRecentActivity(token),
        _loadQuickStats(token),
      ]);

      setState(() {
        _userProfile = results[0] as Map<String, dynamic>;
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

  Future<void> _loadNotificationCount() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await ApiService.getUnreadNotificationCount(token);
      setState(() {
        _unreadNotificationCount = response['unreadCount'] ?? 0;
      });
    } catch (e) {
      print('Failed to load notification count: $e');
    }
  }

  Future<void> _loadRecentActivity(String token) async {
    try {
      print('🔄 Loading recent activity from API...');
      final activityData = await ApiService.getRecentActivity(token);
      print(
        '✅ Recent activity loaded successfully: ${activityData['activities']?.length ?? 0} items',
      );
      print('📊 Activity data: $activityData');

      setState(() {
        _recentActivity = List<Map<String, dynamic>>.from(
          activityData['activities'] ?? [],
        );
      });
    } catch (e) {
      print('❌ Failed to load recent activity: $e');
      // Use fallback data if API fails
      setState(() {
        _recentActivity = _getFallbackActivity();
      });
    }
  }

  Future<void> _loadQuickStats(String token) async {
    try {
      final statsData = await ApiService.getQuickStats(token);
      setState(() {
        _quickStats = statsData;
      });
    } catch (e) {
      print('Failed to load quick stats: $e');
      // Use fallback data if API fails
      setState(() {
        _quickStats = _getFallbackStats();
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackActivity() {
    return [
      {
        'title': 'Tomato plant scanned',
        'subtitle': 'Early Blight detected - Medium severity',
        'time': '2 hours ago',
        'icon': 'local_florist',
        'color': 'orange',
        'type': 'scan',
      },
      {
        'title': 'Weekly report generated',
        'subtitle': '15 scans completed this week',
        'time': '1 day ago',
        'icon': 'article',
        'color': 'blue',
        'type': 'report',
      },
      {
        'title': 'Potato crop healthy',
        'subtitle': 'No diseases detected',
        'time': '2 days ago',
        'icon': 'eco',
        'color': 'green',
        'type': 'scan',
      },
      {
        'title': 'Treatment reminder',
        'subtitle': 'Apply fungicide to tomato plants',
        'time': '3 days ago',
        'icon': 'notification_important',
        'color': 'red',
        'type': 'reminder',
      },
    ];
  }

  Map<String, dynamic> _getFallbackStats() {
    return {'totalScans': 10, 'diseasesDetected': 5, 'plantsScanned': 20};
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
        title: const Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          NotificationBadge(
            count: _unreadNotificationCount,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                ).then((_) => _loadNotificationCount()); // Refresh count when returning
              },
              tooltip: 'Notifications',
            ),
          ),
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
                          Text(
                            'Welcome, ${_userProfile?['fullName'] ?? 'Farmer'}!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mobile: ${_userProfile?['mobile'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Role: ${_userProfile?['role'] ?? 'Farmer'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
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
                        icon: Icons.camera_alt,
                        label: 'Scan Plant',
                        color: Colors.green,
                        onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DiseaseDetectionScreen(),
    ),
  );
  
  // Refresh dashboard data when returning from scan
  if (result != null) {
    _loadDashboardData();
  }
},
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.history,
                        label: 'Scan History',
                        color: Colors.blue,
                                                onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanHistoryScreen(),
                            ),
                          );
                          
                          // Refresh dashboard data when returning
                          if (result != null) {
                            _loadDashboardData();
                          }
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.support_agent,
                        label: 'Ask Expert',
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AskExpertScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.question_answer,
                        label: 'My Queries',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyQueriesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.article,
                        label: 'My Reports',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyReportsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.settings,
                        label: 'Settings',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity Section
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityList(),
                  const SizedBox(height: 24),

                  // Quick Stats Section
                  _buildQuickStats(),
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

  Widget _buildActivityList() {
    if (_recentActivity.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No recent activities',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Start scanning plants to see your activity here',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentActivity.length,
      itemBuilder: (context, index) {
        final activity = _recentActivity[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getColorFromString(activity['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconFromString(activity['icon']),
                color: _getColorFromString(activity['color']),
                size: 20,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['subtitle'] as String),
                const SizedBox(height: 2),
                Text(
                  activity['time'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              String type = activity['type'] as String;
              switch (type) {
                case 'scan':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanHistoryScreen(),
                    ),
                  );
                  break;
                case 'report':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReportsScreen(),
                    ),
                  );
                  break;
                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${activity['title']} details')),
                  );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _quickStats['totalScans'].toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scans completed',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _quickStats['diseasesDetected'].toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diseases detected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _quickStats['plantsScanned'].toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plants scanned',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromString(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    }

    if (colorValue is String) {
      switch (colorValue.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'orange':
          return Colors.orange;
        case 'yellow':
          return Colors.yellow;
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'teal':
          return Colors.teal;
        case 'cyan':
          return Colors.cyan;
        case 'indigo':
          return Colors.indigo;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          // Try to parse hex color
          if (colorValue.startsWith('#') && colorValue.length == 7) {
            try {
              return Color(
                int.parse(colorValue.substring(1), radix: 16) + 0xFF000000,
              );
            } catch (e) {
              return Colors.blue; // Default fallback
            }
          }
          return Colors.blue; // Default fallback
      }
    }

    return Colors.blue; // Default fallback
  }

  IconData _getIconFromString(dynamic iconValue) {
    if (iconValue is IconData) {
      return iconValue;
    }

    if (iconValue is String) {
      switch (iconValue.toLowerCase()) {
        case 'local_florist':
          return Icons.local_florist;
        case 'article':
          return Icons.article;
        case 'eco':
          return Icons.eco;
        case 'notification_important':
          return Icons.notification_important;
        case 'history':
          return Icons.history;
        case 'camera_alt':
          return Icons.camera_alt;
        case 'settings':
          return Icons.settings;
        default:
          return Icons.info; // Default fallback
      }
    }

    return Icons.info; // Default fallback
  }
}