//this is helper class for haptic feedback
//this file basically wraps the vibration.vibrate() method
//so i dont keep using vibration.vibrate() all over the code
import 'package:vibration/vibration.dart';

class HapticHelper {
  // Very light tap (like selectionClick)
  static Future<void> selection() async {
    // Check if device has a vibrator to prevent crashes
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
  }

  // Light impact
  static Future<void> light() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 25);
    }
  }

  // Medium impact
  static Future<void> medium() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 35);
    }
  }

  // Heavy impact
  static Future<void> heavy() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }
}
