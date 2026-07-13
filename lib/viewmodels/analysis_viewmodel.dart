import 'package:flutter/material.dart';
import '../services/openalex_service.dart';

class AnalysisViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  AnalysisViewModel({required this.openAlexService});

  bool _isLoading = false;
  String? _errorMessage;
  Map<int, int> _trendData = {};
  List<Map<String, dynamic>> _topKeywords = [];
  List<Map<String, dynamic>> _topAuthors = [];
  List<Map<String, dynamic>> _topJournals = [];
  String _keyword = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<int, int> get trendData => _trendData;
  List<Map<String, dynamic>> get topKeywords => _topKeywords;
  List<Map<String, dynamic>> get topAuthors => _topAuthors;
  List<Map<String, dynamic>> get topJournals => _topJournals;
  String get keyword => _keyword;

  Future<void> fetchAnalysis(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      _trendData = {};
      _topKeywords = [];
      _topAuthors = [];
      _topJournals = [];
      _keyword = '';
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _keyword = trimmedKeyword;
    notifyListeners();

    try {
      final results = await Future.wait([
        openAlexService.getPublicationsTrend(trimmedKeyword),
        openAlexService.getTopKeywords(trimmedKeyword),
        openAlexService.getTopAuthors(trimmedKeyword),
        openAlexService.getTopJournals(trimmedKeyword),
      ]);

      _trendData = results[0] as Map<int, int>;
      _topKeywords = results[1] as List<Map<String, dynamic>>;
      _topAuthors = results[2] as List<Map<String, dynamic>>;
      _topJournals = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _trendData = {};
      _topKeywords = [];
      _topAuthors = [];
      _topJournals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
