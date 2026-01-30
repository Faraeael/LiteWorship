
import 'package:drift/drift.dart';
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
  Future<List<BibleVerse>> searchByKeyword(String query, {String? version}) async {
    return _db.searchBibleVerses(query, version: version);
  }

  /// Get verses by reference
  Future<List<BibleVerse>> getByReference({
    required String version,
    required String book,
    required int chapter,
    int? verseStart,
    int? verseEnd,
  }) {
    // EasyWorship Behavior: Always fetch the FULL chapter, even if a specific verse is requested.
    // The Provider/UI will handle highlighting the specific verse.
    return _db.getVersesByReference(
      version: version,
      book: book,
      chapter: chapter,
      // Intentionally ignoring verseStart/verseEnd here to get whole chapter
    );
  }

  /// Get available bible versions
  Future<List<String>> getAvailableVersions() {
    return _db.getAvailableVersions();
  }

  /// Get all books for a Bible version
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

  // ==========================================================================
  // INGESTION METHODS
  // ==========================================================================
  
  /// Batch insert bible verses (Used by Ingestion Service)
  Future<void> batchInsertBibleVerses(List<BibleVersesCompanion> verses) async {
    // Using insertOrReplace to safely handle duplicates during ingestion retry
    await _db.batch((batch) {
      batch.insertAll(_db.bibleVerses, verses, mode: InsertMode.insertOrReplace);
    });
  }

  /// Rebuild FTS indexes manually (Used by Ingestion Service)
  Future<void> rebuildFtsIndexes() async {
    try {
      await _db.rebuildFtsIndexes();
    } catch (e) {
      print("FTS Error ignored: $e");
    }
  }

  /// Delete a specific version
  Future<void> deleteVersion(String version) async {
     await _db.customStatement('DELETE FROM bible_verses WHERE version = ?', [version]);
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Format a verse reference as a string
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
