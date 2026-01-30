
import '../data/database.dart';

sealed class SearchResultItem {
  const SearchResultItem();
}

class SongResult extends SearchResultItem {
  final Song song;
  const SongResult(this.song);
}

class BibleResult extends SearchResultItem {
  final BibleVerse verse;
  const BibleResult(this.verse);
}
