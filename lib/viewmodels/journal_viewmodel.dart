import 'package:flutter/material.dart';
import '../models/journal.dart';
import '../models/journal_detail.dart';
import '../services/openalex_service.dart';
import '../services/analytics_service.dart';

class JournalViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;
  final AnalyticsService analyticsService;

  JournalViewModel({
    required this.openAlexService,
    required this.analyticsService,
  });

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;
  String? _detailErrorMessage;
  String _topic = '';
  List<Journal> _journals = [];
  JournalDetailData? _selectedJournalDetail;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  String? get detailErrorMessage => _detailErrorMessage;
  String get topic => _topic;
  List<Journal> get journals => List.unmodifiable(_journals);
  JournalDetailData? get selectedJournalDetail => _selectedJournalDetail;

  // Calculates ranked statistics for UI
  double get totalPublicationsInTopJournals {
    return _journals.fold(0.0, (sum, j) => sum + j.publicationCount);
  }

  Future<void> loadForTopic(String topic) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      _topic = '';
      _journals = [];
      _errorMessage = null;
      _selectedJournalDetail = null;
      _detailErrorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _topic = trimmedTopic;
    notifyListeners();

    try {
      final journalsData = await openAlexService.getTopJournals(trimmedTopic);
      
      _journals = journalsData
          .where((journalMap) {
            final displayName = journalMap['key_display_name']?.toString().trim() ?? '';
            return displayName.isNotEmpty && displayName.toLowerCase() != 'unknown';
          })
          .take(10) // Display top 10 journals
          .map((journalMap) {
            final keyId = journalMap['key']?.toString() ?? '';
            final displayName = journalMap['key_display_name']?.toString() ?? 'Unknown Source';
            return Journal(
              id: keyId,
              displayName: displayName,
              publisher: 'Various Publishers',
              type: 'journal',
              publicationCount: journalMap['count'] as int? ?? 0,
            );
          })
          .toList();
    } catch (e) {
      _journals = [];
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJournalDetail(String journalId, String keyword) async {
    final trimmedId = journalId.trim();
    if (trimmedId.isEmpty) {
      _selectedJournalDetail = null;
      _detailErrorMessage = null;
      notifyListeners();
      return;
    }

    _isDetailLoading = true;
    _detailErrorMessage = null;
    _selectedJournalDetail = null;
    notifyListeners();

    try {
      final detail = await openAlexService.getJournalDetail(trimmedId, keyword);
      _selectedJournalDetail = detail;

      // Log Analytics view_journal event
      await analyticsService.logViewJournal(detail.displayName);
    } catch (e) {
      _selectedJournalDetail = null;
      _detailErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
