---
name: "Vision & ML"
version: "1.0.0"
description: |
  On-device machine learning and computer vision for Flutter.
  ML Kit, TensorFlow Lite, and Vision patterns.
  Tetikleyiciler: "ml", "ai", "vision", "ocr", "face", "object detection", "tflite"
---

# Flutter Vision & ML

## Amaç
On-device ML/AI için Flutter best practices.

---

## Paket Seçimi

| İhtiyaç | Paket | Platform |
|---------|-------|----------|
| Text Recognition | google_mlkit_text_recognition | iOS, Android |
| Face Detection | google_mlkit_face_detection | iOS, Android |
| Barcode Scanning | google_mlkit_barcode_scanning | iOS, Android |
| Image Labeling | google_mlkit_image_labeling | iOS, Android |
| Object Detection | google_mlkit_object_detection | iOS, Android |
| Pose Detection | google_mlkit_pose_detection | iOS, Android |
| Custom Models | tflite_flutter | iOS, Android |
| Speech to Text | speech_to_text | iOS, Android |

---

## ML Kit Setup

### pubspec.yaml
```yaml
dependencies:
  google_mlkit_text_recognition: ^0.11.0
  google_mlkit_face_detection: ^0.9.0
  google_mlkit_barcode_scanning: ^0.10.0
  camera: ^0.10.5
```

### Android (android/app/build.gradle)
```groovy
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS (ios/Podfile)
```ruby
platform :ios, '12.0'
```

---

## Text Recognition (OCR)

```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  final textRecognizer = TextRecognizer();
  
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }
  
  void dispose() {
    textRecognizer.close();
  }
}
```

---

## Face Detection

```dart
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  
  Future<List<Face>> detectFaces(InputImage image) async {
    return await faceDetector.processImage(image);
  }
  
  void dispose() {
    faceDetector.close();
  }
}
```

---

## Barcode Scanning

```dart
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  final barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.qrCode, BarcodeFormat.ean13],
  );
  
  Future<List<Barcode>> scanBarcodes(InputImage image) async {
    return await barcodeScanner.processImage(image);
  }
  
  void dispose() {
    barcodeScanner.close();
  }
}
```

---

## TensorFlow Lite (Custom Models)

### Setup
```yaml
dependencies:
  tflite_flutter: ^0.10.4
```

### Model Loading
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }
  
  List<double> runInference(List<double> input) {
    var output = List<double>.filled(10, 0);
    _interpreter.run(input, output);
    return output;
  }
  
  void dispose() {
    _interpreter.close();
  }
}
```

---

## Camera Integration

```dart
import 'package:camera/camera.dart';

class CameraMLService {
  late CameraController _controller;
  bool _isProcessing = false;
  
  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();
  }
  
  void startImageStream(Function(CameraImage) onImage) {
    _controller.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;
      onImage(image);
      _isProcessing = false;
    });
  }
  
  InputImage convertCameraImage(CameraImage image) {
    final bytes = _concatenatePlanes(image.planes);
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
  
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
}
```

---

## Performance Tips

1. **Use isolates for heavy processing**
```dart
final result = await compute(processImage, imageData);
```

2. **Throttle frame processing**
```dart
if (DateTime.now().difference(_lastProcess).inMilliseconds < 100) return;
```

3. **Dispose resources**
```dart
@override
void dispose() {
  textRecognizer.close();
  faceDetector.close();
  super.dispose();
}
```

---

## Checklist

- [ ] ML Kit package added
- [ ] Platform-specific setup complete
- [ ] Camera integration working
- [ ] Resource disposal implemented
- [ ] Frame throttling for real-time
- [ ] Error handling for edge cases
