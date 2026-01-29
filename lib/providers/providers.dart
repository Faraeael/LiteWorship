import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slide_content.dart';

// ============================================================================
// LITEWORSHIP — Riverpod State Providers
// Central state management for the application
// ============================================================================

/// Current slide content being displayed
final currentSlideProvider = StateProvider<SlideContent?>((ref) {
  return null;
});

/// Whether the projector output is "live"
final isLiveProvider = StateProvider<bool>((ref) {
  return false;
});

// REMOVED: projectorControllerProvider (we use WebSocket sink now)

/// List of slides in the current service/presentation
final slideListProvider = StateProvider<List<SlideContent>>((ref) {
  // Demo slides
  return [
    const TextSlideContent(
      id: 'demo-1',
      text: 'Amazing Grace\nHow sweet the sound',
      subtitle: 'Verse 1',
      fontSize: TextSlideFontSize.large,
    ),
    const TextSlideContent(
      id: 'demo-2',
      text: 'That saved a wretch like me',
      subtitle: 'Verse 1 (cont.)',
      fontSize: TextSlideFontSize.large,
    ),
  ];
});

/// Index of the currently selected slide
final selectedSlideIndexProvider = StateProvider<int>((ref) {
  return 0;
});

/// Derived provider: Get the currently selected slide
final selectedSlideProvider = Provider<SlideContent?>((ref) {
  final slides = ref.watch(slideListProvider);
  final index = ref.watch(selectedSlideIndexProvider);

  if (slides.isEmpty || index < 0 || index >= slides.length) {
    return null;
  }

  return slides[index];
});
