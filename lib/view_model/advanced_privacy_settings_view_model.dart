import 'package:elite_wallet/entities/fiat_api_mode.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/settings/switcher_list_item.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/generated/i18n.dart';

part 'advanced_privacy_settings_view_model.g.dart';

class AdvancedPrivacySettingsViewModel = AdvancedPrivacySettingsViewModelBase
    with _$AdvancedPrivacySettingsViewModel;

abstract class AdvancedPrivacySettingsViewModelBase with Store {
  AdvancedPrivacySettingsViewModelBase(this.type, this._settingsStore)
      : _addCustomNode = false {
    settings = [
      SwitcherListItem(
        title: S.current.disable_fiat,
        value: () => _settingsStore.fiatApiMode == FiatApiMode.disabled,
        onValueChange: (_, bool value) => setFiatMode(value),
      ),
      SwitcherListItem(
        title: S.current.disable_exchange,
        value: () => _settingsStore.disableExchange,
        onValueChange: (_, bool value) {
          _settingsStore.disableExchange = value;
        },
      ),
      SwitcherListItem(
        title: S.current.add_custom_node,
        value: () => _addCustomNode,
        onValueChange: (_, bool value) => _addCustomNode = value,
      ),
    ];
  }

  late List<SwitcherListItem> settings;

  @observable
  bool _addCustomNode = false;

  final WalletType type;
  final SettingsStore _settingsStore;

  @computed
  bool get addCustomNode => _addCustomNode;

  @action
  void setFiatMode(bool value) {
    if (value) {
      _settingsStore.fiatApiMode = FiatApiMode.disabled;
      return;
    }
    _settingsStore.fiatApiMode = FiatApiMode.enabled;
  }
}
