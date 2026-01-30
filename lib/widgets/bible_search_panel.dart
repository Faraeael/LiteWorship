
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; // Import
import 'package:uuid/uuid.dart';
import '../data/database.dart'; // Import Drift models (BibleVerse) directly
import '../models/slide_content.dart';
import '../config/theme.dart';
import '../providers/bible_provider.dart';
import '../providers/service_provider.dart';
import '../providers/providers.dart';
import '../services/server.dart'; // sendProjectorMessage
import '../screens/bible_store_screen.dart';

class BibleSearchPanel extends ConsumerStatefulWidget {
  const BibleSearchPanel({super.key});

  @override
  ConsumerState<BibleSearchPanel> createState() => _BibleSearchPanelState();
}

class _BibleSearchPanelState extends ConsumerState<BibleSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ItemScrollController _itemScrollController = ItemScrollController(); // Use ItemScrollController
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addScripture(BibleVerse verse) {
    // Construct text using dot notation from Drift model
    final text = "${verse.content}\n\n${verse.book} ${verse.chapter}:${verse.verse}";
    
    final slide = TextSlideContent(
      id: const Uuid().v4(),
      text: text,
      label: 'Verse',
    );
    
    // Set live
    ref.read(currentSlideProvider.notifier).state = slide;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${verse.book} ${verse.chapter}:${verse.verse}'),
        backgroundColor: LWColors.primary,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Actively watch the search watcher to enable reactive updates
    ref.watch(bibleSearchWatcher);

    final booksAsync = ref.watch(bibleBooksProvider);
    final selectedVersion = ref.watch(selectedBibleVersionProvider);
    final selectedBook = ref.watch(selectedBookProvider);
    final selectedChapter = ref.watch(selectedChapterProvider);
    final searchMode = ref.watch(bibleSearchModeProvider);
    
    final availableVersionsAsync = ref.watch(availableBibleVersionsProvider);
    
    return Row(
      children: [
        // SIDEBAR (Left - Controls + Books)
        Container(
          width: 250,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: LWColors.border)),
            color: LWColors.surface,
          ),
          child: Column(
            children: [
               // Controls Container (Search + Version)
               Container(
                 padding: const EdgeInsets.all(8),
                 color: LWColors.surfaceElevated,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search (e.g. Jn 3:16)',
                        prefixIcon: Icon(Icons.search, size: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                        fillColor: LWColors.background,
                        filled: true,
                      ),
                      onChanged: (val) {
                         if (val.isEmpty) {
                           ref.read(bibleSearchProvider.notifier).search("");
                           setState(() {});
                         } else {
                           ref.read(bibleSearchProvider.notifier).search(val);
                         }
                      },
                      onSubmitted: (val) {
                        final searchResults = ref.read(bibleSearchProvider);
                        if (searchResults.isNotEmpty) {
                          final verse = searchResults.first;
                          _addScripture(verse);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Version Selector
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: LWColors.border),
                        borderRadius: BorderRadius.circular(4),
                        color: LWColors.background,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: availableVersionsAsync.when(
                          loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_,__) => const Text("Error"),
                          data: (versions) {
                            // Ensure selected version is in list, else default to first or KJV
                            String actualSelected = selectedVersion;
                            if (!versions.contains(actualSelected) && versions.isNotEmpty) {
                              // If KJV is default but not in list, pick first available
                              actualSelected = versions.first;
                              Future.microtask(() => ref.read(selectedBibleVersionProvider.notifier).state = actualSelected);
                            }
                            
                            return DropdownButton<String>(
                              value: versions.contains(actualSelected) ? actualSelected : null,
                              isExpanded: true,
                              dropdownColor: LWColors.surfaceElevated,
                              style: const TextStyle(color: LWColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                              items: [
                                ...versions.map((v) {
                                  return DropdownMenuItem(
                                    value: v,
                                    child: Text(v.toUpperCase(), overflow: TextOverflow.ellipsis),
                                  );
                                }),
                                const DropdownMenuItem(
                                  value: "__SHOP__",
                                  child: Row(
                                    children: [
                                      Icon(Icons.shopping_cart, size: 16, color: LWColors.primary),
                                      SizedBox(width: 8),
                                      Text("Get More Bibles...", style: TextStyle(color: LWColors.primary, fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v == "__SHOP__") {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BibleStoreScreen()));
                                } else if (v != null) {
                                  ref.read(selectedBibleVersionProvider.notifier).state = v;
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                   ],
                 ),
               ),
               const Divider(height: 1),
               // BOOK LIST
               Expanded(
                  child: booksAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                    data: (books) {
                      if (books.isEmpty) return const Center(child: Text("No Books"));
                      
                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final bookName = books[index];
                          final isSelected = bookName == selectedBook;
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            selected: isSelected,
                            selectedTileColor: LWColors.primary.withValues(alpha: 0.2),
                            title: Text(bookName, 
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? LWColors.primary : LWColors.textPrimary
                              )
                            ),
                            onTap: () {
                              ref.read(selectedBookProvider.notifier).state = bookName;
                              ref.read(selectedChapterProvider.notifier).state = null; // Reset chapter
                              // Clear search if selecting book
                              if (_searchController.text.isNotEmpty) {
                                _searchController.clear();
                                ref.read(bibleSearchProvider.notifier).search("");
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
               ),
            ],
          ),
        ),

        // MAIN CONTENT
        Expanded(
          child: Builder(
            builder: (context) {
              final searchQuery = ref.watch(bibleSearchProvider);
              // Check active search query text as well, to avoid showing previous results blankly
              final hasText = _searchController.text.trim().isNotEmpty;
              
              // 1. SEARCH RESULTS
              if (hasText && searchQuery.isNotEmpty) {
                 return _buildVerseList(searchQuery, isSearchResult: true);
              } else if (hasText && searchQuery.isEmpty) {
                 return const Center(child: Text("No results found", style: TextStyle(color: LWColors.textMuted)));
              }
              
              // 2. BROWSE MODE
              if (selectedBook == null) {
                 return const Center(child: Text("Select a Book", style: TextStyle(color: LWColors.textMuted)));
              }

              // Load Chapters logic
              final chaptersAsync = ref.watch(bibleChaptersProvider);
              
              return Column(
                children: [
                   // TOP: Chapter Selector
                   Container(
                     height: 50,
                     padding: const EdgeInsets.symmetric(horizontal: 8),
                     color: LWColors.surfaceElevated,
                     child: chaptersAsync.when(
                       loading: () => const Center(child: CircularProgressIndicator()),
                       error: (e,s) => Text("Error $e"),
                       data: (chapters) {
                         return ListView.separated(
                           scrollDirection: Axis.horizontal,
                           itemCount: chapters.length,
                           separatorBuilder: (_, __) => const SizedBox(width: 4),
                           itemBuilder: (context, index) {
                             final ch = chapters[index];
                             final isSelected = ch == selectedChapter;
                             return ChoiceChip(
                               label: Text("$ch"),
                               selected: isSelected,
                               onSelected: (val) {
                                 ref.read(selectedChapterProvider.notifier).state = ch;
                               },
                               backgroundColor: LWColors.background,
                               selectedColor: LWColors.primary,
                               labelStyle: TextStyle(
                                 color: isSelected ? Colors.white : LWColors.textPrimary
                               ),
                             );
                           },
                         );
                       },
                     ),
                   ),
                   const Divider(height: 1),
                   
                   // BOTTOM: Verses
                   Expanded(
                     child: selectedChapter == null 
                       ? const Center(child: Text("Select a Chapter", style: TextStyle(color: LWColors.textMuted)))
                       : Consumer(
                           builder: (context, ref, child) {
                             final versesAsync = ref.watch(bibleVersesProvider);
                             return versesAsync.when(
                               loading: () => const Center(child: CircularProgressIndicator()),
                               error: (e, s) => Center(child: Text('Error: $e')),
                               data: (verses) => _buildVerseList(verses),
                             );
                           },
                         ),
                   ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerseList(List<BibleVerse> verses, {bool isSearchResult = false}) {
    if (verses.isEmpty) return const Center(child: Text("No verses found"));
    
    // Auto-Scroll Logic - Use listen to trigger jump only once when highlight changes
    ref.listen(bibleSearchHighlightProvider, (prev, next) {
      if (next != null && !isSearchResult) {
         final index = verses.indexWhere((v) => v.verse == next);
         if (index != -1 && _itemScrollController.isAttached) {
             _itemScrollController.jumpTo(index: index);
         }
      }
    });

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: LWColors.surface,
          child: Row(
            children: const [
              SizedBox(width: 140, child: Text("REFERENCE", style: TextStyle(color: LWColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(child: Text("SCRIPTURE", style: TextStyle(color: LWColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ScrollablePositionedList.separated(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemCount: verses.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final verse = verses[index];
              final isHighlighted = ref.watch(bibleSearchHighlightProvider) == verse.verse && !isSearchResult;

              return InkWell(
                onTap: () => _addScripture(verse),
                child: Container(
                  color: isHighlighted ? LWColors.primary.withOpacity(0.3) : null, // Highlight Color
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          "${verse.book} ${verse.chapter}:${verse.verse}",
                          style: const TextStyle(color: LWColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verse.content, 
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
