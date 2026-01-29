import 'package:uuid/uuid.dart';
import 'bible_model.dart';
import 'slide_content.dart';
import '../data/database.dart' as db;

enum ServiceItemType {
  song,
  scripture,
  media, // Video/Image background
  text,  // Custom text announcement
}

class ServiceItem {
  final String id;
  final ServiceItemType type;
  final String title;
  final String? subtitle;
  
  // Payload (One of these will be populated based on type)
  final db.Song? song;
  final BibleReference? scripture; // Helper class for reference
  final String? customText;
  final String? mediaPath;

  ServiceItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.song,
    this.scripture,
    this.customText,
    this.mediaPath,
  });

  factory ServiceItem.fromSong(db.Song song) {
    return ServiceItem(
      id: const Uuid().v4(),
      type: ServiceItemType.song,
      title: song.title,
      subtitle: song.author ?? '',
      song: song,
    );
  }

  factory ServiceItem.fromScripture(BibleBook book, BibleChapter chapter, BibleVerse verse) {
    return ServiceItem(
      id: const Uuid().v4(),
      type: ServiceItemType.scripture,
      title: '${book.name} ${chapter.chapterNumber}:${verse.verseNumber}',
      subtitle: verse.text,
      scripture: BibleReference(book: book, chapter: chapter, verse: verse),
    );
  }
}

class BibleReference {
  final BibleBook book;
  final BibleChapter chapter;
  final BibleVerse verse;

  BibleReference({required this.book, required this.chapter, required this.verse});
}
