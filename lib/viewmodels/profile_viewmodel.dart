import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../models/analytics_summary.dart';
import '../services/analytics_service.dart';
import '../services/fcm_service.dart';
import '../services/remote_config_service.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ReportService reportService;
  final StorageService storageService;
  final AnalyticsService analyticsService;
  final FcmService fcmService;
  final RemoteConfigService remoteConfigService;

  ProfileViewModel({
    required this.reportService,
    required this.storageService,
    required this.analyticsService,
    required this.fcmService,
    required this.remoteConfigService,
  }) {
    // Lắng nghe khi FCM nhận được thông báo mới -> notify UI
    fcmService.onNewNotification = () => notifyListeners();
  }

  // --- State: PDF Export ---
  bool _isExporting = false;
  String? _exportError;
  String? _uploadedUrl;

  bool get isExporting => _isExporting;
  String? get exportError => _exportError;
  String? get uploadedUrl => _uploadedUrl;

  // --- State: Remote Config ---
  bool _isLoadingConfig = false;
  bool _configFetched = false;
  String? _configError;

  bool get isLoadingConfig => _isLoadingConfig;
  bool get configFetched => _configFetched;
  String? get configError => _configError;
  int get maxJournalsDisplay => remoteConfigService.maxJournalsDisplay;
  int get maxKeywordsDisplay => remoteConfigService.maxKeywordsDisplay;

  // --- State: Crashlytics ---
  String? _crashlyticsMessage;
  String? get crashlyticsMessage => _crashlyticsMessage;

  // --- Getters: FCM Notifications ---
  List<AppNotification> get notifications => fcmService.notifications;

  // ===================================================
  // PDF Export & Firebase Storage Upload
  // ===================================================
  Future<void> exportAndUploadReport(AnalyticsSummary summary, String topic) async {
    _isExporting = true;
    _exportError = null;
    _uploadedUrl = null;
    notifyListeners();

    try {
      final pdfBytes = await reportService.generatePdfReport(summary, topic);

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'report_$timestamp.pdf';
      final downloadUrl = await storageService.uploadPdfReport(
        topic: topic,
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      _uploadedUrl = downloadUrl;
      await analyticsService.logExportPdf(topic);
    } catch (e) {
      _exportError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  void clearExportState() {
    _isExporting = false;
    _exportError = null;
    _uploadedUrl = null;
    notifyListeners();
  }

  // ===================================================
  // Firebase Remote Config
  // ===================================================
  Future<void> fetchRemoteConfig() async {
    _isLoadingConfig = true;
    _configError = null;
    _configFetched = false;
    notifyListeners();

    try {
      await remoteConfigService.fetchAndActivate();
      _configFetched = true;
    } catch (e) {
      _configError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingConfig = false;
      notifyListeners();
    }
  }

  // ===================================================
  // Firebase Crashlytics Demos
  // ===================================================

  /// Demo 1: Tạo một Handled Exception (lỗi được bắt và gửi lên Crashlytics)
  Future<void> triggerHandledException() async {
    try {
      throw Exception('This is a TEST handled exception from Trí - ProfileViewModel');
    } catch (e, stack) {
      // Ghi lỗi lên Crashlytics (app KHÔNG crash, lỗi được xử lý)
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Handled exception demo triggered by user',
        fatal: false,
      );
      _crashlyticsMessage = '✅ Handled exception recorded! Check Firebase Crashlytics Console.';
      notifyListeners();
    }
  }

  /// Demo 2: Force crash app (ghi nhận và làm ứng dụng văng để test Crashlytics)
  void triggerTestCrash() {
    // Ghi log trước khi crash
    FirebaseCrashlytics.instance.log('User triggered test crash from Profile screen');
    // Force crash - Firebase sẽ ghi nhận cái này trong Crashlytics Console
    FirebaseCrashlytics.instance.crash();
  }

  // ===================================================
  // FCM Notifications
  // ===================================================
  void clearNotifications() {
    fcmService.clearNotifications();
    // notifyListeners được gọi từ callback trong constructor
  }
}
