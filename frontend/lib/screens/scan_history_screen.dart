import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';
import 'disease_detection_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _scanHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final scanData = await ApiService.getScanHistory(token);

      print('🔍 Scan data received: $scanData');
      print('🔍 Scans array: ${scanData['scans']}');
      print('🔍 Scans array length: ${scanData['scans']?.length ?? 0}');

      setState(() {
        _scanHistory = List<Map<String, dynamic>>.from(scanData['scans'] ?? []);
        print('🔍 Final _scanHistory length: ${_scanHistory.length}');
        print('🔍 Final _scanHistory content: $_scanHistory');
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load scan history: $e');
      setState(() {
        _scanHistory = [];
        _isLoading = false;
        _errorMessage =
            'Failed to load scan history. ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow.shade700;
      case 'none':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'treated':
        return Colors.blue;
      case 'under treatment':
        return Colors.orange;
      case 'monitoring':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadScanHistory();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scanHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No scan history found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start scanning plants to see your history here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseaseDetectionScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Start Scanning'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadScanHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  final scan = _scanHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _showScanDetails(scan);
                      },
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
                                    Icons.local_florist,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scan['plantType'] ?? 'Unknown Plant',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        scan['disease'] ?? 'Unknown',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
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
                                    color: _getStatusColor(
                                      scan['status'] ?? '',
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    scan['status'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: _getStatusColor(
                                        scan['status'] ?? '',
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${scan['date']} at ${scan['time']}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.trending_up,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${((scan['confidence'] ?? 0.0) * 100).toInt()}% confidence',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Severity: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(
                                      scan['severity'] ?? '',
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    scan['severity'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: _getSeverityColor(
                                        scan['severity'] ?? '',
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            ),
    );
  }

  void _showScanDetails(Map<String, dynamic> scan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Plant Type', scan['plantType'] ?? 'Unknown'),
                _buildDetailRow('Disease', scan['disease'] ?? 'Unknown'),
                _buildDetailRow(
                  'Confidence',
                  '${((scan['confidence'] ?? 0.0) * 100).toInt()}%',
                ),
                _buildDetailRow('Date', scan['date'] ?? 'Unknown'),
                _buildDetailRow('Time', scan['time'] ?? 'Unknown'),
                _buildDetailRow('Severity', scan['severity'] ?? 'Unknown'),
                _buildDetailRow('Status', scan['status'] ?? 'Unknown'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Detailed report feature coming soon!'),
                  ),
                );
              },
              child: const Text('View Report'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
