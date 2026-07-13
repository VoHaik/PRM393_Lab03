import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/utils/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const envString = '''
{
  "FIREBASE_WEB_API_KEY": "web-api-key",
  "FIREBASE_WEB_APP_ID": "web-app-id",
  "FIREBASE_ANDROID_API_KEY": "android-api-key",
  "FIREBASE_ANDROID_APP_ID": "android-app-id",
  "FIREBASE_MESSAGING_SENDER_ID": "messaging-sender-id",
  "FIREBASE_PROJECT_ID": "project-id",
  "FIREBASE_STORAGE_BUCKET": "storage-bucket",
  "FIREBASE_AUTH_DOMAIN": "auth-domain",
  "GOOGLE_SIGN_IN_WEB_CLIENT_ID": "web-client-id"
}
''';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == '.env.json') {
        final bytes = Uint8List.fromList(utf8.encode(envString));
        return ByteData.view(bytes.buffer);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('Firebase and Google options are loaded from env asset', () async {
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
