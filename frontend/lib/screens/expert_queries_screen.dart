import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';

class ExpertQueriesScreen extends StatefulWidget {
  const ExpertQueriesScreen({super.key});

  @override
  State<ExpertQueriesScreen> createState() => _ExpertQueriesScreenState();
}

class _ExpertQueriesScreenState extends State<ExpertQueriesScreen> {
  List<Map<String, dynamic>> _queries = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Pending',
    'In Progress',
    'Answered',
    'Closed',
  ];

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

      final response = await ApiService.getExpertQueries(token);
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
        .where(
          (query) =>
              query['status'] ==
              _selectedFilter.toLowerCase().replaceAll(' ', '_'),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Queries'),
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
                      'Total',
                      _queries.length.toString(),
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Pending',
                      _queries
                          .where((q) => q['status'] == 'pending')
                          .length
                          .toString(),
                      Colors.orange,
                    ),
                    _buildStatColumn(
                      'Answered',
                      _queries
                          .where((q) => q['status'] == 'answered')
                          .length
                          .toString(),
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 16),

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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'All'
                  ? 'No queries available'
                  : 'No ${_selectedFilter.toLowerCase()} queries',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'All'
                  ? 'Farmers haven\'t submitted any queries yet'
                  : 'Try selecting a different filter to see more queries',
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

  Widget _buildQueryCard(Map<String, dynamic> query) {
    final status = query['status'] as String? ?? 'pending';
    final urgency = query['urgency'] as String? ?? 'medium';
    final farmerName = query['farmerName'] as String? ?? 'Unknown Farmer';

    // Check if expert has already responded (based on response count or hasResponded flag)
    final responseCount = query['responseCount'] ?? 0;
    final hasResponded = query['hasResponded'] == true || responseCount > 0;

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
                  _buildUrgencyChip(urgency),
                ],
              ),
              const SizedBox(height: 8),

              // Farmer Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    farmerName,
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
                  Text(
                    _formatDate(query['createdAt'] as String?),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  if (status != 'closed')
                    hasResponded
                        ? ElevatedButton.icon(
                            onPressed: () => _showQueryDetails(query),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Update Response'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _showResponseDialog(query),
                            icon: const Icon(Icons.reply, size: 16),
                            label: Text(
                              status == 'pending' ? 'Respond' : 'Add Response',
                            ),
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

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'in_progress':
        color = Colors.blue;
        icon = Icons.hourglass_empty;
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
            status.toUpperCase().replaceAll('_', ' '),
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

  Widget _buildUrgencyChip(String urgency) {
    final color = _getUrgencyColor(urgency);
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
          Icon(Icons.priority_high, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            urgency.toUpperCase(),
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
      builder: (context) => _ExpertQueryDetailsBottomSheet(
        query: query,
        onResponseSubmitted: _loadQueries,
      ),
    );
  }

  void _showResponseDialog(Map<String, dynamic> query) {
    showDialog(
      context: context,
      builder: (context) =>
          _ResponseDialog(query: query, onResponseSubmitted: _loadQueries),
    );
  }
}

class _ExpertQueryDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> query;
  final VoidCallback onResponseSubmitted;

  const _ExpertQueryDetailsBottomSheet({
    required this.query,
    required this.onResponseSubmitted,
  });

  @override
  State<_ExpertQueryDetailsBottomSheet> createState() =>
      _ExpertQueryDetailsBottomSheetState();
}

class _ExpertQueryDetailsBottomSheetState
    extends State<_ExpertQueryDetailsBottomSheet> {
  String? _currentExpertId;
  Map<String, dynamic>? _expertOwnResponse;
  bool _isCheckingResponse = true;

  @override
  void initState() {
    super.initState();
    _checkExpertResponse();
  }

  Future<void> _checkExpertResponse() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      // Get current expert's profile
      final profile = await AuthService.getProfile();
      _currentExpertId = profile['id']?.toString();

      // Get all responses for this query
      final queryId = int.tryParse(widget.query['id'].toString()) ?? 0;
      final responses = await ApiService.getQueryResponses(queryId, token);

      // Find if current expert has already responded
      final ownResponse = responses.firstWhere(
        (response) => response['expertId']?.toString() == _currentExpertId,
        orElse: () => {},
      );

      setState(() {
        _expertOwnResponse = ownResponse.isNotEmpty ? ownResponse : null;
        _isCheckingResponse = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingResponse = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResponse =
        widget.query['response'] != null &&
        (widget.query['response'] as String).isNotEmpty;
    final farmerName =
        widget.query['farmerName'] as String? ?? 'Unknown Farmer';

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
                if (widget.query['status'] != 'closed' && !_isCheckingResponse)
                  _expertOwnResponse != null
                      ? ElevatedButton.icon(
                          onPressed: () {
                            _showEditResponseDialog(_expertOwnResponse!);
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Update Response'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            _showResponseDialog(context, widget.query);
                          },
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text('Add Response'),
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
                    widget.query['title'] as String? ?? 'Untitled Query',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  _buildMetadataRow('Farmer', farmerName, Icons.person),
                  _buildMetadataRow(
                    'Crop Type',
                    widget.query['cropType'] as String? ?? 'Unknown',
                    Icons.agriculture,
                  ),
                  _buildMetadataRow(
                    'Category',
                    widget.query['category'] as String? ?? 'General',
                    Icons.category,
                  ),
                  _buildMetadataRow(
                    'Urgency',
                    widget.query['urgency'] as String? ?? 'Medium',
                    Icons.priority_high,
                  ),
                  _buildMetadataRow(
                    'Status',
                    widget.query['status'] as String? ?? 'Pending',
                    Icons.info,
                  ),
                  _buildMetadataRow(
                    'Date',
                    _formatFullDate(widget.query['createdAt'] as String?),
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
                      widget.query['description'] as String? ??
                          'No description provided',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  // Attached Image
                  if (widget.query['hasImage'] == true &&
                      widget.query['imageUrl'] != null) ...[
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
                        final baseUrlWithoutApi = ApiService.baseUrl.replaceAll(
                          '/api',
                          '',
                        );
                        final imageUrl =
                            '$baseUrlWithoutApi${widget.query['imageUrl']}';
                        print('🖼️ Expert loading image from: $imageUrl');
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
                                print('❌ Expert image load error: $error');
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Text('Image not available'),
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
                  _ExpertResponsesList(queryId: widget.query['id']),

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

  void _showResponseDialog(BuildContext context, Map<String, dynamic> query) {
    showDialog(
      context: context,
      builder: (context) => _ResponseDialog(
        query: query,
        onResponseSubmitted: widget.onResponseSubmitted,
      ),
    );
  }

  void _showEditResponseDialog(Map<String, dynamic> response) {
    final TextEditingController controller = TextEditingController(
      text: response['response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Response'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Enter your updated response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Response cannot be empty'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              try {
                final token = await AuthService.getToken();
                if (token == null) throw Exception('Authentication required');

                await ApiService.updateQueryResponse(
                  response['id'],
                  controller.text.trim(),
                  token,
                );

                if (mounted) {
                  // Capture messenger before popping
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(dialogContext);

                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Response updated successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  widget.onResponseSubmitted(); // Reload queries
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Failed to update: ${e.toString().replaceAll('Exception: ', '')}',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _ResponseDialog extends StatefulWidget {
  final Map<String, dynamic> query;
  final VoidCallback onResponseSubmitted;

  const _ResponseDialog({
    required this.query,
    required this.onResponseSubmitted,
  });

  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final _responseController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    final responseText = _responseController.text.trim();

    if (responseText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (responseText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response must be at least 10 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (responseText.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response must be less than 2000 characters'),
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
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Get query ID
      final queryId = int.tryParse(widget.query['id'].toString()) ?? 0;

      print('📤 Adding response to query ID: $queryId');
      print('📤 Response text length: ${responseText.length}');

      final result = await ApiService.addQueryResponse(
        queryId,
        responseText,
        token,
      );
      print('✅ Response added successfully: $result');

      if (mounted) {
        // Capture messenger before popping
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Response submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onResponseSubmitted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit response: ${e.toString().replaceAll('Exception: ', '')}',
            ),
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
      title: const Text('Respond to Query'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Query: ${widget.query['title']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Farmer: ${widget.query['farmerName'] ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _responseController,
              decoration: InputDecoration(
                labelText: 'Your Response',
                hintText: 'Provide detailed advice and recommendations...',
                helperText: 'Minimum 10 characters required',
                counterText: '${_responseController.text.length}/2000',
              ),
              maxLines: 5,
              maxLength: 2000,
              onChanged: (value) {
                setState(() {}); // Refresh to update counter
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitResponse,
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
              : const Text('Submit Response'),
        ),
      ],
    );
  }
}

// Widget to display all expert responses for a query
class _ExpertResponsesList extends StatefulWidget {
  final dynamic queryId;

  const _ExpertResponsesList({required this.queryId});

  @override
  State<_ExpertResponsesList> createState() => _ExpertResponsesListState();
}

class _ExpertResponsesListState extends State<_ExpertResponsesList> {
  List<Map<String, dynamic>> _responses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _currentExpertId;

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

      // Get current expert's profile to identify their responses
      final profile = await AuthService.getProfile();
      _currentExpertId = profile['id']?.toString();

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
          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_responses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'No responses yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Be the first expert to respond!',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
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
          final isOwnResponse =
              response['expertId']?.toString() == _currentExpertId;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOwnResponse ? Colors.blue.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isOwnResponse
                    ? Colors.blue.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expert name with verification badge
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isOwnResponse
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
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
                                response['expertName'] ?? 'Unknown Expert',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isOwnResponse
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (response['isVerified'] == true)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              if (isOwnResponse) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                    // Edit button for own responses
                    if (isOwnResponse)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: Colors.blue.shade700,
                        onPressed: () => _showEditResponseDialog(response),
                        tooltip: 'Edit Response',
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

  void _showEditResponseDialog(Map<String, dynamic> response) {
    final TextEditingController controller = TextEditingController(
      text: response['response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Response'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Enter your updated response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Response cannot be empty'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              try {
                final token = await AuthService.getToken();
                if (token == null) throw Exception('Authentication required');

                await ApiService.updateQueryResponse(
                  response['id'],
                  controller.text.trim(),
                  token,
                );

                if (mounted) {
                  // Capture messenger before popping
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(dialogContext);

                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Response updated successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _loadResponses(); // Reload responses
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Failed to update: ${e.toString().replaceAll('Exception: ', '')}',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
