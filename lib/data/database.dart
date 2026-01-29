import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'tables.dart';

part 'database.g.dart';

// ============================================================================
// LITEWORSHIP — Main Database
// Drift database with FTS5 full-text search for Songs and Bible
// ============================================================================

@DriftDatabase(tables: [Songs, BibleVerses])
class LiteWorshipDatabase extends _$LiteWorshipDatabase {
  LiteWorshipDatabase._internal(super.e);

  /// Singleton instance
  static LiteWorshipDatabase? _instance;

  /// Get the singleton database instance
  static LiteWorshipDatabase get instance {
    _instance ??= LiteWorshipDatabase._internal(_openConnection());
    return _instance!;
  }

  /// Open database connection using drift_flutter
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lite_worship',
      native: const DriftNativeOptions(
        // Enable shared cache for better performance
        shareAcrossIsolates: true,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Create all tables
        await m.createAll();

        // Create FTS5 virtual tables
        await _createFtsTables();

        // Create indexes for performance
        await _createIndexes();

        debugPrint('✅ Database created with FTS5 tables');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
        debugPrint('📦 Migrating database from v$from to v$to');
      },
    );
  }

  /// Create FTS5 virtual tables for full-text search
  Future<void> _createFtsTables() async {
    // Songs FTS5 table - uses porter tokenizer for stemming
    // (e.g., "amazing" matches "amazed", "loves" matches "loving")
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS songs_fts USING fts5(
        title,
        lyrics,
        content='songs',
        content_rowid='id',
        tokenize='porter unicode61 remove_diacritics 2'
      );
    ''');

    // Triggers to keep FTS in sync with main songs table
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS songs_ai AFTER INSERT ON songs BEGIN
        INSERT INTO songs_fts(rowid, title, lyrics) 
        VALUES (new.id, new.title, new.lyrics);
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS songs_ad AFTER DELETE ON songs BEGIN
        INSERT INTO songs_fts(songs_fts, rowid, title, lyrics) 
        VALUES ('delete', old.id, old.title, old.lyrics);
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS songs_au AFTER UPDATE ON songs BEGIN
        INSERT INTO songs_fts(songs_fts, rowid, title, lyrics) 
        VALUES ('delete', old.id, old.title, old.lyrics);
        INSERT INTO songs_fts(rowid, title, lyrics) 
        VALUES (new.id, new.title, new.lyrics);
      END;
    ''');

    // Bible verses FTS5 table
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS bible_verses_fts USING fts5(
        book,
        content_text,
        content='bible_verses',
        content_rowid='id',
        tokenize='porter unicode61 remove_diacritics 2'
      );
    ''');

    // Triggers for Bible FTS sync
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS bible_ai AFTER INSERT ON bible_verses BEGIN
        INSERT INTO bible_verses_fts(rowid, book, content_text) 
        VALUES (new.id, new.book, new.content);
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS bible_ad AFTER DELETE ON bible_verses BEGIN
        INSERT INTO bible_verses_fts(bible_verses_fts, rowid, book, content_text) 
        VALUES ('delete', old.id, old.book, old.content);
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS bible_au AFTER UPDATE ON bible_verses BEGIN
        INSERT INTO bible_verses_fts(bible_verses_fts, rowid, book, content_text) 
        VALUES ('delete', old.id, old.book, old.content);
        INSERT INTO bible_verses_fts(rowid, book, content_text) 
        VALUES (new.id, new.book, new.content);
      END;
    ''');
  }

  /// Create indexes for fast lookups
  Future<void> _createIndexes() async {
    // Composite index for Bible verse lookups
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_bible_lookup 
      ON bible_verses(version, book, chapter, verse);
    ''');

    // Index for book order (for navigation)
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_bible_order 
      ON bible_verses(version, book_order, chapter, verse);
    ''');

    // Index for song title search (non-FTS fallback)
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_song_title 
      ON songs(title);
    ''');
  }

  // ==========================================================================
  // SONG QUERIES
  // ==========================================================================

  /// Search songs by title or lyrics using FTS5
  /// Returns results prioritized by title match over lyrics match
  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      return select(songs).get();
    }

    // Escape FTS5 special characters and add prefix matching
    final escapedQuery = _escapeFtsQuery(query);

    // FTS5 search with ranking - title matches rank higher
    final results = await customSelect('''
      SELECT s.*, 
             bm25(songs_fts, 10.0, 1.0) as rank
      FROM songs s
      INNER JOIN songs_fts ON songs_fts.rowid = s.id
      WHERE songs_fts MATCH ?
      ORDER BY rank
      LIMIT 50
    ''', variables: [Variable.withString(escapedQuery)]).get();

    return results.map((row) {
      return Song(
        id: row.read<int>('id'),
        title: row.read<String>('title'),
        lyrics: row.read<String>('lyrics'),
        tags: row.read<String>('tags'),
        author: row.readNullable<String>('author'),
        ccliNumber: row.readNullable<String>('ccli_number'),
        copyright: row.readNullable<String>('copyright'),
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
      );
    }).toList();
  }

  /// Watch songs as they change (reactive stream)
  Stream<List<Song>> watchAllSongs() => select(songs).watch();

  /// Get a single song by ID
  Future<Song?> getSongById(int id) {
    return (select(songs)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new song
  Future<int> insertSong(SongsCompanion song) {
    return into(songs).insert(song);
  }

  /// Update an existing song
  Future<bool> updateSong(Song song) {
    return update(songs).replace(song);
  }

  /// Delete a song by ID
  Future<int> deleteSong(int id) {
    return (delete(songs)..where((t) => t.id.equals(id))).go();
  }

  // ==========================================================================
  // BIBLE QUERIES
  // ==========================================================================

  /// Search Bible verses by content using FTS5
  Future<List<BibleVerse>> searchBibleVerses(String query,
      {String? version}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final escapedQuery = _escapeFtsQuery(query);

    String sql = '''
      SELECT b.*, 
             bm25(bible_verses_fts) as rank
      FROM bible_verses b
      INNER JOIN bible_verses_fts ON bible_verses_fts.rowid = b.id
      WHERE bible_verses_fts MATCH ?
    ''';

    List<Variable> variables = [Variable.withString(escapedQuery)];

    if (version != null) {
      sql += ' AND b.version = ?';
      variables.add(Variable.withString(version));
    }

    sql += ' ORDER BY rank LIMIT 100';

    final results = await customSelect(sql, variables: variables).get();

    return results.map((row) {
      return BibleVerse(
        id: row.read<int>('id'),
        version: row.read<String>('version'),
        book: row.read<String>('book'),
        bookOrder: row.read<int>('book_order'),
        chapter: row.read<int>('chapter'),
        verse: row.read<int>('verse'),
        content: row.read<String>('content'),
      );
    }).toList();
  }

  /// Get verses by reference (e.g., "John 3:16")
  Future<List<BibleVerse>> getVersesByReference({
    required String version,
    required String book,
    required int chapter,
    int? verseStart,
    int? verseEnd,
  }) async {
    var query = select(bibleVerses)
      ..where((v) => v.version.equals(version))
      ..where((v) => v.book.equals(book))
      ..where((v) => v.chapter.equals(chapter));

    if (verseStart != null && verseEnd != null) {
      query = query
        ..where((v) => v.verse.isBetweenValues(verseStart, verseEnd));
    } else if (verseStart != null) {
      query = query..where((v) => v.verse.equals(verseStart));
    }

    query = query..orderBy([(v) => OrderingTerm.asc(v.verse)]);

    return query.get();
  }

  /// Get all books for a version
  Future<List<String>> getBooksForVersion(String version) async {
    final results = await customSelect('''
      SELECT DISTINCT book, book_order 
      FROM bible_verses 
      WHERE version = ?
      ORDER BY book_order
    ''', variables: [Variable.withString(version)]).get();

    return results.map((row) => row.read<String>('book')).toList();
  }

  /// Get all chapters for a book
  Future<List<int>> getChaptersForBook(String version, String book) async {
    final results = await customSelect('''
      SELECT DISTINCT chapter 
      FROM bible_verses 
      WHERE version = ? AND book = ?
      ORDER BY chapter
    ''', variables: [
      Variable.withString(version),
      Variable.withString(book),
    ]).get();

    return results.map((row) => row.read<int>('chapter')).toList();
  }

  /// Check if Bible data exists for a version
  Future<bool> hasBibleData(String version) async {
    final count = await customSelect('''
      SELECT COUNT(*) as count FROM bible_verses WHERE version = ?
    ''', variables: [Variable.withString(version)]).getSingle();

    return count.read<int>('count') > 0;
  }

  /// Get total verse count for a version
  Future<int> getBibleVerseCount(String version) async {
    final count = await customSelect('''
      SELECT COUNT(*) as count FROM bible_verses WHERE version = ?
    ''', variables: [Variable.withString(version)]).getSingle();

    return count.read<int>('count');
  }

  // ==========================================================================
  // BATCH OPERATIONS (for seeding)
  // ==========================================================================

  /// Batch insert Bible verses (for fast seeding)
  Future<void> batchInsertBibleVerses(
      List<BibleVersesCompanion> verses) async {
    await batch((batch) {
      batch.insertAll(bibleVerses, verses);
    });
  }

  /// Batch insert songs
  Future<void> batchInsertSongs(List<SongsCompanion> songList) async {
    await batch((batch) {
      batch.insertAll(songs, songList);
    });
  }

  /// Rebuild FTS index (call after batch inserts)
  Future<void> rebuildFtsIndexes() async {
    // Rebuild songs FTS
    await customStatement('''
      INSERT INTO songs_fts(songs_fts) VALUES('rebuild');
    ''');

    // Rebuild Bible FTS
    await customStatement('''
      INSERT INTO bible_verses_fts(bible_verses_fts) VALUES('rebuild');
    ''');

    debugPrint('🔄 FTS indexes rebuilt');
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Escape special FTS5 characters and prepare query
  String _escapeFtsQuery(String query) {
    // Remove FTS5 special characters that could cause syntax errors
    String escaped = query
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('*', '')
        .replaceAll('-', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(':', '')
        .trim();

    // Split into words and add prefix matching (*)
    final words =
        escaped.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) return '';

    // Use prefix matching for partial word matches
    return words.map((w) => '"$w"*').join(' ');
  }
}
