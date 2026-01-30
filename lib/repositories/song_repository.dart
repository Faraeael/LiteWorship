import 'package:drift/drift.dart';
import '../data/database.dart';

// ============================================================================
// LITEWORSHIP — Song Repository
// Clean interface for song data operations with FTS5 search
// ============================================================================

class SongRepository {
  final LiteWorshipDatabase _db;

  SongRepository(this._db);

  /// Factory constructor using singleton database
  factory SongRepository.instance() {
    return SongRepository(LiteWorshipDatabase.instance);
  }

  /// Search songs by title or lyrics
  /// 
  /// Uses FTS5 with BM25 ranking where title matches are weighted 10x
  /// higher than lyric matches for relevance.
  /// 
  /// Example:
  /// ```dart
  /// final songs = await repo.search('amazing grace');
  /// // Returns "Amazing Grace" at top, then any songs with those words in lyrics
  /// ```
  Future<List<Song>> search(String query) async {
    return _db.searchSongs(query);
  }

  /// Watch songs as a reactive stream
  /// 
  /// Automatically updates when songs are added, modified, or deleted.
  Stream<List<Song>> watchAll() {
    return _db.watchAllSongs();
  }

  /// Get all songs (non-reactive)
  Future<List<Song>> getAll() async {
    return _db.select(_db.songs).get();
  }

  /// Get a single song by ID
  Future<Song?> getById(int id) {
    return _db.getSongById(id);
  }

  /// Get a single song by UUID
  Future<Song?> getByUuid(String uuid) async {
    return (_db.select(_db.songs)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Create a new song
  /// 
  /// Returns the auto-generated ID of the new song.
  Future<int> create({
    required String title,
    required String lyrics,
    String? tags,
    String? author,
    String? ccliNumber,
    String? copyright,
  }) async {
    return _db.insertSong(SongsCompanion.insert(
      title: title,
      lyrics: lyrics,
      tags: tags != null ? Value(tags) : const Value(''),
      author: author != null ? Value(author) : const Value.absent(),
      ccliNumber: ccliNumber != null ? Value(ccliNumber) : const Value.absent(),
      copyright: copyright != null ? Value(copyright) : const Value.absent(),
      source: const Value('local'), // Default for manual creation via repo, or 'bundled'
      uuid: Value(DateTime.now().millisecondsSinceEpoch.toString()), // Simple fallback
    ));
  }

  /// Update an existing song
  Future<bool> update(Song song) {
    return _db.updateSong(song);
  }

  /// Delete a song by ID
  Future<int> delete(int id) {
    return _db.deleteSong(id);
  }

  /// Upsert a user song (Insert or Update based on UUID)
  Future<void> syncUserSong(String uuid, SongsCompanion song) async {
    // Check if exists by UUID
    final existing = await getByUuid(uuid);
    if (existing != null) {
      // Update
      await (_db.update(_db.songs)..where((t) => t.uuid.equals(uuid))).write(song);
    } else {
      // Insert
      await _db.into(_db.songs).insert(song);
    }
  }

  /// Search songs and return as a stream (for real-time UI updates)
  /// 
  /// Note: This is a one-shot stream that emits once. For truly reactive
  /// search, use watchAll() and filter client-side, or implement debouncing.
  Stream<List<Song>> searchStream(String query) async* {
    yield await search(query);
  }
}
