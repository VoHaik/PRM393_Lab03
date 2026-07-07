# Walkthrough - Firebase Authentication Integration

This walkthrough documents the successful integration of **Firebase Authentication with Google Sign-In** into the Journal Trend Analyzer project under the MVVM + Provider architecture, as required by the Lab 03 specifications.

---

## 🛠️ Changes Implemented

### 1. SDK Configurations & Gradle
* Modified [settings.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/settings.gradle.kts) and [build.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/build.gradle.kts) to support the `com.google.gms.google-services` Gradle plugin (version `4.5.0`).
* Installed `firebase_core`, `firebase_auth`, and `google_sign_in` dependencies.
* Placed the latest `google-services.json` file in `android/app/`.

### 2. Services & ViewModels
* **`auth_service.dart`**: Implements authentication flows wrapping FirebaseAuth and GoogleSignIn.
* **`auth_viewmodel.dart`**: Listens to the auth state changes stream, stores the current authenticated `User` object, manages error/loading states, and exposes `signIn` and `signOut` methods.

### 3. UI Screens & Navigation Shell
* **`login_screen.dart`**: A cyberpunk-themed login gateway featuring the Scientia Analytics branding and a polished "Continue with Google" button. Handles error display and loading overlays.
* **`profile_screen.dart`**: Renders the current user's profile picture, name, and email from their Google Account, provides a "Sign Out" option, and displays cards representing future Firebase service integrations (FCM, Storage, Remote Config, Crashlytics).
* **`main_shell.dart`**: Reconfigured the bottom navigation bar to support 4 navigation tabs (Search, Trends, Dashboard, and Profile).

### 4. Routing Guards & Bootstrap
* **`router.dart`**: Added `/login` and `/profile` routes, and implemented a redirect guard checking if `FirebaseAuth.instance.currentUser != null`. If not logged in, any attempt to access internal screens redirects to `/login`. If logged in, visiting `/login` redirects to `/search`.
* **`main.dart`**: Bootstrapped Firebase initialization via `Firebase.initializeApp()` before app execution, and registered the `AuthViewModel` provider.
* **`injection_container.dart`**: Registered singletons and factories for `AuthService` and `AuthViewModel`.

---

## ✅ Verification & Validation Results

### 1. Code Quality & Lints
Ran `flutter analyze`:
* **Result**: **0 codebase errors!**

### 2. Unit Tests
Ran `flutter test`:
* **Result**: **All tests passed!**

```bash
00:00 +4: All tests passed!
```
