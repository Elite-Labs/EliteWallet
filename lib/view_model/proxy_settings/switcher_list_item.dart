import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';

class SwitcherListItem extends SettingsListItem {
  SwitcherListItem(
      {required String title,
      required this.value,
      required this.onValueChange})
      : super(title);

  final bool Function() value;
  final void Function(BuildContext context, bool value) onValueChange;
}
