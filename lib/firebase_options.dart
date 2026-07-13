import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: '736803003999',
    projectId: 'journal-trend-analyzer-7cd2e',
    authDomain: 'journal-trend-analyzer-7cd2e.firebaseapp.com',
    storageBucket: 'journal-trend-analyzer-7cd2e.firebasestorage.app',
    measurementId: 'G-GDW060H3TW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: '736803003999',
    projectId: 'journal-trend-analyzer-7cd2e',
    storageBucket: 'journal-trend-analyzer-7cd2e.firebasestorage.app',
  );
}
