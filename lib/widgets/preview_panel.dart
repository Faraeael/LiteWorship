import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/service_model.dart';
import '../models/slide_content.dart';
import '../providers/service_provider.dart';
import '../providers/providers.dart';
import '../services/lyric_parser.dart';
import '../services/server.dart'; // For sending messages
import 'dart:io';
import 'package:uuid/uuid.dart';

class PreviewPanel extends ConsumerStatefulWidget {
  const PreviewPanel({super.key});

  @override
  ConsumerState<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends ConsumerState<PreviewPanel> {
  // Local state for slide generation (cached for performance)
  ServiceItem? _currentItem;
  List<SlideContent> _slides = [];
  
  @override
  Widget build(BuildContext context) {
    // Jukebox Mode: Watch the active item directly
    final currentItem = ref.watch(activeServiceItemProvider);
    
    // React to item change: Generate slides if needed
    if (currentItem != _currentItem) {
      _currentItem = currentItem;
      _generateSlides(currentItem);
    }
    
    final isLive = ref.watch(isLiveProvider);
    final currentSlide = ref.watch(currentSlideProvider);

    return Row(
      children: [
        // LEFT: CONTROLS (Flex 2)
        Expanded(
          flex: 2,
          child: Column(
            children: [
               // Header Controls
              Container(
                padding: const EdgeInsets.all(LWSpacing.sm),
                color: LWColors.surfaceElevated,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentItem?.title ?? "Select an Item to Play", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ),
                    ElevatedButton.icon(
                      // Live Toggle
                      onPressed: () => _toggleLive(),
                      icon: Icon(isLive ? Icons.stop : Icons.play_arrow),
                      label: Text(isLive ? "STOP LIVE" : "GO LIVE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLive ? LWColors.live : LWColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _clearScreen(),
                      icon: const Icon(Icons.desktop_access_disabled),
                      tooltip: "Clear Screen",
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Slide Grid
              Expanded(
                child: _currentItem == null 
                  ? const Center(child: Text("Library Item -> Direct Play", style: TextStyle(color: LWColors.textMuted)))
                  : _buildContentArea(isLive, currentSlide),
              ),
            ],
          ),
        ),
        
        const VerticalDivider(width: 1),

        // RIGHT: PREVIEW MONITOR (Flex 1)
        Expanded(
          flex: 1,
          child: _buildPreviewMonitor(isLive, currentSlide),
        ),
      ],
    );
  }

  Widget _buildPreviewMonitor(bool isLive, SlideContent? slide) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("LIVE OUTPUT", style: TextStyle(color: LWColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isLive ? LWColors.live : LWColors.border, width: 2),
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(12),
                child: slide is TextSlideContent 
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                  maxHeight: constraints.maxHeight,
                                ),
                                child: Text(
                                  slide.text, 
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _generateSlides(ServiceItem? item) {
    if (item == null) {
      setState(() => _slides = []);
      return;
    }

    List<SlideContent> slides = [];
    
    if (item.type == ServiceItemType.song && item.song != null) {
      // Song Parsing: LyricParser already returns List<SlideContent>
      slides = LyricParser.parse(item.song!.lyrics, item.id);
    } else if (item.type == ServiceItemType.scripture && item.scripture != null) {
       // Scripture Single Slide
       final ref = item.scripture!;
       final text = "${ref.verse.text}\n\n${ref.book.name} ${ref.chapter.chapterNumber}:${ref.verse.verseNumber}";
       slides.add(TextSlideContent(
         id: Uuid().v4(),
         text: text,
         label: 'Verse'
       ));
    }
    
    setState(() {
      _slides = slides;
    });
  }

  Widget _buildContentArea(bool isLive, SlideContent? currentSlide) {
     return GridView.builder(
       padding: const EdgeInsets.all(LWSpacing.md),
       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
         maxCrossAxisExtent: 250,
         childAspectRatio: 16/9,
         crossAxisSpacing: LWSpacing.md,
         mainAxisSpacing: LWSpacing.md,
       ),
       itemCount: _slides.length,
       itemBuilder: (context, index) {
         final slide = _slides[index];
         // Check if this slide is "Active" (content matches currentSlide)
         // Note: Logic allows duplicates, ID comparison is better.
         final isActive = isLive && (currentSlide is TextSlideContent && slide is TextSlideContent && currentSlide.text == slide.text);
         
         return InkWell(
           onTap: () => _activateSlide(slide),
           child: Container(
             decoration: BoxDecoration(
               color: isActive ? LWColors.live : LWColors.surface,
               border: Border.all(
                 color: isActive ? LWColors.live : LWColors.border,
                 width: 2
               ),
               borderRadius: BorderRadius.circular(LWRadius.md),
             ),
             padding: const EdgeInsets.all(LWSpacing.sm),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 if (slide is TextSlideContent && slide.label != null)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                     decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                     child: Text(slide.label!, style: const TextStyle(fontSize: 10, color: LWColors.textMuted)),
                   ),
                 const Spacer(),
                 Center(
                   child: Text(
                     (slide is TextSlideContent) ? slide.text : "",
                     maxLines: 4,
                     overflow: TextOverflow.ellipsis,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 12),
                   ),
                 ),
                 const Spacer(),
               ],
             ),
           ),
         );
       },
     );
  }

  void _activateSlide(SlideContent slide) {
    if (!ref.read(isLiveProvider)) {
       // Auto Go Live?
       ref.read(isLiveProvider.notifier).state = true;
    }
    
    ref.read(currentSlideProvider.notifier).state = slide;
    _sendToProjector(slide);
  }

  void _toggleLive() {
    final newState = !ref.read(isLiveProvider);
    ref.read(isLiveProvider.notifier).state = newState;
    if (!newState) {
       _clearScreen();
    } else {
       // Resend current slide
       _sendToProjector(ref.read(currentSlideProvider));
    }
  }

  void _clearScreen() {
    sendProjectorMessage({'type': 'CLEAR'});
    ref.read(currentSlideProvider.notifier).state = const BlankSlideContent();
  }

  void _sendToProjector(SlideContent? slide) {
    if (slide == null) return;
    if (slide is TextSlideContent) {
      sendProjectorMessage({
        'type': 'LYRICS',
        'content': slide.text,
      });
    } else if (slide is BlankSlideContent) {
       sendProjectorMessage({'type': 'CLEAR'});
    }
  }
}
