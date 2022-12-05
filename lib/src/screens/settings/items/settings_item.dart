import 'package:flutter/material.dart';
import 'package:elite_wallet/src/screens/settings/attributes.dart';

class SettingsItem {
  SettingsItem(
      {this.onTaped,
      this.title,
      this.link,
      this.image,
      this.widget,
      this.attribute,
      this.widgetBuilder});

  final VoidCallback onTaped;
  final String title;
  final String link;
  final Image image;
  final Widget widget;
  final Attributes attribute;
  final WidgetBuilder widgetBuilder;
}
