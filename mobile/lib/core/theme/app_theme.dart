import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Cyberpunk Colour Palette ────────────────────────────────────────────────
const kBg = Color(0xFF0A0A0A);
const kSurface = Color(0xFF0F0F0F);
const kCard = Color(0xFF141414);
const kCardHover = Color(0xFF1C1C1C);
const kPrimary = Color(0xFFFFD700);
const kPrimaryDim = Color(0xFF9A7B00);
const kAccent = Color(0xFF39FF14);
const kError = Color(0xFFFF2052);
const kText = Color(0xFFDDDDDD);
const kTextSub = Color(0xFF777777);
const kTextDim = Color(0xFF3A3A3A);
const kBorderDim = Color(0xFF222222);
const kBorderActive = Color(0xFFFFD700);

// ─── Light-mode equivalents ──────────────────────────────────────────────────
const kLightBg     = Color(0xFFF5F5F5);
const kLightCard   = Colors.white;
const kLightText   = Color(0xFF1A1A1A);
const kLightSub    = Color(0xFF555555);
const kLightDim    = Color(0xFFAAAAAA);

// ─── Theme-aware colour accessor ─────────────────────────────────────────────
extension AppColors on BuildContext {
  bool get _dark => Theme.of(this).brightness == Brightness.dark;
  Color get cBg      => _dark ? kBg      : kLightBg;
  Color get cCard    => _dark ? kCard    : kLightCard;
  Color get cText    => _dark ? kText    : kLightText;
  Color get cTextSub => _dark ? kTextSub : kLightSub;
  Color get cTextDim => _dark ? kTextDim : kLightDim;
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;
  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme() {
    final mono = GoogleFonts.shareTechMono;
    return TextTheme(
      displayLarge:  mono(fontSize: 57, color: kText),
      displayMedium: mono(fontSize: 45, color: kText),
      displaySmall:  mono(fontSize: 36, color: kText),
      headlineLarge:  mono(fontSize: 32, fontWeight: FontWeight.w700, color: kPrimary),
      headlineMedium: mono(fontSize: 28, fontWeight: FontWeight.w700, color: kPrimary),
      headlineSmall:  mono(fontSize: 24, fontWeight: FontWeight.w600, color: kPrimary),
      titleLarge:  mono(fontSize: 20, fontWeight: FontWeight.w600, color: kText),
      titleMedium: mono(fontSize: 16, fontWeight: FontWeight.w500, color: kText),
      titleSmall:  mono(fontSize: 14, fontWeight: FontWeight.w500, color: kText),
      bodyLarge:   mono(fontSize: 16, color: kText),
      bodyMedium:  mono(fontSize: 14, color: kText),
      bodySmall:   mono(fontSize: 12, color: kTextSub),
      labelLarge:  mono(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: kText),
      labelMedium: mono(fontSize: 12, letterSpacing: 1.2, color: kTextSub),
      labelSmall:  mono(fontSize: 11, letterSpacing: 1.0, color: kTextSub),
    );
  }

  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: kPrimary,
      onPrimary: Colors.black,
      secondary: kAccent,
      onSecondary: Colors.black,
      error: kError,
      onError: Colors.white,
      surface: kSurface,
      onSurface: kText,
      outline: kBorderDim,
      surfaceContainerHighest: kCard,
      onSurfaceVariant: kTextSub,
      primaryContainer: kCardHover,
      onPrimaryContainer: kPrimary,
      errorContainer: Color(0xFF3D0014),
      onErrorContainer: kError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: kBg,
      textTheme: _textTheme(),

      appBarTheme: AppBarTheme(
        backgroundColor: kBg,
        foregroundColor: kPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: kPrimary),
        actionsIconTheme: const IconThemeData(color: kPrimary),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF2A2000), width: 1),
        ),
      ),

      cardTheme: CardThemeData(
        color: kCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: kPrimary.withValues(alpha: 0.25), width: 1),
        ),
        clipBehavior: Clip.none,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kBorderDim, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kPrimary.withValues(alpha: 0.25), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kError, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kError, width: 1.5),
        ),
        labelStyle: GoogleFonts.shareTechMono(color: kTextSub, fontSize: 14),
        hintStyle: GoogleFonts.shareTechMono(color: kTextDim, fontSize: 14),
        floatingLabelStyle: GoogleFonts.shareTechMono(color: kPrimary, fontSize: 12),
        errorStyle: GoogleFonts.shareTechMono(color: kError, fontSize: 11),
        prefixIconColor: kTextSub,
        suffixIconColor: kTextSub,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: kPrimaryDim,
          disabledForegroundColor: Colors.black54,
          textStyle: GoogleFonts.shareTechMono(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontSize: 14,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 1),
          textStyle: GoogleFonts.shareTechMono(
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimary,
          textStyle: GoogleFonts.shareTechMono(letterSpacing: 1, fontSize: 13),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        extendedTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.black : kTextSub,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kPrimary : kBorderDim,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: kPrimary,
        inactiveTrackColor: kBorderDim,
        thumbColor: kPrimary,
        overlayColor: kPrimary.withValues(alpha: 0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        valueIndicatorColor: kPrimary,
        valueIndicatorTextStyle: GoogleFonts.shareTechMono(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: kPrimary.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: kCard,
        selectedColor: kPrimary,
        labelStyle: GoogleFonts.shareTechMono(fontSize: 11, letterSpacing: 0.5),
        secondaryLabelStyle: GoogleFonts.shareTechMono(
          fontSize: 11,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: kPrimary.withValues(alpha: 0.3), width: 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: kCard,
        iconColor: kPrimary,
        textColor: kText,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: kCard,
        contentTextStyle: GoogleFonts.shareTechMono(color: kPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.zero,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(12),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
        ),
        titleTextStyle: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        contentTextStyle: GoogleFonts.shareTechMono(color: kText, fontSize: 13),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kPrimary,
        linearTrackColor: kBorderDim,
        circularTrackColor: kBorderDim,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kBorderDim),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kPrimary.withValues(alpha: 0.25)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: kPrimary,
      onPrimary: Colors.black,
      secondary: Color(0xFF1A7A00),
      onSecondary: Colors.white,
      error: kError,
      onError: Colors.white,
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF1A1A1A),
      outline: Color(0xFFCCCCCC),
      surfaceContainerHighest: Colors.white,
      onSurfaceVariant: Color(0xFF555555),
      primaryContainer: Color(0xFFFFF8DC),
      onPrimaryContainer: Color(0xFF5A4000),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: () {
        final mono = GoogleFonts.shareTechMono;
        const dark = Color(0xFF1A1A1A);
        const sub = Color(0xFF555555);
        return TextTheme(
          displayLarge:  mono(fontSize: 57, color: dark),
          displayMedium: mono(fontSize: 45, color: dark),
          displaySmall:  mono(fontSize: 36, color: dark),
          headlineLarge:  mono(fontSize: 32, fontWeight: FontWeight.w700, color: kPrimary),
          headlineMedium: mono(fontSize: 28, fontWeight: FontWeight.w700, color: kPrimary),
          headlineSmall:  mono(fontSize: 24, fontWeight: FontWeight.w600, color: kPrimary),
          titleLarge:  mono(fontSize: 20, fontWeight: FontWeight.w600, color: dark),
          titleMedium: mono(fontSize: 16, fontWeight: FontWeight.w500, color: dark),
          titleSmall:  mono(fontSize: 14, fontWeight: FontWeight.w500, color: dark),
          bodyLarge:   mono(fontSize: 16, color: dark),
          bodyMedium:  mono(fontSize: 14, color: dark),
          bodySmall:   mono(fontSize: 12, color: sub),
          labelLarge:  mono(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: dark),
          labelMedium: mono(fontSize: 12, letterSpacing: 1.2, color: sub),
          labelSmall:  mono(fontSize: 11, letterSpacing: 1.0, color: sub),
        );
      }(),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: kPrimary),
        actionsIconTheme: const IconThemeData(color: kPrimary),
        shape: Border.all(color: const Color(0xFFE8D800), width: 0),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
        ),
        clipBehavior: Clip.none,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kError, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kError, width: 1.5),
        ),
        labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF555555), fontSize: 14),
        hintStyle: GoogleFonts.shareTechMono(color: const Color(0xFFAAAAAA), fontSize: 14),
        floatingLabelStyle: GoogleFonts.shareTechMono(color: kPrimary, fontSize: 12),
        errorStyle: GoogleFonts.shareTechMono(color: kError, fontSize: 11),
        prefixIconColor: const Color(0xFF555555),
        suffixIconColor: const Color(0xFF555555),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: kPrimaryDim,
          disabledForegroundColor: Colors.black54,
          textStyle: GoogleFonts.shareTechMono(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontSize: 14,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 1),
          textStyle: GoogleFonts.shareTechMono(
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimary,
          textStyle: GoogleFonts.shareTechMono(letterSpacing: 1, fontSize: 13),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        extendedTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.black : const Color(0xFF888888),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kPrimary : const Color(0xFFCCCCCC),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: kPrimary,
        inactiveTrackColor: const Color(0xFFCCCCCC),
        thumbColor: kPrimary,
        overlayColor: kPrimary.withValues(alpha: 0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        valueIndicatorColor: kPrimary,
        valueIndicatorTextStyle: GoogleFonts.shareTechMono(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: kPrimary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: kPrimary,
        labelStyle: GoogleFonts.shareTechMono(fontSize: 11, letterSpacing: 0.5),
        secondaryLabelStyle: GoogleFonts.shareTechMono(
          fontSize: 11,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: kPrimary.withValues(alpha: 0.5), width: 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
        iconColor: kPrimary,
        textColor: Color(0xFF1A1A1A),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: GoogleFonts.shareTechMono(color: kPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.zero,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(12),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: kPrimary.withValues(alpha: 0.4), width: 1),
        ),
        titleTextStyle: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        contentTextStyle: GoogleFonts.shareTechMono(color: const Color(0xFF1A1A1A), fontSize: 13),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kPrimary,
        linearTrackColor: Color(0xFFCCCCCC),
        circularTrackColor: Color(0xFFCCCCCC),
      ),
    );
  }
}
