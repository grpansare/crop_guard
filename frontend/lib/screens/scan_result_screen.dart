import 'dart:io';
import 'package:flutter/material.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;
  final bool isGallery;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    required this.isGallery,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isAnalyzing = true;
  String _analysisResult = '';
  String _diseaseName = '';
  String _confidence = '';
  String _treatment = '';

  @override
  void initState() {
    super.initState();
    // Simulate API call to analyze the image
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    // TODO: Replace with actual API call to your backend
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _diseaseName = 'Tomato Blight';
        _confidence = '92%';
        _treatment = '''1. Remove and destroy infected leaves and plants
2. Apply copper-based fungicides
3. Improve air circulation
4. Water at the base of plants''';
        _analysisResult = 'Analysis complete';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the selected/taken image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Analysis Results Section
            Text(
              'Analysis Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            if (_isAnalyzing) ..._buildLoadingIndicator(),
            if (!_isAnalyzing) ..._buildResults(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Rescan the plant
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rescan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Save the result
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Scan result saved to history'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Result'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingIndicator() {
    return [
      const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your plant...'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildResults() {
    return [
      // Disease Name
      _buildResultCard(
        context,
        title: 'Disease Detected',
        value: _diseaseName,
        icon: Icons.health_and_safety,
        color: Colors.red,
      ),
      const SizedBox(height: 12),
      
      // Confidence Level
      _buildResultCard(
        context,
        title: 'Confidence',
        value: _confidence,
        icon: Icons.assessment,
        color: Colors.blue,
      ),
      
      const SizedBox(height: 20),
      
      // Treatment Section
      Text(
        'Recommended Treatment',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Text(
          _treatment,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    ];
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
