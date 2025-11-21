import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';
import 'ask_expert_screen.dart';

class MyQueriesScreen extends StatefulWidget {
  const MyQueriesScreen({super.key});

  @override
  State<MyQueriesScreen> createState() => _MyQueriesScreenState();
}

class _MyQueriesScreenState extends State<MyQueriesScreen> {
  List<Map<String, dynamic>> _queries = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Pending', 'Answered', 'Closed'];

  @override
  void initState() {
    super.initState();
    _loadQueries();
  }

  Future<void> _loadQueries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiService.getMyQueries(token);
      setState(() {
        _queries = List<Map<String, dynamic>>.from(response['queries'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load queries: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredQueries {
    if (_selectedFilter == 'All') {
      return _queries;
    }
    return _queries
        .where((query) => query['status'] == _selectedFilter.toLowerCase())
        .toList();
  }

  Future<void> _navigateToAskExpert() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AskExpertScreen()),
    );

    if (result == true) {
      _loadQueries(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Queries'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
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
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadQueries,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredQueries.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadQueries,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredQueries.length,
                      itemBuilder: (context, index) {
                        final query = _filteredQueries[index];
                        return _buildQueryCard(query);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAskExpert,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ask Expert'),
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
            Icon(Icons.help_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'All'
                  ? 'No queries yet'
                  : 'No ${_selectedFilter.toLowerCase()} queries',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'All'
                  ? 'Start by asking your first question to our crop experts'
                  : 'Try selecting a different filter to see more queries',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_selectedFilter == 'All')
              ElevatedButton.icon(
                onPressed: _navigateToAskExpert,
                icon: const Icon(Icons.add),
                label: const Text('Ask Your First Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    final status = query['status'] as String? ?? 'pending';
    final urgency = query['urgency'] as String? ?? 'medium';
    final hasResponse =
        query['response'] != null && (query['response'] as String).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showQueryDetails(query),
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
                      query['title'] as String? ?? 'Untitled Query',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 8),

              // Crop Type and Category
              Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    query['cropType'] as String? ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      query['category'] as String? ?? 'General',
                      style: TextStyle(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description Preview
              Text(
                query['description'] as String? ?? 'No description provided',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Image indicator
              if (query['hasImage'] == true && query['imageUrl'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.image, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Photo attached',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // Bottom Row
              Row(
                children: [
                  // Urgency Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(urgency).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getUrgencyColor(urgency).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 12,
                          color: _getUrgencyColor(urgency),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          urgency.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getUrgencyColor(urgency),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Response Indicator
                  if (hasResponse)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply,
                            size: 12,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ANSWERED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Date
                  Text(
                    _formatDate(query['createdAt'] as String?),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'answered':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'closed':
        color = Colors.grey;
        icon = Icons.lock;
        break;
      default:
        color = Colors.blue;
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
            status.toUpperCase(),
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

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
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

  void _showQueryDetails(Map<String, dynamic> query) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QueryDetailsBottomSheet(query: query),
    );
  }
}

class _QueryDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> query;

  const _QueryDetailsBottomSheet({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    'Query Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                    query['title'] as String? ?? 'Untitled Query',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  _buildMetadataRow(
                    'Crop Type',
                    query['cropType'] as String? ?? 'Unknown',
                    Icons.agriculture,
                  ),
                  _buildMetadataRow(
                    'Category',
                    query['category'] as String? ?? 'General',
                    Icons.category,
                  ),
                  _buildMetadataRow(
                    'Urgency',
                    query['urgency'] as String? ?? 'Medium',
                    Icons.priority_high,
                  ),
                  _buildMetadataRow(
                    'Status',
                    query['status'] as String? ?? 'Pending',
                    Icons.info,
                  ),
                  _buildMetadataRow(
                    'Date',
                    _formatFullDate(query['createdAt'] as String?),
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
                      query['description'] as String? ??
                          'No description provided',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  // Attached Image
                  if (query['hasImage'] == true && query['imageUrl'] != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Attached Photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        // Backend returns imageUrl as '/api/images/filename.jpg'
                        // We need base URL without '/api' since imageUrl already has it
                        final baseUrlWithoutApi = ApiService.baseUrl.replaceAll('/api', '');
                        final imageUrl = '$baseUrlWithoutApi${query['imageUrl']}';
                        print('🖼️ Loading image from: $imageUrl');
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Image load error: $error');
                            print('❌ Stack trace: $stackTrace');
                            return Container(
                              color: Colors.grey.shade100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Image not available', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Show all expert responses
                  const SizedBox(height: 24),
                  _FarmerExpertResponsesList(queryId: query['id']),

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
}

// Widget to display all expert responses for a query (Farmer view)
class _FarmerExpertResponsesList extends StatefulWidget {
  final dynamic queryId;

  const _FarmerExpertResponsesList({required this.queryId});

  @override
  State<_FarmerExpertResponsesList> createState() => _FarmerExpertResponsesListState();
}

class _FarmerExpertResponsesListState extends State<_FarmerExpertResponsesList> {
  List<Map<String, dynamic>> _responses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final queryId = int.tryParse(widget.queryId.toString()) ?? 0;
      final responses = await ApiService.getQueryResponses(queryId, token);

      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load responses: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_responses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.pending,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for Expert Response',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Our experts will review your query and respond within 24-48 hours',
              style: TextStyle(color: Colors.orange.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              'Expert Responses (${_responses.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._responses.map((response) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expert name with verification badge
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.shade700,
                      radius: 16,
                      child: Text(
                        (response['expertName'] ?? 'E')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Dr. ${response['expertName'] ?? 'Unknown Expert'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (response['isVerified'] == true)
                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ),
                          Text(
                            _formatDate(response['createdAt']),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Response text
                Text(
                  response['response'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
