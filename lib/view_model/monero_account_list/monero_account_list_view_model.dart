import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:elite_wallet/view_model/monero_account_list/account_list_item.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:elite_wallet/haven/haven.dart';
import 'package:elite_wallet/wownero/wownero.dart';

part 'monero_account_list_view_model.g.dart';

class MoneroAccountListViewModel = MoneroAccountListViewModelBase
    with _$MoneroAccountListViewModel;

abstract class MoneroAccountListViewModelBase with Store {
  MoneroAccountListViewModelBase(this._wallet) : scrollOffsetFromTop = 0;

  @observable
  double scrollOffsetFromTop;

  @action
  void setScrollOffsetFromTop(double scrollOffsetFromTop) {
    this.scrollOffsetFromTop = scrollOffsetFromTop;
  }

  CryptoCurrency get currency => _wallet.currency;

  @computed
  List<AccountListItem> get accounts {
    if (_wallet.type == WalletType.haven) {
      return haven
        !.getAccountList(_wallet)
        .accounts.map((acc) => AccountListItem(
            label: acc.label,
            id: acc.id,
            isSelected: acc.id == haven!.getCurrentAccount(_wallet).id))
        .toList();
    }

    if (_wallet.type == WalletType.monero) {
      return monero
        !.getAccountList(_wallet)
        .accounts.map((acc) => AccountListItem(
            label: acc.label,
            id: acc.id,
            balance: acc.balance,
            isSelected: acc.id == monero!.getCurrentAccount(_wallet).id))
        .toList();
    }

    if (_wallet.type == WalletType.wownero) {
      return wownero
        !.getAccountList(_wallet)
        .accounts.map((acc) => AccountListItem(
            label: acc.label,
            id: acc.id,
            isSelected: acc.id == wownero!.getCurrentAccount(_wallet).id))
        .toList();
    }

    throw Exception('Unexpected wallet type: ${_wallet.type}');
  }

  final WalletBase _wallet;

  void select(AccountListItem item) {
    if (_wallet.type == WalletType.monero) {
      monero!.setCurrentAccount(
        _wallet,
        item.id,
        item.label,
        item.balance,
        );
    }

    if (_wallet.type == WalletType.haven) {
      haven!.setCurrentAccount(
        _wallet,
        item.id,
        item.label);
    }

    if (_wallet.type == WalletType.wownero) {
      wownero!.setCurrentAccount(
        _wallet,
        item.id,
        item.label);
    }
  }
}
