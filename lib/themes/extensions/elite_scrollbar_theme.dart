import 'package:flutter/material.dart';

class EliteScrollbarTheme extends ThemeExtension<EliteScrollbarTheme> {
  final Color thumbColor;
  final Color trackColor;

  EliteScrollbarTheme({required this.thumbColor, required this.trackColor});

  @override
  Object get type => EliteScrollbarTheme;

  @override
  EliteScrollbarTheme copyWith({Color? thumbColor, Color? trackColor}) =>
      EliteScrollbarTheme(
          thumbColor: thumbColor ?? this.thumbColor,
          trackColor: trackColor ?? this.trackColor);

  @override
  EliteScrollbarTheme lerp(ThemeExtension<EliteScrollbarTheme>? other, double t) {
    if (other is! EliteScrollbarTheme) {
      return this;
    }

    return EliteScrollbarTheme(
        thumbColor: Color.lerp(thumbColor, other.thumbColor, t) ?? thumbColor,
        trackColor: Color.lerp(trackColor, other.trackColor, t) ?? trackColor);
  }
}
