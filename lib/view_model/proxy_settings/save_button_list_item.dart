import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:mobx/mobx.dart';

part 'save_button_list_item.g.dart';

class SaveButtonistItem = SaveButtonistItemBase with _$SaveButtonistItem;

abstract class SaveButtonistItemBase extends SettingsListItem with Store {
  SaveButtonistItemBase(@required this._action)
    : isLoading = false,
      super("Proxy save button");

  static bool _alwaysEnabled() {
    return true;
  }

  final Future<void> Function() _action;

  void navigateTo() async {
    isLoading = true;
    await _action();
    isLoading = false;
  }

  @observable
  bool isLoading;
}
