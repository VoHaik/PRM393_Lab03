class AbstractParser {
  /// Reconstructs the original publication abstract from OpenAlex's abstract_inverted_index map.
  static String reconstruct(Map<String, dynamic>? invertedIndex) {
    if (invertedIndex == null || invertedIndex.isEmpty) {
      return 'No abstract available.';
    }

    try {
      int maxPos = 0;
      invertedIndex.forEach((word, positions) {
        if (positions is List) {
          for (var pos in positions) {
            if (pos is int && pos > maxPos) {
              maxPos = pos;
            }
          }
        }
      });

      final List<String?> wordsList = List.filled(maxPos + 1, null);
      invertedIndex.forEach((word, positions) {
        if (positions is List) {
          for (var pos in positions) {
            if (pos is int && pos >= 0 && pos < wordsList.length) {
              wordsList[pos] = word;
            }
          }
        }
      });

      return wordsList.where((w) => w != null).join(' ');
    } catch (e) {
      return 'Error reconstructing abstract.';
    }
  }
}
