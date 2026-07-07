import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get_it/get_it.dart';
import '../lib/main.dart';
import '../lib/injection_container.dart' as di;
import '../lib/services/auth_service.dart';
import '../lib/services/analytics_service.dart';
import 'mock_services.dart';

void main() {
  final sl = GetIt.instance;

  patrolTest(
    'Verify Firebase Analytics Event Logging',
    ($) async {
      // 1. Reset DI and register mocks
      await sl.reset();
      await di.init();
      
      await sl.unregister<AuthService>();
      await sl.unregister<AnalyticsService>();
      
      final mockAuth = MockAuthService();
      final mockAnalytics = MockAnalyticsService();
      
      sl.registerLazySingleton<AuthService>(() => mockAuth);
      sl.registerLazySingleton<AnalyticsService>(() => mockAnalytics);

      // 2. Launch App
      await $.pumpWidgetAndSettle(const MyApp());

      // 3. Log In (Verify 'login' event logged)
      await $.tap($('Continue with Google'));
      await $.pumpAndSettle();
      
      expect(mockAnalytics.loggedEvents.contains('login'), isTrue);

      // 4. Enter a search topic (e.g. 'Cybersecurity') and search
      await $.enterText(find.byType(TextField), 'Cybersecurity');
      await $.tap(find.byIcon(Icons.arrow_forward_rounded));
      await $.pumpAndSettle();

      // 5. Verify 'search_topic' event is logged with correct parameters
      expect(mockAnalytics.loggedEvents.contains('search_topic'), isTrue);
      expect(mockAnalytics.loggedParameters['search_topic']?['keyword'], equals('Cybersecurity'));

      // 6. Navigate to Profile, Sign Out, and verify 'logout' event logged
      await $.tap($('Profile'));
      await $.pumpAndSettle();
      await $.tap($('Sign Out'));
      await $.pumpAndSettle();

      expect(mockAnalytics.loggedEvents.contains('logout'), isTrue);
    },
  );
}
