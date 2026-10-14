import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _historyKey = "jarvis_chat_history";
  static const String _apiKeyKey = "jarvis_gemini_api_key";

  Future<List<ChatMessage>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((item) => ChatMessage.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadHistory();
    list.insert(0, message); // Newest first

    // Keep last 100 messages for storage efficiency
    final trimmed = list.take(100).toList();
    final encoded = jsonEncode(trimmed.map((m) => m.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }
}
