class AlarmIntent {
  final int hour;
  final int minute;
  final String label;

  AlarmIntent({
    required this.hour,
    required this.minute,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
    'hour': hour,
    'minute': minute,
    'label': label,
  };

  factory AlarmIntent.fromJson(Map<String, dynamic> json) {
    return AlarmIntent(
      hour: json['hour'] ?? 7,
      minute: json['minute'] ?? 0,
      label: json['label'] ?? 'Alarm dari Vis',
    );
  }

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
