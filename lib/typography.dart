import 'package:flutter/material.dart';

const latoFont = "Lato";

TextStyle textXxSmall({Color color}) => _eliteRegular(10, color);

TextStyle textXxSmallSemiBold({Color color}) => _eliteSemiBold(10, color);

TextStyle textXSmall({Color color}) => _eliteRegular(12, color);

TextStyle textXSmallSemiBold({Color color}) => _eliteSemiBold(12, color);

TextStyle textSmall({Color color}) => _eliteRegular(14, color);

TextStyle textSmallSemiBold({Color color}) => _eliteSemiBold(14, color);

TextStyle textMedium({Color color}) => _eliteRegular(16, color);

TextStyle textMediumBold({Color color}) => _eliteBold(16, color);

TextStyle textMediumSemiBold({Color color}) => _eliteSemiBold(22, color);

TextStyle textLarge({Color color}) => _eliteRegular(18, color);

TextStyle textLargeSemiBold({Color color}) => _eliteSemiBold(24, color);

TextStyle textXLarge({Color color}) => _eliteRegular(32, color);

TextStyle textXLargeSemiBold({Color color}) => _eliteSemiBold(32, color);

TextStyle _eliteRegular(double size, Color color) => _textStyle(
      size: size,
      fontWeight: FontWeight.normal,
      color: color,
    );

TextStyle _eliteBold(double size, Color color) => _textStyle(
      size: size,
      fontWeight: FontWeight.w900,
      color: color,
    );

TextStyle _eliteSemiBold(double size, Color color) => _textStyle(
      size: size,
      fontWeight: FontWeight.w700,
      color: color,
    );

TextStyle _textStyle({
  @required double size,
  @required FontWeight fontWeight,
  Color color,
}) =>
    TextStyle(
      fontFamily: latoFont,
      fontSize: size,
      fontWeight: fontWeight,
      color: color ?? Colors.white,
    );
