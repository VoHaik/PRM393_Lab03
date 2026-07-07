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
    'Verify Authentication Flow & Redirect Guards',
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

      // 3. Verify unauthenticated redirect to Login Screen
      expect($('Authentication Required'), findsOneWidget);
      expect($('Continue with Google'), findsOneWidget);

      // 4. Tap the Google Sign-In button
      await $.tap($('Continue with Google'));
      await $.pumpAndSettle();

      // 5. Verify transition to Search Screen (Home)
      expect($('Scientia Analytics'), findsOneWidget);
      expect($('Search topic (e.g. Machine Learning)...'), findsOneWidget);

      // 6. Navigate to Profile tab in bottom navigation
      await $.tap($('Profile'));
      await $.pumpAndSettle();

      // 7. Verify user profile details display correctly
      expect($('User Settings & Labs'), findsOneWidget);
      expect($('Test Professor'), findsOneWidget);
      expect($('test.professor@example.com'), findsOneWidget);

      // 8. Tap Sign Out button
      await $.tap($('Sign Out'));
      await $.pumpAndSettle();

      // 9. Verify redirect back to Login Screen
      expect($('Authentication Required'), findsOneWidget);
      expect($('Continue with Google'), findsOneWidget);
    },
  );
}
