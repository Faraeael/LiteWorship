import '../models/slide_content.dart';

// ============================================================================
// LITEWORSHIP — Lyric Parser Engine
// Parses raw song text into structured slides with labels
// ============================================================================

class LyricParser {
  /// Parse raw lyrics into a list of labeled slides
  static List<SlideContent> parse(String lyrics, String songId, {String? defaultTitle}) {
    final slides = <SlideContent>[];
    
    // Split by double newlines (paragraphs)
    final blocks = lyrics.split(RegExp(r'\n\s*\n'));
    
    // Regex for headers like [V1], Verse 1:, Chorus, etc.
    final headerRegex = RegExp(r'^\[?((?:Verse|Chorus|Bridge|Pre-Chorus|Tag|V|C|B|P|T)\s*\d*)\]?:?', caseSensitive: false);

    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i].trim();
      if (block.isEmpty) continue;

      String? label;
      
      // Check for header line
      final lines = block.split('\n');
      if (lines.isNotEmpty) {
        final firstLine = lines.first.trim();
        final match = headerRegex.firstMatch(firstLine);
        
        if (match != null) {
          // Extracted label (e.g. "Verse 1")
          final rawLabel = match.group(1) ?? 'Slide';
          label = _normalizeLabel(rawLabel);
          
          // Remove the header line from the text if it was a standalone header
          // Logic: If the block started with "[V1]" or "Verse 1:", we remove it.
          // If it was just inline, we might keep it? 
          // Usually in song databases, headers are on their own line.
          if (lines.length > 1) {
            block = lines.sublist(1).join('\n').trim();
          } else {
            // If the block is ONLY the header, skip it? Or keep it?
            // Some formats have header, then next block is lyrics.
            // But here we split by \n\n.
            // If block is JUST "Verse 1", it might depend on next block.
            // For now, assume lyrics follow in same block or next. 
            // If same block, we stripped it. 
            // If block was just header, block becomes empty.
            block = ''; 
          }
        }
      }

      if (block.isNotEmpty) {
        slides.add(TextSlideContent(
          id: '$songId-$i',
          text: block,
          label: label, 
          // Show title only on first slide if not labeled? Or leave null.
          subtitle: (i == 0 && label == null) ? defaultTitle : null,
        ));
      }
    }

    // Add a blank slide at the end
    slides.add(BlankSlideContent(id: '$songId-end'));

    return slides;
  }

  /// Normalize labels to short forms (V1, C, B, etc.)
  static String _normalizeLabel(String raw) {
    final lower = raw.toLowerCase();
    if (lower.startsWith('verse')) {
      return raw.replaceFirst(RegExp(r'verse', caseSensitive: false), 'V').replaceAll(' ', '');
    }
    if (lower.startsWith('chorus')) return 'C';
    if (lower.startsWith('bridge')) return 'B';
    if (lower.startsWith('pre')) return 'P';
    if (lower.startsWith('tag')) return 'T';
    
    // Default: return uppercase first letter + rest
    if (raw.length > 2) return raw.substring(0, 2).toUpperCase();
    return raw.toUpperCase();
  }
}
