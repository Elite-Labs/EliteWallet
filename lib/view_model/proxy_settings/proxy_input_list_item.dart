import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';

class ProxyInputListItem extends SettingsListItem {
  ProxyInputListItem(
      {@required this.type,
      @required this.value,
      @required this.onValueChange,
      this.enabled = _alwaysEnabled})
      : super("Proxy Input");

  static bool _alwaysEnabled() {
    return true;
  }

  final ProxyInputType type;
  final String Function() value;
  final void Function(BuildContext context, String value) onValueChange;
  final bool Function() enabled;
}
