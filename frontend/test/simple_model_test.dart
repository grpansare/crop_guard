import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/services/ml_service.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test ML Service initialization and prediction', () async {
    print('\n=== Testing ML Service ===');

    final mlService = MLService();
    await mlService.initialize();

    // Create a simple test image (224x224 pixels)
    final testImage = img.Image(224, 224);
    img.fill(testImage, img.getColor(0, 255, 0)); // Green image

    // Save test image to a temporary file
    final tempDir = Directory.systemTemp;
    final testFile = File('${tempDir.path}/test_plant.jpg');
    await testFile.writeAsBytes(img.encodeJpg(testImage));

    try {
      print('🔄 Making prediction...');
      final result = await mlService.predictDisease(testFile);

      print('\n=== Prediction Results ===');
      if (mlService.isUsingMock) {
        print('⚠️  Using mock predictions (TensorFlow Lite not available)');
      } else {
        print('✅ Using real TensorFlow Lite model');
      }

      print('\nTop prediction: ${result.predictions.first.label}');
      print(
        'Confidence: ${(result.predictions.first.confidence * 100).toStringAsFixed(2)}%',
      );
      print('Is healthy: ${result.isHealthy}');
      print('Timestamp: ${result.timestamp}');

      if (result.predictions.length > 1) {
        print('\nAll predictions:');
        for (var i = 0; i < result.predictions.length; i++) {
          final pred = result.predictions[i];
          print(
            '${i + 1}. ${pred.label}: ${(pred.confidence * 100).toStringAsFixed(2)}%',
          );
          if (pred.diseaseInfo != null) {
            print('   Severity: ${pred.diseaseInfo!.severity.displayName}');
          }
        }
      }

      // Verify the result structure
      expect(result.predictions, isNotEmpty);
      expect(result.predictions.first.label, isNotEmpty);
      expect(result.predictions.first.confidence, greaterThan(0.0));
      expect(result.predictions.first.confidence, lessThanOrEqualTo(1.0));

      print('\n✅ All tests passed! ML Service is working correctly.');
    } catch (e) {
      print('❌ Error during prediction: $e');
      rethrow;
    } finally {
      // Clean up test file
      if (await testFile.exists()) {
        await testFile.delete();
      }
    }
  });

  test('Test ML Service with multiple predictions', () async {
    final mlService = MLService();
    await mlService.initialize();

    // Create different colored test images
    final colors = [
      img.getColor(255, 0, 0), // Red
      img.getColor(0, 255, 0), // Green
      img.getColor(0, 0, 255), // Blue
    ];

    for (var i = 0; i < colors.length; i++) {
      final testImage = img.Image(224, 224);
      img.fill(testImage, colors[i]);

      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_plant_$i.jpg');
      await testFile.writeAsBytes(img.encodeJpg(testImage));

      try {
        final result = await mlService.predictDisease(testFile);
        print(
          'Test $i: ${result.predictions.first.label} (${(result.predictions.first.confidence * 100).toStringAsFixed(1)}%)',
        );

        expect(result.predictions, isNotEmpty);
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    }

    print('✅ Multiple prediction test completed successfully!');
  });
}
