# Adding a TensorFlow Lite Model for Crop Disease Detection

## Quick Start

The app is currently configured to work with mock predictions. To add a real TensorFlow Lite model:

### Step 1: Get a Model

**Option A: Download a Pre-trained Model**
```bash
# Example: Download from a public repository
# Replace this URL with an actual model URL
wget https://example.com/plant_disease_model.tflite -O assets/models/plant_disease_model.tflite
```

**Option B: Use a Popular Model**
- **PlantNet Model**: Search for PlantNet TensorFlow Lite models
- **PlantVillage Dataset Models**: Look for models trained on the PlantVillage dataset
- **TensorFlow Hub**: Browse https://tfhub.dev/ for plant classification models
- **Kaggle**: Check https://www.kaggle.com/datasets for crop disease models

### Step 2: Model Requirements

Your `.tflite` model should:
- **Input**: 224x224x3 RGB images (normalized 0-1)
- **Output**: Probability scores for each disease class
- **Size**: Preferably under 50MB for mobile performance
- **Format**: TensorFlow Lite (.tflite)

### Step 3: Replace the Placeholder

1. Download your model file
2. Replace `assets/models/plant_disease_model.tflite` with your model
3. Update `assets/models/labels.txt` if your model has different classes

### Step 4: Test the Integration

```bash
flutter pub get
flutter run
```

The app will automatically detect and use your model!

## Model Sources

### Free Models
1. **TensorFlow Hub**
   - Search for "plant disease" or "crop classification"
   - Download as TensorFlow Lite format

2. **Kaggle Datasets**
   - PlantVillage dataset models
   - Community-contributed models

3. **Research Papers**
   - Many papers provide downloadable models
   - Check supplementary materials

### Creating Your Own Model

If you want to train your own model:

```python
# Example using TensorFlow
import tensorflow as tf

# Load your dataset (e.g., PlantVillage)
# Train your model
# Convert to TensorFlow Lite

converter = tf.lite.TFLiteConverter.from_saved_model('your_model')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('plant_disease_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Supported Disease Classes

The current labels support 38+ diseases including:

**Crops**: Apple, Corn, Grape, Tomato, Potato, Cherry, Peach, Pepper, Strawberry, etc.

**Diseases**: Blight, Rust, Scab, Bacterial Spot, Powdery Mildew, etc.

Update `assets/models/labels.txt` to match your model's output classes.

## Performance Tips

- **Quantization**: Use int8 quantized models for faster inference
- **Model Size**: Keep under 50MB for better app performance  
- **Input Size**: 224x224 is optimal for mobile devices
- **Preprocessing**: The app handles image resizing and normalization

## Troubleshooting

**Model not loading?**
- Check file path: `assets/models/plant_disease_model.tflite`
- Verify model format is `.tflite`
- Check model input/output shapes

**Poor predictions?**
- Ensure good image quality
- Check if model supports your plant types
- Verify labels match model output

**App crashes?**
- Model might be too large
- Check memory usage
- Try a smaller/quantized model

The app gracefully falls back to mock predictions if the model fails to load.
