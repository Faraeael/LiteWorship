
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart'; // Drift models: BibleVerse
import '../repositories/bible_repository.dart';
import '../services/bible_download_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart'; // Drift models: BibleVerse
import '../repositories/bible_repository.dart';
import '../services/bible_download_service.dart';
import 'search_provider.dart'; // for databaseProvider

enum BibleSearchMode {
  reference,
  keyword,
}

// ============================================================================
// LITEWORSHIP — Bible State & Logic
// Handles dynamic version switching, navigation, and smart search
// ============================================================================

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository(ref.watch(databaseProvider));
});

final bibleDownloadServiceProvider = Provider<BibleDownloadService>((ref) {
  return BibleDownloadService();
});

// ----------------------------------------------------------------------------
// VERSION MANAGEMENT
// ----------------------------------------------------------------------------

/// List of available Bible versions in the database
final availableBibleVersionsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getAvailableVersions();
});

/// Currently selected Bible version (default: KJV)
final selectedBibleVersionProvider = StateProvider<String>((ref) => 'KJV');

/// List of books for the selected version (for navigation)
final bibleBooksProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final version = ref.watch(selectedBibleVersionProvider);
  return repo.getBooks(version: version);
});

// ----------------------------------------------------------------------------
// NAVIGATION STATE (Miller Columns)
// ----------------------------------------------------------------------------

final selectedBookProvider = StateProvider<String?>((ref) => null);
final selectedChapterProvider = StateProvider<int?>((ref) => null);

/// Chapters for selected book
final bibleChaptersProvider = FutureProvider<List<int>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  
  if (book == null) return [];
  return repo.getChapters(version: version, book: book);
});

/// Verses for selected chapter
final bibleVersesProvider = FutureProvider<List<BibleVerse>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  final chapter = ref.watch(selectedChapterProvider);
  
  if (book == null || chapter == null) return [];
  
  // Ensure we return List<BibleVerse> (Drift model)
  return repo.getByReference(
    version: version, 
    book: book, 
    chapter: chapter
  );
});

// ----------------------------------------------------------------------------
// SEARCH LOGIC
// ----------------------------------------------------------------------------

/// Stores the current search query to enable re-searching on version change
final bibleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stores the current search mode (Reference vs Keyword)
final bibleSearchModeProvider = StateProvider<BibleSearchMode>((ref) => BibleSearchMode.reference);

/// Stores the ID of the verse to highlight (for Reference Mode auto-scroll)
final bibleSearchHighlightProvider = StateProvider<int?>((ref) => null);

class BibleSearchNotifier extends StateNotifier<List<BibleVerse>> {
  final Ref ref;
  
  BibleSearchNotifier(this.ref) : super([]) {
    // Watch for version changes and re-run search if query exists
    ref.listen(selectedBibleVersionProvider, (previous, next) {
      if (previous != next) {
        final query = ref.read(bibleSearchQueryProvider);
        if (query.isNotEmpty) {
          search(query);
        }
      }
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = [];
      return;
    }

    // Capture the query for "EasyWorship" style state-based re-search
    ref.read(bibleSearchQueryProvider.notifier).state = query;

    final repo = ref.read(bibleRepositoryProvider);
    final version = ref.read(selectedBibleVersionProvider);
    final mode = ref.read(bibleSearchModeProvider);

    if (mode == BibleSearchMode.reference) {
      // 1. ROBUST REFERENCE PARSE
      // Handles: "1Cor 13:4", "1 Cor 13:4", "Jn 3:16", "John 3 16"
      final refRegex = RegExp(r'^(\d?\s*[a-zA-Z]+)\s+(\d+)(?:[:\s](\d+)(?:-(\d+))?)?$');
      final match = refRegex.firstMatch(query.trim());

      if (match != null) {
        final bookPart = match.group(1)?.trim() ?? '';
        final chapterStr = match.group(2);
        final verseStr = match.group(3);
        final verseEndStr = match.group(4);

        if (chapterStr != null) {
          final bookList = await repo.getBooks(version: version);
          final bookName = _findBookName(bookList, bookPart);
          if (bookName != null) {
            final chapter = int.tryParse(chapterStr) ?? 1;
            final verseStart = verseStr != null ? int.tryParse(verseStr) : null;
            
            // Set highlight if a specific verse was requested
            if (verseStart != null) {
              ref.read(bibleSearchHighlightProvider.notifier).state = verseStart;
            } else {
              ref.read(bibleSearchHighlightProvider.notifier).state = null;
            }

            final results = await repo.getByReference(
              version: version,
              book: bookName,
              chapter: chapter,
              // Repo now ignores verseStart/End to return full chapter
              verseStart: verseStart,
            );
            
            state = results;
            return;
          }
        }
      }
      // If reference parsing fails, return empty or maybe a "Not Found" state
      // For now, we just clear results if it's not a valid reference
      state = [];
    } else {
      // 2. KEYWORD SEARCH
      final textResults = await repo.searchByKeyword(query, version: version);
      state = textResults;
    }
  }
  
  /// Helper to fuzzy match book names from query parts
  String? _findBookName(List<String> books, String queryBook) {
    // Normalize: Remove spaces if it starts with digit (e.g., "1 Cor" -> "1Cor") for caching/lookup consistency
    // Actually, simpler to just normalize the input query to lower case and handle variations
    
    String q = queryBook.toLowerCase().replaceAll(RegExp(r'\s+'), ''); // remove all spaces for matching
    
    // Map common abbreviations to full names (normalized keys)
    final abbrevs = {
      'genesis': 'Genesis', 'gen': 'Genesis', 'ge': 'Genesis', 'gn': 'Genesis',
      'exodus': 'Exodus', 'ex': 'Exodus', 'exod': 'Exodus',
      'leviticus': 'Leviticus', 'lev': 'Leviticus', 'lv': 'Leviticus',
      'numbers': 'Numbers', 'num': 'Numbers', 'nm': 'Numbers',
      'deuteronomy': 'Deuteronomy', 'deut': 'Deuteronomy', 'dt': 'Deuteronomy',
      'joshua': 'Joshua', 'josh': 'Joshua', 'jos': 'Joshua',
      'judges': 'Judges', 'judg': 'Judges', 'jdg': 'Judges',
      'ruth': 'Ruth', 'ru': 'Ruth',
      '1samuel': '1 Samuel', '1sam': '1 Samuel', '1sa': '1 Samuel', '1s': '1 Samuel',
      '2samuel': '2 Samuel', '2sam': '2 Samuel', '2sa': '2 Samuel', '2s': '2 Samuel',
      '1kings': '1 Kings', '1kgs': '1 Kings', '1ki': '1 Kings', '1k': '1 Kings',
      '2kings': '2 Kings', '2kgs': '2 Kings', '2ki': '2 Kings', '2k': '2 Kings',
      '1chronicles': '1 Chronicles', '1chr': '1 Chronicles', '1ch': '1 Chronicles',
      '2chronicles': '2 Chronicles', '2chr': '2 Chronicles', '2ch': '2 Chronicles',
      'ezra': 'Ezra', 'ezr': 'Ezra',
      'nehemiah': 'Nehemiah', 'neh': 'Nehemiah', 'ne': 'Nehemiah',
      'esther': 'Esther', 'est': 'Esther',
      'job': 'Job', 'jb': 'Job',
      'psalms': 'Psalms', 'psalm': 'Psalms', 'ps': 'Psalms', 'psa': 'Psalms',
      'proverbs': 'Proverbs', 'prov': 'Proverbs', 'pro': 'Proverbs', 'prv': 'Proverbs',
      'ecclesiastes': 'Ecclesiastes', 'ecc': 'Ecclesiastes', 'ec': 'Ecclesiastes',
      'songofsolomon': 'Song of Solomon', 'song': 'Song of Solomon', 'sos': 'Song of Solomon', 'canticles': 'Song of Solomon',
      'isaiah': 'Isaiah', 'isa': 'Isaiah',
      'jeremiah': 'Jeremiah', 'jer': 'Jeremiah',
      'lamentations': 'Lamentations', 'lam': 'Lamentations', 'lm': 'Lamentations',
      'ezekiel': 'Ezekiel', 'ezek': 'Ezekiel', 'ez': 'Ezekiel',
      'daniel': 'Daniel', 'dan': 'Daniel', 'dn': 'Daniel',
      'hosea': 'Hosea', 'hos': 'Hosea', 'ho': 'Hosea',
      'joel': 'Joel', 'jl': 'Joel',
      'amos': 'Amos', 'am': 'Amos',
      'obadiah': 'Obadiah', 'obad': 'Obadiah', 'ob': 'Obadiah',
      'jonah': 'Jonah', 'jon': 'Jonah', 'jnh': 'Jonah',
      'micah': 'Micah', 'mic': 'Micah', 'mc': 'Micah',
      'nahum': 'Nahum', 'nah': 'Nahum', 'na': 'Nahum',
      'habakkuk': 'Habakkuk', 'hab': 'Habakkuk',
      'zephaniah': 'Zephaniah', 'zeph': 'Zephaniah', 'zep': 'Zephaniah',
      'haggai': 'Haggai', 'hag': 'Haggai', 'hg': 'Haggai',
      'zechariah': 'Zechariah', 'zech': 'Zechariah', 'zec': 'Zechariah',
      'malachi': 'Malachi', 'mal': 'Malachi',
      'matthew': 'Matthew', 'matt': 'Matthew', 'mt': 'Matthew',
      'mark': 'Mark', 'mk': 'Mark', 'mrk': 'Mark',
      'luke': 'Luke', 'lk': 'Luke', 'luc': 'Luke',
      'john': 'John', 'jn': 'John', 'jhn': 'John',
      'acts': 'Acts', 'ac': 'Acts',
      'romans': 'Romans', 'rom': 'Romans', 'rm': 'Romans',
      '1corinthians': '1 Corinthians', '1cor': '1 Corinthians', '1co': '1 Corinthians',
      '2corinthians': '2 Corinthians', '2cor': '2 Corinthians', '2co': '2 Corinthians',
      'galatians': 'Galatians', 'gal': 'Galatians', 'gl': 'Galatians',
      'ephesians': 'Ephesians', 'eph': 'Ephesians',
      'philippians': 'Philippians', 'phil': 'Philippians', 'php': 'Philippians',
      'colossians': 'Colossians', 'col': 'Colossians',
      '1thessalonians': '1 Thessalonians', '1thess': '1 Thessalonians', '1th': '1 Thessalonians',
      '2thessalonians': '2 Thessalonians', '2thess': '2 Thessalonians', '2th': '2 Thessalonians',
      '1timothy': '1 Timothy', '1tim': '1 Timothy', '1ti': '1 Timothy',
      '2timothy': '2 Timothy', '2tim': '2 Timothy', '2ti': '2 Timothy',
      'titus': 'Titus', 'tit': 'Titus',
      'philemon': 'Philemon', 'philem': 'Philemon', 'phm': 'Philemon',
      'hebrews': 'Hebrews', 'heb': 'Hebrews',
      'james': 'James', 'jas': 'James', 'jm': 'James',
      '1peter': '1 Peter', '1pet': '1 Peter', '1pe': '1 Peter', '1pt': '1 Peter',
      '2peter': '2 Peter', '2pet': '2 Peter', '2pe': '2 Peter', '2pt': '2 Peter',
      '1john': '1 John', '1jn': '1 John', '1jhn': '1 John',
      '2john': '2 John', '2jn': '2 John', '2jhn': '2 John',
      '3john': '3 John', '3jn': '3 John', '3jhn': '3 John',
      'jude': 'Jude', 'jud': 'Jude', 'jd': 'Jude',
      'revelation': 'Revelation', 'rev': 'Revelation', 'rv': 'Revelation',
    };
    
    // 1. Try exact match in map
    if (abbrevs.containsKey(q)) {
      return abbrevs[q];
    }
    
    // 2. Try matching against actual book list (removing spaces for comparison)
    try {
      return books.firstWhere((b) => b.toLowerCase().replaceAll(' ', '') == q);
    } catch (_) {}

    try {
      return books.firstWhere((b) => b.toLowerCase().replaceAll(' ', '').startsWith(q));
    } catch (_) {}

    return null;
  }
}

final bibleSearchProvider = StateNotifierProvider<BibleSearchNotifier, List<BibleVerse>>((ref) {
  return BibleSearchNotifier(ref);
});

// Watcher to trigger re-search when version changes
final bibleSearchWatcher = Provider((ref) {
  ref.listen(selectedBibleVersionProvider, (previous, next) {
    if (previous != next) {
      final query = ref.read(bibleSearchQueryProvider);
      if (query.isNotEmpty) {
        ref.read(bibleSearchProvider.notifier).search(query);
      }
    }
  });
});
