import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/database.dart';

// ============================================================================
// LITEWORSHIP — Database Seeder Service
// Handles initial data seeding for Bible and sample songs
// ============================================================================

/// Book order mapping for Bible navigation
const Map<String, int> _bookOrder = {
  'Genesis': 1, 'Exodus': 2, 'Leviticus': 3, 'Numbers': 4, 'Deuteronomy': 5,
  'Joshua': 6, 'Judges': 7, 'Ruth': 8, '1 Samuel': 9, '2 Samuel': 10,
  '1 Kings': 11, '2 Kings': 12, '1 Chronicles': 13, '2 Chronicles': 14,
  'Ezra': 15, 'Nehemiah': 16, 'Esther': 17, 'Job': 18, 'Psalms': 19,
  'Proverbs': 20, 'Ecclesiastes': 21, 'Song of Solomon': 22, 'Isaiah': 23,
  'Jeremiah': 24, 'Lamentations': 25, 'Ezekiel': 26, 'Daniel': 27,
  'Hosea': 28, 'Joel': 29, 'Amos': 30, 'Obadiah': 31, 'Jonah': 32,
  'Micah': 33, 'Nahum': 34, 'Habakkuk': 35, 'Zephaniah': 36, 'Haggai': 37,
  'Zechariah': 38, 'Malachi': 39,
  // New Testament
  'Matthew': 40, 'Mark': 41, 'Luke': 42, 'John': 43, 'Acts': 44,
  'Romans': 45, '1 Corinthians': 46, '2 Corinthians': 47, 'Galatians': 48,
  'Ephesians': 49, 'Philippians': 50, 'Colossians': 51, '1 Thessalonians': 52,
  '2 Thessalonians': 53, '1 Timothy': 54, '2 Timothy': 55, 'Titus': 56,
  'Philemon': 57, 'Hebrews': 58, 'James': 59, '1 Peter': 60, '2 Peter': 61,
  '1 John': 62, '2 John': 63, '3 John': 64, 'Jude': 65, 'Revelation': 66,
};

class DatabaseSeeder {
  final LiteWorshipDatabase _db;

  DatabaseSeeder(this._db);

  /// Check if initial seeding is needed and perform it
  Future<void> seedInitialData() async {
    final sw = Stopwatch()..start();

    // Check if songs already exist
    final hasSongs = await _db.select(_db.songs).get();
    if (hasSongs.isEmpty) {
      debugPrint('🎵 Seeding sample songs...');
      await _seedSampleSongs();
    }

    // Check if Bible data exists
    final hasBible = await _db.hasBibleData('KJV');
    if (!hasBible) {
      debugPrint('📖 Seeding KJV Bible... (this may take a moment)');
      await _seedBibleFromAsset('assets/data/kjv_bible.json', 'KJV');
    }

    sw.stop();
    debugPrint('✅ Database seeding complete in ${sw.elapsedMilliseconds}ms');
  }

  /// Seed sample worship songs
  Future<void> _seedSampleSongs() async {
    final sampleSongs = [
      SongsCompanion.insert(
        title: 'Amazing Grace',
        lyrics: '''[Verse 1]
Amazing grace, how sweet the sound
That saved a wretch like me
I once was lost, but now am found
Was blind, but now I see

[Verse 2]
'Twas grace that taught my heart to fear
And grace my fears relieved
How precious did that grace appear
The hour I first believed

[Verse 3]
Through many dangers, toils, and snares
I have already come
'Tis grace hath brought me safe thus far
And grace will lead me home

[Verse 4]
When we've been there ten thousand years
Bright shining as the sun
We've no less days to sing God's praise
Than when we first begun''',
        tags: const Value('hymn,classic,grace,worship'),
        author: const Value('John Newton'),
        copyright: const Value('Public Domain'),
      ),
      SongsCompanion.insert(
        title: '10,000 Reasons (Bless the Lord)',
        lyrics: '''[Chorus]
Bless the Lord, O my soul, O my soul
Worship His holy name
Sing like never before, O my soul
I'll worship Your holy name

[Verse 1]
The sun comes up, it's a new day dawning
It's time to sing Your song again
Whatever may pass and whatever lies before me
Let me be singing when the evening comes

[Verse 2]
You're rich in love and You're slow to anger
Your name is great and Your heart is kind
For all Your goodness I will keep on singing
Ten thousand reasons for my heart to find

[Verse 3]
And on that day when my strength is failing
The end draws near and my time has come
Still my soul will sing Your praise unending
Ten thousand years and then forevermore''',
        tags: const Value('contemporary,worship,praise,matt redman'),
        author: const Value('Matt Redman, Jonas Myrin'),
        copyright: const Value('© 2011 Thankyou Music, Said And Done Music, sixsteps Music, SHOUT! Music Publishing, worshiptogether.com songs'),
      ),
      SongsCompanion.insert(
        title: 'Way Maker',
        lyrics: '''[Verse 1]
You are here, moving in our midst
I worship You, I worship You
You are here, working in this place
I worship You, I worship You

[Chorus]
Way maker, miracle worker
Promise keeper, light in the darkness
My God, that is who You are

[Verse 2]
You are here, touching every heart
I worship You, I worship You
You are here, healing every heart
I worship You, I worship You

[Verse 3]
You are here, turning lives around
I worship You, I worship You
You are here, mending every heart
I worship You, I worship You

[Bridge]
Even when I don't see it, You're working
Even when I don't feel it, You're working
You never stop, You never stop working
You never stop, You never stop working''',
        tags: const Value('contemporary,worship,sinach,faith'),
        author: const Value('Sinach'),
        copyright: const Value('© 2015 Integrity Music'),
      ),
    ];

    await _db.batchInsertSongs(sampleSongs);
    debugPrint('   ✓ Inserted ${sampleSongs.length} sample songs');
  }

  /// Seed Bible verses from a JSON asset file
  /// 
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "translation": "KJV: ...",
  ///   "books": [
  ///     {
  ///       "name": "Genesis",
  ///       "chapters": [
  ///         {
  ///           "chapter": 1,
  ///           "verses": [
  ///             { "verse": 1, "text": "In the beginning..." }
  ///           ]
  ///         }
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  Future<void> _seedBibleFromAsset(String assetPath, String version) async {
    final sw = Stopwatch()..start();

    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString(assetPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final books = data['books'] as List<dynamic>;
      final verses = <BibleVersesCompanion>[];

      // Parse all verses
      for (final bookData in books) {
        final bookName = bookData['name'] as String;
        final bookOrderNum = _bookOrder[bookName] ?? 0;
        final chapters = bookData['chapters'] as List<dynamic>;

        for (final chapterData in chapters) {
          final chapterNum = chapterData['chapter'] as int;
          final versesList = chapterData['verses'] as List<dynamic>;

          for (final verseData in versesList) {
            final verseNum = verseData['verse'] as int;
            final text = verseData['text'] as String;

            verses.add(BibleVersesCompanion.insert(
              version: version,
              book: bookName,
              bookOrder: bookOrderNum,
              chapter: chapterNum,
              verse: verseNum,
              content: text.trim(),
            ));
          }
        }
      }

      debugPrint('   📝 Parsed ${verses.length} verses');

      // Batch insert in chunks for optimal performance
      const chunkSize = 5000;
      for (var i = 0; i < verses.length; i += chunkSize) {
        final end = (i + chunkSize > verses.length) ? verses.length : i + chunkSize;
        final chunk = verses.sublist(i, end);
        await _db.batchInsertBibleVerses(chunk);
        debugPrint('   📦 Inserted verses ${i + 1} to $end');
      }

      // Rebuild FTS index after batch insert
      await _db.rebuildFtsIndexes();

      sw.stop();
      debugPrint('   ✓ Bible seeding complete: ${verses.length} verses in ${sw.elapsedMilliseconds}ms');

    } catch (e, stack) {
      debugPrint('❌ Failed to seed Bible: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  /// Force reseed (for development/testing)
  Future<void> forceReseed() async {
    debugPrint('🔄 Force reseeding database...');

    // Clear existing data
    await _db.delete(_db.songs).go();
    await _db.delete(_db.bibleVerses).go();

    // Reseed
    await seedInitialData();
  }
}
