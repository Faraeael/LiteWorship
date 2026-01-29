import 'package:flutter/material.dart';

// ============================================================================
// LITEWORSHIP DESIGN SYSTEM — Flutter Theme Configuration
// Generated from design-system/liteworship/MASTER.md
// ============================================================================

/// LiteWorship Color Tokens
/// OLED Black + Amber/Gold theme for maximum contrast and power efficiency
abstract class LWColors {
  // === BACKGROUNDS (OLED Black Spectrum) ===
  /// Pure OLED Black - Main app background
  static const Color background = Color(0xFF000000);

  /// Slightly lifted black - Secondary surfaces
  static const Color surface = Color(0xFF0A0A0A);

  /// Cards, panels, elevated surfaces
  static const Color surfaceElevated = Color(0xFF141414);

  /// Hover states for interactive elements
  static const Color surfaceHover = Color(0xFF1A1A1A);

  // === ACCENTS (Amber/Gold - Active States) ===
  /// Warm Amber - Main CTA and primary actions
  static const Color primary = Color(0xFFE6A800);

  /// Bright Gold - Highlights, selected states
  static const Color primaryBright = Color(0xFFFFB800);

  /// Dim Amber - Secondary accents
  static const Color primaryDim = Color(0xFFB38600);

  /// Live/Recording Indicator - Attention red
  static const Color live = Color(0xFFFF4444);

  // === TEXT (High Contrast Hierarchy) ===
  /// Pure White - Headings, important text
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Light Gray - Body text
  static const Color textSecondary = Color(0xFFB3B3B3);

  /// Dim Gray - Captions, disabled text
  static const Color textMuted = Color(0xFF666666);

  /// Black text on Amber buttons
  static const Color textOnAccent = Color(0xFF000000);

  // === BORDERS & DIVIDERS ===
  /// Subtle border for cards
  static const Color border = Color(0xFF2A2A2A);

  /// Section dividers
  static const Color divider = Color(0xFF1F1F1F);

  // === STATUS COLORS ===
  /// Green - Connected, Saved, Success
  static const Color success = Color(0xFF22C55E);

  /// Orange - Attention, Warning
  static const Color warning = Color(0xFFFFA500);

  /// Red - Error, Disconnect, Danger
  static const Color error = Color(0xFFEF4444);

  /// Blue - Info, Neutral status
  static const Color info = Color(0xFF3B82F6);
}

/// LiteWorship Spacing Tokens
/// Consistent 8px base unit spacing scale
abstract class LWSpacing {
  static const double xs = 4.0; // 0.5 units
  static const double sm = 8.0; // 1 unit
  static const double md = 16.0; // 2 units
  static const double lg = 24.0; // 3 units
  static const double xl = 32.0; // 4 units
  static const double xxl = 48.0; // 6 units
  static const double xxxl = 64.0; // 8 units

  // Component-specific
  static const double buttonPadding = 12.0;
  static const double cardPadding = 16.0;
  static const double panelPadding = 20.0;
  static const double screenPadding = 24.0;
}

/// LiteWorship Border Radius Tokens
abstract class LWRadius {
  static const double none = 0.0;
  static const double sm = 4.0; // Small chips, tags
  static const double md = 8.0; // Buttons, inputs
  static const double lg = 12.0; // Cards
  static const double xl = 16.0; // Modals, large panels
  static const double full = 999.0; // Circular
}

/// LiteWorship Animation Tokens (Potato PC Safe)
/// ONLY use opacity and transform - NO blur, NO shadow animations
abstract class LWAnimations {
  // === DURATIONS ===
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);

  // === CURVES ===
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;

  /// Get animation duration respecting user's reduced motion preference
  static Duration getDuration(BuildContext context, Duration duration) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : duration;
  }
}

/// LiteWorship ThemeData Factory
/// Creates the complete Material theme with OLED Black + Amber/Gold palette
class LWTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: LWColors.primary,
        onPrimary: LWColors.textOnAccent,
        secondary: LWColors.primaryDim,
        onSecondary: LWColors.textOnAccent,
        surface: LWColors.surface,
        onSurface: LWColors.textPrimary,
        error: LWColors.error,
        onError: LWColors.textPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: LWColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: LWColors.surface,
        foregroundColor: LWColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: LWColors.textPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: LWColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LWRadius.lg),
          side: const BorderSide(color: LWColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Buttons (Primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LWColors.primary,
          foregroundColor: LWColors.textOnAccent,
          padding: const EdgeInsets.symmetric(
            horizontal: LWSpacing.lg,
            vertical: LWSpacing.buttonPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LWRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'system-ui',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Buttons (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LWColors.primary,
          side: const BorderSide(color: LWColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: LWSpacing.lg,
            vertical: LWSpacing.buttonPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LWRadius.md),
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: LWColors.primary),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: LWColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(color: LWColors.textSecondary, size: 24),

      // Text Theme (System fonts only for Potato PC performance)
      textTheme: const TextTheme(
        // Display styles (for projector output)
        displayLarge: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 72,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.1,
          color: LWColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.15,
          color: LWColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 36,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: LWColors.textPrimary,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: LWColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: LWColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: LWColors.textPrimary,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: LWColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: LWColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: LWColors.textPrimary,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: LWColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: LWColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: LWColors.textMuted,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: LWColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: LWColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'system-ui',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: LWColors.textMuted,
        ),
      ),
    );
  }
}
