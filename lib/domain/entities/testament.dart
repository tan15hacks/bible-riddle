enum Testament {
  old,
  newTestament;

  String get key => switch (this) {
        Testament.old => 'old',
        Testament.newTestament => 'new',
      };

  String get label => switch (this) {
        Testament.old => 'Old Testament',
        Testament.newTestament => 'New Testament',
      };

  static Testament fromKey(String key) {
    return switch (key) {
      'old' => Testament.old,
      'new' => Testament.newTestament,
      _ => throw ArgumentError.value(key, 'key', 'Expected old or new'),
    };
  }
}
