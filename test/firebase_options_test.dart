import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/utils/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Firebase and Google options are loaded from env asset', () async {
    final envString = await rootBundle.loadString('.env.json');
    final env = jsonDecode(envString) as Map<String, dynamic>;
    final config = await AppConfig.load();

    expect(config.webFirebaseOptions.apiKey, env['FIREBASE_WEB_API_KEY']);
    expect(config.webFirebaseOptions.appId, env['FIREBASE_WEB_APP_ID']);
    expect(
      config.androidFirebaseOptions.apiKey,
      env['FIREBASE_ANDROID_API_KEY'],
    );
    expect(
      config.androidFirebaseOptions.appId,
      env['FIREBASE_ANDROID_APP_ID'],
    );
    expect(
      config.googleSignInWebClientId,
      env['GOOGLE_SIGN_IN_WEB_CLIENT_ID'],
    );
  });
}
