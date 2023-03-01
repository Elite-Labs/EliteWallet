import 'package:elite_wallet/store/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/entities/fiat_api_mode.dart';

part 'privacy_settings_view_model.g.dart';

class PrivacySettingsViewModel = PrivacySettingsViewModelBase with _$PrivacySettingsViewModel;

abstract class PrivacySettingsViewModelBase with Store {
  PrivacySettingsViewModelBase(this.settingsStore);

  final SettingsStore settingsStore;

  @computed
  bool get disableExchange => settingsStore.disableExchange;

  @computed
  bool get shouldSaveRecipientAddress => settingsStore.shouldSaveRecipientAddress;

  @computed
  bool get isFiatDisabled => settingsStore.fiatApiMode == FiatApiMode.disabled;

  @action
  void setShouldSaveRecipientAddress(bool value) => settingsStore.shouldSaveRecipientAddress = value;

  @action
  void setEnableExchange(bool value) => settingsStore.disableExchange = value;

  @action
  void setFiatMode(bool value) {
    if (value) {
      settingsStore.fiatApiMode = FiatApiMode.disabled;
      return;
    }
    settingsStore.fiatApiMode = FiatApiMode.enabled;
  }

}
