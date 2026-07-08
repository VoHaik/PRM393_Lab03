import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/firebase_options.dart';

void main() {
  test('web Firebase options are configured for the project', () {
    expect(DefaultFirebaseOptions.web.projectId, 'journal-trend-analyzer-7cd2e');
    expect(DefaultFirebaseOptions.web.messagingSenderId, '736803003999');
    expect(DefaultFirebaseOptions.web.apiKey,
        'AIzaSyDB1HuCMlR3q83sHcMYomc7F6B2EHi2GEc');
    expect(DefaultFirebaseOptions.web.appId,
        '1:736803003999:web:412d89deeb9cd11e6305ea');
    expect(DefaultFirebaseOptions.web.authDomain,
        'journal-trend-analyzer-7cd2e.firebaseapp.com');
  });
}
