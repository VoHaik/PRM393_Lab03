import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';

import '../lib/screens/profile_screen.dart';
import '../lib/services/analytics_service.dart';
import '../lib/services/report_service.dart';
import '../lib/services/storage_service.dart';
import '../lib/viewmodels/auth_viewmodel.dart';
import '../lib/viewmodels/search_viewmodel.dart';
import '../lib/viewmodels/dashboard_viewmodel.dart';
import '../lib/viewmodels/profile_viewmodel.dart';
import 'mock_services.dart';

void main() {
  final sl = GetIt.instance;

  tearDown(() async {
    await sl.reset();
  });

  patrolTest(
    'Test Case 9 - PDF Export generates report, uploads to Firebase Storage, and logs export_pdf analytics',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      final auth = MockAuthService();
      final storage = MockStorageService();
      final report = MockReportService();

      // Register Services
      sl.registerLazySingleton<AnalyticsService>(() => analytics);
      sl.registerLazySingleton<StorageService>(() => storage);
      sl.registerLazySingleton<ReportService>(() => report);

      final authViewModel = AuthViewModel(
        authService: auth,
        analyticsService: analytics,
      );

      final searchViewModel = SearchViewModel(
        openAlexService: openAlex,
        analyticsService: analytics,
      );
      // Pre-populate search topic
      await searchViewModel.searchTopic('Artificial Intelligence');

      final dashboardViewModel = DashboardViewModel(
        openAlexService: openAlex,
      );
      // Pre-populate dashboard summary
      await dashboardViewModel.fetchDashboard('Artificial Intelligence');

      final profileViewModel = ProfileViewModel(
        reportService: report,
        storageService: storage,
        analyticsService: analytics,
        fcmService: MockFcmService(),
        remoteConfigService: MockRemoteConfigService(),
      );

      await $.pumpWidgetAndSettle(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authViewModel),
            ChangeNotifierProvider.value(value: searchViewModel),
            ChangeNotifierProvider.value(value: dashboardViewModel),
            ChangeNotifierProvider.value(value: profileViewModel),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      expect($('User Settings & Labs'), findsOneWidget);
      expect($('Report Export & Storage'), findsOneWidget);

      // Tap on the Report Export & Storage card
      await $.tap($('Report Export & Storage'));
      await $.pumpAndSettle();

      // Assert successful upload dialog elements are displayed
      expect($('Export Successful'), findsOneWidget);
      expect($('Report uploaded successfully to Firebase Storage!'), findsOneWidget);
      expect($('Copy Link'), findsOneWidget);
      expect($('Open'), findsOneWidget);
      expect($('Close'), findsOneWidget);

      // Verify Firebase Analytics export_pdf event
      expect(analytics.loggedEvents.contains('export_pdf'), isTrue);
      expect(
        analytics.loggedParameters['export_pdf']?['topic'],
        equals('Artificial Intelligence'),
      );

      // Tap Close button
      await $.tap($('Close'));
      await $.pumpAndSettle();
      expect($('Export Successful'), findsNothing);
    },
  );
}
