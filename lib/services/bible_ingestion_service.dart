
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../data/database.dart';
import '../repositories/bible_repository.dart';

class BibleIngestionService {
  final BibleRepository _repository;

  BibleIngestionService(this._repository);

  // Normalization Map: Maps various book name formats to standard names
  static final Map<String, String> _bookMap = {
    'Genesis': 'Genesis', 'Gen': 'Genesis',
    'Exodus': 'Exodus', 'Ex': 'Exodus',
    'Leviticus': 'Leviticus', 'Lev': 'Leviticus',
    'Numbers': 'Numbers', 'Num': 'Numbers',
    'Deuteronomy': 'Deuteronomy', 'Deut': 'Deuteronomy',
    'Joshua': 'Joshua', 'Josh': 'Joshua',
    'Judges': 'Judges', 'Judg': 'Judges',
    'Ruth': 'Ruth',
    '1 Samuel': '1 Samuel', 'I Samuel': '1 Samuel', '1Sam': '1 Samuel',
    '2 Samuel': '2 Samuel', 'II Samuel': '2 Samuel', '2Sam': '2 Samuel',
    '1 Kings': '1 Kings', 'I Kings': '1 Kings', '1Kgs': '1 Kings',
    '2 Kings': '2 Kings', 'II Kings': '2 Kings', '2Kgs': '2 Kings',
    '1 Chronicles': '1 Chronicles', 'I Chronicles': '1 Chronicles', '1Chr': '1 Chronicles',
    '2 Chronicles': '2 Chronicles', 'II Chronicles': '2 Chronicles', '2Chr': '2 Chronicles',
    'Ezra': 'Ezra',
    'Nehemiah': 'Nehemiah', 'Neh': 'Nehemiah',
    'Esther': 'Esther', 'Est': 'Esther',
    'Job': 'Job',
    'Psalms': 'Psalms', 'Ps': 'Psalms', 'Psalm': 'Psalms',
    'Proverbs': 'Proverbs', 'Prov': 'Proverbs',
    'Ecclesiastes': 'Ecclesiastes', 'Eccl': 'Ecclesiastes',
    'Song of Solomon': 'Song of Solomon', 'Song': 'Song of Solomon', 'Song of Songs': 'Song of Solomon',
    'Isaiah': 'Isaiah', 'Isa': 'Isaiah',
    'Jeremiah': 'Jeremiah', 'Jer': 'Jeremiah',
    'Lamentations': 'Lamentations', 'Lam': 'Lamentations',
    'Ezekiel': 'Ezekiel', 'Ezek': 'Ezekiel',
    'Daniel': 'Daniel', 'Dan': 'Daniel',
    'Hosea': 'Hosea', 'Hos': 'Hosea',
    'Joel': 'Joel',
    'Amos': 'Amos',
    'Obadiah': 'Obadiah', 'Obad': 'Obadiah',
    'Jonah': 'Jonah',
    'Micah': 'Micah', 'Mic': 'Micah',
    'Nahum': 'Nahum', 'Nah': 'Nahum',
    'Habakkuk': 'Habakkuk', 'Hab': 'Habakkuk',
    'Zephaniah': 'Zephaniah', 'Zeph': 'Zephaniah',
    'Haggai': 'Haggai', 'Hag': 'Haggai',
    'Zechariah': 'Zechariah', 'Zech': 'Zechariah',
    'Malachi': 'Malachi', 'Mal': 'Malachi',
    'Matthew': 'Matthew', 'Matt': 'Matthew',
    'Mark': 'Mark',
    'Luke': 'Luke',
    'John': 'John',
    'Acts': 'Acts',
    'Romans': 'Romans', 'Rom': 'Romans',
    '1 Corinthians': '1 Corinthians', 'I Corinthians': '1 Corinthians', '1Cor': '1 Corinthians',
    '2 Corinthians': '2 Corinthians', 'II Corinthians': '2 Corinthians', '2Cor': '2 Corinthians',
    'Galatians': 'Galatians', 'Gal': 'Galatians',
    'Ephesians': 'Ephesians', 'Eph': 'Ephesians',
    'Philippians': 'Philippians', 'Phil': 'Philippians',
    'Colossians': 'Colossians', 'Col': 'Colossians',
    '1 Thessalonians': '1 Thessalonians', 'I Thessalonians': '1 Thessalonians', '1Thess': '1 Thessalonians',
    '2 Thessalonians': '2 Thessalonians', 'II Thessalonians': '2 Thessalonians', '2Thess': '2 Thessalonians',
    '1 Timothy': '1 Timothy', 'I Timothy': '1 Timothy', '1Tim': '1 Timothy',
    '2 Timothy': '2 Timothy', 'II Timothy': '2 Timothy', '2Tim': '2 Timothy',
    'Titus': 'Titus',
    'Philemon': 'Philemon', 'Phlm': 'Philemon',
    'Hebrews': 'Hebrews', 'Heb': 'Hebrews',
    'James': 'James',
    '1 Peter': '1 Peter', 'I Peter': '1 Peter', '1Pet': '1 Peter',
    '2 Peter': '2 Peter', 'II Peter': '2 Peter', '2Pet': '2 Peter',
    '1 John': '1 John', 'I John': '1 John', '1Jn': '1 John',
    '2 John': '2 John', 'II John': '2 John', '2Jn': '2 John',
    '3 John': '3 John', 'III John': '3 John', '3Jn': '3 John',
    'Jude': 'Jude',
    'Revelation': 'Revelation', 'Rev': 'Revelation',
  };

  /// Ingest a Bible JSON and store it in the database
  /// 
  /// [filePath] is the path to the JSON file.
  /// [versionName] is the identifier (e.g. 'NIV', 'ESV'). 
  Future<void> ingestJsonFile(String filePath, String versionName) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('File not found: $filePath');

    debugPrint('📖 Starting ingestion for $versionName from $filePath');
    final jsonStr = await file.readAsString();
    dynamic data;
    try {
      data = jsonDecode(jsonStr);
    } catch (e) {
      throw Exception('Invalid JSON format: $e');
    }
    
    // Normalize input to List of Books
    List<dynamic> books = [];
    if (data is List) {
       books = data;
    } else if (data is Map) {
       // Look for keys like 'books', 'Books', etc.
       if (data.containsKey('books')) books = data['books'];
       else if (data.containsKey('Books')) books = data['Books'];
       // Some formats have root keys as book names? Assuming ScrollMapper standard for now
    }

    if (books.isEmpty) {
      debugPrint('⚠️ No books found in structure. attempting strict ScrollMapper parse.');
      // If the JSON is different, we might need more logic. 
      // ScrollMapper usually returns an array of objects for each book.
    }

    final List<BibleVersesCompanion> batch = [];
    int bookOrder = 1;

    for (var bookData in books) {
       if (bookData is! Map) continue;
       
       // Extract name
       String rawName = bookData['name'] ?? bookData['book'] ?? bookData['title'] ?? '';
       String normalizedName = _bookMap[rawName] ?? rawName; // Fallback to raw if logic fails
       
       if (normalizedName.isEmpty) continue;

       // Chapters
       // ScrollMapper: chapters is an array of arrays (verses)
       // Or array of objects {verses: [...]}
       var chapters = bookData['chapters'];
       if (chapters == null || chapters is! List) continue;
       
       for (int cIndex = 0; cIndex < chapters.length; cIndex++) {
         int chapterNum = cIndex + 1;
         var chapterData = chapters[cIndex];
         
         List verses = [];
         if (chapterData is List) {
           verses = chapterData; // [[v1, v2], [v1]] - ScrollMapper typical
         } else if (chapterData is Map && chapterData.containsKey('verses')) {
           verses = chapterData['verses'];
         }
         
         for (int vIndex = 0; vIndex < verses.length; vIndex++) {
            int verseNum = vIndex + 1; 
            String text = '';
            
            // Handle different verse formats
            if (verses[vIndex] is String) {
              text = verses[vIndex];
            } else if (verses[vIndex] is Map) {
              text = verses[vIndex]['text'] ?? verses[vIndex]['content'] ?? '';
            } else {
              text = verses[vIndex].toString();
            }
            
            if (text.isNotEmpty) {
              batch.add(BibleVersesCompanion.insert(
                version: versionName,
                book: normalizedName,
                bookOrder: bookOrder,
                chapter: chapterNum,
                verse: verseNum,
                content: text,
              ));
            }
         }
       }
       bookOrder++;
    }
    
    if (batch.isNotEmpty) {
      debugPrint('💾 Inserting ${batch.length} verses for $versionName...');
      await _repository.batchInsertBibleVerses(batch);
      
      debugPrint('🔄 Rebuilding FTS Index...');
      await _repository.rebuildFtsIndexes();
      debugPrint('✅ Ingestion Complete.');
    } else {
      debugPrint('⚠️ No verses found to insert.');
    }
  }
}
