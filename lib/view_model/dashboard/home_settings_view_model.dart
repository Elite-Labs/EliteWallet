import 'package:elite_wallet/core/fiat_conversion_service.dart';
import 'package:elite_wallet/entities/fiat_api_mode.dart';
import 'package:elite_wallet/entities/sort_balance_types.dart';
import 'package:elite_wallet/ethereum/ethereum.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/dashboard/balance_view_model.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/erc20_token.dart';
import 'package:mobx/mobx.dart';

part 'home_settings_view_model.g.dart';

class HomeSettingsViewModel = HomeSettingsViewModelBase with _$HomeSettingsViewModel;

abstract class HomeSettingsViewModelBase with Store {
  HomeSettingsViewModelBase(this._settingsStore, this._balanceViewModel)
      : tokens = ObservableSet<Erc20Token>() {
    _updateTokensList();
  }

  final SettingsStore _settingsStore;
  final BalanceViewModel _balanceViewModel;

  final ObservableSet<Erc20Token> tokens;

  @observable
  String searchText = '';

  @computed
  SortBalanceBy get sortBalanceBy => _settingsStore.sortBalanceBy;

  @action
  void setSortBalanceBy(SortBalanceBy value) {
    _settingsStore.sortBalanceBy = value;
    _updateTokensList();
  }

  @computed
  bool get pinNativeToken => _settingsStore.pinNativeTokenAtTop;

  @action
  void setPinNativeToken(bool value) => _settingsStore.pinNativeTokenAtTop = value;

  Future<void> addErc20Token(Erc20Token token) async {
    await ethereum!.addErc20Token(_balanceViewModel.wallet, token);
    _updateTokensList();
    _updateFiatPrices(token);
  }

  Future<void> deleteErc20Token(Erc20Token token) async {
    await ethereum!.deleteErc20Token(_balanceViewModel.wallet, token);
    _updateTokensList();
  }

  Future<Erc20Token?> getErc20Token(String contractAddress) async =>
      await ethereum!.getErc20Token(_balanceViewModel.wallet, contractAddress);

  CryptoCurrency get nativeToken => _balanceViewModel.wallet.currency;

  void _updateFiatPrices(Erc20Token token) async {
    try {
      _balanceViewModel.fiatConvertationStore.prices[token] =
          await FiatConversionService.fetchPrice(
              token,
              _settingsStore.fiatCurrency,
              _settingsStore);
    } catch (_) {}
  }

  void changeTokenAvailability(Erc20Token token, bool value) async {
    token.enabled = value;
    ethereum!.addErc20Token(_balanceViewModel.wallet, token);
    _refreshTokensList();
  }

  @action
  void _updateTokensList() {
    int _sortFunc(Erc20Token e1, Erc20Token e2) {
      int index1 = _balanceViewModel.formattedBalances.indexWhere((element) => element.asset == e1);
      int index2 = _balanceViewModel.formattedBalances.indexWhere((element) => element.asset == e2);

      if (e1.enabled && !e2.enabled) {
        return -1;
      } else if (e2.enabled && !e1.enabled) {
        return 1;
      } else if (!e1.enabled && !e2.enabled) { // if both are disabled then sort alphabetically
        return e1.name.compareTo(e2.name);
      }

      return index1.compareTo(index2);
    }

    tokens.clear();

    tokens.addAll(ethereum!
        .getERC20Currencies(_balanceViewModel.wallet)
        .where((element) => _matchesSearchText(element))
        .toList()
      ..sort(_sortFunc));
  }

  @action
  void _refreshTokensList() {
    final _tokens = Set.of(tokens);
    tokens.clear();
    tokens.addAll(_tokens);
  }

  @action
  void changeSearchText(String text) {
    searchText = text;
    _updateTokensList();
  }

  bool _matchesSearchText(Erc20Token asset) {
    return searchText.isEmpty ||
        asset.fullName!.toLowerCase().contains(searchText.toLowerCase()) ||
        asset.title.toLowerCase().contains(searchText.toLowerCase()) ||
        asset.contractAddress == searchText;
  }
}
