import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_model.dart';

// State for the Bible Data
// Bible Versions Enum
enum BibleVersion {
  kjv('King James Version', 'kjv_bible.json'),
  niv('New International Version', 'kjv_bible.json'), // Using KJV as placeholder
  tag('Tagalog Biblia', 'kjv_bible.json'); // Using KJV as placeholder

  final String displayName;
  final String assetName;
  const BibleVersion(this.displayName, this.assetName);
}

// Current Selected Version
final selectedBibleVersionProvider = StateProvider<BibleVersion>((ref) => BibleVersion.kjv);

// State for the Bible Data (Reloads when version changes)
final bibleDataProvider = FutureProvider<List<BibleBook>>((ref) async {
  final version = ref.watch(selectedBibleVersionProvider);
  // In real app, we would load different files based on version.assetName
  final jsonString = await rootBundle.loadString('assets/data/${version.assetName}');
  final jsonMap = jsonDecode(jsonString);
  final booksList = jsonMap['books'] as List;
  return booksList.map((b) => BibleBook.fromJson(b)).toList();
});

// Navigation State (Miller Columns)
final selectedBookIndexProvider = StateProvider<int>((ref) => -1);
final selectedChapterIndexProvider = StateProvider<int>((ref) => -1);

// State for Search Results
class BibleSearchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  BibleSearchNotifier() : super([]);

  void search(String query, List<BibleBook> bible) {
    if (query.trim().isEmpty) {
      state = [];
      return;
    }

    // 1. SMART PARSE
    // Regex: (Number optional) (Letters) (Space optional) (Number optional) (Colon optional) (Number optional)
    // Matches: "1 Cor", "1Cor", "Gen 1", "Jn 3:16"
    final refRegex = RegExp(r'^(\d?)\s*([a-zA-Z]+)(?:\s+(\d+))?(?:[:\s](\d+))?$');
    final match = refRegex.firstMatch(query.trim());

    if (match != null) {
      final numPrefix = match.group(1) ?? '';
      final namePart = match.group(2) ?? '';
      final chapterStr = match.group(3);
      final verseStr = match.group(4);

      // Reconstruct Book Name (e.g., "1Cor" -> "1 Cor" if needed by helper, but helper handles it)
      final bookQuery = numPrefix.isNotEmpty ? "$numPrefix$namePart" : namePart;
      
      final bookIndex = _findBookIndex(bible, bookQuery);
      if (bookIndex != -1) {
        final book = bible[bookIndex];
        
        if (chapterStr != null) {
           final chapterNum = int.tryParse(chapterStr);
           if (chapterNum != null && chapterNum > 0 && chapterNum <= book.chapters.length) {
              final chapter = book.chapters[chapterNum - 1];
              
              if (verseStr != null) {
                // Verse specified: "Jn 3 16"
                final verseNum = int.tryParse(verseStr);
                 if (verseNum != null && verseNum > 0 && verseNum <= chapter.verses.length) {
                    // Exact Verse Match
                    state = [{
                      'book': book,
                      'chapter': chapter,
                      'verse': chapter.verses[verseNum - 1]
                    }];
                    return;
                 }
              } else {
                // Whole Chapter match
                state = chapter.verses.take(100).map((v) => { // Increased limit
                  'book': book,
                  'chapter': chapter,
                  'verse': v
                }).toList();
                return;
              }
           }
        } else {
           // BOOK ONLY MATCH (e.g. "1Cor") -> Return Ch 1 (or all? Limiting to avoid lag)
           // Let's return Chapter 1 verses by default for responsiveness
           if (book.chapters.isNotEmpty) {
             state = book.chapters[0].verses.map((v) => {
               'book': book,
               'chapter': book.chapters[0],
               'verse': v
             }).toList();
             return;
           }
        }
      }
    }

    // 2. FALLBACK: Keyword Search
    final lowerQ = query.toLowerCase();
    final List<Map<String, dynamic>> results = [];
    int count = 0;

    for (var book in bible) {
      for (var chapter in book.chapters) {
        for (var verse in chapter.verses) {
            bool match = verse.text.toLowerCase().contains(lowerQ);
            if (match) {
               results.add({
                 'book': book,
                 'chapter': chapter,
                 'verse': verse
               });
               count++;
               if (count >= 50) break;
            }
        }
        if (count >= 50) break;
      }
      if (count >= 50) break;
    }
    state = results;
  }

  int _findBookIndex(List<BibleBook> bible, String query) {
    var q = query.toLowerCase().replaceAll(RegExp(r'\.'), '').trim();
    
    // Extract number prefix if present (e.g., "1cor" -> prefix="1", rest="cor")
    String numPrefix = '';
    String bookPart = q;
    
    final numMatch = RegExp(r'^(\d+)\s*(.+)$').firstMatch(q);
    if (numMatch != null) {
      numPrefix = numMatch.group(1)!;
      bookPart = numMatch.group(2)!.trim();
    }

    // 1. Exact Name Match
    int idx = bible.indexWhere((b) => b.name.toLowerCase() == q);
    if (idx != -1) return idx;
    
    // 2. Starts With (handles "genesis" from "gen")
    idx = bible.indexWhere((b) => b.name.toLowerCase().startsWith(q));
    if (idx != -1) return idx;

    // 3. Common Abbreviations (Extended)
    final abbrevs = {
      'gen': 'genesis', 'ex': 'exodus', 'lev': 'leviticus', 'num': 'numbers', 'deut': 'deuteronomy', 'dt': 'deuteronomy',
      'josh': 'joshua', 'jos': 'joshua', 'judg': 'judges', 'jdg': 'judges', 'ruth': 'ruth', 'rut': 'ruth',
      'sam': 'samuel', 'sa': 'samuel', 
      'king': 'kings', 'kgs': 'kings', 'kg': 'kings', 'ki': 'kings',
      'chr': 'chronicles', 'ch': 'chronicles', 'chron': 'chronicles',
      'ezr': 'ezra', 'neh': 'nehemiah', 'ne': 'nehemiah', 'est': 'esther', 'es': 'esther',
      'jb': 'job', 'ps': 'psalms', 'psa': 'psalms', 'psalm': 'psalms',
      'prov': 'proverbs', 'pr': 'proverbs', 'ecc': 'ecclesiastes', 'ec': 'ecclesiastes',
      'song': 'song of solomon', 'so': 'song of solomon', 'sos': 'song of solomon',
      'isa': 'isaiah', 'is': 'isaiah', 'jer': 'jeremiah', 'jr': 'jeremiah',
      'lam': 'lamentations', 'la': 'lamentations', 'ezek': 'ezekiel', 'ez': 'ezekiel', 'eze': 'ezekiel',
      'dan': 'daniel', 'da': 'daniel', 'hos': 'hosea', 'ho': 'hosea',
      'joel': 'joel', 'jl': 'joel', 'amos': 'amos', 'am': 'amos',
      'obad': 'obadiah', 'ob': 'obadiah', 'jonah': 'jonah', 'jon': 'jonah',
      'mic': 'micah', 'mi': 'micah', 'nah': 'nahum', 'na': 'nahum',
      'hab': 'habakkuk', 'ha': 'habakkuk', 'zeph': 'zephaniah', 'ze': 'zephaniah',
      'hag': 'haggai', 'hg': 'haggai', 'zech': 'zechariah', 'zc': 'zechariah', 'zec': 'zechariah',
      'mal': 'malachi', 'ma': 'malachi',
      'matt': 'matthew', 'mt': 'matthew', 'mat': 'matthew',
      'mark': 'mark', 'mk': 'mark', 'mr': 'mark',
      'luke': 'luke', 'lk': 'luke', 'lu': 'luke',
      'john': 'john', 'jn': 'john', 'joh': 'john',
      'acts': 'acts', 'ac': 'acts', 'act': 'acts',
      'rom': 'romans', 'rm': 'romans', 'ro': 'romans',
      'cor': 'corinthians', 'co': 'corinthians',
      'gal': 'galatians', 'ga': 'galatians',
      'eph': 'ephesians', 'ep': 'ephesians',
      'phil': 'philippians', 'php': 'philippians', 'ph': 'philippians',
      'col': 'colossians', 'cl': 'colossians',
      'thess': 'thessalonians', 'th': 'thessalonians', 'thes': 'thessalonians',
      'tim': 'timothy', 'ti': 'timothy',
      'titus': 'titus', 'tit': 'titus', 'tt': 'titus',
      'philem': 'philemon', 'phm': 'philemon', 'phlm': 'philemon',
      'heb': 'hebrews', 'he': 'hebrews',
      'james': 'james', 'jas': 'james', 'ja': 'james', 'jm': 'james',
      'pet': 'peter', 'pe': 'peter', 'pt': 'peter',
      'jude': 'jude', 'jud': 'jude', 'ju': 'jude',
      'rev': 'revelation', 're': 'revelation', 'reve': 'revelation', 'revelations': 'revelation'
    };
    
    // Try to expand the book part using abbreviations
    String expandedBook = abbrevs[bookPart] ?? bookPart;
    
    // Build search term with number prefix if present
    String searchTerm = numPrefix.isNotEmpty ? '$numPrefix $expandedBook' : expandedBook;
    
    // Map Arabic to Roman for names like "I Kings", "II Corinthians"
    String romanPrefix = '';
    if (numPrefix == '1') romanPrefix = 'i';
    else if (numPrefix == '2') romanPrefix = 'ii';
    else if (numPrefix == '3') romanPrefix = 'iii';
    
    // Try exact match first
    idx = bible.indexWhere((b) => b.name.toLowerCase() == searchTerm);
    if (idx != -1) return idx;
    
    // Try contains match with Roman Numeral support
    // e.g. "1cor" -> prefix:1, book:cor -> expanded:corinthians
    // Matches "I Corinthians" because it starts with "i " and contains "corinthians"
    idx = bible.indexWhere((b) {
      final bookName = b.name.toLowerCase();
      
      if (numPrefix.isNotEmpty) {
        bool matchesArabic = bookName.startsWith(numPrefix) && bookName.contains(expandedBook);
        bool matchesRoman = false;
        if (romanPrefix.isNotEmpty) {
           // Check for "i " or "i" (e.g. "i kings" or "1kings" -> "1 kings")
           // Roman numerals in this JSON seem to be "I Kings" (space after I)
           matchesRoman = bookName.startsWith("$romanPrefix ") && bookName.contains(expandedBook);
        }
        return matchesArabic || matchesRoman;
      } else {
        // If no number typed, but book has number (e.g. user typed "corinthians", match "I Corinthians"?)
        // Usually if user types "corinthians", they want 1 Cor 1:1 or list of books?
        // Let's stick to contains for lazy search.
        return bookName.contains(expandedBook);
      }
    });
    if (idx != -1) return idx;

    // Try starts-with on the book part only (for partial matches)
    // Also try comparing roman prefix + bookPart raw
    idx = bible.indexWhere((b) {
      final bookName = b.name.toLowerCase();
      if (numPrefix.isNotEmpty) {
        bool matchesArabic = bookName.startsWith(numPrefix) && bookName.contains(bookPart);
        bool matchesRoman = romanPrefix.isNotEmpty && bookName.startsWith("$romanPrefix ") && bookName.contains(bookPart);
        return matchesArabic || matchesRoman;
      } else {
        return bookName.startsWith(bookPart);
      }
    });
    
    return idx;
  }
}

final bibleSearchProvider = StateNotifierProvider<BibleSearchNotifier, List<Map<String, dynamic>>>((ref) {
  return BibleSearchNotifier();
});
