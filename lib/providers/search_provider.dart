import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../repositories/song_repository.dart';
import '../repositories/bible_repository.dart'; // import
import '../providers/bible_provider.dart'; // import
import '../models/search_result.dart'; // import

// ============================================================================
// LITEWORSHIP — Search Logic
// Handles Omni-Search state, debouncing, and database access
// ============================================================================

// ----------------------------------------------------------------------------
// REPOSITORY PROVIDERS
// ----------------------------------------------------------------------------

final databaseProvider = Provider<LiteWorshipDatabase>((ref) {
  return LiteWorshipDatabase.instance;
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(databaseProvider));
});

// ----------------------------------------------------------------------------
// SEARCH STATE
// ----------------------------------------------------------------------------

/// The raw search text typed by the user (updates immediately for UI)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// The debounced search query (updates after 300ms pause)
final debouncedQueryProvider = StateProvider<String>((ref) => '');

/// Controller to manage debounce logic
class SearchDebounceController {
  final Ref ref;
  Timer? _timer;

  SearchDebounceController(this.ref) {
    // Listen to raw query changes
    ref.listen(searchQueryProvider, (previous, next) {
      if (previous == next) return;
      _onQueryChanged(next);
    });
  }

  void _onQueryChanged(String query) {
    _timer?.cancel();
    
    if (query.isEmpty) {
      // Clear immediately if empty
      ref.read(debouncedQueryProvider.notifier).state = '';
      return;
    }

    // Debounce for 300ms
    _timer = Timer(const Duration(milliseconds: 300), () {
      ref.read(debouncedQueryProvider.notifier).state = query;
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Provider to instaiate the controller (must be watched in UI root)
final searchControllerProvider = Provider.autoDispose((ref) {
  final controller = SearchDebounceController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

// ----------------------------------------------------------------------------
// RESULTS PROVIDER
// ----------------------------------------------------------------------------

/// Async search results based on the debounced query
final searchResultsProvider = FutureProvider.autoDispose<List<SearchResultItem>>((ref) async {
  final query = ref.watch(debouncedQueryProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  final bibleRepo = ref.watch(bibleRepositoryProvider); // Implies bible_provider.dart is imported

  if (query.isEmpty) {
    // Return all songs (limited) if query is empty
    final songs = await songRepo.getAll();
    return songs.map((s) => SongResult(s)).toList();
  }

  // Perform parallel search
  final results = await Future.wait([
    songRepo.search(query),
    bibleRepo.searchByKeyword(query),
  ]);
  
  final songs = results[0] as List<Song>;
  final verses = results[1] as List<BibleVerse>;

  // Combine
  final List<SearchResultItem> combined = [];
  combined.addAll(songs.map((s) => SongResult(s)));
  combined.addAll(verses.map((v) => BibleResult(v)));
  
  return combined;
});
