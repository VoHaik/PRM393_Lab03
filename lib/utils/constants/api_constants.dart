class ApiConstants {
  static const String baseUrl = 'https://api.openalex.org';
  static const String worksEndpoint = '$baseUrl/works';

  // Polite Pool requests are faster and more reliable.
  static const String contactEmail = 'your_email@domain.com';

  static Map<String, String> get headers => {
        'User-Agent': 'JournalTrendAnalyzer/1.0 (mailto:$contactEmail)',
        'Accept': 'application/json',
      };
}
