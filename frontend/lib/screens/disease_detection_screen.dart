import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../services/ml_service.dart';
import 'disease_result_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final MLService _mlService = MLService();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMLService();
  }

  Future<void> _initializeMLService() async {
    setState(() => _isLoading = true);
    try {
      await _mlService.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Error initializing ML service: $e');
      setState(() => _isInitialized = true); // Continue with mock predictions
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('Camera Error', 'Failed to capture image: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('Gallery Error', 'Failed to select image: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isLoading = true);

    try {
      final result = await _mlService.predictDisease(imageFile);

      if (mounted) {
        final scanResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DiseaseResultScreen(imageFile: imageFile, result: result),
          ),
        );

        // If scan was saved, return to dashboard with result
        if (scanResult == true && mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showErrorDialog('Prediction Error', 'Failed to analyze image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Crop Disease Detection',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take a photo or select an image of your plant to identify potential diseases',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Camera Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: _isInitialized
                                ? _captureFromCamera
                                : null,
                            icon: const Icon(Icons.camera_alt, size: 28),
                            label: const Text(
                              'Take Photo',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gallery Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: _isInitialized
                                ? _selectFromGallery
                                : null,
                            icon: const Icon(Icons.photo_library, size: 28),
                            label: const Text(
                              'Choose from Gallery',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Instructions
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for better results:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('• Ensure good lighting'),
                          const Text('• Focus on affected leaves or parts'),
                          const Text('• Avoid blurry images'),
                          const Text('• Include the entire leaf if possible'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
