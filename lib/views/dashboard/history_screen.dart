import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/voice_assistant_service.dart';
import '../../models/chat_message.dart';
import '../../core/constants/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<VoiceAssistantService>();
    final messages = assistant.messages.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Obrolan Vis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            tooltip: "Bersihkan Riwayat",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.cardDark,
                  title: const Text("Hapus Semua Riwayat?"),
                  content: const Text("Log obrolan lu sama Vis bakal dihapus dari HP."),
                  actions: [
                    TextButton(
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                    TextButton(
                      child: const Text("Hapus", style: TextStyle(color: AppTheme.crimsonAlert)),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await assistant.storageService.clearHistory();
                assistant.messages.clear();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Cari omongan Vis kemarin...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neonCyan),
                filled: true,
                fillColor: AppTheme.cardGlass,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonCyan.withOpacity(0.2)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),

          // Message List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? "Belum ada obrolan sama Vis nih." : "Kaga nemu omongan yang cocok.",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageCard(msg, assistant);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage msg, VoiceAssistantService assistant) {
    final timeStr = DateFormat("dd MMM, HH:mm").format(msg.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: msg.isUser ? AppTheme.cardDark : AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.Border.all(
          color: msg.isUser
              ? Colors.white.withOpacity(0.1)
              : msg.isSleepWarning
                  ? AppTheme.amberWarning.withOpacity(0.5)
                  : msg.isAlarmTriggered
                      ? AppTheme.emeraldSuccess.withOpacity(0.5)
                      : AppTheme.neonCyan.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    msg.isUser ? Icons.person_outline : Icons.auto_awesome,
                    size: 16,
                    color: msg.isUser ? AppTheme.electricBlue : AppTheme.neonCyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    msg.isUser ? "Lu" : "Vis",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: msg.isUser ? AppTheme.electricBlue : AppTheme.neonCyan,
                    ),
                  ),
                  if (msg.isSleepWarning) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.amberWarning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Begadang Alert", style: TextStyle(color: AppTheme.amberWarning, fontSize: 10)),
                    ),
                  ],
                  if (msg.isAlarmTriggered) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldSuccess.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Alarm Set", style: TextStyle(color: AppTheme.emeraldSuccess, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              Text(
                timeStr,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg.text,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
          ),
          if (!msg.isUser) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => assistant.replayMessage(msg),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.volume_up, size: 16, color: AppTheme.neonCyan),
                      SizedBox(width: 4),
                      Text(
                        "Putar Ulang",
                        style: TextStyle(color: AppTheme.neonCyan, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
