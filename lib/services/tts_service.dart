import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  Function(bool isSpeaking)? onSpeakingStateChanged;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    // Set Indonesian locale
    await _flutterTts.setLanguage("id-ID");

    // Tuning for Young Male Voice:
    // Pitch 0.95 - 1.05 gives a natural, friendly, non-booming, non-robotic young male timbre
    await _flutterTts.setPitch(1.0);

    // Natural conversation speech rate (not too rushed, not sluggish)
    await _flutterTts.setSpeechRate(0.53);

    // Volume level
    await _flutterTts.setVolume(1.0);

    // Try finding Indonesian male voice in system engine
    try {
      final List<dynamic>? voices = await _flutterTts.getVoices;
      if (voices != null) {
        for (final voice in voices) {
          if (voice is Map) {
            final locale = voice["locale"]?.toString().toLowerCase() ?? "";
            final name = voice["name"]?.toString().toLowerCase() ?? "";
            if (locale.contains("id") && (name.contains("male") || name.contains("pria") || name.contains("id-id-x-dfz#male"))) {
              await _flutterTts.setVoice({
                "name": voice["name"],
                "locale": voice["locale"],
              });
              break;
            }
          }
        }
      }
    } catch (_) {
      // Use system default if voice selection fails
    }

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onSpeakingStateChanged?.call(true);
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    });
  }

  // Interruption / Barge-in: Stops immediately if new speech occurs
  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await stop(); // Cut off previous speech for responsive barge-in
    await _flutterTts.speak(text);
  }
}
