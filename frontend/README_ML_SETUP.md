# Crop Disease Detection with Machine Learning

This Flutter app includes crop disease detection using TensorFlow Lite models. The app can identify various plant diseases from images captured via camera or selected from gallery.

## Setup Instructions

### 1. Install Dependencies

Run the following command to install required packages:

```bash
flutter pub get
```

### 2. Add Your TensorFlow Lite Model

1. **Download a pretrained crop disease model** (`.tflite` format)
   - You can use models from TensorFlow Hub, Kaggle, or train your own
   - Popular options:
     - PlantNet models
     - Custom trained models on PlantVillage dataset
     - MobileNet-based plant disease classifiers

2. **Place the model file** in `assets/models/`
   - Rename your model to `plant_disease_model.tflite`
   - Or update the model path in `lib/services/ml_service.dart`

3. **Update labels** (if needed)
   - The current `labels.txt` includes 38 common plant diseases
   - Update this file to match your model's output classes

### 3. Model Requirements

Your TensorFlow Lite model should:
- Accept input images of size 224x224x3 (RGB)
- Output probability scores for each disease class
- Be optimized for mobile inference

### 4. Features Included

- **Camera Integration**: Capture plant images directly
- **Gallery Selection**: Choose existing photos
- **Real-time Inference**: On-device ML processing
- **Disease Information**: Symptoms, treatment, and prevention tips
- **Confidence Scores**: Multiple prediction results with confidence levels
- **User-friendly UI**: Clean, intuitive interface

### 5. Supported Diseases (Current Labels)

The app currently supports detection of diseases in:
- **Apple**: Scab, Black rot, Cedar apple rust
- **Corn**: Cercospora leaf spot, Common rust, Northern Leaf Blight
- **Grape**: Black rot, Esca, Leaf blight
- **Tomato**: Bacterial spot, Early blight, Late blight, Leaf Mold, etc.
- **Potato**: Early blight, Late blight
- **And many more...**

### 6. Customization

#### Adding New Diseases
1. Update `assets/models/labels.txt` with new disease names
2. Retrain or use a model that supports the new diseases
3. Update disease information in `lib/services/ml_service.dart`:
   - `_getSymptoms()` method
   - `_getTreatment()` method
   - `_getPrevention()` method

#### Changing Model Input Size
1. Update `_inputSize` constant in `MLService`
2. Ensure your model accepts the new input dimensions

### 7. Performance Tips

- **Model Size**: Keep models under 50MB for better performance
- **Quantization**: Use quantized models (int8) for faster inference
- **Image Quality**: Higher resolution images may improve accuracy but slow down processing
- **Preprocessing**: The app automatically resizes and normalizes images

### 8. Fallback Behavior

If the TensorFlow Lite model fails to load:
- The app will show mock predictions for demonstration
- All UI functionality remains available
- Users can still capture and process images

### 9. Integration with Backend

The disease detection works entirely on-device and doesn't require the Spring Boot backend. However, you can:
- Save detection results to the backend
- Sync detection history across devices
- Get expert consultations for severe cases

### 10. Testing

1. **Test with sample images** of diseased plants
2. **Verify confidence scores** are reasonable
3. **Check disease information** displays correctly
4. **Test camera and gallery** functionality

## Troubleshooting

### Common Issues

1. **Model not loading**
   - Ensure the model file exists in `assets/models/`
   - Check the model format is `.tflite`
   - Verify the model path in `MLService`

2. **Poor predictions**
   - Use clear, well-lit images
   - Focus on affected plant parts
   - Ensure the model supports the plant type

3. **App crashes during inference**
   - Check model input/output dimensions
   - Verify image preprocessing steps
   - Monitor memory usage with large models

### Getting Models

**Free Sources:**
- TensorFlow Hub: https://tfhub.dev/
- Kaggle Datasets: https://www.kaggle.com/datasets
- PlantNet API models
- Academic research papers with shared models

**Training Your Own:**
- Use PlantVillage dataset
- TensorFlow Lite Model Maker
- Transfer learning with MobileNet
- Quantization for mobile optimization

## Next Steps

1. **Add more plant types** and diseases
2. **Implement result saving** to local storage
3. **Add expert consultation** features
4. **Include treatment reminders** and tracking
5. **Offline map integration** for nearby agricultural stores

For technical support or questions about the ML integration, refer to the TensorFlow Lite Flutter documentation or the app's ML service implementation.
