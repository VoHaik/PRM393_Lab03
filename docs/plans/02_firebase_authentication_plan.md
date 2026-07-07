# Firebase Authentication (Google Sign-In) Integration Plan

This implementation plan describes the technical steps to integrate **Firebase Authentication with Google Sign-In** into the restructured MVVM + Provider codebase. It includes adding configuration settings, updating dependencies, establishing authentication services and view models, building the Login and Profile screens, and enforcing routing guards.

---

## User Review Required

> [!IMPORTANT]
> To successfully implement Firebase Authentication and Google Sign-In, you must complete the following manual configuration steps on the Firebase Console:

1. **Create Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com/) and create a new project named `Journal-Trend-Analyzer` (or similar).
2. **Add Android App**: Add an Android application to your Firebase project. Use the Package Name / Application ID: **`com.example.journal_trend_analyzer`** (see [build.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/build.gradle.kts#L8)).
3. **Register SHA-1 Fingerprint**:
   * Generate your local debug SHA-1 certificate fingerprint using the command:
     `keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore` (default password is `android`).
   * Add this SHA-1 fingerprint in your Firebase project's Android app settings. **This is required for Google Sign-In to function.**
4. **Enable Google Sign-In**: In the Firebase Console, go to **Build > Authentication > Sign-in method**, enable the **Google** provider, and save.
5. **Download Config File**: Download **`google-services.json`** and place it in the project directory at:
   `android/app/google-services.json`
6. **Enable Web App (Optional for Chrome Testing)**: If you plan to test on Chrome, you must also add a Web app in the Firebase console, copy the configuration object, and initialize it dynamically for web. *Note: Google Sign-In on Web requires custom OAuth client clientID configuration.*

---

## Open Questions

> [!NOTE]
> Currently, the package name in `android/app/build.gradle.kts` is `com.example.journal_trend_analyzer`. If you plan to release the app or change the package name later, please let me know so we can update it before registering on Firebase.

---

## Proposed Changes

### Dependencies & Build Configurations

#### [MODIFY] [pubspec.yaml](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/pubspec.yaml)
* Add dependencies:
  * `firebase_core: ^2.32.0`
  * `firebase_auth: ^4.20.0`
  * `google_sign_in: ^6.2.1`

#### [MODIFY] [settings.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/settings.gradle.kts)
* Add Google services Gradle plugin inside the `plugins` block:
  ```kotlin
  id("com.google.gms.google-services") version "4.4.1" apply false
  ```

#### [MODIFY] [build.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/build.gradle.kts)
* Apply Google services Gradle plugin inside the `plugins` block:
  ```kotlin
  id("com.google.gms.google-services")
  ```

---

### Core & Services (`lib/services/`)

#### [NEW] [auth_service.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/services/auth_service.dart)
Create an authentication service class wrapping `FirebaseAuth` and `GoogleSignIn` SDKs. It will expose:
* `Stream<User?> get authStateChanges` (Listen to user state changes)
* `User? get currentUser`
* `Future<UserCredential?> signInWithGoogle()`
* `Future<void> signOut()`

---

### ViewModels (`lib/viewmodels/`)

#### [NEW] [auth_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/auth_viewmodel.dart)
Create a ChangeNotifier class to manage UI state for authentication:
* Expose state: `bool isLoading`, `String? errorMessage`, `User? user`, `bool get isAuthenticated => user != null`.
* Expose actions: `signIn()`, `signOut()`.
* Listen to `AuthService.authStateChanges` stream to update state automatically.

---

### UI Screens & Navigation

#### [NEW] [login_screen.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/screens/login_screen.dart)
Create a Login Screen with a premium design matching the theme (Neon Orange, Dark background, glassmorphism card, and a polished Google Sign-In button).

#### [NEW] [profile_screen.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/screens/profile_screen.dart)
Create a Profile Screen displaying:
* User profile picture (avatar), name, and email.
* A "Sign Out" button.
* Placeholders for "Notification Center", "PDF Export", "Crashlytics Demo" and "Remote Config Demo" (which will be implemented in subsequent phases).

#### [MODIFY] [main_shell.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/widgets/main_shell.dart)
* Add a 4th tab item: **Profile** in the BottomNavigationBar (index 3).
* Link it to `/profile`.

#### [MODIFY] [router.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/navigation/router.dart)
* Add `/login` and `/profile` routes.
* Implement a **Redirect Guard**: Check if the user is authenticated via `AuthViewModel`. If not authenticated and attempting to access any screen other than `/login`, redirect them to `/login`.

---

### Bootstrapping

#### [MODIFY] [main.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/main.dart)
* Initialize Firebase inside `main()`:
  ```dart
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ```
* Provide `AuthViewModel` in `MultiProvider`.

#### [MODIFY] [injection_container.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/injection_container.dart)
* Register `AuthService` in the dependency injection container.
* Register `AuthViewModel` factory.

---

## Verification Plan

### Automated Tests
* Run `flutter analyze` to ensure no syntax errors.

### Manual Verification
* Run on Android emulator / physical device.
* Open the app: Verify it redirects to `/login`.
* Click **Sign In with Google**: Completes Google Auth and redirects to `/search` (Home).
* Navigate to **Profile**: Verify avatar photo, name, and email are loaded from the signed-in Google account.
* Click **Sign Out**: Verify user is redirected back to `/login` and access to other tabs is blocked.
