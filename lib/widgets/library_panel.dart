
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';
import '../providers/search_provider.dart';
import '../data/database.dart' as db;
import 'dashboard_search_field.dart';
import 'bible_search_panel.dart';
import '../models/search_result.dart';
import '../screens/song_editor_screen.dart';

class LibraryPanel extends ConsumerStatefulWidget {
  const LibraryPanel({super.key});

  @override
  ConsumerState<LibraryPanel> createState() => _LibraryPanelState();
}

class _LibraryPanelState extends ConsumerState<LibraryPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addSong(db.Song song) {
    // JUKEBOX MODE: Play Immediately
    final item = ServiceItem.fromSong(song);
    ref.read(activeServiceItemProvider.notifier).state = item;
    
    // Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: "${song.title}"'), duration: const Duration(milliseconds: 500)),
    );
  }

  Widget _buildBibleTab() {
    return const BibleSearchPanel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Container(
          color: LWColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: LWColors.primary,
            unselectedLabelColor: LWColors.textMuted,
            indicatorColor: LWColors.primary,
            tabs: const [
              Tab(text: 'SONGS'),
              Tab(text: 'BIBLE'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSongsTab(),
              _buildBibleTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSongsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(LWSpacing.sm),
          child: Row(
            children: [
              const Expanded(child: DashboardSearchField()),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: "Add New Song",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SongEditorScreen()));
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final resultsAsync = ref.watch(searchResultsProvider);
              return resultsAsync.when(
                data: (items) {
                   if (items.isEmpty) {
                     return const Center(child: Text("No results found", style: TextStyle(color: LWColors.textMuted)));
                   }
                   return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      if (item is SongResult) {
                        final song = item.song;
                        return ListTile(
                          title: Text(song.title, style: const TextStyle(color: LWColors.textPrimary)),
                          subtitle: Text(song.author ?? 'Song', style: const TextStyle(color: LWColors.textSecondary, fontSize: 12)),
                          leading: const Icon(Icons.music_note, color: LWColors.primaryDim),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _addSong(song),
                            tooltip: 'Add to Schedule',
                          ),
                          onTap: () => _addSong(song),
                        );
                      } else if (item is BibleResult) {
                        final verse = item.verse;
                        return ListTile(
                          title: Text("${verse.book} ${verse.chapter}:${verse.verse}", style: const TextStyle(color: LWColors.textPrimary)),
                          subtitle: Text(verse.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: LWColors.textSecondary, fontSize: 12)),
                          // Changed LWColors.secondary to LWColors.primary to fix compilation error if secondary is missing
                          // Or use a safe color
                          leading: const Icon(Icons.menu_book, color: LWColors.primary), 
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              // We don't have a direct "Scripture Item" from Drift Verse handy in this scope without helpers.
                              // For now, simple feedback
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bible Verse selected (Support coming soon)'), duration: Duration(milliseconds: 500)),
                              );
                            },
                            tooltip: 'Add to Schedule',
                          ),
                          onTap: () {
                             // _addVerse(verse);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              );
            },
          ),
        ),
      ],
    );
  }
}
