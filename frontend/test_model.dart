import 'dart:io';
import 'lib/services/ml_service.dart';

void main() async {
  print('Testing ML Service initialization...');
  
  final mlService = MLService();
  
  try {
    await mlService.initialize();
    print('✅ ML Service initialized successfully!');
    print('🤖 Model loaded and ready for predictions');
    
    // Test with a dummy file path (won't actually run inference without real image)
    print('📱 Disease detection system is ready to use in the app');
    
  } catch (e) {
    print('❌ Error during initialization: $e');
    print('🔄 App will fall back to mock predictions');
  }
  
  print('\n🚀 You can now run: flutter run');
  print('📸 Use "Scan Plant" feature in the farmer dashboard');
}
