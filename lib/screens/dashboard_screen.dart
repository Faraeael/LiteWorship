import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../config/theme.dart';
import '../data/database.dart' as db;
import '../models/bible_model.dart';
import '../models/slide_content.dart';
import '../providers/providers.dart';
import '../providers/search_provider.dart';
import '../services/lyric_parser.dart';
import '../services/server.dart';
import '../widgets/dashboard_search_field.dart';

// ============================================================================
// LITEWORSHIP — Dashboard Screen (Local Server Controller)
// MULTI-MONITOR + BIBLE SEARCH SUPPORT
// ============================================================================

class ControlDashboard extends ConsumerStatefulWidget {
  const ControlDashboard({super.key});

  @override
  ConsumerState<ControlDashboard> createState() => _ControlDashboardState();
}

class _ControlDashboardState extends ConsumerState<ControlDashboard> {
  // Multi-Monitor State
  List<Display> _displays = [];
  Display? _selectedDisplay;
  bool _isLoadingDisplays = false;

  // Bible State
  List<BibleBook> _bible = [];
  bool _isLoadingBible = false;
  
  // Selection State (0-based indices)
  int _selectedBookIndex = -1; 
  int _selectedChapterIndex = -1;
  int _selectedVerseIndex = -1;
  
  // Scrolling
  final ScrollController _bookController = ScrollController();
  final ScrollController _chapterController = ScrollController();
  final ScrollController _verseController = ScrollController();

  // Bible Search State (OMNI-SEARCH)
  final TextEditingController _omniController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDisplays();
    _loadBible();
  }
  
  @override
  void dispose() {
    _bookController.dispose();
    _chapterController.dispose();
    _verseController.dispose();
    _omniController.dispose();
    super.dispose();
  }

  Future<void> _loadBible() async {
    setState(() => _isLoadingBible = true);
    try {
      final jsonString = await rootBundle.loadString('assets/data/kjv_bible.json');
      final jsonMap = jsonDecode(jsonString);
      final booksList = jsonMap['books'] as List;
      
      final bible = booksList.map((b) => BibleBook.fromJson(b)).toList();
      
      if (mounted) {
        setState(() {
          _bible = bible;
        });
      }
    } catch (e) {
      debugPrint('Error loading Bible: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBible = false);
    }
  }

  Future<void> _loadDisplays() async {
    setState(() => _isLoadingDisplays = true);
    try {
      final displays = await ScreenRetriever.instance.getAllDisplays();
      setState(() {
        _displays = displays;
        if (displays.length > 1) {
          _selectedDisplay = displays[1];
        } else if (displays.isNotEmpty) {
          _selectedDisplay = displays[0];
        }
      });
    } catch (e) {
      debugPrint('Error loading displays: $e');
    } finally {
      setState(() => _isLoadingDisplays = false);
    }
  }

  // --- ROBUST NORMALIZATION ---
  String _normalize(String input) {
    String s = input.trim().toLowerCase();
    // Aggressive replacements for 1Cor, 2Kin, etc.
    // Handles cases like "1cor", "1 cor", "1st cor"
    s = s.replaceAll(RegExp(r'^(1st|1)\s*'), 'i ');
    s = s.replaceAll(RegExp(r'^(2nd|2)\s*'), 'ii ');
    s = s.replaceAll(RegExp(r'^(3rd|3)\s*'), 'iii ');
    return s.trim();
  }
  
  // Helper to scroll to index
  void _scrollToSelection(ScrollController controller, int index, double itemHeight) {
    if (index < 0) return;
    // Delay slightly to allow UI build
    Future.delayed(const Duration(milliseconds: 100), () {
      if (controller.hasClients) {
        // Simple calculation: index * height. Center it roughly.
        double offset = index * itemHeight;
        // Adjust to center: offset - (viewport / 2) + (itemHeight / 2)
        // For simplicity, just jump to top or slightly padded
        double maxScroll = controller.position.maxScrollExtent;
        if (offset > maxScroll) offset = maxScroll;
        
        controller.animateTo(
          offset,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut
        );
      }
    });
  }

  // --- OMNI SEARCH LOGIC ---

  void _onOmniSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        // Optional: Reset selection? 
        // _selectedBookIndex = -1;
      });
      return;
    }

    // 1. Try to parse as Reference (Book Chapter)
    // Regex: Start with Number/Text (Group 1), optional Space, Optional Chapter (Group 2)
    final refRegex = RegExp(r'^(\d?\s*[a-zA-Z]+)(?:\s+(\d+))?(?::(\d+))?');
    final match = refRegex.firstMatch(query);

    if (match != null) {
      String bookPart = match.group(1)?.trim() ?? "";
      String? chapterPart = match.group(2);

      // Smart Fuzzy match book name using normalization
      String normQuery = _normalize(bookPart);
      
      int bookIndex = -1;
      // Exact match normalized
      bookIndex = _bible.indexWhere((b) => _normalize(b.name) == normQuery);
      if (bookIndex == -1) {
        // Starts with normalized
        bookIndex = _bible.indexWhere((b) => _normalize(b.name).startsWith(normQuery));
      }

      if (bookIndex != -1) {
        // MATCHED A BOOK
        int chapterIndex = -1;
        if (chapterPart != null) {
           int cNum = int.tryParse(chapterPart) ?? 0;
           if (cNum > 0 && cNum <= _bible[bookIndex].chapters.length) {
              chapterIndex = cNum - 1; // Convert 1-based input to 0-based index
           }
        }

        setState(() {
          _selectedBookIndex = bookIndex;
          _selectedChapterIndex = chapterIndex;
          _selectedVerseIndex = -1; 
          _searchResults = []; 
          _isSearching = false;
        });
        
        // Auto Scroll Book
        _scrollToSelection(_bookController, bookIndex, 56.0); // Approx ListTile height
        if (chapterIndex != -1) {
           // Grid item height approximation (Width/AspectRatio)
           // Difficult to predict exactly in Grid, but rough estimate:
           // Row count = index / 5
           // Row height approx 50
           int row = (chapterIndex / 5).floor();
           _scrollToSelection(_chapterController, row, 60.0);
        }
        
        return; 
      }
    }

    // 2. Fallback -> Keyword Search
    _runKeywordSearch(query);
  }

  void _handleSearchSubmit(String query) {
     if (query.trim().isEmpty) return;

     // 1. TRY DIRECT REFERENCE MATCH (Book Chapter:Verse)
     // Aggressive regex to handle "Gen 1:1" or "Gen 1 1"
     final refRegex = RegExp(r'^(\d?\s*[a-zA-Z]+)\s+(\d+)[:\s]+(\d+)$');
     final match = refRegex.firstMatch(query);

     if (match != null) {
        String bookPart = match.group(1)!.trim();
        int chapterNumInput = int.parse(match.group(2)!);
        int verseNumInput = int.parse(match.group(3)!);

        String normBookPart = _normalize(bookPart);

        // Find Book
        int bookIdx = _bible.indexWhere((b) => _normalize(b.name).startsWith(normBookPart));

        if (bookIdx != -1) {
           var book = _bible[bookIdx];
           // Find Chapter (Input is 1-based)
           if (chapterNumInput > 0 && chapterNumInput <= book.chapters.length) {
              var chapter = book.chapters[chapterNumInput - 1];
              // Find Verse (Input is 1-based)
              if (verseNumInput > 0 && verseNumInput <= chapter.verses.length) {
                 var verse = chapter.verses[verseNumInput - 1];
                 
                 // SYNC UI STATE (0-based indices)
                 setState(() {
                   _selectedBookIndex = bookIdx;
                   _selectedChapterIndex = chapterNumInput - 1;
                   _selectedVerseIndex = verseNumInput - 1; // V1 is index 0
                   _searchResults = [];
                 });
                 
                 _projectVerse(book, chapter, verse);
                 
                 // SCROLL TO IT
                 _scrollToSelection(_bookController, bookIdx, 56.0);
                 _scrollToSelection(_chapterController, ((chapterNumInput-1)/5).floor(), 60.0);
                 _scrollToSelection(_verseController, verseNumInput - 1, 56.0);

                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Projecting ${book.name} $chapterNumInput:$verseNumInput'), duration: const Duration(seconds: 1)));
                 _omniController.clear();
                 return;
              }
           }
        }
     }

     // 2. FALLBACK -> Best Search Result
     if (_searchResults.isNotEmpty) {
        final result = _searchResults[0];
        final book = result['book'] as BibleBook;
        final chapter = result['chapter'] as BibleChapter;
        final verse = result['verse'] as BibleVerse;
        
        // SYNC UI STATE (Inverse Lookup)
        int bIdx = _bible.indexOf(book);
        int cIdx = book.chapters.indexOf(chapter);
        int vIdx = chapter.verses.indexOf(verse);
        
        setState(() {
          _selectedBookIndex = bIdx;
          _selectedChapterIndex = cIdx;
          _selectedVerseIndex = vIdx;
          _searchResults = [];
        });
        
        // SCROLL
        _scrollToSelection(_bookController, bIdx, 56.0);
        _scrollToSelection(_chapterController, (cIdx/5).floor(), 60.0);
        _scrollToSelection(_verseController, vIdx, 56.0);

        _projectVerse(book, chapter, verse);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Projecting best match: ${book.name} ${chapter.chapterNumber}:${verse.verseNumber}'), duration: const Duration(seconds: 1)));
        _omniController.clear();
     } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No matching verse found to project.')));
     }
  }

  void _runKeywordSearch(String query) {
    setState(() => _isSearching = true);
    final lowerQ = query.toLowerCase();
    final List<Map<String, dynamic>> results = [];

    // Brute force search
    int count = 0;
    for (var book in _bible) {
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
               if (count >= 100) break;
            }
        }
        if (count >= 100) break;
      }
      if (count >= 100) break;
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _launchChromeKiosk() async {
    if (_selectedDisplay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No display selected! Check Settings.')),
      );
      return;
    }

    try {
      final x = _selectedDisplay!.visiblePosition?.dx.toInt() ?? 0;
      final y = _selectedDisplay!.visiblePosition?.dy.toInt() ?? 0;

      await Process.run(
        'start',
        [
          'chrome',
          '--new-window',
          '--window-position=$x,$y',
          '--kiosk',
          'http://localhost:8080'
        ],
        runInShell: true,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launching Projector on Display ${_selectedDisplay!.id ?? "Unknown"}')),
      );
    } catch (e) {
      debugPrint('Error launching Chrome: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _identifyScreens() async {
    for (var i = 0; i < _displays.length; i++) {
      final d = _displays[i];
      final x = d.visiblePosition?.dx.toInt() ?? 0;
      final y = d.visiblePosition?.dy.toInt() ?? 0;
      
      final htmlContent = "data:text/html,<body style='background:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;'><h1 style='font-size:100px;font-family:sans-serif;'>Display $i</h1></body>";
      
      try {
        await Process.run(
          'start',
          [
            'chrome',
            '--app=$htmlContent', 
            '--window-position=$x,$y',
            '--window-size=600,400'
          ],
          runInShell: true,
        );
      } catch (e) {
        debugPrint("Failed to identify display $i: $e");
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _showProjectorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Projector Setup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoadingDisplays)
                  const CircularProgressIndicator()
                else if (_displays.isEmpty)
                  const Text('No displays detected.')
                else
                  DropdownButton<Display>(
                    isExpanded: true,
                    value: _selectedDisplay,
                    hint: const Text('Select Target Display'),
                    items: _displays.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text('Display ${d.id}: ${d.size.width.toInt()}x${d.size.height.toInt()}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedDisplay = val;
                      });
                      setState(() {
                        _selectedDisplay = val;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Click "Identify" to flash numbers on all screens to verify layout.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _identifyScreens,
                child: const Text('IDENTIFY SCREENS'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DONE'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CONTROLLER LOGIC ---

  void _goLive() {
    final isLive = ref.read(isLiveProvider);
    ref.read(isLiveProvider.notifier).state = !isLive;
    if (!isLive) {
       _updateProjector(ref.read(currentSlideProvider));
    } else {
       _updateProjector(const BlankSlideContent());
    }
  }

  void _updateProjector(SlideContent? slide) {
    if (slide == null) return;
    String textContent = '';
    if (slide is TextSlideContent) {
      textContent = slide.text;
    } 
    sendProjectorMessage({
      'type': 'LYRICS',
      'content': textContent,
    });
  }

  void _projectVerse(BibleBook book, BibleChapter chapter, BibleVerse verse) {
    // If called directly from tap, index is already set in UI callbacks
    // If called from search, indices are set in _handleSearchSubmit
    // Just ensure we update local state if needed
    if (mounted) {
       // Find verse index (0-based)
       int vIdx = chapter.verses.indexOf(verse);
       if (vIdx != -1) {
          setState(() => _selectedVerseIndex = vIdx);
       }
    }
    
    final content = "${verse.text}\n\n${book.name} ${chapter.chapterNumber}:${verse.verseNumber}";
    sendProjectorMessage({
      'type': 'LYRICS',
      'content': content,
    });
    ref.read(currentSlideProvider.notifier).state = TextSlideContent(
      id: 'bible-${book.name}-${chapter.chapterNumber}-${verse.verseNumber}',
      text: content,
    );
  }

  void _selectSlide(int index) {
    ref.read(selectedSlideIndexProvider.notifier).state = index;
    if (ref.read(isLiveProvider)) {
      final slides = ref.read(slideListProvider);
      if (index >= 0 && index < slides.length) {
        final slide = slides[index];
        ref.read(currentSlideProvider.notifier).state = slide;
        _updateProjector(slide);
      }
    }
  }

  void _clearScreen() {
    sendProjectorMessage({'type': 'CLEAR'});
    ref.read(currentSlideProvider.notifier).state = const BlankSlideContent();
  }

  void _updateProjectorBackground(String path) {
    if (path == 'STOP') {
        sendProjectorMessage({'type': 'BACKGROUND', 'content': 'STOP'});
        return;
    }
    final filename = path.split('/').last;
    final url = 'http://localhost:8080/motion/$filename';
    sendProjectorMessage({
      'type': 'BACKGROUND',
      'content': url,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLive = ref.watch(isLiveProvider);

    return Scaffold(
      backgroundColor: LWColors.background,
      body: DefaultTabController(
        length: 2, // SONGS, SCRIPTURE
        child: Column(
          children: [
            _buildHeader(isLive),
            // Main Tab Bar
            Container(
              color: LWColors.surface,
              child: const TabBar(
                labelColor: LWColors.primary,
                indicatorColor: LWColors.primary,
                tabs: [
                  Tab(icon: Icon(Icons.music_note), text: 'SONGS'),
                  Tab(icon: Icon(Icons.book), text: 'SCRIPTURE'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSongsTab(),
                  _buildScriptureTab(),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildFooter(isLive),
          ],
        ),
      ),
    );
  }

  // --- SONGS TAB LAYOUT ---
  Widget _buildSongsTab() {
     final slides = ref.watch(slideListProvider);
     final selectedIndex = ref.watch(selectedSlideIndexProvider);

     return Row(
       children: [
          // Left: Library
          Container(
             width: 300,
             color: LWColors.surface,
             child: Column(
               children: [
                 const Padding(padding: EdgeInsets.all(LWSpacing.md), child: DashboardSearchField()),
                 const Divider(height: 1),
                 Expanded(
                   child: Consumer(
                     builder: (context, ref, child) {
                       final resultsAsync = ref.watch(searchResultsProvider);
                       return resultsAsync.when(
                         data: (List<db.Song> songs) => ListView.separated(
                             itemCount: songs.length,
                             separatorBuilder: (_, __) => const Divider(height: 1),
                             itemBuilder: (context, index) => _buildSongItem(songs[index]),
                         ),
                         loading: () => const Center(child: CircularProgressIndicator()),
                         error: (e, s) => Center(child: Text('Error: $e')),
                       );
                     },
                   ),
                 ),
                 const Divider(height: 1),
                 // Mini Motion Panel
                 SizedBox(
                   height: 150, 
                   child: _buildMiniMotionGrid(),
                 )
               ],
             ),
          ),
          const VerticalDivider(width: 1),
          // Center: Control Deck
          Expanded(child: _buildControlDeck(slides, selectedIndex)),
          const VerticalDivider(width: 1),
          // Right: Quick
          _buildQuickActionsPanel(),
       ],
     );
  }

  // --- SCRIPTURE TAB LAYOUT ---
  Widget _buildScriptureTab() {
    if (_isLoadingBible) return const Center(child: CircularProgressIndicator());
    if (_bible.isEmpty) return const Center(child: Text('Could not load Bible data'));

    return Column(
      children: [
        // OMNI SEARCH HEADER
        Container(
          color: LWColors.surface,
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _omniController,
            textInputAction: TextInputAction.go,
            onSubmitted: _handleSearchSubmit,
            decoration: const InputDecoration(
              hintText: 'Enter reference (Gen 1:1) or keyword (Love)...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
            onChanged: _onOmniSearchChanged,
          ),
        ),
        const Divider(height: 1),
        
        // RESULT AREA
        Expanded(
          child: _searchResults.isNotEmpty
              ? _buildSearchResults()
              : _buildBookChapterVerseSelector(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) return const Center(child: CircularProgressIndicator());
    
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final book = result['book'] as BibleBook;
        final chapter = result['chapter'] as BibleChapter;
        final verse = result['verse'] as BibleVerse;

        return ListTile(
          title: Text(verse.text),
          subtitle: Text('${book.name} ${chapter.chapterNumber}:${verse.verseNumber}', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: LWColors.primary)),
          onTap: () => _projectVerse(book, chapter, verse),
        );
      },
    );
  }

  Widget _buildBookChapterVerseSelector() {
    return Row(
      children: [
        // Col 1: Books
        Expanded(
          flex: 1,
          child: Container(
            color: LWColors.surface,
            child: ListView.builder(
              controller: _bookController,
              itemCount: _bible.length,
              itemExtent: 56.0, // Fixed height for auto-scroll calc
              itemBuilder: (context, index) {
                final book = _bible[index];
                final isSelected = index == _selectedBookIndex;

                return ListTile(
                  title: Text(
                    book.name, 
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : LWColors.textPrimary
                    )
                  ),
                  tileColor: isSelected ? Colors.blueAccent : null,
                  onTap: () {
                    setState(() {
                      _selectedBookIndex = index;
                      _selectedChapterIndex = -1; 
                      _selectedVerseIndex = -1;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Col 2: Chapters
        Expanded(
          flex: 1,
          child: _selectedBookIndex == -1 
            ? const Center(child: Text('Select a Book'))
            : Container(
               color: LWColors.background,
               child: GridView.builder(
                 controller: _chapterController,
                 padding: const EdgeInsets.all(LWSpacing.sm),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 5, childAspectRatio: 1.0, crossAxisSpacing: 8, mainAxisSpacing: 8
                 ),
                 itemCount: _bible[_selectedBookIndex].chapters.length,
                 itemBuilder: (context, index) {
                   final chapter = _bible[_selectedBookIndex].chapters[index];
                   final isSelected = index == _selectedChapterIndex;
                   return InkWell(
                     onTap: () => setState(() {
                       _selectedChapterIndex = index;
                       _selectedVerseIndex = -1;
                     }),
                     child: Container(
                       decoration: BoxDecoration(
                         color: isSelected ? Colors.blueAccent : LWColors.surface,
                         shape: BoxShape.circle,
                       ),
                       alignment: Alignment.center,
                       child: Text(
                         '${chapter.chapterNumber}', 
                         style: TextStyle(
                           color: isSelected ? Colors.white : LWColors.textPrimary,
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )
                       ),
                     ),
                   );
                 },
               ),
            ),
        ),
        const VerticalDivider(width: 1),
        // Col 3: Verses
        Expanded(
          flex: 2,
          child: (_selectedBookIndex == -1 || _selectedChapterIndex == -1)
            ? const Center(child: Text('Select a Chapter'))
            : Container(
                color: LWColors.background,
                child: ListView.separated(
                  controller: _verseController,
                  padding: const EdgeInsets.all(LWSpacing.md),
                  itemCount: _bible[_selectedBookIndex].chapters[_selectedChapterIndex].verses.length,
                  separatorBuilder: (_,__) => const Divider(height: 1), // Minimal divider
                  itemBuilder: (context, index) {
                    final verse = _bible[_selectedBookIndex].chapters[_selectedChapterIndex].verses[index];
                    // Correct 0-based check
                    final isSelected = index == _selectedVerseIndex;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent.withOpacity(0.2) : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 12, 
                          backgroundColor: isSelected ? Colors.blueAccent : LWColors.surfaceElevated,
                          foregroundColor: isSelected ? Colors.white : null,
                          child: Text('${verse.verseNumber}', style: const TextStyle(fontSize: 10)),
                        ),
                        title: Text(verse.text),
                        onTap: () => _projectVerse(
                          _bible[_selectedBookIndex], 
                          _bible[_selectedBookIndex].chapters[_selectedChapterIndex], 
                          verse
                        ),
                      ),
                    );
                  },
                ),
            ),
        ),
        const VerticalDivider(width: 1),
        _buildQuickActionsPanel(),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildMiniMotionGrid() {
    final backgrounds = [
      'assets/motion/blue_nebula.mp4',
      'assets/motion/gold_worship.mp4',
      'assets/motion/particles.mp4',
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            const Text('MOTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Spacer(),
            InkWell(onTap: () => _updateProjectorBackground('STOP'), child: const Icon(Icons.close, size: 16)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: backgrounds.length,
            itemBuilder: (context, index) {
               final path = backgrounds[index];
               final filename = path.split('/').last;
               return InkWell(
                 onTap: () => _updateProjectorBackground(path),
                 child: Container(
                   width: 100,
                   margin: const EdgeInsets.all(4),
                   decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                   alignment: Alignment.center,
                   child: const Icon(Icons.motion_photos_on, color: Colors.blueGrey),
                 ),
               );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongItem(db.Song song) {
    return ListTile(
      title: Text(song.title),
      subtitle: Text(song.lyrics.split('\n').first, overflow: TextOverflow.ellipsis),
      onTap: () => _openSong(song),
    );
  }

  void _openSong(db.Song song) {
    final slides = LyricParser.parse(song.lyrics, song.id.toString(), defaultTitle: song.title);
    ref.read(slideListProvider.notifier).state = slides;
    ref.read(selectedSlideIndexProvider.notifier).state = 0;
  }

  Widget _buildControlDeck(List<SlideContent> slides, int selectedIndex) {
    return Container(
      color: LWColors.background,
      padding: const EdgeInsets.all(LWSpacing.md),
      child: Column(
        children: [
           Row(children: [Text('Song Slides'), const Spacer(), Chip(label: Text('${slides.length}'))]),
           const SizedBox(height: LWSpacing.md),
           Expanded(
            child: slides.isEmpty
                ? const Center(child: Text('Select a song from the Library'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 16/9),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return _SlideGridCard(
                        slide: slides[index],
                        index: index,
                        isActive: isSelected,
                        isLive: ref.watch(isLiveProvider) && isSelected,
                        onTap: () => _selectSlide(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    return Container(
      width: 80,
      color: LWColors.surface,
      child: Column(children: [
        const SizedBox(height: 20),
        IconButton(icon: const Icon(Icons.tv_off), onPressed: _clearScreen, tooltip: 'Clear Text'),
      ]),
    );
  }

  Widget _buildHeader(bool isLive) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: LWSpacing.md),
      color: LWColors.surface,
      child: Row(
        children: [
          const Icon(Icons.church, color: LWColors.primary, size: 24),
          const SizedBox(width: LWSpacing.sm),
          Text(
            'LiteWorship Server',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: LWColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Projector Setup',
            onPressed: _showProjectorSetupDialog,
          ),
          const SizedBox(width: LWSpacing.sm),
          ElevatedButton.icon(
            onPressed: _launchChromeKiosk,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('OPEN PROJECTOR'),
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: LWSpacing.md),
          if (isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: LWColors.live, borderRadius: BorderRadius.circular(LWRadius.sm)),
              child: const Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isLive) {
    return Container(
      height: 56,
      color: LWColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
             onPressed: _goLive,
             style: ElevatedButton.styleFrom(backgroundColor: isLive ? Colors.red : Colors.green, foregroundColor: Colors.white),
             icon: Icon(isLive ? Icons.stop : Icons.play_arrow),
             label: Text(isLive ? 'STOP LIVE' : 'GO LIVE'),
          ),
        ],
      ),
    );
  }
}

class _SlideGridCard extends StatelessWidget {
  const _SlideGridCard({required this.slide, required this.index, required this.isActive, required this.isLive, required this.onTap});
  final SlideContent slide;
  final int index;
  final bool isActive;
  final bool isLive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String text = '';
    if (slide is TextSlideContent) text = (slide as TextSlideContent).text;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[800] : Colors.grey[900],
          border: isActive ? Border.all(color: Colors.blue, width: 2) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Center(child: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10))),
             if (isLive) Positioned(bottom: 0, right: 0, child: Container(color: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 4), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8))))
          ],
        ),
      ),
    );
  }
}
