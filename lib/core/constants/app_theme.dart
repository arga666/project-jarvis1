import 'package:flutter/material.dart';

class AppTheme {
  // Backgrounds
  static const Color darkBackground = Color(0xFF030712);
  static const Color cardDark = Color(0xFF0B132B);
  static const Color cardGlass = Color(0x331C2541);

  // Fade Dark Blue Gradient Colors
  static const Color blueLightRim = Color(0xFF1282A2);
  static const Color blueRoyal = Color(0xFF034078);
  static const Color blueNavy = Color(0xFF001F54);
  static const Color blueCosmic = Color(0xFF0A1128);

  // Accents & State Colors
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF38BDF8);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color crimsonAlert = Color(0xFFEF4444);

  // Gradient for the Orb
  static const RadialGradient orbGradient = RadialGradient(
    center: Alignment(-0.2, -0.3),
    radius: 0.95,
    colors: [
      Color(0xFF1E5F8A), // Core inner highlight
      blueRoyal,        // Mid sphere
      blueNavy,         // Deep shade
      blueCosmic,       // Dark outer edge
    ],
    stops: [0.0, 0.45, 0.8, 1.0],
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: neonCyan,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: neonCyan,
      secondary: electricBlue,
      surface: cardDark,
      error: crimsonAlert,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: neonCyan.withOpacity(0.15), width: 1),
      ),
    ),
  );
}
