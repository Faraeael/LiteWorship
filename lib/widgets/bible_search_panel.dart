import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/bible_model.dart';
import '../models/service_model.dart';
import '../models/slide_content.dart';
import '../config/theme.dart';
import '../providers/bible_provider.dart';
import '../providers/search_provider.dart';
import '../providers/service_provider.dart';
import '../providers/providers.dart';
import '../services/server.dart'; // sendProjectorMessage

class BibleSearchPanel extends ConsumerStatefulWidget {
  const BibleSearchPanel({super.key});

  @override
  ConsumerState<BibleSearchPanel> createState() => _BibleSearchPanelState();
}

class _BibleSearchPanelState extends ConsumerState<BibleSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addScripture(BibleBook book, BibleChapter chapter, BibleVerse verse) {
    // JUKEBOX MODE: Play Immediately
    final item = ServiceItem.fromScripture(book, chapter, verse);
    ref.read(activeServiceItemProvider.notifier).state = item;
    
    // Optional: Auto-Go Live logic could be added here if desired by user, 
    // but usually they want to see it in preview first.
    
    // Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${book.name} ${chapter.chapterNumber}:${verse.verseNumber}'),
        backgroundColor: LWColors.primary,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleDataProvider);
    final selectedVersion = ref.watch(selectedBibleVersionProvider);
    final selectedBookIndex = ref.watch(selectedBookIndexProvider);
    
    // Using a Row to create Left Sidebar | Right Content
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
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, size: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                        fillColor: LWColors.background,
                        filled: true,
                      ),
                      onChanged: (val) {
                         if (val.isEmpty) setState(() {}); 
                         bibleAsync.whenData((bible) {
                            ref.read(bibleSearchProvider.notifier).search(val, bible);
                         });
                      },
                      onSubmitted: (val) {
                        debugPrint('ENTER pressed. Search query: $val');
                        final searchResults = ref.read(bibleSearchProvider);
                        debugPrint('Search results count: ${searchResults.length}');
                        
                        if (searchResults.isNotEmpty) {
                          final res = searchResults.first;
                          final book = res['book'] as BibleBook;
                          final chapter = res['chapter'] as BibleChapter;
                          final verse = res['verse'] as BibleVerse;
                          
                          debugPrint('First result: ${book.name} ${chapter.chapterNumber}:${verse.verseNumber}');
                          
                          // Check if this verse is ALREADY loaded in the Active Panel
                          final currentItem = ref.read(activeServiceItemProvider);
                          debugPrint('Current active item: $currentItem');
                          
                          final isSame = currentItem != null && 
                                         currentItem.type == ServiceItemType.scripture &&
                                         currentItem.scripture!.book.name == book.name &&
                                         currentItem.scripture!.chapter.chapterNumber == chapter.chapterNumber &&
                                         currentItem.scripture!.verse.verseNumber == verse.verseNumber;
                          
                          debugPrint('isSame check: $isSame');

                          if (isSame) {
                             // SECOND ENTER: GO LIVE!
                             debugPrint('Going LIVE!');
                             ref.read(isLiveProvider.notifier).state = true;
                             
                             // Construct slide to push to projector
                             final text = "${verse.text}\n\n${book.name} ${chapter.chapterNumber}:${verse.verseNumber}";
                             final slide = TextSlideContent(
                               id: const Uuid().v4(),
                               text: text,
                               label: 'Verse',
                             );
                             
                             ref.read(currentSlideProvider.notifier).state = slide;
                             
                             // FORCE SEND TO PROJECTOR
                             sendProjectorMessage({
                               'type': 'LYRICS',
                               'content': slide.text,
                             });

                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('LIVE!'),
                                 duration: Duration(milliseconds: 500),
                                 backgroundColor: LWColors.live,
                               ),
                             );
                          } else {
                             // FIRST ENTER: LOAD PREVIEW
                             _addScripture(book, chapter, verse);
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Previewing. Press Enter again to Go Live.'),
                                 duration: Duration(seconds: 2),
                                 backgroundColor: LWColors.primaryDim,
                               ),
                             );
                             // Keep focus on search field for second Enter
                             _searchFocusNode.requestFocus();
                          }
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
                        child: DropdownButton<BibleVersion>(
                          value: selectedVersion,
                          isExpanded: true,
                          dropdownColor: LWColors.surfaceElevated,
                          style: const TextStyle(color: LWColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          items: BibleVersion.values.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) => ref.read(selectedBibleVersionProvider.notifier).state = v!,
                        ),
                      ),
                    ),
                   ],
                 ),
               ),
               const Divider(height: 1),
               // BOOK LIST (Remaining height of sidebar)
               Expanded(
                  child: bibleAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error')),
                    data: (bible) {
                      return ListView.builder(
                        itemCount: bible.length,
                        itemBuilder: (context, index) {
                          final book = bible[index];
                          final isSelected = index == selectedBookIndex;
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            selected: isSelected,
                            selectedTileColor: LWColors.primary.withValues(alpha: 0.2),
                            title: Text(book.name, 
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? LWColors.primary : LWColors.textPrimary
                              )
                            ),
                            onTap: () {
                              // If current search is active, clear it when selecting book? 
                              // User's diagram implies book list is always visible.
                              // We'll keep search separate.
                              if (_searchController.text.isNotEmpty) {
                                _searchController.clear();
                                ref.read(bibleSearchProvider.notifier).search("", bible);
                                setState(() {});
                              }
                              ref.read(selectedBookIndexProvider.notifier).state = index;
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

        // MAIN CONTENT (Right - Verses)
        Expanded(
          child: bibleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (bible) {
              final searchQuery = ref.watch(bibleSearchProvider);
              
              // 1. SEARCH MODE
              if (_searchController.text.isNotEmpty) {
                 if (searchQuery.isEmpty) {
                   return const Center(child: Text("No results found", style: TextStyle(color: LWColors.textMuted)));
                 }
                 return _buildVerseList(searchQuery);
              }

              // 2. BROWSE MODE
              if (selectedBookIndex < 0) {
                return const Center(child: Text("Select a Book from the sidebar", style: TextStyle(color: LWColors.textMuted)));
              }
              
              final book = bible[selectedBookIndex];
              return _buildBookDetailView(book);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookDetailView(BibleBook book) {
    // Flatten verses
    final List<Map<String, dynamic>> verses = [];
    for (var chapter in book.chapters) {
      for (var verse in chapter.verses) {
        verses.add({
          'book': book,
          'chapter': chapter,
          'verse': verse,
        });
      }
    }

    return Column(
      children: [
        Container(
          height: 32,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: LWColors.surfaceElevated,
          child: Text("${book.name} - ${book.chapters.length} Chapters", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: LWColors.textMuted)),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildVerseList(verses),
        ),
      ],
    );
  }

  Widget _buildVerseList(List<Map<String, dynamic>> verses, {bool isSearchResult = false}) {
    return Column(
      children: [
        // Header Row
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
          child: ListView.separated(
            itemCount: verses.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final item = verses[index];
              final book = item['book'] as BibleBook;
              final chapter = item['chapter'] as BibleChapter;
              final verse = item['verse'] as BibleVerse;
              
              return InkWell(
                onTap: () => _addScripture(book, chapter, verse),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference
                      SizedBox(
                        width: 140,
                        child: Text(
                          "${book.name} ${chapter.chapterNumber}:${verse.verseNumber}",
                          style: const TextStyle(color: LWColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      // Scripture
                      Expanded(
                        child: Text(
                          verse.text,
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
