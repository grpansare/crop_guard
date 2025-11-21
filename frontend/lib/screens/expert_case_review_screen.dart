import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';

class ExpertCaseReviewScreen extends StatefulWidget {
  const ExpertCaseReviewScreen({super.key});

  @override
  State<ExpertCaseReviewScreen> createState() => _ExpertCaseReviewScreenState();
}

class _ExpertCaseReviewScreenState extends State<ExpertCaseReviewScreen> {
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  final List<String> _filterOptions = [
    'All',
    'Pending Review',
    'Under Review',
    'Reviewed',
    'Critical',
  ];

  final List<String> _sortOptions = [
    'Recent',
    'Oldest',
    'Severity',
    'Crop Type',
  ];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Fetch all scans from backend (expert endpoint)
      final response = await ApiService.getWithAuth(
        'scans/all?page=0&size=100',
        token,
      );

      print('📋 Case Review - Backend Response: $response');

      // Parse the response
      List<Map<String, dynamic>> cases = [];
      if (response['scans'] != null) {
        final scans = response['scans'] as List;
        cases = scans.map((scan) {
          // Handle symptoms and recommendations which might be Lists
          String description = 'No description available';
          if (scan['symptoms'] != null) {
            if (scan['symptoms'] is List) {
              description = (scan['symptoms'] as List).join(', ');
            } else {
              description = scan['symptoms'].toString();
            }
          }

          String recommendations = 'No recommendations available';
          if (scan['recommendations'] != null) {
            if (scan['recommendations'] is List) {
              recommendations = (scan['recommendations'] as List).join(', ');
            } else {
              recommendations = scan['recommendations'].toString();
            }
          }

          return {
            'id': scan['id'],
            'farmerName': scan['userName'] ?? 'Unknown Farmer',
            'cropType': scan['plantType'] ?? 'Unknown',
            'diseaseDetected': scan['disease'] ?? 'Unknown',
            'confidence': (scan['confidence'] ?? 0.0) is int
                ? (scan['confidence'] as int).toDouble()
                : (scan['confidence'] as double),
            'severity': scan['severity'] ?? 'Medium',
            'imageUrl': scan['imageUrl'] ?? '/uploads/default.jpg',
            'scanDate': scan['createdAt'] ?? DateTime.now().toIso8601String(),
            'status': _mapStatusToReviewStatus(scan['status'] ?? 'Pending'),
            'location': 'India', // Default location since it's not in scan data
            'description': description,
            'aiRecommendation': recommendations,
            'expertNotes': null,
            'expertRating': null,
          };
        }).toList();
      }

      print('📋 Parsed ${cases.length} cases from backend');

      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load cases: $e');
      setState(() {
        _errorMessage = 'Failed to load cases: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _mapStatusToReviewStatus(String scanStatus) {
    switch (scanStatus.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'under treatment':
        return 'Under Review';
      case 'treated':
        return 'Reviewed';
      default:
        return 'Pending Review';
    }
  }

  List<Map<String, dynamic>> _getMockCases() {
    return [
      {
        'id': 1,
        'farmerName': 'Rajesh Kumar',
        'cropType': 'Tomato',
        'diseaseDetected': 'Late Blight',
        'confidence': 0.89,
        'severity': 'High',
        'imageUrl': '/uploads/case1.jpg',
        'scanDate': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'status': 'Pending Review',
        'location': 'Punjab, India',
        'description':
            'Tomato plants showing dark spots on leaves with yellowing edges',
        'aiRecommendation': 'Apply copper-based fungicide immediately',
        'expertNotes': null,
        'expertRating': null,
      },
      {
        'id': 2,
        'farmerName': 'Priya Sharma',
        'cropType': 'Wheat',
        'diseaseDetected': 'Rust',
        'confidence': 0.76,
        'severity': 'Medium',
        'imageUrl': '/uploads/case2.jpg',
        'scanDate': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'status': 'Under Review',
        'location': 'Haryana, India',
        'description': 'Wheat leaves showing orange pustules',
        'aiRecommendation': 'Apply sulfur-based fungicide',
        'expertNotes':
            'Confirmed rust infection. Recommend immediate treatment.',
        'expertRating': 4,
      },
      {
        'id': 3,
        'farmerName': 'Amit Singh',
        'cropType': 'Rice',
        'diseaseDetected': 'Blast',
        'confidence': 0.92,
        'severity': 'Critical',
        'imageUrl': '/uploads/case3.jpg',
        'scanDate': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        'status': 'Pending Review',
        'location': 'West Bengal, India',
        'description': 'Rice plants showing severe blast symptoms',
        'aiRecommendation':
            'Urgent treatment required - apply systemic fungicide',
        'expertNotes': null,
        'expertRating': null,
      },
      {
        'id': 4,
        'farmerName': 'Sunita Devi',
        'cropType': 'Corn',
        'diseaseDetected': 'Leaf Spot',
        'confidence': 0.68,
        'severity': 'Low',
        'imageUrl': '/uploads/case4.jpg',
        'scanDate': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'status': 'Reviewed',
        'location': 'Bihar, India',
        'description': 'Corn leaves showing small brown spots',
        'aiRecommendation':
            'Monitor closely, apply preventive fungicide if needed',
        'expertNotes': 'Minor infection. Preventive measures sufficient.',
        'expertRating': 3,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredCases {
    List<Map<String, dynamic>> filtered = _cases;

    // Apply filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((case_) {
        switch (_selectedFilter) {
          case 'Pending Review':
            return case_['status'] == 'Pending Review';
          case 'Under Review':
            return case_['status'] == 'Under Review';
          case 'Reviewed':
            return case_['status'] == 'Reviewed';
          case 'Critical':
            return case_['severity'] == 'Critical';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Recent':
        filtered.sort(
          (a, b) => DateTime.parse(
            b['scanDate'],
          ).compareTo(DateTime.parse(a['scanDate'])),
        );
        break;
      case 'Oldest':
        filtered.sort(
          (a, b) => DateTime.parse(
            a['scanDate'],
          ).compareTo(DateTime.parse(b['scanDate'])),
        );
        break;
      case 'Severity':
        final severityOrder = {'Critical': 4, 'High': 3, 'Medium': 2, 'Low': 1};
        filtered.sort(
          (a, b) => (severityOrder[b['severity']] ?? 0).compareTo(
            severityOrder[a['severity']] ?? 0,
          ),
        );
        break;
      case 'Crop Type':
        filtered.sort((a, b) => a['cropType'].compareTo(b['cropType']));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Review'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCases,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      'Total Cases',
                      _cases.length.toString(),
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Pending',
                      _cases
                          .where((c) => c['status'] == 'Pending Review')
                          .length
                          .toString(),
                      Colors.orange,
                    ),
                    _buildStatColumn(
                      'Critical',
                      _cases
                          .where((c) => c['severity'] == 'Critical')
                          .length
                          .toString(),
                      Colors.red,
                    ),
                    _buildStatColumn(
                      'Reviewed',
                      _cases
                          .where((c) => c['status'] == 'Reviewed')
                          .length
                          .toString(),
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter and Sort Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.2),
                                checkmarkColor: Theme.of(context).primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Sort: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _sortOptions.map((sort) {
                            final isSelected = _selectedSort == sort;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(sort),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSort = sort;
                                  });
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.2),
                                checkmarkColor: Theme.of(context).primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _filteredCases.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadCases,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCases.length,
                      itemBuilder: (context, index) {
                        final case_ = _filteredCases[index];
                        return _buildCaseCard(case_);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
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
          ElevatedButton(onPressed: _loadCases, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'All'
                  ? 'No cases available'
                  : 'No ${_selectedFilter.toLowerCase()} cases',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'All'
                  ? 'No farmer scan results to review yet'
                  : 'Try selecting a different filter to see more cases',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> case_) {
    final severity = case_['severity'] as String;
    final status = case_['status'] as String;
    final confidence = (case_['confidence'] as double) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCaseDetails(case_),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${case_['cropType']} - ${case_['diseaseDetected']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSeverityChip(severity),
                ],
              ),
              const SizedBox(height: 8),

              // Farmer Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    case_['farmerName'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 8),

              // Confidence and Location
              Row(
                children: [
                  Icon(Icons.analytics, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Confidence: ${confidence.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      case_['location'],
                      style: TextStyle(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description Preview
              Text(
                case_['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Bottom Row
              Row(
                children: [
                  Text(
                    _formatDate(case_['scanDate']),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  if (status == 'Pending Review')
                    ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(case_),
                      icon: const Icon(Icons.rate_review, size: 16),
                      label: const Text('Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color color;
    IconData icon;

    switch (severity.toLowerCase()) {
      case 'critical':
        color = Colors.red.shade900;
        icon = Icons.warning;
        break;
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.info;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            severity.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending review':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'under review':
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        break;
      case 'reviewed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase().replaceAll(' ', ' '),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showCaseDetails(Map<String, dynamic> case_) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CaseDetailsBottomSheet(case_: case_, onReviewSubmitted: _loadCases),
    );
  }

  void _showReviewDialog(Map<String, dynamic> case_) {
    showDialog(
      context: context,
      builder: (context) =>
          _ReviewDialog(case_: case_, onReviewSubmitted: _loadCases),
    );
  }
}

class _CaseDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> case_;
  final VoidCallback onReviewSubmitted;

  const _CaseDetailsBottomSheet({
    required this.case_,
    required this.onReviewSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = (case_['confidence'] as double) * 100;
    final hasExpertNotes =
        case_['expertNotes'] != null &&
        (case_['expertNotes'] as String).isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Case Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (case_['status'] == 'Pending Review')
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showReviewDialog(context, case_);
                    },
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '${case_['cropType']} - ${case_['diseaseDetected']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  _buildMetadataRow(
                    'Farmer',
                    case_['farmerName'],
                    Icons.person,
                  ),
                  _buildMetadataRow(
                    'Crop Type',
                    case_['cropType'],
                    Icons.agriculture,
                  ),
                  _buildMetadataRow(
                    'Disease',
                    case_['diseaseDetected'],
                    Icons.bug_report,
                  ),
                  _buildMetadataRow(
                    'Severity',
                    case_['severity'],
                    Icons.warning,
                  ),
                  _buildMetadataRow(
                    'Confidence',
                    '${confidence.toStringAsFixed(1)}%',
                    Icons.analytics,
                  ),
                  _buildMetadataRow(
                    'Location',
                    case_['location'],
                    Icons.location_on,
                  ),
                  _buildMetadataRow('Status', case_['status'], Icons.info),
                  _buildMetadataRow(
                    'Scan Date',
                    _formatFullDate(case_['scanDate']),
                    Icons.calendar_today,
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      case_['description'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // AI Recommendation
                  Text(
                    'AI Recommendation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      case_['aiRecommendation'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  // Attached Image
                  if (case_['imageUrl'] != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Scan Image:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),

                        child: Builder(
                          builder: (context) {
                            final imageUrl = case_['imageUrl'] as String;

                            // Check if it's a local path (starts with /data/)
                            if (imageUrl.startsWith('/data/')) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image not uploaded to server',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '(Local path: ${imageUrl.split('/').last})',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Backend returns imageUrl as '/api/images/filename.jpg'
                            // We need base URL without '/api' since imageUrl already has it
                            final baseUrlWithoutApi = ApiService.baseUrl
                                .replaceAll('/api', '');
                            final fullImageUrl = '$baseUrlWithoutApi$imageUrl';

                            print(
                              '🖼️ Loading image: $fullImageUrl',
                            ); // Debug log

                            return Image.network(
                              fullImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  '❌ Image load error for $fullImageUrl: $error',
                                ); // Debug log
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Text('Image not available'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  if (hasExpertNotes) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Expert Review',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            case_['expertNotes'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (case_['expertRating'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Rating: '),
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < (case_['expertRating'] as int)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> case_) {
    showDialog(
      context: context,
      builder: (context) =>
          _ReviewDialog(case_: case_, onReviewSubmitted: onReviewSubmitted),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final Map<String, dynamic> case_;
  final VoidCallback onReviewSubmitted;

  const _ReviewDialog({required this.case_, required this.onReviewSubmitted});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _notesController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final notes = _notesController.text.trim();

    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your review notes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Authentication required');

      final reviewData = {
        'expertNotes': notes,
        'expertRating': _rating,
        'status': 'Reviewed',
      };

      // Convert ID to int if it's a string
      int scanId;
      if (widget.case_['id'] is String) {
        scanId = int.parse(widget.case_['id']);
      } else {
        scanId = widget.case_['id'];
      }

      await ApiService.submitScanReview(scanId, reviewData, token);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onReviewSubmitted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review Case'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Case: ${widget.case_['cropType']} - ${widget.case_['diseaseDetected']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Farmer: ${widget.case_['farmerName']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              const Text('Rating:'),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Expert Notes',
                  hintText:
                      'Provide your professional assessment and recommendations...',
                  helperText:
                      'Include treatment recommendations, prevention tips, etc.',
                ),
                maxLines: 5,
                maxLength: 1000,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit Review'),
        ),
      ],
    );
  }
}
