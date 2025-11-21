import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AskExpertScreen extends StatefulWidget {
  const AskExpertScreen({super.key});

  @override
  State<AskExpertScreen> createState() => _AskExpertScreenState();
}

class _AskExpertScreenState extends State<AskExpertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cropTypeController = TextEditingController();

  String _selectedCategory = 'Disease Identification';
  String _selectedUrgency = 'Medium';
  File? _selectedImage;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Disease Identification',
    'Pest Control',
    'Nutrient Deficiency',
    'Growth Issues',
    'Treatment Advice',
    'Prevention Methods',
    'General Consultation',
  ];

  final List<String> _urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      final image = await picker.pickImage(source: pickedFile);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) {
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
      String? imagePath;

      // Upload image first if selected
      if (_selectedImage != null) {
        print('📸 Uploading image from: ${_selectedImage!.path}');
        try {
          imagePath = await ApiService.uploadImage(_selectedImage!, token);
          print('✅ Image uploaded successfully: $imagePath');
        } catch (e) {
          print('❌ Image upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      final queryData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'cropType': _cropTypeController.text.trim(),
        'category': _selectedCategory,
        'urgency': _selectedUrgency,
        'hasImage': _selectedImage != null,
        'imagePath': imagePath,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await ApiService.createExpertQuery(queryData, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Query submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit query: ${e.toString().replaceAll('Exception: ', '')}',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Expert'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get Expert Help',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Describe your crop issue and our experts will provide personalized advice',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Query Form
              Text(
                'Query Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Query Title *',
                  hintText: 'Brief description of your issue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title for your query';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters long';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Crop Type Field
              TextFormField(
                controller: _cropTypeController,
                decoration: InputDecoration(
                  labelText: 'Crop Type *',
                  hintText: 'e.g., Tomato, Potato, Corn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.agriculture),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please specify the crop type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Urgency Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.priority_high),
                ),
                items: _urgencyLevels.map((urgency) {
                  return DropdownMenuItem(
                    value: urgency,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: _getUrgencyColor(urgency),
                        ),
                        const SizedBox(width: 8),
                        Text(urgency),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUrgency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Detailed Description *',
                  hintText: 'Describe your crop issue in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a detailed description';
                  }
                  if (value.trim().length < 20) {
                    return 'Description must be at least 20 characters long';
                  }
                  return null;
                },
                maxLength: 1000,
              ),
              const SizedBox(height: 16),

              // Image Upload Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Photo (Optional)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a photo of your crop to help experts provide better advice',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.edit),
                              label: const Text('Change Photo'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Remove Photo'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add photo',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            SizedBox(width: 8),
                            Text('Submit Query'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your query will be reviewed by certified crop experts\n'
                      '• You\'ll receive a detailed response within 24-48 hours\n'
                      '• Follow-up questions are welcome\n'
                      '• All consultations are free of charge',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
}
