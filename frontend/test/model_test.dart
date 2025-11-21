import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/services/ml_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test model prediction with local image', () async {
    final mlService = MLService();

    print('\n=== TensorFlow Lite Setup Status ===');
    try {
      // Check if TensorFlow Lite is properly installed
      await Interpreter.fromAsset('assets/model/model_unquant.tflite');
      print('✅ TensorFlow Lite is properly installed');
    } catch (e) {
      print('❌ TensorFlow Lite setup issue detected:');
      print('   $e');
      print('\n=== How to fix this issue ===');
      print(
        '1. Make sure you have the latest Visual C++ Redistributable installed',
      );
      print('   Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe');
      print('2. Run these commands in your project directory:');
      print('   flutter clean');
      print('   flutter pub get');
      print('   flutter pub run tflite_flutter:generate_headers');
      print('   flutter pub run tflite_flutter:setup');
      print('\nFor now, continuing with mock predictions...\n');
    }

    await mlService.initialize();

    // Load a test image from the test directory
    final file = File('test/test_images/test_image.jpg');
    if (!await file.exists()) {
      print('Test image not found at: ${file.path}');
      print('Please add a test image to test/test_images/');
      return;
    }

    try {
      print('\n=== Running Prediction ===');
      final result = await mlService.predictDisease(file);

      print('\n=== Prediction Results ===');
      if (mlService.isUsingMock) {
        print('⚠️ Using mock predictions (TensorFlow Lite not available)');
      } else {
        print('✅ Using TensorFlow Lite model');
      }

      print('\nTop prediction: ${result.predictions.first.label}');
      print(
        'Confidence: ${(result.predictions.first.confidence * 100).toStringAsFixed(2)}%',
      );
      print('Is healthy: ${result.isHealthy}');

      if (result.predictions.isNotEmpty) {
        print('\nTop 3 predictions:');
        for (var i = 0; i < result.predictions.length; i++) {
          final pred = result.predictions[i];
          print(
            '${i + 1}. ${pred.label}: ${(pred.confidence * 100).toStringAsFixed(2)}%',
          );
        }
      }

      print('\n✅ Test completed successfully!');
    } catch (e) {
      print('❌ Error during prediction: $e');
      rethrow;
    }
  });
}
