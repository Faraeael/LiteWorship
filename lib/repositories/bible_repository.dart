import '../data/database.dart';

// ============================================================================
// LITEWORSHIP — Bible Repository
// Clean interface for Bible verse data operations with FTS5 search
// ============================================================================

class BibleRepository {
  final LiteWorshipDatabase _db;

  BibleRepository(this._db);

  /// Factory constructor using singleton database
  factory BibleRepository.instance() {
    return BibleRepository(LiteWorshipDatabase.instance);
  }

  /// Search Bible verses by content
  /// 
  /// Uses FTS5 for instant fuzzy matching across 31,000+ verses.
  /// 
  /// Example:
  /// ```dart
  /// final verses = await repo.search('for God so loved');
  /// // Returns John 3:16 and related verses
  /// ```
  Future<List<BibleVerse>> search(String query, {String? version}) async {
    return _db.searchBibleVerses(query, version: version);
  }

  /// Get verses by reference
  /// 
  /// Examples:
  /// ```dart
  /// // Single verse
  /// await repo.getByReference(version: 'KJV', book: 'John', chapter: 3, verseStart: 16);
  /// 
  /// // Verse range
  /// await repo.getByReference(version: 'KJV', book: 'John', chapter: 3, verseStart: 16, verseEnd: 17);
  /// 
  /// // Entire chapter
  /// await repo.getByReference(version: 'KJV', book: 'John', chapter: 3);
  /// ```
  Future<List<BibleVerse>> getByReference({
    required String version,
    required String book,
    required int chapter,
    int? verseStart,
    int? verseEnd,
  }) {
    return _db.getVersesByReference(
      version: version,
      book: book,
      chapter: chapter,
      verseStart: verseStart,
      verseEnd: verseEnd,
    );
  }

  /// Get all books for a Bible version
  /// 
  /// Returns books in canonical order (Genesis to Revelation)
  Future<List<String>> getBooks({required String version}) {
    return _db.getBooksForVersion(version);
  }

  /// Get all chapters for a book
  Future<List<int>> getChapters({
    required String version,
    required String book,
  }) {
    return _db.getChaptersForBook(version, book);
  }

  /// Check if a Bible version has been loaded
  Future<bool> hasVersion(String version) {
    return _db.hasBibleData(version);
  }

  /// Get total verse count for a version
  Future<int> getVerseCount(String version) {
    return _db.getBibleVerseCount(version);
  }

  /// Format a verse reference as a string
  /// 
  /// Example: "John 3:16" or "John 3:16-17"
  static String formatReference(BibleVerse verse, {BibleVerse? endVerse}) {
    if (endVerse != null && endVerse.verse != verse.verse) {
      return '${verse.book} ${verse.chapter}:${verse.verse}-${endVerse.verse}';
    }
    return '${verse.book} ${verse.chapter}:${verse.verse}';
  }

  /// Format multiple verses as a single text block
  static String formatVersesAsText(List<BibleVerse> verses) {
    if (verses.isEmpty) return '';
    return verses.map((v) => v.content).join(' ');
  }
}
