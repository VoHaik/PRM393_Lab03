// Test Case 10: Remote Config
// Verifies that the app can fetch Firebase Remote Config values
// and display them correctly on the Profile screen.

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    'Test Case 10 – Remote Config: Fetch and Verify Configuration Values',
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

      // Override with mocks (MockRemoteConfigService returns max_journals=5, max_keywords=8)
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
      expect($('User Settings & Labs'), findsOneWidget);

      // =========================================================
      // STEP 3: Verify Remote Config section is present
      // =========================================================
      expect($(find.byKey(const Key('remote_config_section'))), findsOneWidget,
          reason: 'Remote Config section must be visible on Profile screen');

      // Verify the Fetch button is present before fetching
      expect($(find.byKey(const Key('fetch_remote_config_button'))), findsOneWidget,
          reason: 'Fetch Remote Config button should be visible');

      // Verify config values are NOT shown before fetching
      expect($(find.byKey(const Key('max_journals_config_value'))), findsNothing,
          reason: 'Config values should not show before fetch is triggered');

      // =========================================================
      // STEP 4: Tap Fetch Remote Config button
      // =========================================================
      final fetchButton = find.byKey(const Key('fetch_remote_config_button'));
      await $.tester.ensureVisible(fetchButton);
      await $.pumpAndSettle();
      await $.tap($(fetchButton));
      await $.pumpAndSettle();

      // =========================================================
      // STEP 5: Verify config values are displayed
      // =========================================================

      // 5a. max_journals_display row is visible
      final row1 = find.byKey(const Key('max_journals_config_value'));
      await $.tester.ensureVisible(row1);
      expect($(row1), findsOneWidget,
          reason: 'max_journals_display config row should be visible after fetch');

      // 5b. max_keywords_display row is visible
      final row2 = find.byKey(const Key('max_keywords_config_value'));
      await $.tester.ensureVisible(row2);
      expect($(row2), findsOneWidget,
          reason: 'max_keywords_display config row should be visible after fetch');

      // 5c. Verify the actual config key labels are displayed
      expect($('max_journals_display'), findsOneWidget,
          reason: 'Config key label for journals must be displayed');
      expect($('max_keywords_display'), findsOneWidget,
          reason: 'Config key label for keywords must be displayed');

      // 5d. Verify the fetched values match mock expectations (5 and 8)
      expect($('5'), findsOneWidget,
          reason: 'max_journals_display value should be 5 (from MockRemoteConfigService)');
      expect($('8'), findsOneWidget,
          reason: 'max_keywords_display value should be 8 (from MockRemoteConfigService)');
    },
  );
}
