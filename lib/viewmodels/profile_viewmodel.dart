import 'package:flutter/material.dart';
import '../models/analytics_summary.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ReportService reportService;
  final StorageService storageService;
  final AnalyticsService analyticsService;

  ProfileViewModel({
    required this.reportService,
    required this.storageService,
    required this.analyticsService,
  });

  bool _isExporting = false;
  String? _exportError;
  String? _uploadedUrl;

  bool get isExporting => _isExporting;
  String? get exportError => _exportError;
  String? get uploadedUrl => _uploadedUrl;

  Future<void> exportAndUploadReport(AnalyticsSummary summary, String topic) async {
    _isExporting = true;
    _exportError = null;
    _uploadedUrl = null;
    notifyListeners();

    try {
      // 1. Generate PDF Report
      final pdfBytes = await reportService.generatePdfReport(summary, topic);

      // 2. Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'report_$timestamp.pdf';
      final downloadUrl = await storageService.uploadPdfReport(
        topic: topic,
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      _uploadedUrl = downloadUrl;

      // 3. Log Analytics export_pdf event
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
}
