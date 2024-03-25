import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/palette.dart';
import 'package:elite_wallet/themes/monero_dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/themes/extensions/menu_theme.dart';

class EliteDarkTheme extends MoneroDarkTheme {
  EliteDarkTheme({required int raw}) : super(raw: raw);

  @override
  String get title => S.current.elite_dark_theme;
  @override
  Color get primaryColor => PaletteDark.cakeBlue;

  @override
  EliteMenuTheme get menuTheme => super.menuTheme.copyWith(
      headerFirstGradientColor: PaletteDark.darkBlue,
      headerSecondGradientColor: containerColor,
      backgroundColor: containerColor,
      subnameTextColor: Colors.grey,
      dividerColor: colorScheme.secondaryContainer,
      iconColor: Colors.white,
      settingActionsIconColor: colorScheme.secondaryContainer);
}