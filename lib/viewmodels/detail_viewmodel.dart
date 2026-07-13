import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class DetailViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  DetailViewModel({required this.openAlexService});

  bool _isLoading = false;
  String? _errorMessage;
  Publication? _publication;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Publication? get publication => _publication;

  Future<void> loadPublicationDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _publication = await openAlexService.getPublicationById(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _publication = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPublication(Publication pub) {
    _publication = pub;
    notifyListeners();
  }
}
