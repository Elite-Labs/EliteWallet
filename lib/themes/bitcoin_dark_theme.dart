import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/palette.dart';
import 'package:elite_wallet/themes/monero_dark_theme.dart';
import 'package:flutter/material.dart';

class BitcoinDarkTheme extends MoneroDarkTheme {
  BitcoinDarkTheme({required int raw}) : super(raw: raw);

  @override
  String get title => S.current.bitcoin_dark_theme;
  @override
  Color get primaryColor => Palette.bitcoinOrange;
}

