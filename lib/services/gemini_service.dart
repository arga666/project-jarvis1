import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/jarvis_config.dart';
import '../models/alarm_intent.dart';

class GeminiResponse {
  final String text;
  final AlarmIntent? alarmIntent;
  final bool isGamingTrigger;

  GeminiResponse({
    required this.text,
    this.alarmIntent,
    this.isGamingTrigger = false,
  });
}

class GeminiService {
  String? _apiKey;

  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<GeminiResponse> queryGemini(String userQuery, {List<Map<String, String>>? conversationHistory}) async {
    if (!hasApiKey) {
      return GeminiResponse(
        text: "Bro, API Key Gemini lu belum dimasukin di Settings nih. Pasang dulu ya biar gua bisa mikir!",
      );
    }

    final lowerQuery = userQuery.toLowerCase().trim();

    // Check immediate Gaming Mode trigger locally for 0ms latency
    for (final trigger in JarvisConfig.gamingModeTriggers) {
      if (lowerQuery.contains(trigger)) {
        return GeminiResponse(
          text: "Siap Ga, gua tidur standby dulu biar RAM HP lu lega. Kalo udah kelar main game, tinggal panggil 'Vis' atau 'Jarvis' ya bro. Have fun!",
          isGamingTrigger: true,
        );
      }
    }

    final url = Uri.parse(
      '${JarvisConfig.geminiApiBaseUrl}/${JarvisConfig.defaultGeminiModel}:generateContent?key=$_apiKey',
    );

    // Build contents payload with system instruction
    final contents = <Map<String, dynamic>>[];

    // Add recent conversation history if available (limit to last 4 turns for low latency & memory)
    if (conversationHistory != null) {
      for (final turn in conversationHistory.take(4)) {
        contents.add({
          "role": turn["role"] == "user" ? "user" : "model",
          "parts": [{"text": turn["text"] ?? ""}]
        });
      }
    }

    // Add current user prompt
    contents.add({
      "role": "user",
      "parts": [{"text": userQuery}]
    });

    final payload = {
      "system_instruction": {
        "parts": [
          {"text": JarvisConfig.systemInstruction}
        ]
      },
      "contents": contents,
      "generationConfig": {
        "temperature": 0.7,
        "maxOutputTokens": 250, // Keep short & punchy for 2-3s voice latency
        "topP": 0.9,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            String rawText = parts[0]['text'] ?? '';
            return _parseResponseAndTools(rawText);
          }
        }
        return GeminiResponse(
          text: "Otak gua rada nge-blank barusan Ga, coba ulangi lagi omongan lu.",
        );
      } else {
        return GeminiResponse(
          text: "Waduh koneksi ke Gemini lagi ngadat bro (Error ${response.statusCode}). Coba cek kuota atau API key lu deh.",
        );
      }
    } catch (e) {
      return GeminiResponse(
        text: "Koneksi internet lu lemot atau putus nih Ga. Coba cek WiFi atau data lu bentar.",
      );
    }
  }

  // Parse structured Tool Call for Alarm
  GeminiResponse _parseResponseAndTools(String rawText) {
    AlarmIntent? alarm;
    String cleanText = rawText;

    // Regex check for embedded JSON tool call: {"tool": "set_alarm", ...}
    final jsonRegex = RegExp(r'\{[^{}]*"tool"\s*:\s*"set_alarm"[^{}]*\}');
    final match = jsonRegex.firstMatch(rawText);

    if (match != null) {
      try {
        final jsonStr = match.group(0)!;
        final parsed = jsonDecode(jsonStr);
        final hour = parsed['hour'] is int ? parsed['hour'] as int : int.tryParse(parsed['hour'].toString()) ?? 7;
        final minute = parsed['minute'] is int ? parsed['minute'] as int : int.tryParse(parsed['minute'].toString()) ?? 0;
        final label = parsed['label']?.toString() ?? 'Alarm dari Vis';

        alarm = AlarmIntent(hour: hour, minute: minute, label: label);
        // Remove the JSON string from speech output so TTS only reads natural Indonesian text
        cleanText = cleanText.replaceAll(jsonStr, '').trim();
      } catch (_) {
        // Fallback gracefully
      }
    }

    return GeminiResponse(
      text: cleanText,
      alarmIntent: alarm,
    );
  }
}
