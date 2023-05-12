import 'package:elite_wallet/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/src/widgets/standard_list.dart';
import 'package:elite_wallet/utils/show_bar.dart';

class SettingsLinkProviderCell extends StandardListRow {
  SettingsLinkProviderCell(
      {required String title,
        required this.link,
        required this.linkTitle,
        this.icon,
        this.iconColor})
      : super(title: title, isSelected: false,
              onTap: (BuildContext context) => _copyToClipboard(context, link));

  
  final String link;
  final String linkTitle;
  final String? icon;
  final Color? iconColor;

  @override
  Widget? buildLeading(BuildContext context) =>
      icon != null ? Image.asset(icon!, color: iconColor, height: 24, width: 24) : null;

  @override
  Widget buildTrailing(BuildContext context) => Text(linkTitle,
      style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Palette.blueCraiola));

  static void _copyToClipboard(BuildContext context, String url) async {
    try {
      Clipboard.setData(ClipboardData(text: url));
      showBar<void>(context, S.of(context).transaction_details_copied(url));
    } catch (e) {}
  }
}
