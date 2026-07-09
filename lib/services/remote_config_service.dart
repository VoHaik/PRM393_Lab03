import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service lấy cấu hình động từ Firebase Remote Config.
/// Cung cấp ít nhất 2 giá trị cấu hình theo yêu cầu checkpoint:
/// - max_journals_display: số lượng journal tối đa hiển thị
/// - max_keywords_display: số lượng keyword tối đa hiển thị
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // --- Tên các key trên Firebase Console ---
  static const String keyMaxJournals = 'max_journals_display';
  static const String keyMaxKeywords = 'max_keywords_display';

  // --- Giá trị mặc định (dùng khi chưa fetch được từ server) ---
  static const int defaultMaxJournals = 10;
  static const int defaultMaxKeywords = 10;

  bool _isFetched = false;
  bool get isFetched => _isFetched;

  Future<void> initialize() async {
    try {
      // Thiết lập giá trị default phòng khi không có internet
      await _remoteConfig.setDefaults({
        keyMaxJournals: defaultMaxJournals,
        keyMaxKeywords: defaultMaxKeywords,
      });

      // Cấu hình thời gian cache (dùng thời gian ngắn để dễ test)
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
      ));

      debugPrint('[RemoteConfig] Initialized with defaults.');
    } catch (e) {
      debugPrint('[RemoteConfig] Init error: $e');
    }
  }

  /// Fetch và activate giá trị mới nhất từ Firebase Console
  Future<void> fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      _isFetched = true;
      debugPrint('[RemoteConfig] fetchAndActivate: updated=$updated');
      debugPrint('[RemoteConfig] max_journals_display = $maxJournalsDisplay');
      debugPrint('[RemoteConfig] max_keywords_display = $maxKeywordsDisplay');
    } catch (e) {
      debugPrint('[RemoteConfig] fetchAndActivate error: $e');
    }
  }

  /// Giá trị 1: Số lượng journal tối đa hiển thị
  int get maxJournalsDisplay =>
      _remoteConfig.getInt(keyMaxJournals);

  /// Giá trị 2: Số lượng keyword tối đa hiển thị
  int get maxKeywordsDisplay =>
      _remoteConfig.getInt(keyMaxKeywords);

  /// Lấy toàn bộ các config hiện tại dưới dạng map để hiển thị
  Map<String, dynamic> getAllValues() => {
        keyMaxJournals: maxJournalsDisplay,
        keyMaxKeywords: maxKeywordsDisplay,
      };
}
