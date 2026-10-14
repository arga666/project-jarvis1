import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/voice_assistant_service.dart';
import '../../core/constants/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _isOverlayGranted = false;

  @override
  void initState() {
    super.initState();
    final assistant = context.read<VoiceAssistantService>();
    assistant.storageService.getApiKey().then((val) {
      if (val != null) {
        _apiKeyController.text = val;
      }
    });
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final assistant = context.read<VoiceAssistantService>();
    final granted = await assistant.alarmService.checkOverlayPermission();
    if (mounted) {
      setState(() => _isOverlayGranted = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<VoiceAssistantService>();
    final sleepService = assistant.sleepHealthService;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan & Siklus Hidup"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Gemini AI Engine
          _buildSectionHeader("AI ENGINE (GEMINI PRO / FLASH)"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neonCyan.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Google Gemini API Key",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dipake buat otak reasoning Jarvis, debater mode, hitung cepat & alarm parser.",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    hintText: "AIzaSy...",
                    filled: true,
                    fillColor: AppTheme.cardGlass,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text("Simpan API Key"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await assistant.updateApiKey(_apiKeyController.text);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("API Key Gemini berhasil disimpan!")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Sleep & Health Cycle
          _buildSectionHeader("HEALTH & SLEEP CYCLE AWARENESS"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.amberWarning.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Target Jam Tidur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.amberWarning,
                        side: const BorderSide(color: AppTheme.amberWarning),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: sleepService.bedtimeHour,
                            minute: sleepService.bedtimeMinute,
                          ),
                        );
                        if (time != null) {
                          await sleepService.updateBedtime(time.hour, time.minute);
                          setState(() {});
                        }
                      },
                      child: Text(
                        "${sleepService.bedtimeHour.toString().padLeft(2, '0')}:${sleepService.bedtimeMinute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Kalo lu masih aktif atau HP nyala lewat dari jam ini, Vis otomatis bakal negur lu dan ngebantah alesan lu buat begadang.",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Android Permissions
          _buildSectionHeader("IZIN SISTEM ANDROID"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildPermissionTile(
                  title: "Floating Overlay (System Alert)",
                  subtitle: "Supaya Orb Vis bisa melayang di atas game dan app lain.",
                  isGranted: _isOverlayGranted,
                  onAction: () async {
                    await assistant.alarmService.requestOverlayPermission();
                    await _checkPermissions();
                  },
                ),
                const Divider(color: Colors.white12),
                _buildPermissionTile(
                  title: "Abaikan Optimasi Baterai",
                  subtitle: "Biar wake-word 'Jarvis' / 'Vis' kaga dibunuh background task Android.",
                  isGranted: true,
                  onAction: () async {
                    await assistant.alarmService.requestBatteryOptimization();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.neonCyan.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: isGranted ? AppTheme.emeraldSuccess.withOpacity(0.2) : AppTheme.electricBlue,
            foregroundColor: isGranted ? AppTheme.emeraldSuccess : Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(isGranted ? "Aktif" : "Izinkan"),
        ),
      ],
    );
  }
}
