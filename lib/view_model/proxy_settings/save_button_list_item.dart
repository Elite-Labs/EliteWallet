import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';

class SaveButtonistItem extends SettingsListItem {
  SaveButtonistItem(@required this.navigateTo)
      : super("Proxy save button");

  static bool _alwaysEnabled() {
    return true;
  }

  final void Function() navigateTo;
}
