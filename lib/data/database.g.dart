// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
      'lyrics', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ccliNumberMeta =
      const VerificationMeta('ccliNumber');
  @override
  late final GeneratedColumn<String> ccliNumber = GeneratedColumn<String>(
      'ccli_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _copyrightMeta =
      const VerificationMeta('copyright');
  @override
  late final GeneratedColumn<String> copyright = GeneratedColumn<String>(
      'copyright', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('lyrics')) {
      context.handle(_lyricsMeta,
          lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta));
    } else if (isInserting) {
      context.missing(_lyricsMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('ccli_number')) {
      context.handle(
          _ccliNumberMeta,
          ccliNumber.isAcceptableOrUnknown(
              data['ccli_number']!, _ccliNumberMeta));
    }
    if (data.containsKey('copyright')) {
      context.handle(_copyrightMeta,
          copyright.isAcceptableOrUnknown(data['copyright']!, _copyrightMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, lyrics, tags, author, ccliNumber, copyright, createdAt, updatedAt];
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      lyrics: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lyrics'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      ccliNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ccli_number']),
      copyright: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}copyright']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final String title;
  final String lyrics;
  final String tags;
  final String? author;
  final String? ccliNumber;
  final String? copyright;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Song(
      {required this.id,
      required this.title,
      required this.lyrics,
      required this.tags,
      this.author,
      this.ccliNumber,
      this.copyright,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['lyrics'] = Variable<String>(lyrics);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || ccliNumber != null) {
      map['ccli_number'] = Variable<String>(ccliNumber);
    }
    if (!nullToAbsent || copyright != null) {
      map['copyright'] = Variable<String>(copyright);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      lyrics: Value(lyrics),
      tags: Value(tags),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      ccliNumber: ccliNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ccliNumber),
      copyright: copyright == null && nullToAbsent
          ? const Value.absent()
          : Value(copyright),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Song.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      lyrics: serializer.fromJson<String>(json['lyrics']),
      tags: serializer.fromJson<String>(json['tags']),
      author: serializer.fromJson<String?>(json['author']),
      ccliNumber: serializer.fromJson<String?>(json['ccliNumber']),
      copyright: serializer.fromJson<String?>(json['copyright']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'lyrics': serializer.toJson<String>(lyrics),
      'tags': serializer.toJson<String>(tags),
      'author': serializer.toJson<String?>(author),
      'ccliNumber': serializer.toJson<String?>(ccliNumber),
      'copyright': serializer.toJson<String?>(copyright),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Song copyWith(
          {int? id,
          String? title,
          String? lyrics,
          String? tags,
          Value<String?> author = const Value.absent(),
          Value<String?> ccliNumber = const Value.absent(),
          Value<String?> copyright = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        lyrics: lyrics ?? this.lyrics,
        tags: tags ?? this.tags,
        author: author.present ? author.value : this.author,
        ccliNumber: ccliNumber.present ? ccliNumber.value : this.ccliNumber,
        copyright: copyright.present ? copyright.value : this.copyright,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lyrics: $lyrics, ')
          ..write('tags: $tags, ')
          ..write('author: $author, ')
          ..write('ccliNumber: $ccliNumber, ')
          ..write('copyright: $copyright, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, lyrics, tags, author, ccliNumber,
      copyright, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.title == this.title &&
          other.lyrics == this.lyrics &&
          other.tags == this.tags &&
          other.author == this.author &&
          other.ccliNumber == this.ccliNumber &&
          other.copyright == this.copyright &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> lyrics;
  final Value<String> tags;
  final Value<String?> author;
  final Value<String?> ccliNumber;
  final Value<String?> copyright;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.tags = const Value.absent(),
    this.author = const Value.absent(),
    this.ccliNumber = const Value.absent(),
    this.copyright = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String lyrics,
    this.tags = const Value.absent(),
    this.author = const Value.absent(),
    this.ccliNumber = const Value.absent(),
    this.copyright = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        lyrics = Value(lyrics);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? lyrics,
    Expression<String>? tags,
    Expression<String>? author,
    Expression<String>? ccliNumber,
    Expression<String>? copyright,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (lyrics != null) 'lyrics': lyrics,
      if (tags != null) 'tags': tags,
      if (author != null) 'author': author,
      if (ccliNumber != null) 'ccli_number': ccliNumber,
      if (copyright != null) 'copyright': copyright,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SongsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? lyrics,
      Value<String>? tags,
      Value<String?>? author,
      Value<String?>? ccliNumber,
      Value<String?>? copyright,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      ccliNumber: ccliNumber ?? this.ccliNumber,
      copyright: copyright ?? this.copyright,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(lyrics.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (ccliNumber.present) {
      map['ccli_number'] = Variable<String>(ccliNumber.value);
    }
    if (copyright.present) {
      map['copyright'] = Variable<String>(copyright.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lyrics: $lyrics, ')
          ..write('tags: $tags, ')
          ..write('author: $author, ')
          ..write('ccliNumber: $ccliNumber, ')
          ..write('copyright: $copyright, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BibleVersesTable extends BibleVerses
    with TableInfo<$BibleVersesTable, BibleVerse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleVersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
      'book', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _bookOrderMeta =
      const VerificationMeta('bookOrder');
  @override
  late final GeneratedColumn<int> bookOrder = GeneratedColumn<int>(
      'book_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterMeta =
      const VerificationMeta('chapter');
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
      'chapter', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
      'verse', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_verses';
  @override
  VerificationContext validateIntegrity(Insertable<BibleVerse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('book')) {
      context.handle(
          _bookMeta, book.isAcceptableOrUnknown(data['book']!, _bookMeta));
    } else if (isInserting) {
      context.missing(_bookMeta);
    }
    if (data.containsKey('book_order')) {
      context.handle(_bookOrderMeta,
          bookOrder.isAcceptableOrUnknown(data['book_order']!, _bookOrderMeta));
    } else if (isInserting) {
      context.missing(_bookOrderMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(_chapterMeta,
          chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta));
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
          _verseMeta, verse.isAcceptableOrUnknown(data['verse']!, _verseMeta));
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<GeneratedColumn> get $columns =>
      [id, version, book, bookOrder, chapter, verse, content];
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {version, book, chapter, verse},
      ];
  @override
  BibleVerse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleVerse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      book: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book'])!,
      bookOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_order'])!,
      chapter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter'])!,
      verse: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $BibleVersesTable createAlias(String alias) {
    return $BibleVersesTable(attachedDatabase, alias);
  }
}

class BibleVerse extends DataClass implements Insertable<BibleVerse> {
  final int id;
  final String version;
  final String book;
  final int bookOrder;
  final int chapter;
  final int verse;
  final String content;
  const BibleVerse(
      {required this.id,
      required this.version,
      required this.book,
      required this.bookOrder,
      required this.chapter,
      required this.verse,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<String>(version);
    map['book'] = Variable<String>(book);
    map['book_order'] = Variable<int>(bookOrder);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['content'] = Variable<String>(content);
    return map;
  }

  BibleVersesCompanion toCompanion(bool nullToAbsent) {
    return BibleVersesCompanion(
      id: Value(id),
      version: Value(version),
      book: Value(book),
      bookOrder: Value(bookOrder),
      chapter: Value(chapter),
      verse: Value(verse),
      content: Value(content),
    );
  }

  factory BibleVerse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleVerse(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<String>(json['version']),
      book: serializer.fromJson<String>(json['book']),
      bookOrder: serializer.fromJson<int>(json['bookOrder']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<String>(version),
      'book': serializer.toJson<String>(book),
      'bookOrder': serializer.toJson<int>(bookOrder),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'content': serializer.toJson<String>(content),
    };
  }

  BibleVerse copyWith(
          {int? id,
          String? version,
          String? book,
          int? bookOrder,
          int? chapter,
          int? verse,
          String? content}) =>
      BibleVerse(
        id: id ?? this.id,
        version: version ?? this.version,
        book: book ?? this.book,
        bookOrder: bookOrder ?? this.bookOrder,
        chapter: chapter ?? this.chapter,
        verse: verse ?? this.verse,
        content: content ?? this.content,
      );
  @override
  String toString() {
    return (StringBuffer('BibleVerse(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('book: $book, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, version, book, bookOrder, chapter, verse, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleVerse &&
          other.id == this.id &&
          other.version == this.version &&
          other.book == this.book &&
          other.bookOrder == this.bookOrder &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.content == this.content);
}

class BibleVersesCompanion extends UpdateCompanion<BibleVerse> {
  final Value<int> id;
  final Value<String> version;
  final Value<String> book;
  final Value<int> bookOrder;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> content;
  const BibleVersesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.book = const Value.absent(),
    this.bookOrder = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.content = const Value.absent(),
  });
  BibleVersesCompanion.insert({
    this.id = const Value.absent(),
    required String version,
    required String book,
    required int bookOrder,
    required int chapter,
    required int verse,
    required String content,
  })  : version = Value(version),
        book = Value(book),
        bookOrder = Value(bookOrder),
        chapter = Value(chapter),
        verse = Value(verse),
        content = Value(content);
  static Insertable<BibleVerse> custom({
    Expression<int>? id,
    Expression<String>? version,
    Expression<String>? book,
    Expression<int>? bookOrder,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (book != null) 'book': book,
      if (bookOrder != null) 'book_order': bookOrder,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (content != null) 'content': content,
    });
  }

  BibleVersesCompanion copyWith(
      {Value<int>? id,
      Value<String>? version,
      Value<String>? book,
      Value<int>? bookOrder,
      Value<int>? chapter,
      Value<int>? verse,
      Value<String>? content}) {
    return BibleVersesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      book: book ?? this.book,
      bookOrder: bookOrder ?? this.bookOrder,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (book.present) {
      map['book'] = Variable<String>(book.value);
    }
    if (bookOrder.present) {
      map['book_order'] = Variable<int>(bookOrder.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleVersesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('book: $book, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

abstract class _$LiteWorshipDatabase extends GeneratedDatabase {
  _$LiteWorshipDatabase(QueryExecutor e) : super(e);
  $LiteWorshipDatabaseManager get managers => $LiteWorshipDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $BibleVersesTable bibleVerses = $BibleVersesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songs, bibleVerses];
}

class $LiteWorshipDatabaseManager {
  final _$LiteWorshipDatabase _db;
  $LiteWorshipDatabaseManager(this._db);
  $SongsTable get songs => _db.songs;
  $BibleVersesTable get bibleVerses => _db.bibleVerses;
}
