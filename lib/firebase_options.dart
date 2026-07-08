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
    apiKey: 'AIzaSyDB1HuCMlR3q83sHcMYomc7F6B2EHi2GEc',
    appId: '1:736803003999:web:412d89deeb9cd11e6305ea',
    messagingSenderId: '736803003999',
    projectId: 'journal-trend-analyzer-7cd2e',
    authDomain: 'journal-trend-analyzer-7cd2e.firebaseapp.com',
    storageBucket: 'journal-trend-analyzer-7cd2e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcI_6dgnT8t1jktbPrDa6ScpBUZ_9dGBM',
    appId: '1:736803003999:android:2bb76ba97974ddb86305ea',
    messagingSenderId: '736803003999',
    projectId: 'journal-trend-analyzer-7cd2e',
    storageBucket: 'journal-trend-analyzer-7cd2e.firebasestorage.app',
  );
}
