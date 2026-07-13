import 'package:flutter/material.dart';

import '../models/keyword_analytics.dart';
import '../models/keyword_detail.dart';
import '../services/openalex_service.dart';

class KeywordViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  KeywordViewModel({required this.openAlexService});

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;
  String? _detailErrorMessage;
  String _topic = '';
  List<KeywordAnalytics> _keywords = [];
  KeywordDetailData? _detail;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  String? get detailErrorMessage => _detailErrorMessage;
  String get topic => _topic;
  List<KeywordAnalytics> get keywords => List.unmodifiable(_keywords);
  KeywordDetailData? get detail => _detail;

  List<KeywordAnalytics> get mostFrequentKeywords => List.unmodifiable(_keywords);

  List<KeywordAnalytics> get trendingKeywords {
    final sortedKeywords = [..._keywords];
    sortedKeywords.sort((a, b) {
      final growthCompare = b.growth.compareTo(a.growth);
      if (growthCompare != 0) {
        return growthCompare;
      }
      return b.publicationCount.compareTo(a.publicationCount);
    });
    return List.unmodifiable(sortedKeywords);
  }

  Future<void> loadForTopic(String topic) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      _topic = '';
      _keywords = [];
      _errorMessage = null;
      _detail = null;
      _detailErrorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _topic = trimmedTopic;
    notifyListeners();

    try {
      _keywords = await openAlexService.getKeywordAnalytics(trimmedTopic);
    } catch (e) {
      _keywords = [];
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      _detail = null;
      _detailErrorMessage = null;
      notifyListeners();
      return;
    }

    _isDetailLoading = true;
    _detailErrorMessage = null;
    _detail = null;
    notifyListeners();

    try {
      _detail = await openAlexService.getKeywordDetail(trimmedKeyword);
    } catch (e) {
      _detail = null;
      _detailErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
