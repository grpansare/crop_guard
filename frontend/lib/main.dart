import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/farmer_dashboard.dart';
import 'screens/expert_dashboard.dart';
import 'screens/admin_expert_verification_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/test_api_screen.dart';
import 'screens/disease_detection_screen.dart';
import 'screens/admin_agri_stores_screen.dart';
import 'screens/farmer_agri_stores_map_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/offline_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final languageService = LanguageService();
  await languageService.initLanguage();

  final themeService = ThemeService();
  await themeService.initTheme();

  final offlineService = OfflineService();
  await offlineService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const CropDiseaseApp());
}

class CropDiseaseApp extends StatefulWidget {
  const CropDiseaseApp({super.key});

  @override
  State<CropDiseaseApp> createState() => _CropDiseaseAppState();
}

class _CropDiseaseAppState extends State<CropDiseaseApp> {
  final LanguageService _languageService = LanguageService();
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    // Listen for language changes
    _languageService.localeNotifier.addListener(_onLocaleChange);
    // Listen for theme changes
    _themeService.themeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    _languageService.localeNotifier.removeListener(_onLocaleChange);
    _themeService.themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onLocaleChange() {
    setState(() {
      // This will trigger a rebuild with the new locale
    });
  }

  void _onThemeChange() {
    setState(() {
      // This will trigger a rebuild with the new theme
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reduce memory usage for graphics buffer (optional)
    SystemChannels.skia.invokeMethod('Skia.setResourceCacheMaxBytes', 1 << 20);

    return MaterialApp(
      title: 'CropGuard',
      debugShowCheckedModeBanner: false,

      // Internationalization configuration
      locale: _languageService.localeNotifier.value,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('mr'), // Marathi
        Locale('te'), // Telugu
        Locale('ta'), // Tamil
      ],

      theme: ThemeService.getLightTheme(),
      darkTheme: ThemeService.getDarkTheme(),
      themeMode: _themeService.themeNotifier.value,
      // Start with splash
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const FarmerDashboard(),
        '/admin/experts': (context) => const AdminExpertVerificationScreen(),
        '/expert-dashboard': (context) => const ExpertDashboard(),
        '/test-api': (context) => const TestApiScreen(),
        '/disease-detection': (context) => const DiseaseDetectionScreen(),
        '/admin/agri-stores': (context) {
          // Import added at top
          return const AdminAgriStoresScreen();
        },
        '/farmer/agri-stores': (context) {
          // Import added at top
          return const FarmerAgriStoresMapScreen();
        },
        '/scan-result': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return ScanResultScreen(
            imagePath: args['imagePath'] ?? '',
            isGallery: args['isGallery'] ?? false,
          );
        },
      },
    );
  }
}
