# 🌌 Jarvis (Vis) - Autonomous Virtual Personal Assistant for Android

> **"Bukan sekadar asisten, tapi sahabat cowok yang santai, perhatian, dan berani nampol realita kalo opini atau pilihan lu salah."**

Jarvis (sering dipanggil **"Vis"**) adalah asisten pribadi virtual berbasis Android yang dirancang dengan arsitektur **Mobile AI System** modern. Menggabungkan **Floating System Overlay (Fade Dark Blue Orb)**, **Background Wake-Word Listener**, **Gemini Flash Low-Latency Engine (<2-3 detik)**, **Mode Hemat RAM (Gaming Mode)**, serta **Sleep Cycle & Health Awareness**.

---

## 🚀 Fitur Unggulan

### 1. Persona Santai & Karakter "Debater" (Anti Yes-Man)
- **Gaya Bicara:** Sangat kasual tongkrongan (`lu-gua`, no kaku, no formal).
- **Berani Membantah:** Kalo lu punya opini atau rencana konyol/berisiko (misal mau begadang kaga jelas, judi, malas-malasan, atau logika ngawur), Jarvis **WAJIB mendebat dan membantah** dengan argumen logis ala sahabat sejati.
- **Interupsi / Barge-in:** Jika ada situasi krusial (jam tidur lewat, alarm bertabrakan), Jarvis langsung memotong pembicaraan: *"Tolong dengerin gua dulu Ga..."*.
- **Low Latency (<2-3 Detik):** Menggunakan model Gemini Flash yang dipangkas tokennya agar respon to-the-point dan langsung diputar oleh TTS tanpa jeda mikir yang lama.
- **Suara TTS:** Suara laki-laki muda (`id-ID`, pitch 1.0, speed 0.53) santai dan natural, bukan suara robotik berat.

### 2. Floating Overlay Window (Fade Dark Blue Orb)
- Widget melayang berbentuk bulat minimalis dengan gradasi **Fade Dark Blue** (`#0A1128` -> `#001F54` -> `#034078` -> `#1282A2`) dan aksen **Neon Cyan Glow** (`#00F0FF`).
- **Clean Interface:** Tidak ada bubble chat atau card teks panjang yang mengganggu saat main game atau buka app lain. Cukup visualisasi gerak orb:
  - *Idle:* Breathing pulse santai.
  - *Listening:* Gelombang suara (soundwave ripples) meluas.
  - *Thinking:* Halo ring neon cyan berputar.
  - *Speaking:* Fluktuasi harmonik audio.
- Bisa digeser ke mana saja di layar (drag & drop physics).

### 3. Wake-Word & Background Service
- Berjalan di background lewat **Android Foreground Service** & **WakeLock**.
- Standby mendeteksi panggilan suara: **"Jarvis"** atau **"Vis"** tanpa perlu membuka aplikasi secara manual.

### 4. Natural Language Alarm Parser
- Mampu mem-parsing kalimat sehari-hari langsung jadi Alarm Sistem Android asli:
  - *Contoh:* *"Jarvis tolong bikinin gua alarm jam 7 malam karena gua mau makan"*
  - Gemini mem-parsing intent JSON: `{"tool": "set_alarm", "hour": 19, "minute": 0, "label": "Makan"}`
  - Otomatis memicu `AlarmClock.ACTION_SET_ALARM` di aplikasi Jam bawaan HP!

### 5. Health & Sleep Cycle Awareness
- Pengguna dapat mengatur target jam tidur (default: 23:00).
- Jika pengguna masih aktif atau berinteraksi lewat jam tersebut, Jarvis otomatis memicu **Begadang Alert** dengan gaya sahabat peduli:
  > *"Ga, udah jam 02:30 subuh bro! Lu mau bikin ginjal lu mogok kerja apa gimana? Besok jangan drama pusing seharian ya. Matiin HP lu sekarang!"*

### 6. Mode Hemat RAM (Gaming Mode)
- **Pemicu Suara:** *"Vis tidur dulu gua mau main game"*.
- **Aksi Otomatis:**
  1. Menghentikan ticker animasi visual orb (0% GPU rendering).
  2. Menyembunyikan floating overlay dari WindowManager.
  3. Memanggil Garbage Collection sistem Android (`System.gc()`, `Runtime.getRuntime().gc()`).
  4. Membersihkan memory cache sehingga RAM lega untuk push rank game.
- **Auto-Wakeup:** Langsung bangun dan aktif seketika saat dipanggil kembali: *"Vis"* atau *"Jarvis"*.

### 7. Riwayat Obrolan & Audio Replay
- Tersedia halaman khusus di dalam aplikasi utama untuk mengecek seluruh log percakapan.
- Tombol **"Putar Ulang"** suara untuk setiap respon Jarvis jika pengguna lupa.

---

## 📁 Struktur Folder Proyek

```
jarvis_assistant/
├── .github/
│   └── workflows/
│       └── build-apk.yml            # CI/CD: Otomatis compile APK di GitHub Actions & upload Release
├── android/
│   ├── app/
│   │   ├── build.gradle             # Android build config (SDK 34, Java 17, Debug signing)
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml  # Perizinan lengkap Android (Overlay, Mic, Alarm, Battery)
│   │           └── kotlin/
│   │               └── com/jarvis/assistant/
│   │                   ├── MainActivity.kt           # Native MethodChannels (Alarm Intent, GC, Overlay)
│   │                   ├── JarvisForegroundService.kt # Background Service + WakeLock
│   │                   └── JarvisOverlayService.kt    # System Alert Window Manager (Floating Orb)
│   ├── build.gradle
│   └── settings.gradle
├── lib/
│   ├── main.dart                    # Bootstrap aplikasi & provider setup
│   ├── core/
│   │   ├── config/
│   │   │   └── jarvis_config.dart   # System instruction, persona debater, wake-words
│   │   └── constants/
│   │       └── app_theme.dart       # Palette Fade Dark Blue, Neon Cyan, Glassmorphism
│   ├── models/
│   │   ├── alarm_intent.dart        # Model alarm waktu & label
│   │   ├── chat_message.dart        # Model riwayat chat & metadata
│   │   └── jarvis_state.dart        # Enum: idle, listening, thinking, speaking, gamingMode
│   ├── services/
│   │   ├── alarm_service.dart       # Jembatan ke native Android AlarmClock
│   │   ├── gaming_mode_service.dart # RAM cleaner & freezer animasi GPU
│   │   ├── gemini_service.dart      # Client Gemini Flash (<2-3s latency) + tool parser
│   │   ├── sleep_health_service.dart# Monitoring jam tidur & pencegah begadang
│   │   ├── storage_service.dart     # Persistensi SQLite/SharedPreferences
│   │   ├── stt_service.dart         # Pengenal ucapan & spotter kata "Jarvis"/"Vis"
│   │   ├── tts_service.dart         # Text-To-Speech cowok muda bahasa Indonesia
│   │   └── voice_assistant_service.dart # Master Orchestrator seluruh sistem
│   └── views/
│       ├── dashboard/
│       │   ├── history_screen.dart  # Halaman riwayat chat + tombol putar ulang audio
│       │   ├── home_dashboard.dart  # Dashboard kontrol, preview orb & simulasi
│       │   └── settings_screen.dart # Konfigurasi Gemini API Key & izin Android
│       └── overlay/
│           ├── floating_orb_widget.dart # Widget animasi Orb
│           └── orb_painter.dart     # Custom Canvas rendering gelombang & gradasi
├── pubspec.yaml                     # Dependensi Flutter
└── README.md                        # Dokumentasi lengkap
```

---

## 🛡️ Konfigurasi Izin Android (`AndroidManifest.xml`)

Aplikasi ini telah dilengkapi seluruh izin yang dibutuhkan:
1. `android.permission.SYSTEM_ALERT_WINDOW`: Menampilkan Floating Orb di atas game/aplikasi lain.
2. `android.permission.RECORD_AUDIO`: Merekam suara untuk mendeteksi wake-word & instruksi.
3. `android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MICROPHONE`: Berjalan terus di background pada Android 14+.
4. `android.permission.WAKE_LOCK`: Menjaga prosesor tetap siaga saat layar mati.
5. `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: Mencegah sistem Android (MIUI, ColorOS, OneUI) membunuh Jarvis di background.
6. `com.android.alarm.permission.SET_ALARM`: Memasang alarm langsung ke jam bawaan Android.
7. `android.permission.SCHEDULE_EXACT_ALARM`: Menjadwalkan alarm tepat waktu.

---

## 📲 Cara Download & Instal File APK Langsung di HP

Karena repository ini telah dilengkapi file otomatisasi **`.github/workflows/build-apk.yml`**, kamu **TIDAK PERLU** install Android Studio atau Flutter di komputermu! GitHub akan meng-compile file APK secara otomatis di server cloud mereka.

### Langkah-langkah:
1. Buka repo kamu di GitHub: [https://github.com/arga666/project-jarvis1](https://github.com/arga666/project-jarvis1)
2. Klik tab **Releases** di sebelah kanan halaman repo, atau klik tab **Actions**.
3. Di sana akan langsung muncul release **`v1.0.0`** dengan file siap unduh bernama:
   - **`app-release.apk`** (atau **`Jarvis-Assistant-v1.0.0.apk`**).
4. Download file APK tersebut langsung dari browser HP kamu.
5. Buka file APK di HP dan pilih **Install**.
6. Saat pertama kali dibuka:
   - Masukkan **Google Gemini API Key** di menu *Pengaturan*.
   - Berikan izin **Tampilkan di atas aplikasi lain (Overlay)**.
   - Matikan **Optimasi Baterai** agar Jarvis standby di background.

---

## 🔑 Mengatasi Git Push (Akun Zell20-21 vs arga666)

Di komputermu saat ini, Windows Credential Manager masih menyimpan akun GitHub lama (**Zell20-21**). Karena repo tujuan adalah `arga666/project-jarvis1.git`, GitHub menolak akses dengan pesan error `403 Permission denied to Zell20-21`.

### Cara Solusi 1 Detik (Paling Gampang):
Buka terminal PowerShell, lalu jalankan perintah berikut untuk menghapus login lama:
```powershell
cmdkey /delete:git:https://github.com
```
Setelah dihapus, jalankan push:
```powershell
git push -u origin main
```
Browser atau pop-up login GitHub akan muncul. Loginlah dengan akun **arga666**, dan seluruh kode beserta file workflow CI/CD akan langsung masuk ke repository!

Atau jika kamu memiliki GitHub Personal Access Token (PAT):
```powershell
git remote set-url origin https://<TOKEN_GITHUB_LU>@github.com/arga666/project-jarvis1.git
git push -u origin main
```
Begitu ter-push, GitHub Actions akan langsung memulai proses build dan menghasilkan file APK siap download dalam waktu 2-3 menit!
