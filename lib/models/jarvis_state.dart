enum JarvisState {
  idle,         // Subtle breathing animation, waiting for wake-word
  listening,    // Expanding audio soundwave ripples
  thinking,     // Rotating neon halo ring (query sent to Gemini)
  speaking,     // Fluctuating waveform & TTS output
  gamingMode,   // Suspended visuals, RAM freed, lowest power wake-word standby
}
