import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';
import '../providers/search_provider.dart';
import '../data/database.dart' as db;
import 'dashboard_search_field.dart';
import '../providers/bible_provider.dart';
import '../models/bible_model.dart';
import 'bible_search_panel.dart';

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
        const Padding(
          padding: EdgeInsets.all(LWSpacing.sm),
          child: DashboardSearchField(),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final resultsAsync = ref.watch(searchResultsProvider);
              return resultsAsync.when(
                data: (List<db.Song> songs) {
                   if (songs.isEmpty) {
                     return const Center(child: Text("No songs found", style: TextStyle(color: LWColors.textMuted)));
                   }
                   return ListView.separated(
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        title: Text(song.title, style: const TextStyle(color: LWColors.textPrimary)),
                        subtitle: Text(song.author ?? '', style: const TextStyle(color: LWColors.textSecondary, fontSize: 12)),
                        leading: const Icon(Icons.music_note, color: LWColors.primaryDim),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _addSong(song),
                          tooltip: 'Add to Schedule',
                        ),
                        onTap: () => _addSong(song), // Also add on tap for speed? Or maybe preview?
                      );
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
