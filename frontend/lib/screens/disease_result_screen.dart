import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ml_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DiseaseResultScreen extends StatefulWidget {
  final File imageFile;
  final PredictionResult result;

  const DiseaseResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final topPrediction = widget.result.topPrediction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Results'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _shareResults(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  widget.imageFile,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Main Result Card
            Card(
              color: _getResultColor(topPrediction.diseaseInfo.severity),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _getResultIcon(widget.result.isHealthy),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topPrediction.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${topPrediction.confidencePercentage}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Severity: ${topPrediction.diseaseInfo.severity.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Disease Information
            if (!widget.result.isHealthy) ...[
              _buildInfoCard(
                'Description',
                Icons.info_outline,
                topPrediction.diseaseInfo.description,
              ),

              _buildInfoCard(
                'Symptoms',
                Icons.warning_amber_outlined,
                '',
                items: topPrediction.diseaseInfo.symptoms,
              ),

              _buildInfoCard(
                'Treatment',
                Icons.medical_services_outlined,
                '',
                items: topPrediction.diseaseInfo.treatment,
              ),

              _buildInfoCard(
                'Prevention',
                Icons.shield_outlined,
                '',
                items: topPrediction.diseaseInfo.prevention,
              ),
            ] else ...[
              _buildInfoCard(
                'Plant Health',
                Icons.eco,
                topPrediction.diseaseInfo.description,
              ),

              _buildInfoCard(
                'Care Tips',
                Icons.lightbulb_outline,
                '',
                items: topPrediction.diseaseInfo.treatment,
              ),
            ],

            // Other Predictions
            if (widget.result.predictions.length > 1) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Other Possibilities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.result.predictions
                          .skip(1)
                          .map(
                            (prediction) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prediction.label,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    prediction.confidencePercentage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Another'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _saveResults(context),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is an AI prediction. For serious issues, consult an agricultural expert.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    String description, {
    List<String>? items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (description.isNotEmpty) ...[
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
            if (items != null && items.isNotEmpty) ...[
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getResultColor(DiseaseSeverity severity) {
    switch (severity) {
      case DiseaseSeverity.none:
        return Colors.green;
      case DiseaseSeverity.low:
        return Colors.yellow.shade700;
      case DiseaseSeverity.medium:
        return Colors.orange;
      case DiseaseSeverity.high:
        return Colors.red;
    }
  }

  IconData _getResultIcon(bool isHealthy) {
    return isHealthy ? Icons.check_circle : Icons.warning;
  }

  void _shareResults(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _saveResults(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Get the authentication token
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Prepare scan data for API
      final topPrediction = widget.result.topPrediction;

      // Extract plant type from disease label (supports multiple formats)
      String plantType = 'Unknown';
      String diseaseName = topPrediction.label;

      // Handle format: "Tomato - Early Blight" (with dash)
      if (topPrediction.label.contains(' - ')) {
        List<String> parts = topPrediction.label.split(' - ');
        if (parts.isNotEmpty) {
          plantType = parts[0].trim();
          if (parts.length > 1) {
            diseaseName = parts[1].trim();
          }
        }
      }
      // Handle format: "Tomato_Early_Blight" (with underscore)
      else if (topPrediction.label.contains('_')) {
        List<String> parts = topPrediction.label.split('_');
        if (parts.isNotEmpty) {
          plantType = parts[0];
          if (parts.length > 1) {
            diseaseName = parts.sublist(1).join(' ').replaceAll('_', ' ');
          }
        }
      }
      // Handle format: "Healthy Plant" or single word diseases
      else {
        // For labels like "Healthy Plant", extract the first word as plant type if it makes sense
        List<String> words = topPrediction.label.split(' ');
        if (words.length >= 2) {
          // Check if first word could be a plant type
          final firstWord = words[0].toLowerCase();
          final knownPlants = [
            'tomato',
            'potato',
            'corn',
            'apple',
            'grape',
            'pepper',
            'cherry',
            'peach',
            'strawberry',
            'blueberry',
            'raspberry',
            'soybean',
            'squash',
            'orange',
          ];

          if (knownPlants.contains(firstWord)) {
            plantType = words[0];
            diseaseName = words.sublist(1).join(' ');
          } else {
            // If we can't determine plant type, keep the full label as disease name
            diseaseName = topPrediction.label;
            plantType = 'Plant'; // Generic fallback
          }
        } else {
          diseaseName = topPrediction.label;
          plantType = 'Plant'; // Generic fallback
        }
      }

      // Upload image first
      String serverImagePath = widget.imageFile.path; // Fallback to local path
      try {
        print('🚀 Starting image upload for: ${widget.imageFile.path}');
        final uploadedFilename = await ApiService.uploadImage(widget.imageFile, token);
        print('✅ Image uploaded successfully: $uploadedFilename');
        
        // Prepend /api/images/ to match the format expected by other parts of the app
        serverImagePath = '/api/images/$uploadedFilename';
      } catch (e) {
        print('❌ Image upload failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: Image upload failed. Saving with local path. ($e)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        // Continue with local path if upload fails
      }

      final scanData = {
        'plantType': plantType,
        'disease': diseaseName,
        'confidence': topPrediction.confidence,
        'severity': topPrediction.diseaseInfo.severity.name.toUpperCase(),
        'status': widget.result.isHealthy ? 'Healthy' : 'Analyzed',
        'imagePath': serverImagePath,
        'recommendations': topPrediction.diseaseInfo.treatment.join(
          '|',
        ), // Convert list to pipe-separated string
        'symptoms': topPrediction.diseaseInfo.symptoms.join(
          '|',
        ), // Convert list to pipe-separated string
      };

      // Call the API to save the scan
      final response = await ApiService.createScan(scanData, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Results saved successfully! Scan ID: ${response['id'] ?? 'N/A'}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving scan results: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save results: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
