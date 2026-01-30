
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_download_service.dart';
import '../services/bible_ingestion_service.dart';
import '../providers/bible_provider.dart';
import '../repositories/bible_repository.dart';

// Helper provider to fetch the list and check status
final bibleStoreUriProvider = FutureProvider.autoDispose<List<BibleStoreItem>>((ref) async {
  final downloadService = ref.watch(bibleDownloadServiceProvider);
  final repository = ref.watch(bibleRepositoryProvider);
  
  // 1. Fetch from GitHub
  final githubFiles = await downloadService.fetchAvailableBibles();
  
  // 2. Check status for each
  final List<BibleStoreItem> items = [];
  for (var file in githubFiles) {
    // Check if installed in DB
    final isInstalled = await repository.hasVersion(file.name);
    // Also check if file exists (per requirement, though DB check is safer for "Installed")
    // The requirement said: "If the file already exists in ApplicationDocumentsDirectory, show 'INSTALLED'"
    // We'll trust the DB check more as it implies it's ready to use, 
    // but we can also check the download service.
    
    // Actually, let's stick to the requirement "If the file already exists... show INSTALLED"
    final isDownloaded = await downloadService.isBibleDownloaded(file.name);
    
    // We consider it "Installed" if it's in the DB. 
    // If it's just downloaded but not in DB, maybe we should auto-ingest? 
    // Let's rely on the DB status for "INSTALLED" as that's what matters for the app.
    // However, the prompt specifically asked to check the file existence.
    // Let's combine: Installed if validation passes.
    
    items.add(BibleStoreItem(
      file: file,
      isInstalled: isInstalled || isDownloaded, // simplistic logic
    ));
  }
  return items;
});

class BibleStoreItem {
  final GitHubBibleFile file;
  final bool isInstalled;
  
  BibleStoreItem({required this.file, required this.isInstalled});
}

class BibleStoreScreen extends ConsumerStatefulWidget {
  const BibleStoreScreen({super.key});

  @override
  ConsumerState<BibleStoreScreen> createState() => _BibleStoreScreenState();
}

class _BibleStoreScreenState extends ConsumerState<BibleStoreScreen> {
  // Track downloading state per item
  final Map<String, bool> _downloading = {};

  Future<void> _handleDownload(GitHubBibleFile file) async {
    setState(() {
      _downloading[file.name] = true;
    });

    try {
      final downloadService = ref.read(bibleDownloadServiceProvider);
      final repo = ref.read(bibleRepositoryProvider);
      final ingestionService = BibleIngestionService(repo);

      // 1. Download
      final localPath = await downloadService.downloadBible(file);

      // 2. Ingest
      await ingestionService.ingestJsonFile(localPath, file.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully installed ${file.name}')),
        );
        // Refresh the list to show "INSTALLED"
        ref.invalidate(bibleStoreUriProvider);
        // Refresh available versions in the main app
        ref.invalidate(availableBibleVersionsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloading[file.name] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(bibleStoreUriProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bible Store"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: asyncList.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text("No Bibles found."));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isDownloading = _downloading[item.file.name] ?? false;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book, size: 48, color: Colors.blueGrey),
                      const SizedBox(height: 12),
                      Text(
                        item.file.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (isDownloading)
                        const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      else if (item.isInstalled)
                        FilledButton.tonal(
                          onPressed: null, // Disabled
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                          ),
                          child: const Text('INSTALLED', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        FilledButton(
                          onPressed: () => _handleDownload(item.file),
                          child: const Text('DOWNLOAD'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
