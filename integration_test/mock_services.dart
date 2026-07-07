import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mocktail/mocktail.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/analytics_service.dart';

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
