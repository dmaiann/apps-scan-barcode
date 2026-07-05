# ScanIt - Smart Barcode & QR App

ScanIt adalah aplikasi mobile berbasis Flutter yang dirancang untuk menscan dan membuat barcode serta QR code dengan mudah. Dibangun dengan desain UI/UX yang modern (*glassmorphism*, warna dinamis, dan animasi yang mulus), aplikasi ini memberikan pengalaman pengguna yang sangat premium.

## 🚀 Fitur Utama

- **Scan Barcode & QR Code**: Memindai berbagai macam tipe barcode secara langsung dengan kamera (*full-screen preview*) dilengkapi dengan animasi garis laser.
- **Auto-Detection**: Otomatis mendeteksi hasil scan. Jika hasil berupa tautan/URL, tersedia tombol aksi cepat untuk membukanya.
- **Generate QR & Barcode**: Membuat QR Code, Code 128, EAN 13, dan UPC-A secara *real-time* sembari Anda mengetik.
- **Modern & Smooth UI**: Transisi layar yang halus, dilengkapi *splash screen* dinamis, *bottom navigation bar* yang modern, dan dukungan *Dark Mode*.
- **Haptic Feedback**: Memberikan getaran (*vibrate*) dan kilat layar (*flash*) sebagai feedback saat kode berhasil dipindai.
- **Flashlight & Camera Switch**: Dukungan untuk menghidupkan *flash* dan memutar kamera (depan/belakang).

## 🛠️ Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Scanner**: [mobile_scanner](https://pub.dev/packages/mobile_scanner)
- **Generator**: [qr_flutter](https://pub.dev/packages/qr_flutter) & [barcode_widget](https://pub.dev/packages/barcode_widget)
- **Animasi**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Lainnya**: Google Fonts, url_launcher

## 📱 Cara Menjalankan

1. Pastikan Anda telah menginstal Flutter SDK terbaru.
2. Clone repositori ini:
   ```bash
   git clone https://github.com/dmaiann/apps-scan-barcode.git
   ```
3. Pindah ke direktori proyek:
   ```bash
   cd apps-scan-barcode
   ```
4. Dapatkan seluruh *dependencies*:
   ```bash
   flutter pub get
   ```
5. Jalankan aplikasi di emulator atau perangkat fisik (disarankan menggunakan *physical device* untuk menguji kamera):
   ```bash
   flutter run
   ```

## 📸 Tampilan Aplikasi
Aplikasi ini memiliki arsitektur yang sangat modular (*Clean Architecture*) di dalam direktori `lib/`, memisahkan *core/theme*, *shared widgets*, dan tiap *features* (Splash, Home, Scan, Generate) sehingga kode mudah untuk dipelihara.
