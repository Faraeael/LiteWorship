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
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
    'lyrics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ccliNumberMeta = const VerificationMeta(
    'ccliNumber',
  );
  @override
  late final GeneratedColumn<String> ccliNumber = GeneratedColumn<String>(
    'ccli_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _copyrightMeta = const VerificationMeta(
    'copyright',
  );
  @override
  late final GeneratedColumn<String> copyright = GeneratedColumn<String>(
    'copyright',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bundled'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    lyrics,
    tags,
    author,
    ccliNumber,
    copyright,
    createdAt,
    updatedAt,
    source,
    uuid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('lyrics')) {
      context.handle(
        _lyricsMeta,
        lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta),
      );
    } else if (isInserting) {
      context.missing(_lyricsMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('ccli_number')) {
      context.handle(
        _ccliNumberMeta,
        ccliNumber.isAcceptableOrUnknown(data['ccli_number']!, _ccliNumberMeta),
      );
    }
    if (data.containsKey('copyright')) {
      context.handle(
        _copyrightMeta,
        copyright.isAcceptableOrUnknown(data['copyright']!, _copyrightMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      lyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      ccliNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ccli_number'],
      ),
      copyright: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}copyright'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  /// Auto-incrementing primary key
  final int id;

  /// Song title (required, indexed for fast lookups)
  final String title;

  /// Song lyrics stored as raw text (ChordPro or plain)
  final String lyrics;

  /// Comma-separated tags for categorization (e.g., "worship,praise,slow")
  final String tags;

  /// Original author/artist (optional)
  final String? author;

  /// CCLI license number (optional)
  final String? ccliNumber;

  /// Copyright info (optional)
  final String? copyright;

  /// Created timestamp
  final DateTime createdAt;

  /// Last modified timestamp
  final DateTime updatedAt;

  /// Data source: 'local' (user-added) or 'bundled' (built-in)
  final String source;

  /// Unique ID for synchronization (UUID)
  final String? uuid;
  const Song({
    required this.id,
    required this.title,
    required this.lyrics,
    required this.tags,
    this.author,
    this.ccliNumber,
    this.copyright,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    this.uuid,
  });
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
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      lyrics: Value(lyrics),
      tags: Value(tags),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      ccliNumber: ccliNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ccliNumber),
      copyright: copyright == null && nullToAbsent
          ? const Value.absent()
          : Value(copyright),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      source: Value(source),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      source: serializer.fromJson<String>(json['source']),
      uuid: serializer.fromJson<String?>(json['uuid']),
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
      'source': serializer.toJson<String>(source),
      'uuid': serializer.toJson<String?>(uuid),
    };
  }

  Song copyWith({
    int? id,
    String? title,
    String? lyrics,
    String? tags,
    Value<String?> author = const Value.absent(),
    Value<String?> ccliNumber = const Value.absent(),
    Value<String?> copyright = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    Value<String?> uuid = const Value.absent(),
  }) => Song(
    id: id ?? this.id,
    title: title ?? this.title,
    lyrics: lyrics ?? this.lyrics,
    tags: tags ?? this.tags,
    author: author.present ? author.value : this.author,
    ccliNumber: ccliNumber.present ? ccliNumber.value : this.ccliNumber,
    copyright: copyright.present ? copyright.value : this.copyright,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    source: source ?? this.source,
    uuid: uuid.present ? uuid.value : this.uuid,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
      tags: data.tags.present ? data.tags.value : this.tags,
      author: data.author.present ? data.author.value : this.author,
      ccliNumber: data.ccliNumber.present
          ? data.ccliNumber.value
          : this.ccliNumber,
      copyright: data.copyright.present ? data.copyright.value : this.copyright,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      source: data.source.present ? data.source.value : this.source,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

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
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    lyrics,
    tags,
    author,
    ccliNumber,
    copyright,
    createdAt,
    updatedAt,
    source,
    uuid,
  );
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
          other.updatedAt == this.updatedAt &&
          other.source == this.source &&
          other.uuid == this.uuid);
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
  final Value<String> source;
  final Value<String?> uuid;
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
    this.source = const Value.absent(),
    this.uuid = const Value.absent(),
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
    this.source = const Value.absent(),
    this.uuid = const Value.absent(),
  }) : title = Value(title),
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
    Expression<String>? source,
    Expression<String>? uuid,
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
      if (source != null) 'source': source,
      if (uuid != null) 'uuid': uuid,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? lyrics,
    Value<String>? tags,
    Value<String?>? author,
    Value<String?>? ccliNumber,
    Value<String?>? copyright,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? source,
    Value<String?>? uuid,
  }) {
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
      source: source ?? this.source,
      uuid: uuid ?? this.uuid,
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
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('uuid: $uuid')
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
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
    'book',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookOrderMeta = const VerificationMeta(
    'bookOrder',
  );
  @override
  late final GeneratedColumn<int> bookOrder = GeneratedColumn<int>(
    'book_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    book,
    bookOrder,
    chapter,
    verse,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleVerse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('book')) {
      context.handle(
        _bookMeta,
        book.isAcceptableOrUnknown(data['book']!, _bookMeta),
      );
    } else if (isInserting) {
      context.missing(_bookMeta);
    }
    if (data.containsKey('book_order')) {
      context.handle(
        _bookOrderMeta,
        bookOrder.isAcceptableOrUnknown(data['book_order']!, _bookOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_bookOrderMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {version, book, chapter, verse},
  ];
  @override
  BibleVerse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleVerse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      book: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book'],
      )!,
      bookOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_order'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $BibleVersesTable createAlias(String alias) {
    return $BibleVersesTable(attachedDatabase, alias);
  }
}

class BibleVerse extends DataClass implements Insertable<BibleVerse> {
  /// Auto-incrementing primary key
  final int id;

  /// Bible version (e.g., "KJV", "NIV", "ESV")
  final String version;

  /// Book name (e.g., "Genesis", "John", "Revelation")
  final String book;

  /// Book order number (1=Genesis, 66=Revelation)
  final int bookOrder;

  /// Chapter number
  final int chapter;

  /// Verse number
  final int verse;

  /// The actual verse text (renamed to avoid conflict with Table.text method)
  final String content;
  const BibleVerse({
    required this.id,
    required this.version,
    required this.book,
    required this.bookOrder,
    required this.chapter,
    required this.verse,
    required this.content,
  });
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

  factory BibleVerse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  BibleVerse copyWith({
    int? id,
    String? version,
    String? book,
    int? bookOrder,
    int? chapter,
    int? verse,
    String? content,
  }) => BibleVerse(
    id: id ?? this.id,
    version: version ?? this.version,
    book: book ?? this.book,
    bookOrder: bookOrder ?? this.bookOrder,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    content: content ?? this.content,
  );
  BibleVerse copyWithCompanion(BibleVersesCompanion data) {
    return BibleVerse(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      book: data.book.present ? data.book.value : this.book,
      bookOrder: data.bookOrder.present ? data.bookOrder.value : this.bookOrder,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      content: data.content.present ? data.content.value : this.content,
    );
  }

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
  }) : version = Value(version),
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

  BibleVersesCompanion copyWith({
    Value<int>? id,
    Value<String>? version,
    Value<String>? book,
    Value<int>? bookOrder,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? content,
  }) {
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

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      required String title,
      required String lyrics,
      Value<String> tags,
      Value<String?> author,
      Value<String?> ccliNumber,
      Value<String?> copyright,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> source,
      Value<String?> uuid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> lyrics,
      Value<String> tags,
      Value<String?> author,
      Value<String?> ccliNumber,
      Value<String?> copyright,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> source,
      Value<String?> uuid,
    });

class $$SongsTableFilterComposer
    extends Composer<_$LiteWorshipDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccliNumber => $composableBuilder(
    column: $table.ccliNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get copyright => $composableBuilder(
    column: $table.copyright,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$LiteWorshipDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccliNumber => $composableBuilder(
    column: $table.ccliNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get copyright => $composableBuilder(
    column: $table.copyright,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$LiteWorshipDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get ccliNumber => $composableBuilder(
    column: $table.ccliNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get copyright =>
      $composableBuilder(column: $table.copyright, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$LiteWorshipDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, BaseReferences<_$LiteWorshipDatabase, $SongsTable, Song>),
          Song,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$LiteWorshipDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> lyrics = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> ccliNumber = const Value.absent(),
                Value<String?> copyright = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> uuid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                title: title,
                lyrics: lyrics,
                tags: tags,
                author: author,
                ccliNumber: ccliNumber,
                copyright: copyright,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                uuid: uuid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String lyrics,
                Value<String> tags = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> ccliNumber = const Value.absent(),
                Value<String?> copyright = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> uuid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                title: title,
                lyrics: lyrics,
                tags: tags,
                author: author,
                ccliNumber: ccliNumber,
                copyright: copyright,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                uuid: uuid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiteWorshipDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, BaseReferences<_$LiteWorshipDatabase, $SongsTable, Song>),
      Song,
      PrefetchHooks Function()
    >;
typedef $$BibleVersesTableCreateCompanionBuilder =
    BibleVersesCompanion Function({
      Value<int> id,
      required String version,
      required String book,
      required int bookOrder,
      required int chapter,
      required int verse,
      required String content,
    });
typedef $$BibleVersesTableUpdateCompanionBuilder =
    BibleVersesCompanion Function({
      Value<int> id,
      Value<String> version,
      Value<String> book,
      Value<int> bookOrder,
      Value<int> chapter,
      Value<int> verse,
      Value<String> content,
    });

class $$BibleVersesTableFilterComposer
    extends Composer<_$LiteWorshipDatabase, $BibleVersesTable> {
  $$BibleVersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookOrder => $composableBuilder(
    column: $table.bookOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleVersesTableOrderingComposer
    extends Composer<_$LiteWorshipDatabase, $BibleVersesTable> {
  $$BibleVersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookOrder => $composableBuilder(
    column: $table.bookOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleVersesTableAnnotationComposer
    extends Composer<_$LiteWorshipDatabase, $BibleVersesTable> {
  $$BibleVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get book =>
      $composableBuilder(column: $table.book, builder: (column) => column);

  GeneratedColumn<int> get bookOrder =>
      $composableBuilder(column: $table.bookOrder, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$BibleVersesTableTableManager
    extends
        RootTableManager<
          _$LiteWorshipDatabase,
          $BibleVersesTable,
          BibleVerse,
          $$BibleVersesTableFilterComposer,
          $$BibleVersesTableOrderingComposer,
          $$BibleVersesTableAnnotationComposer,
          $$BibleVersesTableCreateCompanionBuilder,
          $$BibleVersesTableUpdateCompanionBuilder,
          (
            BibleVerse,
            BaseReferences<
              _$LiteWorshipDatabase,
              $BibleVersesTable,
              BibleVerse
            >,
          ),
          BibleVerse,
          PrefetchHooks Function()
        > {
  $$BibleVersesTableTableManager(
    _$LiteWorshipDatabase db,
    $BibleVersesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> book = const Value.absent(),
                Value<int> bookOrder = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => BibleVersesCompanion(
                id: id,
                version: version,
                book: book,
                bookOrder: bookOrder,
                chapter: chapter,
                verse: verse,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String version,
                required String book,
                required int bookOrder,
                required int chapter,
                required int verse,
                required String content,
              }) => BibleVersesCompanion.insert(
                id: id,
                version: version,
                book: book,
                bookOrder: bookOrder,
                chapter: chapter,
                verse: verse,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleVersesTableProcessedTableManager =
    ProcessedTableManager<
      _$LiteWorshipDatabase,
      $BibleVersesTable,
      BibleVerse,
      $$BibleVersesTableFilterComposer,
      $$BibleVersesTableOrderingComposer,
      $$BibleVersesTableAnnotationComposer,
      $$BibleVersesTableCreateCompanionBuilder,
      $$BibleVersesTableUpdateCompanionBuilder,
      (
        BibleVerse,
        BaseReferences<_$LiteWorshipDatabase, $BibleVersesTable, BibleVerse>,
      ),
      BibleVerse,
      PrefetchHooks Function()
    >;

class $LiteWorshipDatabaseManager {
  final _$LiteWorshipDatabase _db;
  $LiteWorshipDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$BibleVersesTableTableManager get bibleVerses =>
      $$BibleVersesTableTableManager(_db, _db.bibleVerses);
}
