import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/services/ml_service.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MLService initializes correctly', () async {
    final mlService = MLService();
    await mlService.initialize();
    expect(mlService, isNotNull);
    print(' ML Service test completed successfully');
  });

  test('Model makes prediction on sample image', () async {
    // Initialize the service
    final mlService = MLService();
    await mlService.initialize();

    // Load a sample image from assets
    final byteData = await rootBundle.load('assets/model/sample_image.jpg');
    final bytes = byteData.buffer.asUint8List();

    // Convert to image and resize
    final image = img.decodeImage(bytes)!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Make prediction
    try {
      final prediction = await mlService.predict(resizedImage);

      // Verify prediction format
      expect(prediction, isNotNull);
      expect(prediction.isNotEmpty, true);

      print('\nModel Prediction Results:');
      prediction.forEach((key, value) {
        print('$key: ${(value * 100).toStringAsFixed(2)}%');
      });

      print(' Model prediction test completed successfully');
    } catch (e) {
      print(' Error during prediction: $e');
      rethrow;
    }
  });
}
