import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'services/voice_assistant_service.dart';
import 'views/dashboard/home_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark Status Bar & Navigation Bar configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final voiceAssistantService = VoiceAssistantService();
  await voiceAssistantService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<VoiceAssistantService>.value(
          value: voiceAssistantService,
        ),
      ],
      child: const JarvisApp(),
    ),
  );
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis (Vis)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeDashboard(),
    );
  }
}
