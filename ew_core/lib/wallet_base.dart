import 'package:mobx/mobx.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/wallet_addresses.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/pending_transaction.dart';
import 'package:ew_core/currency_for_wallet_type.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/sync_status.dart';
import 'package:ew_core/node.dart';
import 'package:ew_core/wallet_type.dart';

abstract class WalletBase<
    BalanceType extends Balance,
    HistoryType extends TransactionHistoryBase,
    TransactionType extends TransactionInfo> {
  WalletBase(this.walletInfo);

  static String idFor(String name, WalletType type) =>
      walletTypeToString(type).toLowerCase() + '_' + name;

  WalletInfo walletInfo;

  WalletType get type => walletInfo.type;

  CryptoCurrency get currency => currencyForWalletType(type);

  String get id => walletInfo.id;

  String get name => walletInfo.name;

  //String get address;

  //set address(String address);

  ObservableMap<CryptoCurrency, BalanceType> get balance;

  SyncStatus get syncStatus;

  set syncStatus(SyncStatus status);

  String get seed;

  Object get keys;

  WalletAddresses get walletAddresses;

  late HistoryType transactionHistory;

  Future<void> connectToNode({required Node node,
                              required SettingsStore settingsStore});

  Future<void> startSync();

  Future<PendingTransaction> createTransaction(Object credentials);

  int calculateEstimatedFee(TransactionPriority priority, int? amount);

  // void fetchTransactionsAsync(
  //     void Function(TransactionType transaction) onTransactionLoaded,
  //     {void Function() onFinished});

  Future<Map<String, TransactionType>> fetchTransactions();

  Future<void> save();

  Future<void> rescan({required int height});

  void close();

  Future<void> changePassword(String password);

  Future<void>? updateBalance();
}
