# SafeHer AI — Mobile App (Flutter)

Cross-platform (Android + iOS) rebuild of SafeHer AI, replacing the original React/base44
frontend. Talks to the FastAPI backend in `../backend`.

## Stack
- Flutter 3.x, Dart null-safety
- State: `provider`
- Routing: `go_router` (with auth-aware redirects)
- Networking: `dio` (auto token-refresh interceptor) + `web_socket_channel` for the live
  Monitor feed
- Location: `geolocator`
- Maps: `flutter_map` + OpenStreetMap/CartoDB tiles (no Google Maps API key required)
- Evidence capture: `camera` + `record`, uploaded as real files via `multipart/form-data` —
  **no Base64 encoding anywhere in this app.**
- Secure token storage: `flutter_secure_storage` (Keychain / Keystore)

## Setup

This repo ships `lib/`, `pubspec.yaml`, and `assets/` but not the generated native
`android/`, `ios/`, `web/`, etc. folders (those are machine-specific build scaffolding).
Generate them once, then layer this code on top:

```bash
cd mobile
flutter create --org ai.safeher --project-name safeher_ai .   # generates android/ ios/ etc. in place, keeps this lib/ and pubspec.yaml
flutter pub get
```

### Point the app at your backend
By default the app calls `http://10.0.2.2:8000` (the Android emulator's alias for your
host machine's `localhost`, where the FastAPI backend runs). Override at run time:

```bash
# Android emulator (default already works)
flutter run

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Physical device (use your computer's LAN IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.23:8000
```

### Required permissions
Add these after running `flutter create`:

**`android/app/src/main/AndroidManifest.xml`** (inside `<manifest>`, above `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.VIBRATE" />
```

**`ios/Runner/Info.plist`** (inside the top-level `<dict>`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SafeHer AI needs your location to share it during an emergency or journey.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>SafeHer AI needs background location to keep tracking you during an active emergency.</string>
<key>NSCameraUsageDescription</key>
<string>SafeHer AI captures photo/video evidence automatically when you trigger an SOS.</string>
<key>NSMicrophoneUsageDescription</key>
<string>SafeHer AI records audio evidence automatically when you trigger an SOS.</string>
```

Then run:
```bash
flutter run
```

## Known simplifications (honest notes, not hidden)
- **Front+back simultaneous capture**: most phones can't stream both cameras at once
  without a specialized plugin. `EvidenceCaptureService` records continuously on the back
  camera and briefly switches to the front camera every 20s for a selfie, then resumes —
  it satisfies "front + back photos + continuous back video" without needing unsupported
  dual-camera hardware access. See the comment at the top of
  `lib/services/evidence_capture_service.dart`.
- **AI Safety Monitor score on Home** is a static placeholder (86) — a real risk-scoring
  model needs a historical-incident data pipeline, which is out of scope here. The Safety
  Map's "Area Safety Report" uses a simple time-of-day heuristic for the same reason,
  clearly commented in `lib/features/safety_map/safety_map_screen.dart`.
- I could not run a Flutter toolchain in the environment this was built in, so unlike the
  backend (which I actually executed end-to-end), this code has not been compiled. Run
  `flutter analyze` after `flutter pub get` and expect to fix a handful of small issues.

## Project layout
```
lib/
  core/            theme + constants (API base URL, tunables)
  models/          plain Dart models mirroring the backend Pydantic schemas
  services/        Dio API client + one service class per backend router
  providers/       ChangeNotifier state for auth/contacts/journeys/emergencies/monitor
  widgets/         shared UI (buttons, text fields, bottom-nav shell)
  features/        one folder per screen/flow (auth, home, emergency, safety_map,
                    journey, trusted_circle, assistant, fake_call, profile, monitor)
```
