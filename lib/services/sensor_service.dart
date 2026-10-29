import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

/// Đo độ ồn Micro & Cảm biến gia tốc (Lắc máy)
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  void startShakeDetection({required Function onShakeDetected}) {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // Simple shake detection logic based on threshold
      double threshold = 15.0;
      if (event.x.abs() > threshold || event.y.abs() > threshold || event.z.abs() > threshold) {
        onShakeDetected();
      }
    });
  }

  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}
