import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/main.dart';
import '../lib/injection_container.dart' as di;
import '../lib/services/auth_service.dart';
import '../lib/services/analytics_service.dart';
import '../lib/utils/app_config.dart';
import 'mock_services.dart';

void main() {
  final sl = GetIt.instance;

  patrolTest(
    'Verify Authentication Flow & Redirect Guards',
    ($) async {
      // 1. Reset DI and register mocks
      await sl.reset();
      
      final config = await AppConfig.load();
      try {
        await Firebase.initializeApp(options: config.firebaseOptions);
      } catch (e) {} // Ignore if already initialized
      
      await di.init(config);
      
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
      await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
      await $.pumpAndSettle();

      // 4. Tap the Google Sign-In button
      await $.tap($('Continue with Google'));
      await $.pumpAndSettle();
      await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
      await $.pumpAndSettle();

      // 5. Verify transition to Search Screen (Home)
      expect($('Scientia Analytics'), findsOneWidget);
      expect($('Search topic (e.g. Machine Learning)...'), findsOneWidget);

      // 6. Navigate to Profile tab in bottom navigation
      await $.tap($('Profile'));
      await $.pumpAndSettle();
      await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
      await $.pumpAndSettle();

      // 7. Verify user profile details display correctly
      expect($('User Settings & Labs'), findsOneWidget);
      expect($('Test Professor'), findsOneWidget);
      expect($('test.professor@example.com'), findsOneWidget);

      // 8. Tap Sign Out button
      await $.tap($('Sign Out'));
      await $.pumpAndSettle();
      await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
      await $.pumpAndSettle();

      // 9. Verify redirect back to Login Screen
      expect($('Authentication Required'), findsOneWidget);
      expect($('Continue with Google'), findsOneWidget);
    },
  );
}
