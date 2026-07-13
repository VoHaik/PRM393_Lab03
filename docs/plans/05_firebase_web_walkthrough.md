# Walkthrough - Firebase Web Configuration & Security

This walkthrough documents the successful integration of **Environment Variables** via `String.fromEnvironment()` and `--dart-define-from-file=.env.json` to secure API Keys, App IDs, and Client IDs in the Journal Trend Analyzer project. Sensitive settings have been successfully excluded from version control.

---

## 🛠️ Changes Implemented

### 1. Secret Keys & Environment Configuration
* Created **`.env.json`** at the root of the project to hold the following parameters:
  * `FIREBASE_WEB_API_KEY`
  * `FIREBASE_WEB_APP_ID`
  * `FIREBASE_ANDROID_API_KEY`
  * `FIREBASE_ANDROID_APP_ID`
  * `GOOGLE_SIGN_IN_WEB_CLIENT_ID`
* Created **`.env.json.example`** as a template to document what environment variables are expected by the application.
* Updated **`.gitignore`** to exclude:
  * `.env.json`
  * `android/app/google-services.json`
  * Added `!.vscode/launch.json` so that the run configuration remains public for users.

### 2. Dart Source Code Updates
* Updated [lib/firebase_options.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/firebase_options.dart) to load Firebase `apiKey` and `appId` using compile-time constants:
  * `String.fromEnvironment('FIREBASE_WEB_API_KEY')`
  * `String.fromEnvironment('FIREBASE_WEB_APP_ID')`
  * `String.fromEnvironment('FIREBASE_ANDROID_API_KEY')`
  * `String.fromEnvironment('FIREBASE_ANDROID_APP_ID')`
* Updated [lib/services/auth_service.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/services/auth_service.dart) to load the Google Sign-in client ID using `const String.fromEnvironment('GOOGLE_SIGN_IN_WEB_CLIENT_ID')` on the Web platform.
* Removed the hardcoded `<meta name="google-signin-client_id">` tag from [web/index.html](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/web/index.html) to prevent token leakage in the static markup.

### 3. Execution & Build Configuration Scripts
Updated the configuration scripts to automatically inject environment secrets:
* **VS Code Launch Configuration:** Added `--dart-define-from-file` parameter in [.vscode/launch.json](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/.vscode/launch.json).
* **Web Launch Script:** Added the `--dart-define-from-file=.env.json` argument to [run_web.bat](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/run_web.bat).
* **Android Release Script:** Added the `--dart-define-from-file=.env.json` argument to [build_apk.bat](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/build_apk.bat).

---

## ✅ Verification & Validation Results

### 1. Code Quality & Lints
Ran `flutter analyze`:
* **Result**: **0 codebase errors!**

### 2. Unit Tests
Ran `flutter test --dart-define-from-file=.env.json`:
* **Result**: **All tests passed!**

```bash
00:04 +8: All tests passed!
```
