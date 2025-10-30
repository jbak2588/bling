/// Push notification preferences model
/// Stores user-specific push settings like scope and subscribed tag IDs.
class PushPrefsModel {
  /// Notification geographic scope (e.g., 'rt', 'rw', 'kel', 'kec').
  final String scope;

  /// Subscribed local-news tag IDs.
  final List<String> tags;

  // ❌ [수정] final List<String>? regionKeys;
  // ✅ [수정] Cloud Function(buildTopicsFromPrefs)과 호환되려면 Map이어야 합니다.
  /// region keys for server-side topic mapping (e.g., {'kel': 'DKI|Jakarta Barat|...'}).
  final Map<String, String> regionKeys;

  /// Optional: device tokens managed elsewhere.
  final List<String> deviceTokens;

  /// Optional: FCM topics subscribed (server-managed).
  final List<String> subscribedTopics;

  PushPrefsModel({
    this.scope = 'kel',
    this.tags = const [],
    this.regionKeys = const {},
    this.deviceTokens = const [],
    this.subscribedTopics = const [],
  });

  PushPrefsModel copyWith({
    String? scope,
    List<String>? tags,
    Map<String, String>? regionKeys, // ✅ [수정] Map 타입
    List<String>? deviceTokens,
    List<String>? subscribedTopics,
  }) {
    return PushPrefsModel(
      scope: scope ?? this.scope,
      tags: tags ?? this.tags,
      regionKeys: regionKeys ?? this.regionKeys,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scope': scope,
      'tags': tags,
      'regionKeys': regionKeys,
      'deviceTokens': deviceTokens,
      'subscribedTopics': subscribedTopics,
    };
  }

  factory PushPrefsModel.fromMap(Map<String, dynamic> map) {
    // ✅ [경고 수정] '_asStringList' -> 'asStringList'
    List<String> asStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    // ✅ [신규] Map<String, String> 파싱용 헬퍼
    Map<String, String> asStringMap(dynamic v) {
      if (v == null) return <String, String>{};
      if (v is Map) {
        return v
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return <String, String>{};
    }

    return PushPrefsModel(
      scope: map['scope'] as String? ?? 'kel',
      tags: asStringList(map['tags']),
      regionKeys: asStringMap(map['regionKeys']), // ✅ [수정] Map 헬퍼 사용
      deviceTokens: asStringList(map['deviceTokens']),
      subscribedTopics: asStringList(map['subscribedTopics']),
    );
  }
}
