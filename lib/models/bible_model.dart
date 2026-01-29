class BibleVerse {
  final int verseNumber;
  final String text;

  BibleVerse({required this.verseNumber, required this.text});

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verseNumber: json['verse'] as int,
      text: json['text'] as String,
    );
  }
}

class BibleChapter {
  final int chapterNumber;
  final List<BibleVerse> verses;

  BibleChapter({required this.chapterNumber, required this.verses});

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    var list = json['verses'] as List;
    List<BibleVerse> versesList = list.map((i) => BibleVerse.fromJson(i)).toList();

    return BibleChapter(
      chapterNumber: json['chapter'] as int,
      verses: versesList,
    );
  }
}

class BibleBook {
  final String name;
  final List<BibleChapter> chapters;

  BibleBook({required this.name, required this.chapters});

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    var list = json['chapters'] as List;
    List<BibleChapter> chaptersList = list.map((i) => BibleChapter.fromJson(i)).toList();

    return BibleBook(
      name: json['name'] as String,
      chapters: chaptersList,
    );
  }
}
