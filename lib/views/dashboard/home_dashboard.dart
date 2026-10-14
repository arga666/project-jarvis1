import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/voice_assistant_service.dart';
import '../../models/jarvis_state.dart';
import '../../core/constants/app_theme.dart';
import '../overlay/floating_orb_widget.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _MainControlTab(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          border: Border(top: BorderSide(color: AppTheme.neonCyan.withOpacity(0.15))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.neonCyan,
          unselectedItemColor: Colors.grey.shade500,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.blur_on),
              label: "Jarvis",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Riwayat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune),
              label: "Pengaturan",
            ),
          ],
        ),
      ),
    );
  }
}

class _MainControlTab extends StatelessWidget {
  const _MainControlTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<VoiceAssistantService>();
    final isGaming = assistant.gamingModeService.isGamingMode;

    String stateTitle = "Standby (Panggil 'Jarvis' atau 'Vis')";
    Color stateColor = AppTheme.neonCyan;

    switch (assistant.state) {
      case JarvisState.listening:
        stateTitle = "Lagi dengerin lu...";
        stateColor = AppTheme.electricBlue;
        break;
      case JarvisState.thinking:
        stateTitle = "Lagi mikir (Gemini Engine)...";
        stateColor = AppTheme.neonCyan;
        break;
      case JarvisState.speaking:
        stateTitle = "Lagi ngomong...";
        stateColor = AppTheme.emeraldSuccess;
        break;
      case JarvisState.gamingMode:
        stateTitle = "Gaming Mode (RAM Hemat, Standby)";
        stateColor = AppTheme.amberWarning;
        break;
      case JarvisState.idle:
      default:
        stateTitle = "Standby (Panggil 'Jarvis' atau 'Vis')";
        stateColor = AppTheme.neonCyan;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("JARVIS ASSISTANT"),
        actions: [
          IconButton(
            icon: Icon(
              isGaming ? Icons.sports_esports : Icons.sports_esports_outlined,
              color: isGaming ? AppTheme.amberWarning : Colors.grey,
            ),
            tooltip: "Toggle Gaming Mode",
            onPressed: () {
              if (isGaming) {
                assistant.gamingModeService.exitGamingMode();
              } else {
                assistant.gamingModeService.enterGamingMode();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Visual Animated Orb Showcase
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: FloatingOrbWidget(
                    state: assistant.state,
                    onTap: () => assistant.manualVoiceTrigger(),
                    onDoubleTap: () {
                      if (isGaming) {
                        assistant.gamingModeService.exitGamingMode();
                      } else {
                        assistant.gamingModeService.enterGamingMode();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stateColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stateColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stateTitle,
                        style: TextStyle(color: stateColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap Orb buat mic manual / interupsi",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Status Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.shield_outlined,
                  title: "Background",
                  value: "Aktif",
                  accentColor: AppTheme.neonCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.speed,
                  title: "Gaming Mode",
                  value: isGaming ? "HEMAT RAM" : "NORMAL",
                  accentColor: isGaming ? AppTheme.amberWarning : AppTheme.electricBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.bedtime_outlined,
                  title: "Jam Tidur",
                  value: "${assistant.sleepHealthService.bedtimeHour.toString().padLeft(2, '0')}:${assistant.sleepHealthService.bedtimeMinute.toString().padLeft(2, '0')}",
                  accentColor: AppTheme.amberWarning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Quick Voice Test Prompts
          Text(
            "SIMULASI PERINTAH SUARA CEPAT",
            style: TextStyle(
              color: AppTheme.neonCyan.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          _buildQuickActionTile(
            title: "Alarm Otomatis via Suara",
            subtitle: '"Vis bikinin alarm jam 7 malam karena mau makan"',
            icon: Icons.alarm,
            color: AppTheme.emeraldSuccess,
            onTap: () => assistant.processUserCommand("Vis tolong bikinin gua alarm jam 7 malam karena gua mau makan"),
          ),
          const SizedBox(height: 10),

          _buildQuickActionTile(
            title: "Gaming Mode (RAM Saver)",
            subtitle: '"Vis tidur dulu gua mau main game"',
            icon: Icons.sports_esports,
            color: AppTheme.amberWarning,
            onTap: () => assistant.processUserCommand("Vis tidur dulu gua mau main game"),
          ),
          const SizedBox(height: 10),

          _buildQuickActionTile(
            title: "Uji Debater (Bantah Opini Salah)",
            subtitle: '"Vis gua mau begadang nonton anime sampe subuh"',
            icon: Icons.psychology_outlined,
            color: AppTheme.electricBlue,
            onTap: () => assistant.processUserCommand("Vis, gua mau begadang nonton anime sampe subuh ah, kan besok santai"),
          ),
        ],
      ),
    ),
  );
}

  static Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
