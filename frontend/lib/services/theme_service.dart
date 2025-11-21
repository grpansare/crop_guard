import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Theme change notifier
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  // Theme data
  static const String _themeKey = 'theme_mode';

  // Initialize theme from saved preferences
  Future<void> initTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey) ?? 'system';
      setThemeMode(savedTheme, notify: false);
    } catch (e) {
      debugPrint('Error loading saved theme: $e');
    }
  }

  // Set theme mode and save to preferences
  Future<void> setThemeMode(String themeMode, {bool notify = true}) async {
    ThemeMode newThemeMode;
    switch (themeMode) {
      case 'light':
        newThemeMode = ThemeMode.light;
        break;
      case 'dark':
        newThemeMode = ThemeMode.dark;
        break;
      default:
        newThemeMode = ThemeMode.system;
    }

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }

    // Update theme notifier
    if (notify) {
      themeNotifier.value = newThemeMode;
    } else {
      themeNotifier.value = newThemeMode;
    }
  }

  // Get current theme mode name
  String getCurrentThemeModeName() {
    switch (themeNotifier.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.light,
      ),
      primaryColor: const Color(0xFF4CAF50),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Get dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
      ),
      primaryColor: const Color(0xFF4CAF50),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white60),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white70),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white70),
        labelSmall: TextStyle(color: Colors.white60),
      ),
    );
  }

  // Get theme data based on current mode
  ThemeData getThemeData(BuildContext context) {
    switch (themeNotifier.value) {
      case ThemeMode.light:
        return getLightTheme();
      case ThemeMode.dark:
        return getDarkTheme();
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? getDarkTheme()
            : getLightTheme();
    }
  }

  // Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    switch (themeNotifier.value) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final currentMode = themeNotifier.value;
    if (currentMode == ThemeMode.system) {
      await setThemeMode('dark');
    } else if (currentMode == ThemeMode.dark) {
      await setThemeMode('light');
    } else {
      await setThemeMode('system');
    }
  }

  // Get theme mode options
  static List<Map<String, String>> getThemeOptions() {
    return [
      {
        'value': 'light',
        'label': 'Light',
        'description': 'Always use light theme',
      },
      {
        'value': 'dark',
        'label': 'Dark',
        'description': 'Always use dark theme',
      },
      {
        'value': 'system',
        'label': 'System',
        'description': 'Follow system setting',
      },
    ];
  }
}

// Theme toggle widget
class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeNotifier,
      builder: (context, themeMode, child) {
        return IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark
                ? Icons.light_mode
                : themeMode == ThemeMode.light
                ? Icons.dark_mode
                : Icons.brightness_auto,
          ),
          onPressed: () {
            ThemeService().toggleTheme();
          },
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}

// Theme selection dialog
class ThemeSelectionDialog extends StatefulWidget {
  const ThemeSelectionDialog({super.key});

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  final ThemeService _themeService = ThemeService();
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeService.getCurrentThemeModeName().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final themeOptions = ThemeService.getThemeOptions();

    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: themeOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option['label']!),
            subtitle: Text(option['description']!),
            value: option['value']!,
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _themeService.setThemeMode(_selectedTheme);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// Theme preview widget
class ThemePreviewWidget extends StatelessWidget {
  final String themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewWidget({
    super.key,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeMode == 'dark'
        ? ThemeService.getDarkTheme()
        : ThemeService.getLightTheme();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Theme(
            data: theme,
            child: Container(
              width: 120,
              height: 160,
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  // App bar
                  Container(
                    height: 40,
                    color: theme.appBarTheme.backgroundColor,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(
                          Icons.menu,
                          color: theme.appBarTheme.foregroundColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'App',
                          style: TextStyle(
                            color: theme.appBarTheme.foregroundColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 80,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 60,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 40,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 16,
                            width: 100,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(4),
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
        ),
      ),
    );
  }
}
