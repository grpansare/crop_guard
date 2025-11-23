class AppConfig {
  // ========================================
  // 🔧 CONFIGURATION - UPDATE YOUR IP HERE
  // ========================================
  // Your current IP: 10.198.106.66
  // When IP changes, just update this line:
  static const String devIpAddress = '10.167.169.66';

  // Development configuration
  static const String devBaseUrl = 'http://$devIpAddress:8080/api';

  // Production configuration (when you deploy)
  static const String prodBaseUrl = 'https://your-domain.com/api';

  // Current environment
  static const bool isProduction = false;

  // Get current base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // Timeout settings
  static const Duration timeoutDuration = Duration(seconds: 10);

  // ========================================
  // 📝 QUICK IP UPDATE GUIDE
  // ========================================
  // 1. Open PowerShell/CMD
  // 2. Run: ipconfig
  // 3. Find "IPv4 Address" under your WiFi adapter
  // 4. Update devIpAddress above
  // 5. Hot reload the app (press 'r' in terminal)
  // ========================================
}
