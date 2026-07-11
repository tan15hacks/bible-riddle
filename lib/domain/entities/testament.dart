enum Testament {
  old,
  newTestament;

  String get storageValue => switch (this) {
        Testament.old => 'old',
        Testament.newTestament => 'new',
      };

  String get label => switch (this) {
        Testament.old => 'Old Testament',
        Testament.newTestament => 'New Testament',
      };

  String get shortLabel => switch (this) {
        Testament.old => 'Old',
        Testament.newTestament => 'New',
      };

  static Testament fromStorage(String value) {
    return value == 'new' || value == 'newTestament' ? Testament.newTestament : Testament.old;
  }
}
