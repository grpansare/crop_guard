import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_disease_app/services/language_service.dart';
import 'package:crop_disease_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  // Settings preferences
  bool _notificationsEnabled = true;
  bool _diseaseAlertsEnabled = true;
  bool _weeklyReportsEnabled = true;

  bool _highQualityImages = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSettings();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    // TODO: Load settings from SharedPreferences or API
    // For now, using default values
  }

  Future<void> _saveSettings() async {
    // TODO: Save settings to SharedPreferences or API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildNotificationsSection(),
                  const SizedBox(height: 24),

                  // App Preferences Section
                  _buildAppPreferencesSection(),
                  const SizedBox(height: 24),

                  // Account Section
                  _buildAccountSection(),
                  const SizedBox(height: 24),

                  // About Section
                  _buildAboutSection(),
                ],
              ),
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
            Text(
              'Profile',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    (_userProfile?['fullName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile?['fullName'] ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _userProfile?['mobile'] ?? 'No mobile',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userProfile?['role'] ?? 'USER',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editProfile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  if (!value) {
                    _diseaseAlertsEnabled = false;
                    _weeklyReportsEnabled = false;
                  }
                });
              },
            ),
            SwitchListTile(
              title: const Text('Disease Alerts'),
              subtitle: const Text(
                'Get notified about critical disease detections',
              ),
              value: _diseaseAlertsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _diseaseAlertsEnabled = value;
                      });
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Weekly Reports'),
              subtitle: const Text('Receive weekly summary reports'),
              value: _weeklyReportsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _weeklyReportsEnabled = value;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.appPreferences,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectLanguage,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.theme),
              subtitle: Text(_selectedTheme),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectTheme,
            ),
            SwitchListTile(
              title: const Text('High Quality Images'),
              subtitle: const Text('Use higher resolution for better accuracy'),
              value: _highQualityImages,
              onChanged: (value) {
                setState(() {
                  _highQualityImages = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showTermsOfService,
            ),
            ListTile(
              title: const Text('Delete Account'),
              titleTextStyle: const TextStyle(color: Colors.red),
              trailing: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: _deleteAccount,
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
            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.help_outline),
              onTap: _showHelp,
            ),
            ListTile(
              title: const Text('Rate App'),
              trailing: const Icon(Icons.star_outline),
              onTap: _rateApp,
            ),
            ListTile(
              title: const Text('Contact Us'),
              trailing: const Icon(Icons.email_outlined),
              onTap: _contactUs,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(
          text: _userProfile?['fullName'],
        );
        final mobileController = TextEditingController(
          text: _userProfile?['mobile'],
        );

        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile update feature coming soon!'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _selectLanguage() {
    final languages = {
      'English': '🇺🇸 English',
      'Hindi': '🇮🇳 हिंदी (Hindi)',
      'Marathi': '🇮🇳 मराठी (Marathi)',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.entries
                .map(
                  (entry) => RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      Navigator.of(context).pop();
                      _changeAppLanguage(value!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${entry.value}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeAppLanguage(String language) async {
    // Use the language service to change language
    try {
      final languageService = LanguageService();
      await languageService.setLanguage(language);
      
      // Update the UI to reflect the language change
      setState(() {
        _selectedLanguage = language;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.languageChanged),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error changing language: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing language: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectTheme() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['System', 'Light', 'Dark']
                .map(
                  (theme) => RadioListTile<String>(
                    title: Text(theme),
                    value: theme,
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    bool isPasswordVisible = false;
    bool isLoading = false;
    String? errorMessage;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Validate inputs
                          if (currentPasswordController.text.isEmpty ||
                              newPasswordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            setState(() {
                              errorMessage = 'All fields are required';
                            });
                            return;
                          }
                          
                          if (newPasswordController.text.length < 6) {
                            setState(() {
                              errorMessage = 'New password must be at least 6 characters';
                            });
                            return;
                          }
                          
                          if (newPasswordController.text != confirmPasswordController.text) {
                            setState(() {
                              errorMessage = 'New passwords do not match';
                            });
                            return;
                          }
                          
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          
                          try {
                            await AuthService.changePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                            
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = e.toString().contains('Current password is incorrect')
                                  ? 'Current password is incorrect'
                                  : 'Failed to change password. Please try again.';
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy feature coming soon!')),
    );
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service feature coming soon!')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion feature coming soon!'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support feature coming soon!')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate App feature coming soon!')),
    );
  }

  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Us feature coming soon!')),
    );
  }
}
