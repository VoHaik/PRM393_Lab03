import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  final String googleSignInWebClientId;

  AppConfig({required this.googleSignInWebClientId});

  static const _envAssetPath = '.env.json';

  static Future<AppConfig> load() async {
    final jsonString = await rootBundle.loadString(_envAssetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final clientId = data['GOOGLE_SIGN_IN_WEB_CLIENT_ID'] as String?;
    if (clientId == null || clientId.isEmpty) {
      throw Exception(
          'GOOGLE_SIGN_IN_WEB_CLIENT_ID is missing in $_envAssetPath');
    }

    return AppConfig(googleSignInWebClientId: clientId);
  }
}
