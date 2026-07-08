import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/firebase_options.dart';

void main() {
  test('web Firebase options are configured for the project', () {
    expect(DefaultFirebaseOptions.web.projectId, 'journal-trend-analyzer-7cd2e');
    expect(DefaultFirebaseOptions.web.messagingSenderId, '736803003999');
  });
}
