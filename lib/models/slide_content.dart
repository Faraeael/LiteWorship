import 'package:flutter/material.dart' show Alignment, BoxFit, TextAlign;
import 'package:flutter/foundation.dart';

// ============================================================================
// LITEWORSHIP — Slide Content Models
// Generic content types for projector output
// ============================================================================

/// Base class for all slide content types
@immutable
sealed class SlideContent {
  const SlideContent();

  /// Unique identifier for the slide content
  String get id;

  /// Serialize to JSON
  Map<String, dynamic> toJson();

  /// Deserialize from JSON
  static SlideContent fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'text':
        return TextSlideContent.fromJson(json);
      case 'image':
        return ImageSlideContent.fromJson(json);
      case 'video':
        return VideoSlideContent.fromJson(json);
      case 'blank':
        return BlankSlideContent.fromJson(json);
      default:
        // Default to blank if unknown
        return const BlankSlideContent();
    }
  }
}

/// Text-based slide content (lyrics, scripture, announcements)
@immutable
class TextSlideContent extends SlideContent {
  const TextSlideContent({
    required this.id,
    required this.text,
    this.label,
    this.subtitle,
    this.textAlignment = TextSlideAlignment.center,
    this.fontSize = TextSlideFontSize.large,
  });

  @override
  final String id;

  /// Main text content (lyrics verse, scripture text, etc.)
  final String text;

  /// Optional label for UI (e.g. "V1", "C", "B")
  final String? label;

  /// Optional subtitle (scripture reference, song title, etc.)
  final String? subtitle;

  /// Text alignment on screen
  final TextSlideAlignment textAlignment;

  /// Font size preset
  final TextSlideFontSize fontSize;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'id': id,
        'text': text,
        'label': label,
        'subtitle': subtitle,
        'textAlignment': textAlignment.name,
        'fontSize': fontSize.name,
      };

  factory TextSlideContent.fromJson(Map<String, dynamic> json) {
    return TextSlideContent(
      id: json['id'] as String,
      text: json['text'] as String,
      label: json['label'] as String?,
      subtitle: json['subtitle'] as String?,
      textAlignment: TextSlideAlignment.values.firstWhere(
        (e) => e.name == json['textAlignment'],
        orElse: () => TextSlideAlignment.center,
      ),
      fontSize: TextSlideFontSize.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => TextSlideFontSize.large,
      ),
    );
  }

  TextSlideContent copyWith({
    String? id,
    String? text,
    String? label,
    String? subtitle,
    TextSlideAlignment? textAlignment,
    TextSlideFontSize? fontSize,
  }) {
    return TextSlideContent(
      id: id ?? this.id,
      text: text ?? this.text,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      textAlignment: textAlignment ?? this.textAlignment,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSlideContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          label == other.label &&
          subtitle == other.subtitle &&
          textAlignment == other.textAlignment &&
          fontSize == other.fontSize;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      label.hashCode ^
      subtitle.hashCode ^
      textAlignment.hashCode ^
      fontSize.hashCode;
}

/// Image-based slide content with optional text overlay
@immutable
class ImageSlideContent extends SlideContent {
  const ImageSlideContent({
    required this.id,
    required this.imagePath,
    this.overlayText,
    this.fit = ImageSlideFit.cover,
  });

  @override
  final String id;

  /// Path to the image file (local file path)
  final String imagePath;

  /// Optional text overlay on the image
  final String? overlayText;

  /// How the image should fit the screen
  final ImageSlideFit fit;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'id': id,
        'imagePath': imagePath,
        'overlayText': overlayText,
        'fit': fit.name,
      };

  factory ImageSlideContent.fromJson(Map<String, dynamic> json) {
    return ImageSlideContent(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      overlayText: json['overlayText'] as String?,
      fit: ImageSlideFit.values.firstWhere(
        (e) => e.name == json['fit'],
        orElse: () => ImageSlideFit.cover,
      ),
    );
  }

  ImageSlideContent copyWith({
    String? id,
    String? imagePath,
    String? overlayText,
    ImageSlideFit? fit,
  }) {
    return ImageSlideContent(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      overlayText: overlayText ?? this.overlayText,
      fit: fit ?? this.fit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSlideContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imagePath == other.imagePath &&
          overlayText == other.overlayText &&
          fit == other.fit;

  @override
  int get hashCode =>
      id.hashCode ^ imagePath.hashCode ^ overlayText.hashCode ^ fit.hashCode;
}

/// Video-based slide content (placeholder for future media_kit integration)
@immutable
class VideoSlideContent extends SlideContent {
  const VideoSlideContent({
    required this.id,
    required this.videoPath,
    this.loop = false,
    this.autoPlay = true,
  });

  @override
  final String id;

  /// Path to the video file (local file path)
  final String videoPath;

  /// Whether to loop the video
  final bool loop;

  /// Whether to auto-play when shown
  final bool autoPlay;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'video',
        'id': id,
        'videoPath': videoPath,
        'loop': loop,
        'autoPlay': autoPlay,
      };

  factory VideoSlideContent.fromJson(Map<String, dynamic> json) {
    return VideoSlideContent(
      id: json['id'] as String,
      videoPath: json['videoPath'] as String,
      loop: json['loop'] as bool? ?? false,
      autoPlay: json['autoPlay'] as bool? ?? true,
    );
  }

  VideoSlideContent copyWith({
    String? id,
    String? videoPath,
    bool? loop,
    bool? autoPlay,
  }) {
    return VideoSlideContent(
      id: id ?? this.id,
      videoPath: videoPath ?? this.videoPath,
      loop: loop ?? this.loop,
      autoPlay: autoPlay ?? this.autoPlay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoSlideContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          videoPath == other.videoPath &&
          loop == other.loop &&
          autoPlay == other.autoPlay;

  @override
  int get hashCode =>
      id.hashCode ^ videoPath.hashCode ^ loop.hashCode ^ autoPlay.hashCode;
}

/// Blank slide for transitions or "clear screen"
@immutable
class BlankSlideContent extends SlideContent {
  const BlankSlideContent({this.id = 'blank'});

  @override
  final String id;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'blank',
        'id': id,
      };

  factory BlankSlideContent.fromJson(Map<String, dynamic> json) {
    return BlankSlideContent(id: json['id'] as String? ?? 'blank');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlankSlideContent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// ENUMS
// ============================================================================

/// Text alignment options for text slides
enum TextSlideAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Font size presets for text slides
enum TextSlideFontSize {
  /// 48px - Small text
  small,

  /// 64px - Medium text
  medium,

  /// 72px - Large text (default for lyrics)
  large,

  /// 96px - Extra large (emphasis)
  extraLarge,
}

/// Image fit options
enum ImageSlideFit {
  /// Fill the screen, may crop
  cover,

  /// Fit within screen, may letterbox
  contain,

  /// Stretch to fill (distorts)
  fill,
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension TextSlideAlignmentX on TextSlideAlignment {
  /// Convert to Flutter Alignment
  Alignment get toAlignment {
    return switch (this) {
      TextSlideAlignment.topLeft => Alignment.topLeft,
      TextSlideAlignment.topCenter => Alignment.topCenter,
      TextSlideAlignment.topRight => Alignment.topRight,
      TextSlideAlignment.centerLeft => Alignment.centerLeft,
      TextSlideAlignment.center => Alignment.center,
      TextSlideAlignment.centerRight => Alignment.centerRight,
      TextSlideAlignment.bottomLeft => Alignment.bottomLeft,
      TextSlideAlignment.bottomCenter => Alignment.bottomCenter,
      TextSlideAlignment.bottomRight => Alignment.bottomRight,
    };
  }

  /// Convert to Flutter TextAlign
  TextAlign get toTextAlign {
    return switch (this) {
      TextSlideAlignment.topLeft ||
      TextSlideAlignment.centerLeft ||
      TextSlideAlignment.bottomLeft =>
        TextAlign.left,
      TextSlideAlignment.topCenter ||
      TextSlideAlignment.center ||
      TextSlideAlignment.bottomCenter =>
        TextAlign.center,
      TextSlideAlignment.topRight ||
      TextSlideAlignment.centerRight ||
      TextSlideAlignment.bottomRight =>
        TextAlign.right,
    };
  }
}

extension TextSlideFontSizeX on TextSlideFontSize {
  /// Get the actual font size in pixels
  double get toPixels {
    return switch (this) {
      TextSlideFontSize.small => 48.0,
      TextSlideFontSize.medium => 64.0,
      TextSlideFontSize.large => 72.0,
      TextSlideFontSize.extraLarge => 96.0,
    };
  }
}

extension ImageSlideFitX on ImageSlideFit {
  /// Convert to Flutter BoxFit
  BoxFit get toBoxFit {
    return switch (this) {
      ImageSlideFit.cover => BoxFit.cover,
      ImageSlideFit.contain => BoxFit.contain,
      ImageSlideFit.fill => BoxFit.fill,
    };
  }
}
