import 'package:ew_core/transaction_info.dart';
import 'package:mobx/mobx.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:elite_wallet/store/wallet_list_store.dart';
import 'package:elite_wallet/store/authentication_store.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/store/node_list_store.dart';

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  AppStoreBase(
      {required this.authenticationStore,
      required this.walletList,
      required this.settingsStore,
      required this.nodeListStore});

  AuthenticationStore authenticationStore;

  @observable
  WalletBase<Balance, TransactionHistoryBase<TransactionInfo>, TransactionInfo>?
      wallet;

  WalletListStore walletList;

  SettingsStore settingsStore;

  NodeListStore nodeListStore;

  @action
  void changeCurrentWallet(
      WalletBase<Balance, TransactionHistoryBase<TransactionInfo>,
              TransactionInfo>
          wallet) {
    this.wallet?.close();
    this.wallet = wallet;
  }
}
