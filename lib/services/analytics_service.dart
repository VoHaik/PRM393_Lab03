import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() => FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin() async {
    await _analytics.logLogin();
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future<void> logSearchTopic(String keyword) async {
    await _analytics.logEvent(
      name: 'search_topic',
      parameters: {'keyword': keyword},
    );
  }

  Future<void> logViewPublication({
    required String title,
    required int year,
  }) async {
    await _analytics.logEvent(
      name: 'view_publication',
      parameters: {
        'publication_title': title,
        'publication_year': year,
      },
    );
  }

  Future<void> logViewJournal(String journalName) async {
    await _analytics.logEvent(
      name: 'view_journal',
      parameters: {'journal_name': journalName},
    );
  }

  Future<void> logViewKeyword(String keyword) async {
    await _analytics.logEvent(
      name: 'view_keyword',
      parameters: {'keyword': keyword},
    );
  }

  Future<void> logExportPdf(String topic) async {
    await _analytics.logEvent(
      name: 'export_pdf',
      parameters: {'topic': topic},
    );
  }
}
