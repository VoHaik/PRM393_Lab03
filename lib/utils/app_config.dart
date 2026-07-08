import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  final String googleSignInWebClientId;
  final FirebaseOptions webFirebaseOptions;
  final FirebaseOptions androidFirebaseOptions;

  AppConfig({
    required this.googleSignInWebClientId,
    required this.webFirebaseOptions,
    required this.androidFirebaseOptions,
  });

  static const _envAssetPath = '.env.json';

  FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      return webFirebaseOptions;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidFirebaseOptions;
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static Future<AppConfig> load() async {
    final jsonString = await rootBundle.loadString(_envAssetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final messagingSenderId = _required(data, 'FIREBASE_MESSAGING_SENDER_ID');
    final projectId = _required(data, 'FIREBASE_PROJECT_ID');
    final storageBucket = _required(data, 'FIREBASE_STORAGE_BUCKET');

    return AppConfig(
      googleSignInWebClientId: _required(data, 'GOOGLE_SIGN_IN_WEB_CLIENT_ID'),
      webFirebaseOptions: FirebaseOptions(
        apiKey: _required(data, 'FIREBASE_WEB_API_KEY'),
        appId: _required(data, 'FIREBASE_WEB_APP_ID'),
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: _required(data, 'FIREBASE_AUTH_DOMAIN'),
        storageBucket: storageBucket,
      ),
      androidFirebaseOptions: FirebaseOptions(
        apiKey: _required(data, 'FIREBASE_ANDROID_API_KEY'),
        appId: _required(data, 'FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
    );
  }

  static String _required(Map<String, dynamic> data, String key) {
    final value = data[key] as String?;
    if (value == null || value.isEmpty) {
      throw Exception('$key is missing in $_envAssetPath');
    }
    return value;
  }
}
