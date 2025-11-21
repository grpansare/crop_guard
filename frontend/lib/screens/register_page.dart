import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'USER';
  File? _selectedDocument;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join CropGuard',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // Registration Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Full Name Field
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Mobile Number Field
                          TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (value.length < 10) {
                                return 'Mobile number must be at least 10 digits';
                              }
                              if (value.length > 15) {
                                return 'Mobile number must not exceed 15 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Field (only for experts)
                          if (_selectedRole == 'EXPERT')
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address *',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (_selectedRole == 'EXPERT') {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required for experts';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                }
                                return null;
                              },
                            ),
                          if (_selectedRole == 'EXPERT')
                            const SizedBox(height: 16),

                          // Role Selection
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Register as',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'USER',
                                child: Text('Farmer'),
                              ),
                              DropdownMenuItem(
                                value: 'EXPERT',
                                child: Text('Crop Disease Expert'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue ?? 'USER';
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          if (_selectedRole == 'EXPERT') ...[
                            TextFormField(
                              controller: _specializationController,
                              decoration: const InputDecoration(
                                labelText: 'Specialization *',
                                hintText:
                                    'e.g., Tomato Diseases, Pest Management, Organic Farming',
                                prefixIcon: Icon(Icons.school),
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (_selectedRole == 'EXPERT') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Specialization is required for experts';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Please provide more detailed specialization';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Document Upload Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Certification Document *',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Upload your professional certification or license',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_selectedDocument != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Document selected: ${_selectedDocument!.path.split('/').last}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedDocument = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _pickDocument,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Select Document'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress for smaller file size
      );

      if (pickedFile != null) {
        setState(() {
          _selectedDocument = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Additional validation for experts
      if (_selectedRole == 'EXPERT') {
        if (_selectedDocument == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please upload your certification document'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Call the auth service to register
        // For experts, pass the document file (it will be Base64 encoded by AuthService)
        await AuthService.register(
          _fullNameController.text.trim(),
          _mobileController.text.trim(),
          _passwordController.text,
          _selectedRole,
          _selectedRole == 'EXPERT'
              ? _specializationController.text.trim()
              : null,
          _selectedRole == 'EXPERT' ? _emailController.text.trim() : null,
          _selectedRole == 'EXPERT' ? _selectedDocument : null,
        );

        if (mounted) {
          // Show success message
          // Show success message based on role
          String successMessage = 'Registration successful! Please login.';
          if (_selectedRole == 'EXPERT') {
            successMessage =
                'Registration successful! Admin will approve your account. Please login.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate back to login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          String errorMessage = 'Registration failed';
          final errorStr = e.toString();
          print('Registration error details: $errorStr');

          if (errorStr.contains('Exception: ')) {
            errorMessage = errorStr.replaceAll('Exception: ', '');
          } else if (errorStr.contains('message')) {
            errorMessage = errorStr;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
