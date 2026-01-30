
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart'; // For SongsCompanion
import '../models/song_model.dart';
import '../repositories/song_repository.dart';

class UserSongService {
  final SongRepository _repository;
  final Uuid _uuidGenerator = const Uuid();

  UserSongService(this._repository);

  /// Get the directory where user songs are stored
  Future<Directory> get _songsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'LiteWorship', 'Songs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Initialize: Sync all JSON files to DB
  /// Call this when the app starts
  Future<void> initialize() async {
    final dir = await _songsDir;
    debugPrint('🎵 Syncing user songs from ${dir.path}...');
    if (!await dir.exists()) return;

    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final jsonStr = await entity.readAsString();
          final Map<String, dynamic> json = jsonDecode(jsonStr);
          var song = SongModel.fromJson(json);
          
          bool needsSave = false;
          // Ensure UUID
          if (song.uuid == null) {
              // Try to identify if filename is UUID
              final basename = p.basenameWithoutExtension(entity.path);
              if (Uuid.isValidUUID(fromString: basename)) {
                 song = song.copyWith(uuid: basename, source: 'local');
              } else {
                 song = song.copyWith(uuid: _uuidGenerator.v4(), source: 'local');
              }
              needsSave = true;
          }

          // Force source to local
          if (song.source != 'local') {
             song = song.copyWith(source: 'local');
             needsSave = true;
          }
          
          // Upsert to DB
          await _upsertToDb(song);
          
          // Save back if we modified the model (added UUID or Source)
          if (needsSave) {
              await _saveJson(song);
          }
        } catch (e) {
          debugPrint('⚠️ Error loading song ${entity.path}: $e');
        }
      }
    }
  }

  /// Save a song (Create or Update)
  /// Persists to JSON and syncs to DB
  Future<void> saveSong(SongModel song) async {
    SongModel finalSong = song;
    if (finalSong.uuid == null) {
       finalSong = finalSong.copyWith(uuid: _uuidGenerator.v4(), source: 'local');
    }
    
    // 1. Write to JSON
    await _saveJson(finalSong);
    
    // 2. Sync to DB
    await _upsertToDb(finalSong);
  }

  /// Delete a song
  Future<void> deleteSong(String uuid) async {
      // 1. Remove JSON
      final dir = await _songsDir;
      final file = File(p.join(dir.path, '$uuid.json'));
      if (await file.exists()) {
          await file.delete();
      }
      
      // 2. Remove from DB
      final song = await _repository.getByUuid(uuid);
      if (song != null) {
          await _repository.delete(song.id);
      }
  }
  
  /// Helper: Write JSON file
  Future<void> _saveJson(SongModel song) async {
    final dir = await _songsDir;
    final file = File(p.join(dir.path, '${song.uuid}.json'));
    // Pretty print
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(song.toJson()));
  }

  /// Helper: Sync to Drift DB
  Future<void> _upsertToDb(SongModel song) async {
    if (song.uuid == null) return;
    
    await _repository.syncUserSong(song.uuid!, SongsCompanion(
      title: Value(song.title),
      lyrics: Value(song.lyrics),
      source: const Value('local'),
      uuid: Value(song.uuid),
      author: song.author != null ? Value(song.author) : const Value.absent(),
      copyright: song.copyright != null ? Value(song.copyright) : const Value.absent(),
      ccliNumber: song.ccliNumber != null ? Value(song.ccliNumber) : const Value.absent(),
      tags: Value(song.tags.join(',')),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
