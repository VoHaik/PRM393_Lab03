class ApiConstants {
  static const String baseUrl = 'https://api.openalex.org';
  static const String worksEndpoint = '$baseUrl/works';

  // TODO: Replace with your actual email to use the OpenAlex Polite Pool
  // Polite Pool requests are faster and more reliable.
  static const String contactEmail = 'nguyensoi0966622100@gmail.com';

  static Map<String, String> get headers => {
        'User-Agent': 'JournalTrendAnalyzer/1.0 (mailto:$contactEmail)',
        'Accept': 'application/json',
      };
}
