# ML Model Testing Guide

This guide explains how to test if your crop disease detection model is working correctly.

## Overview

The ML service supports two modes:
1. **Real TensorFlow Lite Model** - Uses the actual trained model for predictions
2. **Mock Predictions** - Provides intelligent mock predictions for testing and development

## Quick Start

### 1. Run Basic Tests
```bash
# Navigate to the app directory
cd crop_disease_app

# Run quick tests
flutter test test/ml_service_working_test.dart
```

### 2. Run Comprehensive Tests
```bash
# Run all comprehensive tests
flutter test test/comprehensive_ml_test.dart
```

### 3. Use the Test Runner
```bash
# Quick tests
dart test/run_ml_tests.dart quick

# Comprehensive tests
dart test/run_ml_tests.dart comprehensive

# Performance tests only
dart test/run_ml_tests.dart performance

# All tests
dart test/run_ml_tests.dart all
```

## Test Categories

### 🚀 Basic Functionality Tests
- ML Service initialization
- Basic prediction capability
- Error handling

### 🎨 Image Processing Tests
- Different image formats (JPG, PNG)
- Various image sizes (small, large)
- Color analysis and preprocessing

### 🏥 Disease Information Tests
- Prediction accuracy
- Disease information completeness
- Symptom, treatment, and prevention data

### ⏱️ Performance Tests
- Prediction timing
- Memory usage
- Multiple prediction handling

### 🛡️ Edge Case Tests
- Invalid images
- Corrupted files
- Network issues

## Model Status Check

### Check if Real Model is Loading
```dart
final mlService = MLService();
await mlService.initialize();

if (mlService.isUsingMock) {
  print('Using mock predictions - TensorFlow Lite model not loaded');
} else {
  print('Using real TensorFlow Lite model');
}
```

### Expected Diseases
The model can detect these crop diseases:
- Pepper Bell Bacterial Spot
- Pepper Bell Healthy
- Potato Early Blight
- Potato Healthy
- Potato Late Blight
- Tomato Bacterial Spot
- Tomato Early Blight
- Tomato Healthy
- Tomato Late Blight
- Tomato Leaf Mold
- Tomato Septoria Leaf Spot
- Tomato Spotted Spider Mites
- Tomato Target Spot
- Tomato Mosaic Virus
- Tomato Yellow Leaf Curl Virus

## Troubleshooting

### TensorFlow Lite Not Loading
If you see "Using mock predictions", check:

1. **Dependencies**: Ensure `tflite_flutter` is in pubspec.yaml
```yaml
dependencies:
  tflite_flutter: ^0.9.0
```

2. **Model Files**: Verify these files exist:
   - `assets/model/model_unquant.tflite`
   - `assets/model/labels.txt`

3. **Assets Configuration**: Check pubspec.yaml includes:
```yaml
flutter:
  assets:
    - assets/model/
```

4. **Run pub get**:
```bash
flutter pub get
```

### Common Issues

#### "Failed to load model"
- Check if model file exists and is not corrupted
- Verify file permissions
- Ensure model is compatible with tflite_flutter version

#### "Image processing failed"
- Check if image file is valid
- Verify image format is supported (JPG, PNG)
- Ensure image is not corrupted

#### "Prediction timeout"
- Model might be too large for device
- Check device memory availability
- Consider using quantized model

## Performance Benchmarks

### Expected Performance
- **Mock Predictions**: < 100ms
- **Real Model**: 200ms - 2000ms (depending on device)
- **Memory Usage**: < 50MB additional

### Performance Testing
```bash
# Run performance-specific tests
dart test/run_ml_tests.dart performance
```

## Manual Testing

### Test with Real Images
1. Take photos of plant leaves
2. Use the app's camera feature
3. Check prediction results
4. Verify disease information accuracy

### Test Different Scenarios
- Healthy plants (should show "Healthy" prediction)
- Diseased plants (should show specific disease)
- Non-plant images (should handle gracefully)
- Poor lighting conditions
- Blurry images

## Validation Checklist

- [ ] ML Service initializes without errors
- [ ] Can make predictions with synthetic images
- [ ] Handles different image formats
- [ ] Provides detailed disease information
- [ ] Performance is acceptable (< 5 seconds)
- [ ] Edge cases handled gracefully
- [ ] Mock predictions work when model unavailable
- [ ] Real model loads when dependencies available

## Next Steps

### If Tests Pass ✅
- Your ML model is working correctly
- You can proceed with app development
- Consider testing with real plant images

### If Tests Fail ❌
1. Check error messages in test output
2. Verify all dependencies are installed
3. Ensure model files are present
4. Check device compatibility
5. Review troubleshooting section above

## Advanced Testing

### Custom Test Images
Create your own test images:
```dart
// Create test image
final testImage = img.Image(224, 224);
img.fill(testImage, img.getColor(0, 255, 0)); // Green for healthy

// Save and test
final testFile = File('test_image.jpg');
await testFile.writeAsBytes(img.encodeJpg(testImage));

final result = await mlService.predictDisease(testFile);
print('Prediction: ${result.predictions.first.label}');
```

### Model Accuracy Testing
For production use, test with known disease images:
1. Collect labeled disease images
2. Run predictions
3. Compare with expected results
4. Calculate accuracy metrics

## Support

If you encounter issues:
1. Check the test output for specific error messages
2. Review the troubleshooting section
3. Ensure all dependencies are correctly installed
4. Verify model files are present and valid

---

**Happy Testing! 🧪🌱**
