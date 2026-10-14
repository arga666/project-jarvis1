import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/jarvis_config.dart';

class SleepHealthService {
  int bedtimeHour = JarvisConfig.defaultBedtimeHour;
  int bedtimeMinute = JarvisConfig.defaultBedtimeMinute;
  bool isSleepMonitoringEnabled = true;

  Timer? _checkTimer;
  DateTime? _lastAlertDate;

  Function(String warningMessage)? onBedtimeAlert;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    bedtimeHour = prefs.getInt('bedtime_hour') ?? JarvisConfig.defaultBedtimeHour;
    bedtimeMinute = prefs.getInt('bedtime_minute') ?? JarvisConfig.defaultBedtimeMinute;
    isSleepMonitoringEnabled = prefs.getBool('sleep_monitoring_enabled') ?? true;

    _startPeriodicCheck();
  }

  Future<void> updateBedtime(int hour, int minute) async {
    bedtimeHour = hour;
    bedtimeMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bedtime_hour', hour);
    await prefs.setInt('bedtime_minute', minute);
  }

  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    // Check every 2 minutes
    _checkTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!isSleepMonitoringEnabled) return;
      _evaluateSleepTime();
    });
  }

  void _evaluateSleepTime() {
    final now = DateTime.now();

    // Check if current time is past bedtime (e.g. >= 23:00 or early morning < 05:00)
    final isLateNight = (now.hour > bedtimeHour) ||
        (now.hour == bedtimeHour && now.minute >= bedtimeMinute) ||
        (now.hour < 5);

    if (isLateNight) {
      // Trigger once per night
      if (_lastAlertDate == null || _lastAlertDate!.day != now.day) {
        _lastAlertDate = now;
        final warning = _generateSleepWarning(now.hour, now.minute);
        onBedtimeAlert?.call(warning);
      }
    }
  }

  // Chill best friend anti-begadang warning with debate edge
  String _generateSleepWarning(int hour, int minute) {
    final timeStr = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    final bedtimeStr = "${bedtimeHour.toString().padLeft(2, '0')}:${bedtimeMinute.toString().padLeft(2, '0')}";

    if (hour >= 2 && hour < 5) {
      return "Woi Ga, liat jam! Udah jam $timeStr subuh! Lu mau bikin ginjal lu mogok kerja apa gimana? Besok jangan drama pusing seharian ya. Matiin HP lu sekarang, rebahan!";
    }

    return "Ga, dengerin gua dulu! Ini udah jam $timeStr bro, padahal target tidur lu jam $bedtimeStr. Kaga usah scroll medsos terus, kaga ada faedahnya. Tidur sekarang biar besok otak lu encer!";
  }

  void dispose() {
    _checkTimer?.cancel();
  }
}
