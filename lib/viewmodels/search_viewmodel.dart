import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class SearchViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  SearchViewModel({required this.openAlexService});

  bool _isLoading = false;
  String? _errorMessage;
  List<Publication> _publications = [];
  String _keyword = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Publication> get publications => _publications;
  String get keyword => _keyword;

  Future<void> searchTopic(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      _publications = [];
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
      _publications = await openAlexService.searchPublications(trimmedKeyword);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _publications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
