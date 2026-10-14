import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/jarvis_state.dart';
import '../models/chat_message.dart';
import 'gemini_service.dart';
import 'tts_service.dart';
import 'stt_service.dart';
import 'alarm_service.dart';
import 'sleep_health_service.dart';
import 'gaming_mode_service.dart';
import 'storage_service.dart';

class VoiceAssistantService extends ChangeNotifier {
  final GeminiService geminiService = GeminiService();
  final TtsService ttsService = TtsService();
  final SttService sttService = SttService();
  final AlarmService alarmService = AlarmService();
  final SleepHealthService sleepHealthService = SleepHealthService();
  final GamingModeService gamingModeService = GamingModeService();
  final StorageService storageService = StorageService();

  JarvisState _state = JarvisState.idle;
  List<ChatMessage> _messages = [];
  bool _isInitialized = false;

  JarvisState get state => _state;
  List<ChatMessage> get messages => _messages;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load API Key
    final savedApiKey = await storageService.getApiKey();
    if (savedApiKey != null && savedApiKey.isNotEmpty) {
      geminiService.setApiKey(savedApiKey);
    }

    // Load History
    _messages = await storageService.loadHistory();

    // Init Subservices
    await ttsService.initialize();
    await sttService.initialize();
    await sleepHealthService.initialize();

    // Hook TTS State
    ttsService.onSpeakingStateChanged = (speaking) {
      if (speaking) {
        _setState(JarvisState.speaking);
      } else {
        if (_state == JarvisState.speaking) {
          _setState(gamingModeService.isGamingMode ? JarvisState.gamingMode : JarvisState.idle);
        }
      }
    };

    // Hook STT State
    sttService.onListeningStateChanged = (listening) {
      if (listening && _state != JarvisState.speaking && _state != JarvisState.thinking) {
        _setState(JarvisState.listening);
      }
    };

    // Hook Wake-Word Trigger ("Jarvis" or "Vis")
    sttService.onWakeWordDetected = () {
      // If was in Gaming Mode, wake up immediately!
      if (gamingModeService.isGamingMode) {
        gamingModeService.exitGamingMode();
        ttsService.speak("Yo Ga! Gua udah standby lagi nih. Butuh bantuan apa?");
      }
      _setState(JarvisState.listening);
    };

    // Hook Command Recognized
    sttService.onCommandRecognized = (command) {
      processUserCommand(command);
    };

    // Hook Sleep Health Alert
    sleepHealthService.onBedtimeAlert = (warningText) {
      // Barge-in alert from Vis!
      ttsService.speak(warningText);
      final warningMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: warningText,
        isUser: false,
        timestamp: DateTime.now(),
        isSleepWarning: true,
      );
      _messages.insert(0, warningMsg);
      storageService.saveMessage(warningMsg);
      notifyListeners();
    };

    // Hook Gaming Mode State
    gamingModeService.onGamingModeChanged = (active) {
      _setState(active ? JarvisState.gamingMode : JarvisState.idle);
    };

    _isInitialized = true;
    notifyListeners();

    // Start background listening
    sttService.startListening();
  }

  void _setState(JarvisState newState) {
    _state = newState;
    notifyListeners();
  }

  // Process user voice command
  Future<void> processUserCommand(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Log user speech
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, userMsg);
    await storageService.saveMessage(userMsg);
    notifyListeners();

    // 2. Set State to Thinking (visual neon halo)
    _setState(JarvisState.thinking);

    // Build context
    final history = _messages.take(6).map((m) => {
      "role": m.isUser ? "user" : "model",
      "text": m.text,
    }).toList().reversed.toList();

    // 3. Query Gemini Flash (ultra-fast latency ~1.5 - 2.5s)
    final response = await geminiService.queryGemini(text, conversationHistory: history);

    // 4. Check if Gaming Mode was triggered
    if (response.isGamingTrigger) {
      await gamingModeService.enterGamingMode();
    }

    // 5. Check if Alarm Tool was triggered
    bool hasAlarm = false;
    if (response.alarmIntent != null) {
      hasAlarm = await alarmService.setAlarm(response.alarmIntent!);
    }

    // 6. Log Jarvis reply
    final jarvisMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: response.text,
      isUser: false,
      timestamp: DateTime.now(),
      isAlarmTriggered: hasAlarm,
      isGamingTrigger: response.isGamingTrigger,
    );
    _messages.insert(0, jarvisMsg);
    await storageService.saveMessage(jarvisMsg);
    notifyListeners();

    // 7. Speak response with young male voice profile (barge-in enabled)
    await ttsService.speak(response.text);
  }

  // Replay a message from history
  Future<void> replayMessage(ChatMessage message) async {
    await ttsService.speak(message.text);
  }

  // Update Gemini API key
  Future<void> updateApiKey(String key) async {
    geminiService.setApiKey(key);
    await storageService.saveApiKey(key);
    notifyListeners();
  }

  // Toggle manual trigger from UI
  Future<void> manualVoiceTrigger() async {
    if (ttsService.isSpeaking) {
      await ttsService.stop();
      return;
    }
    if (sttService.isListening) {
      await sttService.stopListening();
    } else {
      await sttService.startListening();
    }
  }
}
