import 'package:flutter/material.dart';
import '../models/analytics_summary.dart';
import '../services/openalex_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  DashboardViewModel({required this.openAlexService});

  bool _isLoading = false;
  String? _errorMessage;
  AnalyticsSummary? _summary;
  String _keyword = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnalyticsSummary? get summary => _summary;
  String get keyword => _keyword;

  Future<void> fetchDashboard(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      _summary = null;
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
      _summary = await openAlexService.getAnalyticsSummary(trimmedKeyword);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _summary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
