# Flutter E-comerse — Open Quick Commerce Platform

This repository is a starter scaffold for an open-source quick-commerce mobile app (food & grocery delivery) similar in concept to Zomato and Blinkit.

Project vision
- Open-source platform for quick commerce where revenue/profits are shared with delivery workers.
- Decentralized operation: no single owner or central controller — community-driven development and governance.

Planned core features
- Browsing restaurants & grocery stores
- Product listings, search and filters
- Cart, checkout and order tracking
- Rider/delivery partner onboarding and payouts
- Real-time order status and notifications
- Ratings, reviews, and basic analytics

What is in this repo now
- `lib/main.dart` — minimal Flutter UI starter
- `pubspec.yaml` — dependencies and assets
- `analysis_options.yaml` — lint rules
- `.github/workflows/android.yml` — CI workflow to build Android APK
- `scripts/create_platforms.sh` — helper to generate native platform folders

Local setup
```bash
# generate native platform folders (android/ios/web/windows)
./scripts/create_platforms.sh

# fetch packages
flutter pub get

# run on Android device/emulator
flutter run

# run on web (Chrome)
flutter run -d chrome

# build release APK
flutter build apk --release
```

CI / GitHub Actions
- A workflow is included at `.github/workflows/android.yml`. On push to `main` (or via manual dispatch) the workflow:
	- installs Flutter
	- runs `flutter create .` to ensure native folders exist
	- runs `flutter pub get`
	- builds a release APK and uploads it as an artifact

How to get the APK from CI
- After a successful workflow run, download the artifact named `app-release-apk` from the Actions run page.

Contributing
- Open-source contributions welcome. Please open issues and PRs for features, bug fixes, and localization.

License & governance
- This project is intended to be an open community resource. Add a license file (e.g., MIT or Apache-2.0) and a short governance/treasury policy describing how profits are distributed to delivery partners.

Next steps I can do for you
- Generate native platform files here and commit them (this adds larger Android/iOS folders).
- Add signing and secure release steps to the CI (recommended for production APKs).
- Add templates for contributions and issues.

If you want, I can generate the native folders and update the repo now (it requires running `flutter create .` in the environment). 
