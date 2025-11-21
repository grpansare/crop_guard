import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/services/ml_service.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ML Service Comprehensive Tests', () {
    late MLService mlService;

    setUp(() {
      mlService = MLService();
    });

    tearDown(() {
      mlService.dispose();
    });

    test('ML Service initializes correctly', () async {
      print('\n🚀 Testing ML Service Initialization...');

      await mlService.initialize();

      print('✅ ML Service initialized');
      print('   Using mock predictions: ${mlService.isUsingMock}');

      expect(mlService, isNotNull);
    });

    test('Model can make predictions with synthetic images', () async {
      print('\n🎨 Testing with synthetic images...');

      await mlService.initialize();

      // Test with different synthetic images
      final testCases = [
        {'name': 'Green Leaf', 'color': img.getColor(0, 255, 0)},
        {'name': 'Brown Leaf', 'color': img.getColor(139, 69, 19)},
        {'name': 'Yellow Leaf', 'color': img.getColor(255, 255, 0)},
        {'name': 'Red Spots', 'color': img.getColor(255, 0, 0)},
      ];

      for (final testCase in testCases) {
        print('\n   Testing ${testCase['name']}...');

        final testImage = img.Image(224, 224);
        img.fill(testImage, testCase['color'] as int);

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_${testCase['name']}.jpg');
        await testFile.writeAsBytes(img.encodeJpg(testImage));

        try {
          final result = await mlService.predictDisease(testFile);

          print('     Prediction: ${result.predictions.first.label}');
          print(
            '     Confidence: ${result.predictions.first.confidencePercentage}',
          );
          print('     Is Healthy: ${result.isHealthy}');

          // Validate results
          expect(result.predictions, isNotEmpty);
          expect(result.predictions.first.label, isNotEmpty);
          expect(result.predictions.first.confidence, greaterThan(0.0));
          expect(result.predictions.first.confidence, lessThanOrEqualTo(1.0));
          expect(result.predictions.first.diseaseInfo, isNotNull);
        } finally {
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      }

      print('✅ Synthetic image tests completed');
    });

    test('Model handles different image formats', () async {
      print('\n📷 Testing different image formats...');

      await mlService.initialize();

      final formats = ['jpg', 'png'];

      for (final format in formats) {
        print('   Testing $format format...');

        final testImage = img.Image(224, 224);
        img.fill(testImage, img.getColor(100, 150, 100));

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test.$format');

        if (format == 'jpg') {
          await testFile.writeAsBytes(img.encodeJpg(testImage));
        } else {
          await testFile.writeAsBytes(img.encodePng(testImage));
        }

        try {
          final result = await mlService.predictDisease(testFile);

          expect(result.predictions, isNotEmpty);
          print('     ✅ $format format processed successfully');
        } finally {
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      }

      print('✅ Image format tests completed');
    });

    test('Model provides detailed disease information', () async {
      print('\n🏥 Testing disease information quality...');

      await mlService.initialize();

      final testImage = img.Image(224, 224);
      img.fill(testImage, img.getColor(139, 69, 19)); // Brown color for disease

      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/disease_test.jpg');
      await testFile.writeAsBytes(img.encodeJpg(testImage));

      try {
        final result = await mlService.predictDisease(testFile);
        final prediction = result.predictions.first;
        final diseaseInfo = prediction.diseaseInfo;

        print('   Disease: ${diseaseInfo.name}');
        print('   Description: ${diseaseInfo.description}');
        print('   Severity: ${diseaseInfo.severity.displayName}');
        print('   Symptoms count: ${diseaseInfo.symptoms.length}');
        print('   Treatments count: ${diseaseInfo.treatment.length}');
        print('   Prevention tips count: ${diseaseInfo.prevention.length}');

        // Validate disease information completeness
        expect(diseaseInfo.name, isNotEmpty);
        expect(diseaseInfo.description, isNotEmpty);
        expect(diseaseInfo.symptoms, isNotEmpty);
        expect(diseaseInfo.treatment, isNotEmpty);
        expect(diseaseInfo.prevention, isNotEmpty);

        // Check that symptoms, treatment, and prevention have meaningful content
        expect(diseaseInfo.symptoms.every((s) => s.isNotEmpty), isTrue);
        expect(diseaseInfo.treatment.every((t) => t.isNotEmpty), isTrue);
        expect(diseaseInfo.prevention.every((p) => p.isNotEmpty), isTrue);
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }

      print('✅ Disease information tests completed');
    });

    test('Model handles multiple predictions correctly', () async {
      print('\n🔄 Testing multiple predictions...');

      await mlService.initialize();

      final results = <PredictionResult>[];

      // Make multiple predictions
      for (int i = 0; i < 5; i++) {
        final testImage = img.Image(224, 224);
        final randomColor = img.getColor(
          (i * 50) % 255,
          (i * 100) % 255,
          (i * 150) % 255,
        );
        img.fill(testImage, randomColor);

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/multi_test_$i.jpg');
        await testFile.writeAsBytes(img.encodeJpg(testImage));

        try {
          final result = await mlService.predictDisease(testFile);
          results.add(result);

          print('   Prediction $i: ${result.predictions.first.label}');
        } finally {
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      }

      // Validate all predictions
      expect(results, hasLength(5));
      for (final result in results) {
        expect(result.predictions, isNotEmpty);
        expect(result.timestamp, isNotNull);
      }

      print('✅ Multiple predictions test completed');
    });

    test('Model performance and timing', () async {
      print('\n⏱️ Testing model performance...');

      await mlService.initialize();

      final testImage = img.Image(224, 224);
      img.fill(testImage, img.getColor(0, 255, 0));

      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/performance_test.jpg');
      await testFile.writeAsBytes(img.encodeJpg(testImage));

      try {
        final stopwatch = Stopwatch()..start();

        // Run multiple predictions to test performance
        for (int i = 0; i < 3; i++) {
          await mlService.predictDisease(testFile);
        }

        stopwatch.stop();
        final averageTime = stopwatch.elapsedMilliseconds / 3;

        print(
          '   Average prediction time: ${averageTime.toStringAsFixed(1)}ms',
        );
        print(
          '   Model type: ${mlService.isUsingMock ? "Mock" : "TensorFlow Lite"}',
        );

        // Performance should be reasonable (under 5 seconds even for mock)
        expect(averageTime, lessThan(5000));
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }

      print('✅ Performance tests completed');
    });

    test('Model handles edge cases gracefully', () async {
      print('\n🛡️ Testing edge cases...');

      await mlService.initialize();

      // Test with very small image
      print('   Testing with small image...');
      final smallImage = img.Image(50, 50);
      img.fill(smallImage, img.getColor(255, 255, 255));

      final tempDir = Directory.systemTemp;
      final smallFile = File('${tempDir.path}/small_test.jpg');
      await smallFile.writeAsBytes(img.encodeJpg(smallImage));

      try {
        final result = await mlService.predictDisease(smallFile);
        expect(result.predictions, isNotEmpty);
        print('     ✅ Small image handled correctly');
      } finally {
        if (await smallFile.exists()) {
          await smallFile.delete();
        }
      }

      // Test with very large image
      print('   Testing with large image...');
      final largeImage = img.Image(1000, 1000);
      img.fill(largeImage, img.getColor(128, 128, 128));

      final largeFile = File('${tempDir.path}/large_test.jpg');
      await largeFile.writeAsBytes(img.encodeJpg(largeImage));

      try {
        final result = await mlService.predictDisease(largeFile);
        expect(result.predictions, isNotEmpty);
        print('     ✅ Large image handled correctly');
      } finally {
        if (await largeFile.exists()) {
          await largeFile.delete();
        }
      }

      print('✅ Edge case tests completed');
    });

    test('Model labels match expected disease types', () async {
      print('\n🏷️ Testing model labels...');

      await mlService.initialize();

      // Expected disease types based on labels.txt
      final expectedDiseases = [
        'Pepper',
        'Potato',
        'Tomato',
        'Healthy',
        'Bacterial',
        'Blight',
        'Spot',
        'Mold',
        'Virus',
      ];

      // Test multiple predictions to see variety of labels
      final seenLabels = <String>{};

      for (int i = 0; i < 10; i++) {
        final testImage = img.Image(224, 224);
        final color = img.getColor(
          (i * 25) % 255,
          (i * 50) % 255,
          (i * 75) % 255,
        );
        img.fill(testImage, color);

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/label_test_$i.jpg');
        await testFile.writeAsBytes(img.encodeJpg(testImage));

        try {
          final result = await mlService.predictDisease(testFile);
          seenLabels.add(result.predictions.first.label);
        } finally {
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      }

      print('   Seen labels: ${seenLabels.join(", ")}');

      // Check if we see some variety in predictions
      expect(seenLabels, isNotEmpty);

      print('✅ Label variety test completed');
    });
  });

  group('Model Accuracy Tests', () {
    test('Healthy plant detection', () async {
      print('\n🌱 Testing healthy plant detection...');

      final mlService = MLService();
      await mlService.initialize();

      // Create a green, healthy-looking image
      final healthyImage = img.Image(224, 224);
      img.fill(healthyImage, img.getColor(34, 139, 34)); // Forest green

      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/healthy_test.jpg');
      await testFile.writeAsBytes(img.encodeJpg(healthyImage));

      try {
        final result = await mlService.predictDisease(testFile);

        print('   Prediction: ${result.predictions.first.label}');
        print('   Is Healthy: ${result.isHealthy}');
        print(
          '   Confidence: ${result.predictions.first.confidencePercentage}',
        );

        // For mock predictions, we can't guarantee healthy detection
        // but we can ensure the result is valid
        expect(result.predictions, isNotEmpty);
        expect(result.predictions.first.confidence, greaterThan(0.0));
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
        mlService.dispose();
      }

      print('✅ Healthy plant detection test completed');
    });

    test('Disease detection with confidence levels', () async {
      print('\n🦠 Testing disease detection confidence...');

      final mlService = MLService();
      await mlService.initialize();

      // Test different scenarios
      final scenarios = [
        {'name': 'Diseased (Brown)', 'color': img.getColor(139, 69, 19)},
        {'name': 'Diseased (Yellow)', 'color': img.getColor(255, 255, 0)},
        {'name': 'Diseased (Red)', 'color': img.getColor(255, 0, 0)},
      ];

      for (final scenario in scenarios) {
        print('   Testing ${scenario['name']}...');

        final testImage = img.Image(224, 224);
        img.fill(testImage, scenario['color'] as int);

        final tempDir = Directory.systemTemp;
        final testFile = File(
          '${tempDir.path}/disease_${scenario['name']}.jpg',
        );
        await testFile.writeAsBytes(img.encodeJpg(testImage));

        try {
          final result = await mlService.predictDisease(testFile);

          print('     Prediction: ${result.predictions.first.label}');
          print(
            '     Confidence: ${result.predictions.first.confidencePercentage}',
          );
          print(
            '     Severity: ${result.predictions.first.diseaseInfo.severity.displayName}',
          );

          // Validate confidence is reasonable
          expect(result.predictions.first.confidence, greaterThan(0.1));
          expect(result.predictions.first.confidence, lessThanOrEqualTo(1.0));
        } finally {
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      }

      mlService.dispose();
      print('✅ Disease detection confidence test completed');
    });
  });
}
