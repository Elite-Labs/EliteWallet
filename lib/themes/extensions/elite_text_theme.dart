import 'package:flutter/material.dart';

class EliteTextTheme extends ThemeExtension<EliteTextTheme> {
  final Color secondaryTextColor;
  final Color textfieldUnderlineColor;
  final Color titleColor;
  final Color addressButtonBorderColor;
  final Color dateSectionRowColor;
  final Color buttonTextColor;
  final Color buttonSecondaryTextColor;

  EliteTextTheme(
      {required this.secondaryTextColor,
      required this.textfieldUnderlineColor,
      required this.titleColor,
      required this.addressButtonBorderColor,
      required this.dateSectionRowColor,
      Color? buttonTextColor,
      Color? buttonSecondaryTextColor})
      : buttonTextColor = buttonTextColor ?? titleColor,
        buttonSecondaryTextColor =
            buttonSecondaryTextColor ?? secondaryTextColor;

  @override
  EliteTextTheme copyWith(
          {Color? secondaryTextColor,
          Color? textfieldUnderlineColor,
          Color? titleColor,
          Color? addressButtonBorderColor,
          Color? dateSectionRowColor,
          Color? buttonTextColor,
          Color? buttonSecondaryTextColor}) =>
      EliteTextTheme(
          secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
          textfieldUnderlineColor:
              textfieldUnderlineColor ?? this.textfieldUnderlineColor,
          titleColor: titleColor ?? this.titleColor,
          addressButtonBorderColor:
              addressButtonBorderColor ?? this.addressButtonBorderColor,
          dateSectionRowColor: dateSectionRowColor ?? this.dateSectionRowColor,
          buttonTextColor: buttonTextColor ?? this.buttonTextColor,
          buttonSecondaryTextColor:
              buttonSecondaryTextColor ?? this.buttonSecondaryTextColor);

  @override
  EliteTextTheme lerp(ThemeExtension<EliteTextTheme>? other, double t) {
    if (other is! EliteTextTheme) {
      return this;
    }

    return EliteTextTheme(
        secondaryTextColor:
            Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
        textfieldUnderlineColor: Color.lerp(
            textfieldUnderlineColor, other.textfieldUnderlineColor, t)!,
        titleColor: Color.lerp(titleColor, other.titleColor, t)!,
        addressButtonBorderColor: Color.lerp(
            addressButtonBorderColor, other.addressButtonBorderColor, t)!,
        dateSectionRowColor:
            Color.lerp(dateSectionRowColor, other.dateSectionRowColor, t)!,
        buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t)!,
        buttonSecondaryTextColor: Color.lerp(
            buttonSecondaryTextColor, other.buttonSecondaryTextColor, t)!);
  }
}
