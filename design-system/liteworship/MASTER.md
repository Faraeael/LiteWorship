# LiteWorship Design System (Flutter Edition)

> **LOGIC:** When building a specific page, first check `design-system/liteworship/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** LiteWorship — Lightweight Church Projection Software
**Platform:** Flutter (Windows/macOS Desktop)
**Generated:** 2026-01-29
**Industry:** Church / Live Event / Broadcast

---

## 🎯 Design Philosophy

### Core Principles
1. **OLED Black First** — Pure black backgrounds (#000000) for maximum contrast and power efficiency
2. **High Legibility** — Text must be readable from 20+ feet away on projector screens
3. **Potato PC Friendly** — All animations use GPU-accelerated opacity and transform only
4. **Volunteer Proof** — UI so simple a grandmother can operate it mid-service

### Target Users
- Non-technical church volunteers
- Age range: 15-75 years
- Often operating under low-light conditions
- Need to make changes quickly without looking at the screen

---

## 🎨 Color Palette (OLED Black + Amber/Gold Theme)

### Primary Colors (Flutter Dart)

```dart
/// LiteWorship Color Tokens
abstract class LWColors {
  // === BACKGROUNDS (OLED Black Spectrum) ===
  static const Color background = Color(0xFF000000);      // Pure OLED Black
  static const Color surface = Color(0xFF0A0A0A);         // Slightly lifted black
  static const Color surfaceElevated = Color(0xFF141414); // Cards, panels
  static const Color surfaceHover = Color(0xFF1A1A1A);    // Hover states
  
  // === ACCENTS (Amber/Gold - Active States) ===
  static const Color primary = Color(0xFFE6A800);         // Warm Amber (Main CTA)
  static const Color primaryBright = Color(0xFFFFB800);   // Bright Gold (Highlights)
  static const Color primaryDim = Color(0xFFB38600);      // Dim Amber (Secondary)
  static const Color live = Color(0xFFFF4444);            // Live/Recording Indicator
  
  // === TEXT (High Contrast Hierarchy) ===
  static const Color textPrimary = Color(0xFFFFFFFF);     // Pure White (Headings)
  static const Color textSecondary = Color(0xFFB3B3B3);   // Light Gray (Body)
  static const Color textMuted = Color(0xFF666666);       // Dim Gray (Captions)
  static const Color textOnAccent = Color(0xFF000000);    // Black text on Amber
  
  // === BORDERS & DIVIDERS ===
  static const Color border = Color(0xFF2A2A2A);          // Subtle border
  static const Color divider = Color(0xFF1F1F1F);         // Section dividers
  
  // === STATUS COLORS ===
  static const Color success = Color(0xFF22C55E);         // Green (Connected, Saved)
  static const Color warning = Color(0xFFFFA500);         // Orange (Attention)
  static const Color error = Color(0xFFEF4444);           // Red (Error, Disconnect)
  static const Color info = Color(0xFF3B82F6);            // Blue (Info)
}
```

### Color Usage Rules
| Context | Color | Notes |
|---------|-------|-------|
| App background | `background` (#000000) | Always pure black |
| Panel/Card background | `surfaceElevated` (#141414) | 1-level elevation |
| Selected/Active item | `primary` (#E6A800) | Amber highlight |
| Current LIVE slide | `primaryBright` + border | Gold glow effect |
| Disabled state | `textMuted` at 50% opacity | Clearly inactive |
| Danger action | `error` with `surface` bg | Delete, stop |

---

## 📝 Typography (System-only for Performance)

### Font Family Stack
```dart
/// System fonts only — NO custom fonts for Potato PC constraint
abstract class LWTypography {
  /// Windows: Segoe UI, macOS: SF Pro Display
  static const String fontFamily = 'system-ui';
  
  // === HEADING STYLES ===
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    color: LWColors.textPrimary,
  );
  
  static TextStyle get displayMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.15,
    color: LWColors.textPrimary,
  );
  
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: LWColors.textPrimary,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: LWColors.textPrimary,
  );
  
  // === BODY STYLES ===
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: LWColors.textSecondary,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: LWColors.textSecondary,
  );
  
  // === LABEL/CAPTION STYLES ===
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: LWColors.textPrimary,
  );
  
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: LWColors.textMuted,
  );
}
```

### Projector Text Sizing
| Content Type | Min Size | Recommended | Notes |
|--------------|----------|-------------|-------|
| Song lyrics (verse) | 48px | 72px | Must read from back row |
| Scripture reference | 24px | 32px | Reference can be smaller |
| Song title | 32px | 48px | Header overlay |
| Announcements | 32px | 48px | Clear readability |

---

## 🧩 Spacing Tokens

```dart
/// Consistent spacing scale (8px base unit)
abstract class LWSpacing {
  static const double xs = 4.0;    // 0.5 units
  static const double sm = 8.0;    // 1 unit
  static const double md = 16.0;   // 2 units
  static const double lg = 24.0;   // 3 units
  static const double xl = 32.0;   // 4 units
  static const double xxl = 48.0;  // 6 units
  static const double xxxl = 64.0; // 8 units
  
  // Component-specific
  static const double buttonPadding = 12.0;
  static const double cardPadding = 16.0;
  static const double panelPadding = 20.0;
  static const double screenPadding = 24.0;
}
```

---

## 🔲 Border Radius Tokens

```dart
abstract class LWRadius {
  static const double none = 0.0;
  static const double sm = 4.0;    // Small chips, tags
  static const double md = 8.0;    // Buttons, inputs
  static const double lg = 12.0;   // Cards
  static const double xl = 16.0;   // Modals, large panels
  static const double full = 999.0; // Circular
}
```

---

## ⚡ Animation Tokens (Potato PC Safe)

> **CRITICAL:** Only use `opacity` and `transform` (translate, scale, rotate).
> NO blur, NO shadow animations, NO Rive/Lottie unless GPU-accelerated.

```dart
/// Animation durations and curves for smooth, CPU-cheap transitions
abstract class LWAnimations {
  // === DURATIONS ===
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  
  // === CURVES ===
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  
  // === RECOMMENDED TRANSITIONS (GPU-ONLY) ===
  // ✅ AnimatedOpacity  — Fade in/out
  // ✅ SlideTransition  — Panel slides
  // ✅ ScaleTransition  — Subtle grow effects (1.0 → 1.02 max)
  // ✅ Transform.translate — Position changes
  
  // === FORBIDDEN (CPU HEAVY) ===
  // ❌ BackdropFilter blur animations
  // ❌ BoxShadow color/spread animations
  // ❌ ClipPath/CustomPainter animations
  // ❌ Rive/Lottie (unless known GPU-accelerated)
}
```

---

## 🎛️ Component Specifications

### Slide Thumbnail Card
```dart
/// Thumbnail for slide preview in dashboard
Container(
  decoration: BoxDecoration(
    color: LWColors.surfaceElevated,
    borderRadius: BorderRadius.circular(LWRadius.lg),
    border: isSelected 
      ? Border.all(color: LWColors.primary, width: 2)
      : Border.all(color: LWColors.border, width: 1),
  ),
  child: ...,
)
```

### Action Button (Primary)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: LWColors.primary,
    foregroundColor: LWColors.textOnAccent,
    padding: EdgeInsets.symmetric(
      horizontal: LWSpacing.lg,
      vertical: LWSpacing.buttonPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(LWRadius.md),
    ),
  ),
  onPressed: () {},
  child: Text('GO LIVE', style: LWTypography.labelLarge),
)
```

### Live Indicator Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: LWColors.live,
    borderRadius: BorderRadius.circular(LWRadius.sm),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 8, color: Colors.white),
      SizedBox(width: 4),
      Text('LIVE', style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.0,
      )),
    ],
  ),
)
```

---

## 📐 Layout Zones

### Main Dashboard Layout
```
┌─────────────────────────────────────────────────────────┐
│ ■ HEADER (48px) — Logo, Window Controls                 │
├──────────────┬──────────────────────────────────────────┤
│              │                                          │
│   SIDEBAR    │         MAIN CONTENT AREA                │
│   (240px)    │                                          │
│              │   ┌──────────────────────────────────┐   │
│  - Services  │   │     SLIDE PREVIEW / EDITOR       │   │
│  - Songs     │   │         (Flexible)               │   │
│  - Media     │   └──────────────────────────────────┘   │
│  - Settings  │                                          │
│              │   ┌──────────────────────────────────┐   │
│              │   │     SLIDE STRIP (THUMBNAILS)     │   │
│              │   │         (120px height)           │   │
│              │   └──────────────────────────────────┘   │
├──────────────┴──────────────────────────────────────────┤
│ ■ FOOTER (32px) — Output Status, Connection Indicators  │
└─────────────────────────────────────────────────────────┘
```

### Projector Output Layout (Window 2)
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                                                         │
│                                                         │
│                   [SLIDE CONTENT]                       │
│                                                         │
│              Centered, full-screen black                │
│              Maximum text contrast                      │
│                                                         │
│                                                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚫 Anti-Patterns (FORBIDDEN)

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Heavy blur effects (`BackdropFilter`) | Solid `surfaceElevated` backgrounds |
| Complex shadows | Single-level subtle border |
| Nested dropdown menus | Flat sidebar navigation |
| White/Light backgrounds | OLED Black spectrum only |
| Custom fonts (Google Fonts) | System fonts (`system-ui`) |
| Rive/Lottie animations | Simple opacity/transform |
| Icon packs (web-based) | Material Icons (bundled) |
| Complex gradients | Solid colors |
| Scroll-jacking | Native scroll behavior |

---

## ♿ Accessibility Requirements

### Contrast Ratios (Minimum)
| Elements | Ratio | Status |
|----------|-------|--------|
| `textPrimary` on `background` | 21:1 | ✓ Passes WCAG AAA |
| `textSecondary` on `background` | 11:1 | ✓ Passes WCAG AAA |
| `primary` on `background` | 8.5:1 | ✓ Passes WCAG AA |

### Motion Sensitivity
```dart
/// Respect system reduced motion preference
MediaQuery.of(context).disableAnimations
  ? Duration.zero
  : LWAnimations.normal
```

### Keyboard Navigation
- All interactive elements must have visible focus rings
- Tab order must follow logical reading flow
- Escape key closes modals/overlays

---

## 📝 Pre-Delivery Checklist

Before shipping any LiteWorship screen:

- [ ] Background is pure `#000000` (not `#1A1A1A` or similar)
- [ ] All text passes WCAG AA contrast (4.5:1 minimum)
- [ ] No `BackdropFilter` blur effects
- [ ] All animations use only `opacity` and `transform`
- [ ] System fonts only (`system-ui`), no Google Fonts
- [ ] All clickable elements have `MouseRegion` with `cursor: SystemMouseCursors.click`
- [ ] Focus states visible for keyboard users
- [ ] `MediaQuery.disableAnimations` respected
- [ ] Works on 1366x768 resolution (minimum target)
- [ ] Projector output is full-screen capable

---

## 🔧 State Management (Riverpod)

```dart
/// All providers should follow this naming convention
final slideListProvider = StateNotifierProvider<SlideListNotifier, List<Slide>>();
final currentSlideProvider = StateProvider<int>();
final projectorWindowProvider = StateProvider<WindowController?>();
```

---

## 📦 Package Dependencies

Required packages for this design system:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0          # State management
  drift: ^2.18.0                    # SQLite database
  desktop_multi_window: ^0.2.0      # Multi-window support
  media_kit: ^1.1.0                 # Video playback
  media_kit_video: ^1.2.0           # Video widget
  media_kit_libs_windows_video: ^1.0.0  # Windows video libs
```
