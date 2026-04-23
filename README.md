# IQACS — Intelligent Quality & Air Control System for Coffee Nursery Greenhouse

> **Repository Description (for GitHub):**
> A Flutter-based mobile application for smart coffee nursery greenhouse management. IQACS integrates real-time IoT sensor monitoring (temperature & humidity), automated sprayer control, AI-powered coffee leaf disease detection using image classification, and data analytics with interactive charts and Excel export — all in one unified platform.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Application Flow](#application-flow)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [API Endpoints](#api-endpoints)
- [Getting Started](#getting-started)
- [Build Guide](#build-guide)
- [Screenshots](#screenshots)

---

## Overview

**IQACS (Intelligent Quality & Air Control System)** is a Flutter mobile application designed for smart management of coffee nursery greenhouses. The system connects to IoT hardware sensors that monitor temperature and humidity inside the greenhouse in real-time, allows operators to remotely control a water sprayer pump, and leverages AI/machine learning to detect coffee leaf diseases from photos taken directly in the field.

The application communicates with a backend REST API server and is built with a responsive layout supporting screens from mobile to 4K displays.

---

## Key Features

| Feature | Description |
|---|---|
| 🌡️ **Real-time Sensor Monitoring** | Live temperature and humidity readings from IoT sensors installed in the greenhouse |
| 💧 **Remote Sprayer Control** | Toggle the water sprayer pump on/off directly from the app |
| 🤖 **AI Leaf Disease Detection** | Upload or capture a photo of a coffee leaf; the AI model classifies the disease and returns a diagnosis with an accuracy score |
| 📊 **Analytics & Charts** | Line chart visualization of historical temperature and humidity data, filterable by custom date range (max 7 days) |
| 📤 **Excel Export** | Export sensor chart data to `.xlsx` format for offline analysis |
| 🌤️ **Weather Integration** | Displays current local weather conditions via OpenWeather API |
| 📜 **Diagnosis History** | View, filter, and delete past diagnosis records categorized by disease type (Miner, Phoma, Rust, No Disease) |
| 🔒 **Authentication** | Secure login with JWT Bearer token, OTP-based forgot password flow, and change password |
| 👤 **User Profile** | View and edit profile, change profile photo |
| 📱 **Responsive Layout** | Supports Mobile, Tablet, Laptop, and 4K screen breakpoints |

---

## Application Flow

### 1. Splash Screen → Onboarding → Login
- The app starts with a **Splash Screen** that checks for an existing session token in `SharedPreferences`.
- First-time users are shown an **Onboarding Screen** (3 slides).
- Users authenticate via the **Login Screen** using email and password. On success, a JWT token and user ID are stored locally.

### 2. Main Dashboard (Home Screen)
After login, the user lands on the **Home Screen** which displays:
- **Custom AppBar** — shows user greeting and weather info.
- **Main Card** — shows live temperature and humidity values fetched from the IoT sensor device.
- **Filter Card** — lets the user filter sensor data by time range.
- **Sensor Card** — detailed temperature/humidity display card.
- **Sprayer Card** — button to toggle the sprayer pump on/off via API.
- **Report Card** — quick link to the analytics/report section.

### 3. Scanner Screen (Disease Detection)
The **Scanner Screen** provides two ways to submit a leaf photo for AI diagnosis:
- **Open Camera** — captures a photo live from the device camera.
- **Open Folder** — picks an image from the device gallery.

On submission, the image is uploaded via multipart POST to the backend AI inference endpoint. The API returns a diagnosis label (e.g., *Miner*, *Phoma*, *Rust*, *No Disease*) along with an accuracy percentage and an AI-generated description.

**Result is displayed on the Predict Result Screen:**
- Full-width leaf image
- Diagnosis name + accuracy badge
- AI-generated markdown description with typewriter animation

The scanner screen also shows the **Latest Diagnoses** list (last hour), where each entry can be tapped to open the detail screen or deleted.

### 4. Analytic Screen (History)
Displays all previous diagnosis records in a **masonry grid layout**, filterable by disease category via tabs:
- All | Miner | Phoma | No Disease | Rust

Tapping any item opens the **Detail Analytic Screen** showing the full diagnosis detail for that record.

### 5. Report Screen (Charts & Data)
- **Line Chart** — visualizes average daily temperature and humidity over a selected date range (up to 7 days).
- **Humidity Detail** — doughnut/radial chart per day.
- **Temperature Detail** — doughnut/radial chart per day.
- **Export** — exports the visible data to an Excel (`.xlsx`) file saved locally.
- **Filter** — date range picker to select a custom period.

### 6. Profile & Account Management
- View and edit user profile (name, email, phone).
- Change profile photo.
- Change password.
- Forgot password flow: enter email → receive OTP → verify OTP → set new password.

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`)
- **HTTP Client:** Dio (`dio`) + `http`
- **Local Storage:** SharedPreferences
- **Charts:** fl_chart
- **AI Result Rendering:** `gpt_markdown`, `animated_text_kit`
- **Image Handling:** `image_picker`, `camera`
- **Export:** `excel`, `open_file`
- **UI Utilities:** `google_fonts`, `gap`, `shimmer`, `flutter_animate`, `responsive_framework`, `flutter_staggered_grid_view`
- **Notifications:** `awesome_snackbar_content`, `quickalert`
- **Internationalization:** `intl`, `timeago`

---

## Project Structure

```
lib/
├── main.dart                     # App entry point, responsive breakpoints
├── constants/
│   ├── api_constant.dart         # All API base URLs and endpoints
│   └── dio_constant.dart         # Dio client configuration
├── models/
│   ├── model_user.dart           # Auth user model
│   ├── model_pengguna.dart       # User profile model
│   ├── model_alat.dart           # IoT device/sensor model
│   ├── model_chart.dart          # Chart data model
│   ├── model_data_predict.dart   # Diagnosis result models
│   ├── model_diagnosa.dart       # Diagnosa response model
│   ├── model_weather.dart        # Weather API model
│   ├── model_monicontrollings.dart
│   ├── model_forgot_password.dart
│   └── model_update_profile.dart
├── providers/
│   ├── login_provider.dart       # Auth state & login logic
│   ├── user_provider.dart        # User profile state
│   ├── diagnosa_provider.dart    # AI predict, list, delete
│   ├── chart_provider.dart       # Chart data + Excel export
│   ├── weather_provider.dart     # Weather fetch
│   ├── get_temp_humidity_provider.dart
│   ├── filter_sensor_provider.dart
│   ├── forgot_password_provider.dart
│   ├── check_otp_provider.dart
│   ├── change_password_provider.dart
│   ├── profile_provider.dart
│   ├── sharedpreferences_provider.dart
│   ├── page_provider.dart
│   ├── input_provider.dart
│   └── counter_provider.dart
├── screens/
│   ├── splash_screen.dart        # Splash + session check
│   ├── onboarding_screen.dart    # Onboarding slides
│   ├── login_screen.dart         # Login form
│   ├── forgot_password_screen.dart
│   ├── otp_verification_screen.dart
│   ├── reset_password.dart
│   ├── page_screen.dart          # Bottom nav container
│   ├── home_screen.dart          # Dashboard
│   ├── scanner_screen.dart       # Leaf disease scanner
│   ├── predict_result_screen.dart
│   ├── analytic_screen.dart      # Diagnosis history grid
│   ├── detail_analytic_screen.dart
│   ├── report_screen.dart        # Charts & export
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   └── change_password.dart
├── widgets/
│   ├── custom_appbar.dart        # Top bar with weather
│   ├── custom_button_nav.dart    # Bottom navigation bar
│   ├── custom_card.dart          # Sensor, sprayer, report cards
│   ├── custom_filter.dart        # Sensor filter widget
│   └── custom_input.dart         # Reusable text input
└── functions/
    ├── dialog_func.dart
    ├── notification_func.dart
    ├── shimmer_card.dart
    └── snackbar_func.dart
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.2.1 | State management |
| `dio` | ^5.7.0 | HTTP client |
| `http` | ^1.2.2 | Additional HTTP |
| `shared_preferences` | ^2.0.0 | Token & session storage |
| `fl_chart` | ^1.1.1 | Line & pie charts |
| `image_picker` | ^1.1.2 | Gallery/camera image picker |
| `camera` | ^0.11.0+2 | Camera access |
| `excel` | ^4.0.6 | Excel file generation |
| `open_file` | ^3.5.10 | Open files natively |
| `gpt_markdown` | ^1.1.5 | Render markdown AI output |
| `animated_text_kit` | ^4.2.2 | Typewriter animation |
| `google_fonts` | ^8.0.2 | Typography |
| `shimmer` | ^3.0.0 | Loading skeleton effect |
| `responsive_framework` | ^1.5.1 | Responsive breakpoints |
| `flutter_staggered_grid_view` | ^0.7.0 | Masonry grid layout |
| `flutter_animate` | ^4.5.0 | UI animations |
| `intl` | ^0.20.2 | Date/number formatting |
| `timeago` | ^3.7.0 | Relative timestamps |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `encrypt` | ^5.0.3 | Data encryption |
| `quickalert` | ^1.1.0 | Alert dialogs |
| `awesome_snackbar_content` | ^0.1.4 | Styled snackbars |
| `logger` | ^2.4.0 | Debug logging |

---

## API Endpoints

All endpoints use the base URL configured in `lib/constants/api_constant.dart`.

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/login` | User login |
| `POST` | `/api/logout` | User logout |
| `GET` | `/api/check-token` | Validate JWT token |
| `GET` | `/api/getdataalat/{id}` | Get live sensor data |
| `POST` | `/api/aturpompa` | Toggle sprayer pump |
| `GET` | `/api/chartdaritanggal/{range}` | Get chart data by date range |
| `POST` | `/api/diagnosa/{userId}` | Submit leaf image for AI diagnosis |
| `GET` | `/api/data-diagnosa/{filter}` | Get diagnosis history (filtered) |
| `GET` | `/api/data-diagnosa-detail/{id}` | Get single diagnosis detail |
| `DELETE` | `/api/data-diagnosa/{id}` | Delete a diagnosis record |
| `GET` | `/api/get-pengguna/{id}` | Get user profile |
| `POST` | `/api/updatefoto/{id}` | Update profile photo |
| `POST` | `/api/update-data-pengguna-without-photo/{id}` | Update profile data |
| `POST` | `/api/change-password/{id}` | Change password |
| `POST` | `/api/lupa-password` | Forgot password (send OTP) |
| `POST` | `/api/lupa-password/verifikasi-otp/{email}` | Verify OTP |
| `POST` | `/api/lupa-password/kirim-ulang-otp/{email}` | Resend OTP |
| `POST` | `/api/lupa-password/reset-password/{email}` | Reset password |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.5.2`
- Dart SDK `^3.5.2`
- Android Studio / VS Code with Flutter extension
- A running backend API server

### Installation

```bash
# Clone the repository
git clone https://github.com/agungkurniawanid/kopi-greenhouse-aircontrol-app.git
cd kopi-greenhouse-aircontrol-app

# Install dependencies
flutter pub get
```

### Configuration

Edit `lib/constants/api_constant.dart` and update:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:PORT';
static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
```

### Run the App

```bash
flutter run
```

---

## Build Guide

```bash
# Generate launcher icons
flutter pub run flutter_launcher_icons

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release
```

---

---
---

# IQACS — Intelligent Quality & Air Control System untuk Greenhouse Pembibitan Kopi

> **Deskripsi Repository (untuk GitHub):**
> Aplikasi mobile berbasis Flutter untuk manajemen greenhouse pembibitan kopi yang cerdas. IQACS mengintegrasikan pemantauan sensor IoT real-time (suhu & kelembapan), kontrol sprayer otomatis, deteksi penyakit daun kopi berbasis AI menggunakan klasifikasi gambar, serta analitik data dengan grafik interaktif dan ekspor Excel — semua dalam satu platform terintegrasi.

---

## 📋 Daftar Isi

- [Gambaran Umum](#gambaran-umum)
- [Fitur Utama](#fitur-utama)
- [Alur Aplikasi](#alur-aplikasi)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Struktur Proyek](#struktur-proyek)
- [Daftar Dependensi](#daftar-dependensi)
- [Endpoint API](#endpoint-api)
- [Cara Memulai](#cara-memulai)
- [Panduan Build](#panduan-build)

---

## Gambaran Umum

**IQACS (Intelligent Quality & Air Control System)** adalah aplikasi mobile Flutter yang dirancang untuk manajemen greenhouse pembibitan kopi secara cerdas. Sistem ini terhubung ke perangkat sensor IoT yang memantau suhu dan kelembapan di dalam greenhouse secara real-time, memungkinkan operator mengontrol pompa sprayer air dari jarak jauh, serta memanfaatkan kecerdasan buatan (AI/ML) untuk mendeteksi penyakit daun kopi dari foto yang diambil langsung di lapangan.

Aplikasi berkomunikasi dengan server backend REST API dan dibangun dengan layout responsif yang mendukung berbagai ukuran layar dari ponsel hingga 4K.

---

## Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🌡️ **Monitoring Sensor Real-time** | Pembacaan suhu dan kelembapan langsung dari sensor IoT di greenhouse |
| 💧 **Kontrol Sprayer Jarak Jauh** | Nyalakan/matikan pompa sprayer air langsung dari aplikasi |
| 🤖 **Deteksi Penyakit Daun Kopi (AI)** | Upload atau ambil foto daun kopi; model AI mengklasifikasikan penyakit dan memberikan diagnosis beserta skor akurasi |
| 📊 **Analitik & Grafik** | Visualisasi grafik garis data suhu dan kelembapan historis, dapat difilter berdasarkan rentang tanggal (maks. 7 hari) |
| 📤 **Ekspor Excel** | Ekspor data grafik sensor ke format `.xlsx` untuk analisis offline |
| 🌤️ **Integrasi Cuaca** | Menampilkan kondisi cuaca lokal terkini melalui OpenWeather API |
| 📜 **Riwayat Diagnosis** | Lihat, filter, dan hapus riwayat diagnosis yang dikategorikan berdasarkan jenis penyakit (Miner, Phoma, Rust, Tidak Berpenyakit) |
| 🔒 **Autentikasi** | Login aman dengan JWT Bearer token, alur lupa password berbasis OTP, dan ganti password |
| 👤 **Profil Pengguna** | Lihat dan edit profil, ganti foto profil |
| 📱 **Layout Responsif** | Mendukung breakpoint Mobile, Tablet, Laptop, dan 4K |

---

## Alur Aplikasi

### 1. Splash Screen → Onboarding → Login
- Aplikasi dimulai dengan **Splash Screen** yang mengecek token sesi yang tersimpan di `SharedPreferences`.
- Pengguna baru akan ditampilkan **Onboarding Screen** (3 slide).
- Pengguna melakukan autentikasi melalui **Login Screen** menggunakan email dan password. Jika berhasil, token JWT dan ID pengguna disimpan secara lokal.

### 2. Dashboard Utama (Home Screen)
Setelah login, pengguna masuk ke **Home Screen** yang menampilkan:
- **AppBar** — menampilkan sapaan pengguna dan informasi cuaca.
- **Kartu Utama** — menampilkan nilai suhu dan kelembapan langsung dari sensor IoT.
- **Kartu Filter** — memungkinkan pengguna memfilter data sensor berdasarkan rentang waktu.
- **Kartu Sensor** — tampilan detail suhu/kelembapan.
- **Kartu Sprayer** — tombol untuk mengaktifkan/menonaktifkan pompa sprayer melalui API.
- **Kartu Laporan** — tautan cepat ke halaman analitik/laporan.

### 3. Scanner Screen (Deteksi Penyakit)
**Scanner Screen** menyediakan dua cara untuk mengirim foto daun untuk diagnosis AI:
- **Buka Kamera** — mengambil foto langsung dari kamera perangkat.
- **Buka Folder** — memilih gambar dari galeri perangkat.

Setelah dikirim, gambar diunggah melalui multipart POST ke endpoint inferensi AI backend. API mengembalikan label diagnosis (contoh: *Miner*, *Phoma*, *Rust*, *No Disease*) beserta persentase akurasi dan deskripsi yang dihasilkan AI.

**Hasil ditampilkan di Predict Result Screen:**
- Gambar daun lebar penuh
- Nama diagnosis + badge akurasi
- Deskripsi markdown yang dihasilkan AI dengan animasi typewriter

Scanner screen juga menampilkan daftar **Diagnosis Terbaru** (satu jam terakhir), setiap entri dapat diketuk untuk membuka halaman detail atau dihapus.

### 4. Analytic Screen (Riwayat)
Menampilkan semua riwayat diagnosis dalam **layout masonry grid**, dapat difilter berdasarkan kategori penyakit melalui tab:
- Semua | Miner | Phoma | No Disease | Rust

Mengetuk item akan membuka **Detail Analytic Screen** yang menampilkan detail diagnosis lengkap untuk rekaman tersebut.

### 5. Report Screen (Grafik & Data)
- **Grafik Garis** — memvisualisasikan rata-rata suhu dan kelembapan harian dalam rentang tanggal yang dipilih (maks. 7 hari).
- **Detail Kelembapan** — grafik donat/radial per hari.
- **Detail Suhu** — grafik donat/radial per hari.
- **Ekspor** — mengekspor data yang terlihat ke file Excel (`.xlsx`) yang disimpan secara lokal.
- **Filter** — date range picker untuk memilih periode kustom.

### 6. Profil & Manajemen Akun
- Lihat dan edit profil pengguna (nama, email, nomor telepon).
- Ganti foto profil.
- Ganti password.
- Alur lupa password: masukkan email → terima OTP → verifikasi OTP → set password baru.

---

## Teknologi yang Digunakan

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`)
- **HTTP Client:** Dio (`dio`) + `http`
- **Penyimpanan Lokal:** SharedPreferences
- **Grafik:** fl_chart
- **Render Hasil AI:** `gpt_markdown`, `animated_text_kit`
- **Penanganan Gambar:** `image_picker`, `camera`
- **Ekspor:** `excel`, `open_file`
- **UI:** `google_fonts`, `gap`, `shimmer`, `flutter_animate`, `responsive_framework`, `flutter_staggered_grid_view`
- **Notifikasi:** `awesome_snackbar_content`, `quickalert`
- **Internasionalisasi:** `intl`, `timeago`

---

## Struktur Proyek

```
lib/
├── main.dart                     # Entry point aplikasi, breakpoint responsif
├── constants/
│   ├── api_constant.dart         # Semua base URL dan endpoint API
│   └── dio_constant.dart         # Konfigurasi Dio client
├── models/                       # Model data (JSON serialization)
├── providers/                    # State management Riverpod
├── screens/                      # Halaman-halaman aplikasi
├── widgets/                      # Komponen UI yang dapat digunakan ulang
└── functions/                    # Fungsi utilitas (snackbar, dialog, dll.)
```

---

## Daftar Dependensi

Lihat bagian [Dependencies](#dependencies) di atas untuk daftar lengkap paket yang digunakan.

---

## Endpoint API

Semua endpoint menggunakan base URL yang dikonfigurasi di `lib/constants/api_constant.dart`. Lihat bagian [API Endpoints](#api-endpoints) di atas untuk daftar lengkapnya.

---

## Cara Memulai

### Prasyarat

- Flutter SDK `^3.5.2`
- Dart SDK `^3.5.2`
- Android Studio / VS Code dengan ekstensi Flutter
- Server backend API yang sedang berjalan

### Instalasi

```bash
# Clone repositori
git clone https://github.com/agungkurniawanid/kopi-greenhouse-aircontrol-app.git
cd kopi-greenhouse-aircontrol-app

# Install dependensi
flutter pub get
```

### Konfigurasi

Edit `lib/constants/api_constant.dart` dan perbarui:

```dart
static const String baseUrl = 'http://IP_SERVER_ANDA:PORT';
static const String openWeatherApiKey = 'API_KEY_OPENWEATHER_ANDA';
```

### Jalankan Aplikasi

```bash
flutter run
```

---

## Panduan Build

```bash
# Generate launcher icons
flutter pub run flutter_launcher_icons

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release
```

---

*IQACS — Intelligent Quality & Air Control System | Sistem Pemantauan & Kontrol Kualitas Udara Greenhouse Kopi*
