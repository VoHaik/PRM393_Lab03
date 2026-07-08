import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mocktail/mocktail.dart';
import '../lib/models/analytics_summary.dart';
import '../lib/models/journal_detail.dart';
import '../lib/models/keyword_analytics.dart';
import '../lib/models/keyword_detail.dart';
import '../lib/models/publication.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/analytics_service.dart';
import '../lib/services/openalex_service.dart';
import '../lib/services/storage_service.dart';
import '../lib/services/report_service.dart';

class FakeUser extends Fake implements User {
  @override
  String get displayName => 'Test Professor';
  @override
  String get email => 'test.professor@example.com';
  @override
  String get photoURL => 'https://via.placeholder.com/150';
  @override
  String get uid => 'fake_uid_12345';
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  User get user => FakeUser();
}

class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  MockAuthService() {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<UserCredential?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = FakeUser();
    _controller.add(_currentUser);
    return FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeObserver extends Fake implements FirebaseAnalyticsObserver {}

class MockAnalyticsService implements AnalyticsService {
  final List<String> loggedEvents = [];
  final Map<String, Map<String, dynamic>> loggedParameters = {};

  @override
  FirebaseAnalyticsObserver getObserver() {
    return FakeObserver();
  }

  @override
  Future<void> logLogin() async {
    loggedEvents.add('login');
  }

  @override
  Future<void> logLogout() async {
    loggedEvents.add('logout');
  }

  @override
  Future<void> logSearchTopic(String keyword) async {
    loggedEvents.add('search_topic');
    loggedParameters['search_topic'] = {'keyword': keyword};
  }

  @override
  Future<void> logViewPublication({required String title, required int year}) async {
    loggedEvents.add('view_publication');
    loggedParameters['view_publication'] = {
      'publication_title': title,
      'publication_year': year,
    };
  }

  @override
  Future<void> logViewJournal(String journalName) async {
    loggedEvents.add('view_journal');
    loggedParameters['view_journal'] = {'journal_name': journalName};
  }

  @override
  Future<void> logViewKeyword(String keyword) async {
    loggedEvents.add('view_keyword');
    loggedParameters['view_keyword'] = {'keyword': keyword};
  }

  @override
  Future<void> logExportPdf(String topic) async {
    loggedEvents.add('export_pdf');
    loggedParameters['export_pdf'] = {'topic': topic};
  }
}

class MockOpenAlexService implements OpenAlexService {
  @override
  Future<int> getWorksCount(String keyword) async {
    return 20;
  }

  @override
  Future<List<KeywordAnalytics>> getKeywordAnalytics(
    String topic, {
    int limit = 5,
  }) async {
    return [
      const KeywordAnalytics(
        id: 'https://openalex.org/T1',
        name: 'Machine Learning',
        publicationCount: 12,
        totalTopicPublications: 20,
        trendByYear: {2023: 4, 2024: 8, 2025: 12},
      ),
      const KeywordAnalytics(
        id: 'https://openalex.org/T2',
        name: 'Deep Learning',
        publicationCount: 10,
        totalTopicPublications: 20,
        trendByYear: {2023: 1, 2024: 3, 2025: 10},
      ),
      const KeywordAnalytics(
        id: 'https://openalex.org/T3',
        name: 'Neural Networks',
        publicationCount: 8,
        totalTopicPublications: 20,
        trendByYear: {2023: 3, 2024: 4, 2025: 5},
      ),
    ].take(limit).toList();
  }

  @override
  Future<KeywordDetailData> getKeywordDetail(String keyword) async {
    return KeywordDetailData(
      keyword: keyword,
      trendByYear: const {2023: 2, 2024: 5, 2025: 9},
      relatedJournals: const [
        {
          'key': 'https://openalex.org/S-keyword',
          'key_display_name': 'Deep Learning Journal',
          'count': 6,
        },
      ],
      relatedPublications: [
        Publication(
          id: 'W-keyword',
          title: '$keyword Specific Paper',
          publicationYear: 2025,
          citedByCount: 50,
          doiUrl: '',
          abstractText: 'A deterministic keyword-specific publication.',
          authors: const [],
        ),
      ],
      topAuthors: const [
        {
          'key': 'https://openalex.org/A-keyword',
          'key_display_name': 'Deep Learning Author',
          'count': 4,
        },
      ],
    );
  }

  @override
  Future<List<Publication>> searchPublications(String keyword) async {
    return [
      Publication(
        id: 'W1',
        title: '$keyword Research Paper',
        publicationYear: 2024,
        citedByCount: 42,
        doiUrl: '',
        abstractText: 'A deterministic publication for Patrol tests.',
        authors: const [],
      ),
    ];
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    if (keyword == 'Machine Learning') {
      return {2023: 4, 2024: 8, 2025: 12};
    }
    if (keyword == 'Deep Learning') {
      return {2023: 1, 2024: 3, 2025: 10};
    }
    return {2022: 3, 2023: 8, 2024: 12};
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/T1',
        'key_display_name': 'Machine Learning',
        'count': 12,
      },
      {
        'key': 'https://openalex.org/T2',
        'key_display_name': 'Deep Learning',
        'count': 8,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/A1',
        'key_display_name': 'Jane Researcher',
        'count': 5,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/S1',
        'key_display_name': 'Journal of AI',
        'count': 6,
      },
    ];
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) async {
    return const AnalyticsSummary(
      totalPublications: 1,
      averageCitations: 42,
      peakYear: 2024,
    );
  }

  @override
  Future<JournalDetailData> getJournalDetail(String journalId, String keyword) async {
    return JournalDetailData(
      id: journalId,
      displayName: 'Mock Journal of AI',
      publisher: 'Mock Publisher Corp',
      worksCount: 120,
      citedByCount: 4200,
      averageCitations: 35.0,
      relatedPublications: [
        Publication(
          id: 'W-journal-1',
          title: 'Mock Related Journal Paper',
          publicationYear: 2024,
          citedByCount: 50,
          doiUrl: '',
          abstractText: 'Mock abstract text for related paper.',
          authors: const [],
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockStorageService implements StorageService {
  @override
  Future<String> uploadPdfReport({
    required String topic,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'https://firebasestorage.googleapis.com/v0/b/mock-bucket/o/reports%2Fmock_report.pdf?alt=media';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReportService implements ReportService {
  @override
  Future<Uint8List> generatePdfReport(AnalyticsSummary summary, String topic) async {
    return Uint8List.fromList([1, 2, 3, 4]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
