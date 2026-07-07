import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/core/utils/abstract_parser.dart';

void main() {
  group('AbstractParser', () {
    test('should return default message when index is null or empty', () {
      expect(AbstractParser.reconstruct(null), 'No abstract available.');
      expect(AbstractParser.reconstruct({}), 'No abstract available.');
    });

    test('should reconstruct abstract correctly from inverted index', () {
      final invertedIndex = {
        'Hello': [0],
        'world': [1],
        'this': [2],
        'is': [3],
        'a': [4],
        'test': [5]
      };

      expect(
        AbstractParser.reconstruct(invertedIndex),
        'Hello world this is a test',
      );
    });

    test('should handle unordered lists and index offsets correctly', () {
      final invertedIndex = {
        'test': [2],
        'a': [0],
        'is': [1],
      };

      expect(
        AbstractParser.reconstruct(invertedIndex),
        'a is test',
      );
    });
  });
}
