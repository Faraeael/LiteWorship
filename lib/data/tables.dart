import 'package:drift/drift.dart';

// ============================================================================
// LITEWORSHIP — Database Tables
// Core table definitions for Songs and Bible verses
// ============================================================================

/// Songs table for storing worship song lyrics
/// Supports ChordPro format or plain text
class Songs extends Table {
  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// Song title (required, indexed for fast lookups)
  TextColumn get title => text().withLength(min: 1, max: 500)();

  /// Song lyrics stored as raw text (ChordPro or plain)
  TextColumn get lyrics => text()();

  /// Comma-separated tags for categorization (e.g., "worship,praise,slow")
  TextColumn get tags => text().withDefault(const Constant(''))();

  /// Original author/artist (optional)
  TextColumn get author => text().nullable()();

  /// CCLI license number (optional)
  TextColumn get ccliNumber => text().nullable()();

  /// Copyright info (optional)
  TextColumn get copyright => text().nullable()();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Last modified timestamp
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Bible verses table for scripture display
/// Optimized for fast lookups by reference (book, chapter, verse)
class BibleVerses extends Table {
  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// Bible version (e.g., "KJV", "NIV", "ESV")
  TextColumn get version => text().withLength(min: 1, max: 20)();

  /// Book name (e.g., "Genesis", "John", "Revelation")
  TextColumn get book => text().withLength(min: 1, max: 50)();

  /// Book order number (1=Genesis, 66=Revelation)
  IntColumn get bookOrder => integer()();

  /// Chapter number
  IntColumn get chapter => integer()();

  /// Verse number
  IntColumn get verse => integer()();

  /// The actual verse text (renamed to avoid conflict with Table.text method)
  TextColumn get content => text()();

  /// Create composite index for fast reference lookups
  @override
  List<Set<Column>> get uniqueKeys => [
        {version, book, chapter, verse},
      ];
}
