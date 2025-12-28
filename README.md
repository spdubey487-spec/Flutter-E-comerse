# Flutter E-comerse

Minimal starter Flutter project scaffolded to support Android, iOS, Web, and Windows.

Prerequisites
- Flutter SDK installed and on `PATH` (stable channel recommended)
- For iOS builds: Xcode on macOS
- For Windows builds: Visual Studio with Desktop development workload

Quick setup
```bash
# generate missing platform folders and default native files
flutter create .

# fetch packages
flutter pub get

# run on connected Android device / emulator
flutter run

# run on web (Chrome)
flutter run -d chrome

# build release for web
flutter build web

# build APK
flutter build apk

# build for Windows (run on Windows host)
flutter build windows

# build for iOS (run on macOS with Xcode)
flutter build ios
```

Notes
- This repo already contains `lib/main.dart`, `pubspec.yaml`, and basic ignores. Run `flutter create .` once to generate native platform folders (`android`, `ios`, `windows`, `web`, etc.).
- Keep `assets/images/` populated with app images; `pubspec.yaml` already references that folder.
