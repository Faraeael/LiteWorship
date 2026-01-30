
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_song_service.dart';
import 'search_provider.dart'; // for songRepositoryProvider

// ============================================================================
// LITEWORSHIP — User Content Providers
// Access to UserSongService for CRUD operations
// ============================================================================

final userSongServiceProvider = Provider<UserSongService>((ref) {
  final repo = ref.watch(songRepositoryProvider);
  return UserSongService(repo);
});

/// Trigger this provider at app startup to sync JSON files to DB
final userSongSyncProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(userSongServiceProvider);
  await service.initialize();
});
