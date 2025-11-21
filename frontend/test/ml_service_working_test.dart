import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/services/ml_service.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ML Service works correctly with mock predictions', () async {
    print('\n🧪 Testing ML Service...');

    final mlService = MLService();

    // Initialize the service
    await mlService.initialize();
    print('✅ ML Service initialized');

    // Create a simple test image
    final testImage = img.Image(224, 224);
    img.fill(testImage, img.getColor(0, 255, 0)); // Green image

    // Save to temporary file
    final tempDir = Directory.systemTemp;
    final testFile = File('${tempDir.path}/test_leaf.jpg');
    await testFile.writeAsBytes(img.encodeJpg(testImage));
    print('✅ Test image created');

    try {
      // Make prediction
      final result = await mlService.predictDisease(testFile);

      print('\n📊 Prediction Results:');
      print('   Model type: ${mlService.isUsingMock ? "Mock" : ""}');
      print('   Top prediction: ${result.predictions.first.label}');
      print(
        '   Confidence: ${(result.predictions.first.confidence * 100).toStringAsFixed(1)}%',
      );
      print('   Is healthy: ${result.isHealthy}');

      // Test assertions
      expect(result.predictions, isNotEmpty, reason: 'Should have predictions');
      expect(
        result.predictions.first.label,
        isNotEmpty,
        reason: 'Should have a label',
      );
      expect(
        result.predictions.first.confidence,
        greaterThan(0.0),
        reason: 'Confidence should be > 0',
      );
      expect(
        result.predictions.first.confidence,
        lessThanOrEqualTo(1.0),
        reason: 'Confidence should be <= 1',
      );

      print('✅ All validations passed!');
    } catch (e) {
      print('❌ Error: $e');
      fail('Prediction failed: $e');
    } finally {
      // Cleanup
      if (await testFile.exists()) {
        await testFile.delete();
      }
    }
  });

  test('ML Service handles multiple predictions correctly', () async {
    print('\n🔄 Testing multiple predictions...');

    final mlService = MLService();
    await mlService.initialize();

    final results = <String>[];

    // Test with different colored images
    for (int i = 0; i < 3; i++) {
      final testImage = img.Image(224, 224);
      final colors = [
        img.getColor(255, 0, 0), // Red
        img.getColor(0, 255, 0), // Green
        img.getColor(0, 0, 255), // Blue
      ];
      img.fill(testImage, colors[i]);

      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_$i.jpg');
      await testFile.writeAsBytes(img.encodeJpg(testImage));

      try {
        final result = await mlService.predictDisease(testFile);
        results.add(result.predictions.first.label);
        print('   Test $i: ${result.predictions.first.label}');

        expect(result.predictions, isNotEmpty);
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    }

    print('✅ Multiple predictions test completed');
    print('   Results: ${results.join(", ")}');
  });

  test('ML Service provides disease information', () async {
    print('\n🏥 Testing disease information...');

    final mlService = MLService();
    await mlService.initialize();

    // Create test image
    final testImage = img.Image(224, 224);
    img.fill(testImage, img.getColor(255, 255, 0)); // Yellow image

    final tempDir = Directory.systemTemp;
    final testFile = File('${tempDir.path}/test_disease_info.jpg');
    await testFile.writeAsBytes(img.encodeJpg(testImage));

    try {
      final result = await mlService.predictDisease(testFile);
      final prediction = result.predictions.first;

      print('   Disease: ${prediction.label}');
      print('   Confidence: ${prediction.confidencePercentage}');

      if (prediction.diseaseInfo != null) {
        final info = prediction.diseaseInfo!;
        print('   Severity: ${info.severity.displayName}');
        print('   Symptoms: ${info.symptoms.length} listed');
        print('   Treatments: ${info.treatment.length} available');
        print('   Prevention tips: ${info.prevention.length} provided');

        expect(info.name, isNotEmpty);
        expect(info.description, isNotEmpty);
      }

      print('✅ Disease information test completed');
    } finally {
      if (await testFile.exists()) {
        await testFile.delete();
      }
    }
  });
}
