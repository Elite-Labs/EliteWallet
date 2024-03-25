import 'package:elite_wallet/entities/auto_generate_subaddress_status.dart';
import 'package:elite_wallet/entities/exchange_api_mode.dart';
import 'package:elite_wallet/ethereum/ethereum.dart';
import 'package:elite_wallet/polygon/polygon.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/entities/fiat_api_mode.dart';

part 'privacy_settings_view_model.g.dart';

class PrivacySettingsViewModel = PrivacySettingsViewModelBase with _$PrivacySettingsViewModel;

abstract class PrivacySettingsViewModelBase with Store {
  PrivacySettingsViewModelBase(this.settingsStore, this._wallet);

  final SettingsStore settingsStore;
  final WalletBase<Balance, TransactionHistoryBase<TransactionInfo>, TransactionInfo> _wallet;

  @computed
  ExchangeApiMode get exchangeStatus => settingsStore.exchangeStatus;

  @computed
  bool get isAutoGenerateSubaddressesEnabled =>
      settingsStore.autoGenerateSubaddressStatus != AutoGenerateSubaddressStatus.disabled;

  @action
  void setAutoGenerateSubaddresses(bool value) {
    _wallet.isEnabledAutoGenerateSubaddress = value;
    if (value) {
      settingsStore.autoGenerateSubaddressStatus = AutoGenerateSubaddressStatus.enabled;
    } else {
      settingsStore.autoGenerateSubaddressStatus = AutoGenerateSubaddressStatus.disabled;
    }
  }

  bool get isAutoGenerateSubaddressesVisible =>
      _wallet.type == WalletType.monero ||
      _wallet.type == WalletType.bitcoin ||
      _wallet.type == WalletType.litecoin ||
      _wallet.type == WalletType.bitcoinCash;

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

  @computed
  bool get useEtherscan => settingsStore.useEtherscan;

  @computed
  bool get usePolygonScan => settingsStore.usePolygonScan;

  @computed
  bool get lookupTwitter => settingsStore.lookupsTwitter;

  @computed
  bool get looksUpMastodon => settingsStore.lookupsMastodon;

  @computed
  bool get looksUpYatService => settingsStore.lookupsYatService;

  @computed
  bool get looksUpUnstoppableDomains => settingsStore.lookupsUnstoppableDomains;

  @computed
  bool get looksUpOpenAlias => settingsStore.lookupsOpenAlias;

  @computed
  bool get looksUpENS => settingsStore.lookupsENS;

  bool get canUseEtherscan => _wallet.type == WalletType.ethereum;

  bool get canUsePolygonScan => _wallet.type == WalletType.polygon;

  @action
  void setShouldSaveRecipientAddress(bool value) =>
      settingsStore.shouldSaveRecipientAddress = value;

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

  @action
  void setLookupsTwitter(bool value) => settingsStore.lookupsTwitter = value;

  @action
  void setLookupsMastodon(bool value) => settingsStore.lookupsMastodon = value;

  @action
  void setLookupsENS(bool value) => settingsStore.lookupsENS = value;

  @action
  void setLookupsYatService(bool value) => settingsStore.lookupsYatService = value;

  @action
  void setLookupsUnstoppableDomains(bool value) => settingsStore.lookupsUnstoppableDomains = value;

  @action
  void setLookupsOpenAlias(bool value) => settingsStore.lookupsOpenAlias = value;

  @action
  void setUseEtherscan(bool value) {
    settingsStore.useEtherscan = value;
    ethereum!.updateEtherscanUsageState(_wallet, value);
  }

  @action
  void setUsePolygonScan(bool value) {
    settingsStore.usePolygonScan = value;
    polygon!.updatePolygonScanUsageState(_wallet, value);
  }
}
