# Firebase Web (Chrome) Configuration Plan

This implementation plan describes the technical steps to configure **Firebase Web support** for the Journal Trend Analyzer project. This will enable Firebase Authentication (Google Sign-In) and Firebase Analytics to function when running the app in Chrome/browser mode.

---

## User Review Required

> [!IMPORTANT]
> To enable Firebase and Google Sign-In on Chrome, you must perform the following manual configurations:

### Step 1: Create a Firebase Web App
1. Go to your [Firebase Console](https://console.firebase.google.com/) and open your project.
2. In **Project settings > General > Your apps**, click **Add app** and select **Web (`</>`)**.
3. Name the app (e.g., `Journal-Trend-Analyzer-Web`) and click **Register app**.
4. Firebase will show a configuration code block containing keys like `apiKey`, `authDomain`, `projectId`, etc. **Copy this object and paste it in the chat.**

### Step 2: Configure Google Sign-In Web Client ID
Firebase Auth with Google on Web requires an OAuth 2.0 Web Client ID registered in your Google Cloud Project:
1. Open the [Google Cloud Console Credentials Page](https://console.cloud.google.com/apis/credentials).
2. Select your Firebase project from the top dropdown.
3. Under **OAuth 2.0 Client IDs**, locate the client ID labeled **"Web client (auto created by Google Service)"** (or click **Create Credentials > OAuth client ID > Web application** if not present).
4. Edit this Web Client:
   * Under **Authorized JavaScript origins**, add:
     * `http://localhost`
     * `http://localhost:5000` (We will run Flutter web on a fixed port: `5000`)
   * Click **Save**.
5. Copy the **Client ID** string (it ends with `.apps.googleusercontent.com`). **Copy this string and paste it in the chat.**

---

## Proposed Changes

### Configuration & HTML (`web/`)

#### [MODIFY] [index.html](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/web/index.html)
* Add a meta tag in the `<head>` section specifying the Google Sign-in Web Client ID:
  ```html
  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
  ```

---

### Core & Services (`lib/`)

#### [MODIFY] [main.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/main.dart)
* Update `main()` to initialize Firebase with specific Web options when running on Web:
  ```dart
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  ```

#### [MODIFY] [auth_service.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/services/auth_service.dart)
* Update `GoogleSignIn` initialization to receive the Web Client ID when running on Web:
  ```dart
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' : null,
  );
  ```

---

## Verification Plan

### Automated Tests
* Run `flutter analyze` to verify the codebase compiles successfully.

### Manual Verification
* Run the Flutter app on Chrome on port `5000`:
  `flutter run -d chrome --web-port=5000`
* Open the browser console (F12) to verify there are no Firebase initialization errors.
* Click **Continue with Google** -> Verify the OAuth popup appears, completes login, and redirects to `/search`.
