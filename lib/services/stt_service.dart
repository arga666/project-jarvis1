import 'package:speech_to_text/speech_to_text.dart';
import '../core/config/jarvis_config.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _wakeWordTriggered = false;

  Function(String recognizedText)? onCommandRecognized;
  Function(bool isListening)? onListeningStateChanged;
  Function()? onWakeWordDetected;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> initialize() async {
    _isAvailable = await _speechToText.initialize(
      onError: (val) {
        _isListening = false;
        onListeningStateChanged?.call(false);
      },
      onStatus: (val) {
        if (val == 'listening') {
          _isListening = true;
          onListeningStateChanged?.call(true);
        } else if (val == 'notListening' || val == 'done') {
          _isListening = false;
          onListeningStateChanged?.call(false);
        }
      },
    );
    return _isAvailable;
  }

  // Continuous background listening loop
  Future<void> startListening() async {
    if (!_isAvailable) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (_speechToText.isListening) return;

    _wakeWordTriggered = false;

    await _speechToText.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.toLowerCase().trim();

        // Check for Wake-Word: "jarvis" or "vis"
        if (!_wakeWordTriggered) {
          for (final word in JarvisConfig.wakeWords) {
            if (recognized.contains(word)) {
              _wakeWordTriggered = true;
              onWakeWordDetected?.call();
              break;
            }
          }
        }

        // When speech finalizes or long pause occurs
        if (result.finalResult && recognized.isNotEmpty) {
          String cleanedCommand = recognized;
          // Strip the wake word prefix if present
          for (final word in JarvisConfig.wakeWords) {
            if (cleanedCommand.startsWith(word)) {
              cleanedCommand = cleanedCommand.substring(word.length).trim();
            }
          }
          if (cleanedCommand.isNotEmpty) {
            onCommandRecognized?.call(cleanedCommand);
          }
          _wakeWordTriggered = false;
        }
      },
      localeId: "id_ID",
      listenMode: ListenMode.confirmation,
      pauseFor: const Duration(seconds: 2),
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }
}
