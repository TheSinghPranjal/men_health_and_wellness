import 'package:flutter/material.dart';

/// Pastel "clay" tones used to colour-code topics. Each tone has a fill and
/// a readable foreground so colour is never the only signal.
enum ClayTone { teal, blue, sand, sage, lavender, peach, rose, slate }

@immutable
class ClayTonePair {
  const ClayTonePair(this.fill, this.onFill);
  final Color fill;
  final Color onFill;
}

/// Design tokens for the claymorphic surface language.
///
/// Claymorphism = large radii + a soft offset drop shadow that lifts the
/// surface off the page + inner highlight (top-left) and inner shade
/// (bottom-right) that make it look inflated.
@immutable
class ClayTheme extends ThemeExtension<ClayTheme> {
  const ClayTheme({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.dropShadow,
    required this.innerHighlight,
    required this.innerShade,
    required this.textPrimary,
    required this.textSecondary,
    required this.brand,
    required this.onBrand,
    required this.accent,
    required this.onAccent,
    required this.positive,
    required this.caution,
    required this.critical,
    required this.onCritical,
    required this.tones,
    required this.chart,
  });

  final Color background;
  final Color surface;
  final Color surfaceSunken;
  final Color dropShadow;
  final Color innerHighlight;
  final Color innerShade;
  final Color textPrimary;
  final Color textSecondary;
  final Color brand;
  final Color onBrand;
  final Color accent;
  final Color onAccent;
  final Color positive;
  final Color caution;
  final Color critical;
  final Color onCritical;
  final Map<ClayTone, ClayTonePair> tones;

  /// Single-series chart mark colour (validated for contrast/chroma).
  final Color chart;

  ClayTonePair tone(ClayTone t) => tones[t]!;

  static const radiusSm = 16.0;
  static const radiusMd = 24.0;
  static const radiusLg = 32.0;

  static const light = ClayTheme(
    background: Color(0xFFF2EEE8),
    surface: Color(0xFFFBF8F3),
    surfaceSunken: Color(0xFFE9E3DA),
    dropShadow: Color(0x331F2A44),
    innerHighlight: Color(0xD9FFFFFF),
    innerShade: Color(0x1F1F2A44),
    textPrimary: Color(0xFF1B2438),
    textSecondary: Color(0xFF586274),
    brand: Color(0xFF1F2A44),
    onBrand: Color(0xFFF7F4EF),
    accent: Color(0xFF2F7A76),
    onAccent: Color(0xFFFFFFFF),
    positive: Color(0xFF3F7F57),
    caution: Color(0xFF9A6410),
    critical: Color(0xFFB3362D),
    onCritical: Color(0xFFFFFFFF),
    tones: {
      ClayTone.teal: ClayTonePair(Color(0xFFCDE7E3), Color(0xFF17504C)),
      ClayTone.blue: ClayTonePair(Color(0xFFD5DEF2), Color(0xFF233A6B)),
      ClayTone.sand: ClayTonePair(Color(0xFFF2E3CB), Color(0xFF6B4A12)),
      ClayTone.sage: ClayTonePair(Color(0xFFDAE8D3), Color(0xFF2F5228)),
      ClayTone.lavender: ClayTonePair(Color(0xFFE2DCF2), Color(0xFF45367A)),
      ClayTone.peach: ClayTonePair(Color(0xFFF4D9CD), Color(0xFF7A3A22)),
      ClayTone.rose: ClayTonePair(Color(0xFFF2D6DC), Color(0xFF7A2638)),
      ClayTone.slate: ClayTonePair(Color(0xFFDDE1E8), Color(0xFF2E3A4E)),
    },
    chart: Color(0xFF008F82),
  );

  static const dark = ClayTheme(
    background: Color(0xFF141927),
    surface: Color(0xFF1F2638),
    surfaceSunken: Color(0xFF181E2D),
    dropShadow: Color(0x99000000),
    innerHighlight: Color(0x14FFFFFF),
    innerShade: Color(0x66000000),
    textPrimary: Color(0xFFEDEFF5),
    textSecondary: Color(0xFFA9B1C2),
    brand: Color(0xFFB9C7EA),
    onBrand: Color(0xFF141927),
    accent: Color(0xFF7CCBC4),
    onAccent: Color(0xFF0E2624),
    positive: Color(0xFF8BCB9F),
    caution: Color(0xFFE9B562),
    critical: Color(0xFFFF8A80),
    onCritical: Color(0xFF3B0A06),
    tones: {
      ClayTone.teal: ClayTonePair(Color(0xFF1F3F3E), Color(0xFFB8E6E0)),
      ClayTone.blue: ClayTonePair(Color(0xFF243150), Color(0xFFC7D4F5)),
      ClayTone.sand: ClayTonePair(Color(0xFF3E3424), Color(0xFFF1D9AE)),
      ClayTone.sage: ClayTonePair(Color(0xFF263A27), Color(0xFFC7E3BC)),
      ClayTone.lavender: ClayTonePair(Color(0xFF302A4A), Color(0xFFD9D0F7)),
      ClayTone.peach: ClayTonePair(Color(0xFF42291F), Color(0xFFF5CDBB)),
      ClayTone.rose: ClayTonePair(Color(0xFF42242C), Color(0xFFF5C6D0)),
      ClayTone.slate: ClayTonePair(Color(0xFF2A3245), Color(0xFFD3D9E5)),
    },
    chart: Color(0xFF1A9E90),
  );

  @override
  ClayTheme copyWith() => this;

  @override
  ClayTheme lerp(ClayTheme? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ClayTheme(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      dropShadow: l(dropShadow, other.dropShadow),
      innerHighlight: l(innerHighlight, other.innerHighlight),
      innerShade: l(innerShade, other.innerShade),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      brand: l(brand, other.brand),
      onBrand: l(onBrand, other.onBrand),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      positive: l(positive, other.positive),
      caution: l(caution, other.caution),
      critical: l(critical, other.critical),
      onCritical: l(onCritical, other.onCritical),
      tones: {
        for (final key in ClayTone.values)
          key: ClayTonePair(
            l(tones[key]!.fill, other.tones[key]!.fill),
            l(tones[key]!.onFill, other.tones[key]!.onFill),
          ),
      },
      chart: l(chart, other.chart),
    );
  }
}

extension ClayThemeContext on BuildContext {
  ClayTheme get clay => Theme.of(this).extension<ClayTheme>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

/// Spacing scale (4pt grid).
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = 20.0;
}
