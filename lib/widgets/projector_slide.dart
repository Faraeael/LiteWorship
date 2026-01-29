import 'dart:io';

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/slide_content.dart';

// ============================================================================
// LITEWORSHIP — Projector Slide Widget
// Full-screen slide renderer for projector output
// ============================================================================

/// Renders a [SlideContent] in full-screen projector format
/// 
/// Features:
/// - Pure black background (#000000) for OLED efficiency
/// - GPU-safe fade transitions (opacity only)
/// - Respects reduced motion preferences
/// - Handles all SlideContent types: Text, Image, Video, Blank
class ProjectorSlide extends StatelessWidget {
  const ProjectorSlide({
    super.key,
    required this.content,
    this.isLive = true,
  });

  /// The slide content to display
  final SlideContent? content;

  /// Whether the projector is "live" (showing content)
  /// When false, shows black regardless of content
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    // Respect reduced motion preference
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final duration = disableAnimations
        ? LWAnimations.instant
        : LWAnimations.slow;

    return Container(
      color: LWColors.background, // Pure OLED black
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: LWAnimations.enterCurve,
        switchOutCurve: LWAnimations.exitCurve,
        // Fade-only transition (GPU-safe, no blur/shadow)
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: !isLive || content == null
            ? const _BlankScreen(key: ValueKey('blank'))
            : _buildContent(content!),
      ),
    );
  }

  Widget _buildContent(SlideContent content) {
    return switch (content) {
      TextSlideContent() => _TextSlideView(
          key: ValueKey(content.id),
          content: content,
        ),
      ImageSlideContent() => _ImageSlideView(
          key: ValueKey(content.id),
          content: content,
        ),
      VideoSlideContent() => _VideoSlideView(
          key: ValueKey(content.id),
          content: content,
        ),
      BlankSlideContent() => const _BlankScreen(key: ValueKey('blank')),
    };
  }
}

// ============================================================================
// BLANK SCREEN
// ============================================================================

class _BlankScreen extends StatelessWidget {
  const _BlankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

// ============================================================================
// TEXT SLIDE VIEW
// ============================================================================

class _TextSlideView extends StatelessWidget {
  const _TextSlideView({
    super.key,
    required this.content,
  });

  final TextSlideContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LWSpacing.xxl),
      alignment: content.textAlignment.toAlignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main text
          Text(
            content.text,
            textAlign: content.textAlignment.toTextAlign,
            style: TextStyle(
              fontFamily: 'system-ui',
              fontSize: content.fontSize.toPixels,
              fontWeight: FontWeight.w600,
              color: LWColors.textPrimary,
              height: 1.3,
              shadows: const [
                // Subtle shadow for readability on any background
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          // Subtitle (if present)
          if (content.subtitle != null) ...[
            const SizedBox(height: LWSpacing.lg),
            Text(
              content.subtitle!,
              textAlign: content.textAlignment.toTextAlign,
              style: TextStyle(
                fontFamily: 'system-ui',
                fontSize: content.fontSize.toPixels * 0.4,
                fontWeight: FontWeight.w400,
                color: LWColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// IMAGE SLIDE VIEW
// ============================================================================

class _ImageSlideView extends StatelessWidget {
  const _ImageSlideView({
    super.key,
    required this.content,
  });

  final ImageSlideContent content;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.file(
          File(content.imagePath),
          fit: content.fit.toBoxFit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: LWColors.surfaceElevated,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: LWColors.textMuted,
                    ),
                    SizedBox(height: LWSpacing.md),
                    Text(
                      'Image not found',
                      style: TextStyle(
                        color: LWColors.textMuted,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Optional text overlay
        if (content.overlayText != null)
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(LWSpacing.xxl),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LWSpacing.lg,
                vertical: LWSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(LWRadius.md),
              ),
              child: Text(
                content.overlayText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'system-ui',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: LWColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// VIDEO SLIDE VIEW (Placeholder - requires media_kit)
// ============================================================================

class _VideoSlideView extends StatelessWidget {
  const _VideoSlideView({
    super.key,
    required this.content,
  });

  final VideoSlideContent content;

  @override
  Widget build(BuildContext context) {
    // Placeholder until media_kit is integrated
    return Container(
      color: LWColors.surfaceElevated,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 96,
              color: LWColors.primary,
            ),
            const SizedBox(height: LWSpacing.lg),
            Text(
              'Video: ${content.videoPath.split('/').last}',
              style: const TextStyle(
                color: LWColors.textSecondary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: LWSpacing.md),
            const Text(
              'Video playback requires media_kit integration',
              style: TextStyle(
                color: LWColors.textMuted,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
