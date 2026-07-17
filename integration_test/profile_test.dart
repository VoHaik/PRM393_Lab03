// Test Case 8: Profile Navigation
// Verifies user profile information is displayed correctly on the Profile screen.
// Tests: Avatar display, user name, email, notification center presence, and sign out button.

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/screens/profile_screen.dart';
import '../lib/viewmodels/auth_viewmodel.dart';
import '../lib/viewmodels/profile_viewmodel.dart';
import '../lib/viewmodels/search_viewmodel.dart';
import '../lib/viewmodels/dashboard_viewmodel.dart';
import '../lib/injection_container.dart' as di;
import '../lib/services/auth_service.dart';
import '../lib/services/analytics_service.dart';
import '../lib/services/fcm_service.dart';
import '../lib/services/remote_config_service.dart';
import '../lib/utils/app_config.dart';
import 'mock_services.dart';

void main() {
  final sl = GetIt.instance;

  patrolWidgetTest(
    'Test Case 8 – Profile Navigation: Verify Profile Screen Content',
    ($) async {
      // =========================================================
      // SETUP: DI reset and mock injection
      // =========================================================
      await sl.reset();

      final config = await AppConfig.load();
      try {
        await Firebase.initializeApp(options: config.firebaseOptions);
      } catch (e) {} // Ignore if already initialized
      
      await di.init(config);

      // Override with mock services
      await sl.unregister<AuthService>();
      await sl.unregister<AnalyticsService>();
      await sl.unregister<FcmService>();
      await sl.unregister<RemoteConfigService>();

      sl.registerLazySingleton<AuthService>(() => MockAuthService());
      sl.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());
      sl.registerLazySingleton<FcmService>(() => MockFcmService());
      sl.registerLazySingleton<RemoteConfigService>(() => MockRemoteConfigService());

      // =========================================================
      // STEP 1: Launch Profile Screen directly with Providers
      // =========================================================
      
      // Đăng nhập giả lập để có dữ liệu User
      await sl<AuthService>().signInWithGoogle();
      
      await $.pumpWidgetAndSettle(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: sl<AuthViewModel>()),
            ChangeNotifierProvider.value(value: sl<ProfileViewModel>()),
            ChangeNotifierProvider.value(value: sl<SearchViewModel>()),
            ChangeNotifierProvider.value(value: sl<DashboardViewModel>()),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      // =========================================================
      // STEP 4: Verify Profile Screen Content
      // =========================================================

      // 4a. Header section title visible
      expect($('User Settings & Labs'), findsOneWidget,
          reason: 'Profile screen header should be visible');

      // 4b. User display name from mock (FakeUser.displayName = 'Test Professor')
      expect($('Test Professor'), findsOneWidget,
          reason: 'Authenticated user display name should appear');

      // 4c. User email from mock
      expect($('test.professor@example.com'), findsOneWidget,
          reason: 'Authenticated user email should appear');

      // 4d. Sign Out button is present
      expect($(find.byKey(const Key('sign_out_button'))), findsOneWidget,
          reason: 'Sign Out button must be visible on Profile screen');

      // 4e. Notification Center section is present
      expect($('Notification Center (FCM)'), findsOneWidget,
          reason: 'FCM Notification Center section header should be visible');

      // 4f. Empty notification placeholder is shown
      expect($(find.byKey(const Key('no_notification_placeholder'))), findsOneWidget,
          reason: 'Should show empty state when no notifications received');

      // 4g. Remote Config section is visible
      expect($('Remote Config Demo'), findsOneWidget,
          reason: 'Remote Config section must be present on Profile screen');

      // 4h. Crashlytics Demo section is visible
      expect($('Crashlytics Demo'), findsOneWidget,
          reason: 'Crashlytics Demo section must be present');

      // 4i. Both crashlytics buttons are present
      expect($(find.byKey(const Key('handled_exception_button'))), findsOneWidget,
          reason: 'Handled Exception button should be visible');
      expect($(find.byKey(const Key('test_crash_button'))), findsOneWidget,
          reason: 'Force Crash button should be visible');
    },
  );
}
