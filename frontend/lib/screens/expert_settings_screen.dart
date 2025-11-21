import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/api_service.dart';

class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  // Profile fields
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();

  // Settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _queryAlerts = true;
  bool _caseReviewAlerts = true;
  bool _trendAlerts = true;
  String _language = 'en';
  String _theme = 'light';
  bool _autoSave = true;
  bool _dataSync = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final results = await Future.wait([
        AuthService.getProfile(),
        ApiService.getUserSettings(token),
      ]);

      setState(() {
        _userProfile = results[0];
        _settings = results[1];
        _isLoading = false;
      });

      _populateFields();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_userProfile != null) {
      _nameController.text = _userProfile!['fullName'] ?? '';
      _mobileController.text = _userProfile!['mobile'] ?? '';
      _specializationController.text = _userProfile!['specialization'] ?? '';
      _experienceController.text = _userProfile!['experience']?.toString() ?? '';
    }

    if (_settings.isNotEmpty) {
      final notifications = _settings['notifications'] ?? {};
      final preferences = _settings['preferences'] ?? {};

      setState(() {
        _pushNotifications = notifications['pushNotifications'] ?? true;
        _emailNotifications = notifications['emailNotifications'] ?? false;
        _queryAlerts = notifications['queryAlerts'] ?? true;
        _caseReviewAlerts = notifications['caseReviewAlerts'] ?? true;
        _trendAlerts = notifications['trendAlerts'] ?? true;
        _language = preferences['language'] ?? 'en';
        _theme = preferences['theme'] ?? 'light';
        _autoSave = preferences['autoSave'] ?? true;
        _dataSync = preferences['dataSync'] ?? true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final profileData = {
        'fullName': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
      };

      await ApiService.updateUserProfile(profileData, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final settingsData = {
        'notifications': {
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
          'queryAlerts': _queryAlerts,
          'caseReviewAlerts': _caseReviewAlerts,
          'trendAlerts': _trendAlerts,
        },
        'preferences': {
          'language': _language,
          'theme': _theme,
          'autoSave': _autoSave,
          'dataSync': _dataSync,
        },
      };

      await ApiService.updateUserSettings(settingsData, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Confirm your new password',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await AuthService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildNotificationSection(),
                  const SizedBox(height: 24),
                  _buildPreferenceSection(),
                  const SizedBox(height: 24),
                  _buildSecuritySection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                ],
              ),
            ),
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
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: 'Enter your mobile number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: 'Specialization',
                hintText: 'e.g., Plant Pathology, Entomology',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Years of Experience',
                hintText: 'Enter years of experience',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications on your device'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Query Alerts'),
              subtitle: const Text('Get notified about new farmer queries'),
              value: _queryAlerts,
              onChanged: (value) {
                setState(() {
                  _queryAlerts = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Case Review Alerts'),
              subtitle: const Text('Get notified about pending case reviews'),
              value: _caseReviewAlerts,
              onChanged: (value) {
                setState(() {
                  _caseReviewAlerts = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Trend Alerts'),
              subtitle: const Text('Get notified about disease trends'),
              value: _trendAlerts,
              onChanged: (value) {
                setState(() {
                  _trendAlerts = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Notification Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(
                labelText: 'Language',
              ),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                DropdownMenuItem(value: 'mr', child: Text('Marathi')),
              ],
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _theme,
              decoration: const InputDecoration(
                labelText: 'Theme',
              ),
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) {
                setState(() {
                  _theme = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Save'),
              subtitle: const Text('Automatically save your work'),
              value: _autoSave,
              onChanged: (value) {
                setState(() {
                  _autoSave = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Data Sync'),
              subtitle: const Text('Sync data across devices'),
              value: _dataSync,
              onChanged: (value) {
                setState(() {
                  _dataSync = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Preferences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face recognition'),
              trailing: Switch(
                value: false, // Mock value
                onChanged: (value) {
                  // Mock implementation
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              subtitle: const Text('View our privacy policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Mock implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              subtitle: const Text('View our terms of service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Mock implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Service coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help and contact support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Mock implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
