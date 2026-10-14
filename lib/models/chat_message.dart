class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isAlarmTriggered;
  final bool isGamingTrigger;
  final bool isSleepWarning;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isAlarmTriggered = false,
    this.isGamingTrigger = false,
    this.isSleepWarning = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isAlarmTriggered': isAlarmTriggered,
    'isGamingTrigger': isGamingTrigger,
    'isSleepWarning': isSleepWarning,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isAlarmTriggered: json['isAlarmTriggered'] ?? false,
      isGamingTrigger: json['isGamingTrigger'] ?? false,
      isSleepWarning: json['isSleepWarning'] ?? false,
    );
  }
}
