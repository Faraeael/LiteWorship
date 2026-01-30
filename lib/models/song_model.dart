
import 'package:flutter/foundation.dart';

@immutable
class SongModel {
  final int? id; // Nullable for new songs not yet generated
  final String title;
  final String lyrics;
  final String? source; // 'local' or 'bundled'
  final String? uuid; // Unique ID
  final List<String> tags;
  final String? author;
  final String? ccliNumber;
  final String? copyright;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SongModel({
    this.id,
    required this.title,
    required this.lyrics,
    this.source,
    this.uuid,
    this.tags = const [],
    this.author,
    this.ccliNumber,
    this.copyright,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with some fields replaced
  SongModel copyWith({
    int? id,
    String? title,
    String? lyrics,
    String? source,
    String? uuid,
    List<String>? tags,
    String? author,
    String? ccliNumber,
    String? copyright,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      source: source ?? this.source,
      uuid: uuid ?? this.uuid,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      ccliNumber: ccliNumber ?? this.ccliNumber,
      copyright: copyright ?? this.copyright,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON Map for file storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lyrics': lyrics,
      'source': source,
      'uuid': uuid,
      'tags': tags,
      'author': author,
      'ccliNumber': ccliNumber,
      'copyright': copyright,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      lyrics: json['lyrics'] as String,
      source: json['source'] as String?,
      uuid: json['uuid'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      author: json['author'] as String?,
      ccliNumber: json['ccliNumber'] as String?,
      copyright: json['copyright'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongModel &&
        other.id == id &&
        other.title == title &&
        other.lyrics == lyrics &&
        other.source == source &&
        other.uuid == uuid &&
        listEquals(other.tags, tags) &&
        other.author == author &&
        other.copyright == copyright;
  }

  @override
  int get hashCode => Object.hash(id, title, lyrics, source, uuid, Object.hashAll(tags), author, copyright);
}
