import 'package:elite_wallet/entities/exchange_api_mode.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/entities/fiat_api_mode.dart';

part 'privacy_settings_view_model.g.dart';

class PrivacySettingsViewModel = PrivacySettingsViewModelBase with _$PrivacySettingsViewModel;

abstract class PrivacySettingsViewModelBase with Store {
  PrivacySettingsViewModelBase(this.settingsStore);

  final SettingsStore settingsStore;

  @computed
  ExchangeApiMode get exchangeStatus => settingsStore.exchangeStatus;

  @computed
  bool get shouldSaveRecipientAddress => settingsStore.shouldSaveRecipientAddress;

  @computed
  FiatApiMode get fiatApiMode => settingsStore.fiatApiMode;

  @computed
  bool get isAppSecure => settingsStore.isAppSecure;

  @computed
  bool get disableBuy => settingsStore.disableBuy;

  @computed
  bool get disableSell => settingsStore.disableSell;

  @action
  void setShouldSaveRecipientAddress(bool value) => settingsStore.shouldSaveRecipientAddress = value;

  @action
  void setExchangeApiMode(ExchangeApiMode value) => settingsStore.exchangeStatus = value;

  @action
  void setFiatMode(FiatApiMode fiatApiMode) => settingsStore.fiatApiMode = fiatApiMode;

  @action
  void setIsAppSecure(bool value) => settingsStore.isAppSecure = value;

  @action
  void setDisableBuy(bool value) => settingsStore.disableBuy = value;

  @action
  void setDisableSell(bool value) => settingsStore.disableSell = value;

}
