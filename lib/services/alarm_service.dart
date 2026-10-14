import 'package:flutter/services.dart';
import '../models/alarm_intent.dart';

class AlarmService {
  static const MethodChannel _channel = MethodChannel('com.jarvis.assistant/native_bridge');

  Future<bool> setAlarm(AlarmIntent alarm) async {
    try {
      final bool result = await _channel.invokeMethod('setSystemAlarm', {
        'hour': alarm.hour,
        'minute': alarm.minute,
        'message': alarm.label,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to set system alarm: ${e.message}");
      return false;
    }
  }

  // Permission helpers
  Future<bool> checkOverlayPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('checkOverlayPermission');
      return granted;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  Future<void> requestBatteryOptimization() async {
    try {
      await _channel.invokeMethod('requestBatteryOptimization');
    } catch (_) {}
  }
}
