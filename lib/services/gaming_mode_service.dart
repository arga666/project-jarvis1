import 'package:flutter/services.dart';

class GamingModeService {
  static const MethodChannel _channel = MethodChannel('com.jarvis.assistant/native_bridge');
  bool _isGamingMode = false;

  Function(bool isActive)? onGamingModeChanged;

  bool get isGamingMode => _isGamingMode;

  Future<void> enterGamingMode() async {
    _isGamingMode = true;
    onGamingModeChanged?.call(true);

    try {
      // 1. Invoke native Android Memory Cleanup & Garbage Collection
      await _channel.invokeMethod('triggerGamingModeGC');

      // 2. Hide floating overlay view to save GPU rendering cycles
      await _channel.invokeMethod('hideFloatingOverlay');
    } catch (_) {}
  }

  Future<void> exitGamingMode() async {
    _isGamingMode = false;
    onGamingModeChanged?.call(false);

    try {
      // Restore floating overlay
      await _channel.invokeMethod('showFloatingOverlay');
    } catch (_) {}
  }
}
