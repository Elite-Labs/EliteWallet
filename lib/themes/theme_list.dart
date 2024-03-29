import 'package:elite_wallet/themes/bright_theme.dart';
import 'package:elite_wallet/themes/dark_theme.dart';
import 'package:elite_wallet/themes/light_theme.dart';
import 'package:elite_wallet/themes/monero_light_theme.dart';
import 'package:elite_wallet/themes/monero_dark_theme.dart';
import 'package:elite_wallet/themes/elite_dark_theme.dart';
import 'package:elite_wallet/themes/matrix_green_theme.dart';
import 'package:elite_wallet/themes/bitcoin_dark_theme.dart';
import 'package:elite_wallet/themes/bitcoin_light_theme.dart';
import 'package:elite_wallet/themes/high_contrast_theme.dart';
import 'package:elite_wallet/themes/red_dark_theme.dart';
import 'package:elite_wallet/themes/red_light_theme.dart';
import 'package:elite_wallet/themes/theme_base.dart';

class ThemeList {
  static final all = [
    eliteDarkTheme,
    darkTheme,
    lightTheme,
    moneroDarkTheme,
    moneroLightTheme,
    brightTheme,
    bitcoinDarkTheme,
    bitcoinLightTheme,
    matrixGreenTheme,
    redDarkTheme,
    redLightTheme,
    highContrastTheme,
  ];

  static final lightTheme = LightTheme(raw: 0);
  static final brightTheme = BrightTheme(raw: 1);
  static final darkTheme = DarkTheme(raw: 2);
  static final moneroDarkTheme = MoneroDarkTheme(raw: 3);
  static final moneroLightTheme = MoneroLightTheme(raw: 4);
  static final matrixGreenTheme = MatrixGreenTheme(raw: 5);
  static final bitcoinDarkTheme = BitcoinDarkTheme(raw: 6);
  static final bitcoinLightTheme = BitcoinLightTheme(raw: 7);
  static final highContrastTheme = HighContrastTheme(raw: 8);
  static final redLightTheme = RedLightTheme(raw: 9);
  static final redDarkTheme = RedDarkTheme(raw: 10);
  static final eliteDarkTheme = EliteDarkTheme(raw: 11);

  static ThemeBase deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return lightTheme;
      case 1:
        return brightTheme;
      case 2:
        return darkTheme;
      case 3:
        return moneroDarkTheme;
      case 4:
        return moneroLightTheme;
      case 5:
        return matrixGreenTheme;
      case 6:
        return bitcoinDarkTheme;
      case 7:
        return bitcoinLightTheme;
      case 8:
        return highContrastTheme;
      case 9:
        return redLightTheme;
      case 10:
        return redDarkTheme;
      case 11:
        return eliteDarkTheme;
      default:
        throw Exception(
            'Unexpected token raw: $raw for deserialization of ThemeBase');
    }
  }
}