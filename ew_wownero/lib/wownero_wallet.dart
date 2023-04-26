import 'dart:async';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_wownero/wownero_transaction_creation_exception.dart';
import 'package:ew_wownero/wownero_transaction_info.dart';
import 'package:ew_wownero/wownero_wallet_addresses.dart';
import 'package:ew_core/monero_wallet_utils.dart';
import 'package:ew_wownero/api/structs/pending_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:ew_wownero/api/transaction_history.dart'
    as wownero_transaction_history;
import 'package:ew_wownero/api/wallet.dart';
import 'package:ew_wownero/api/wallet.dart' as wownero_wallet;
import 'package:ew_wownero/api/transaction_history.dart' as transaction_history;
import 'package:ew_wownero/wownero_amount_format.dart';
import 'package:ew_wownero/api/wownero_output.dart';
import 'package:ew_wownero/wownero_transaction_creation_credentials.dart';
import 'package:ew_wownero/pending_wownero_transaction.dart';
import 'package:ew_wownero/wownero_balance.dart';
import 'package:ew_wownero/wownero_transaction_history.dart';
import 'package:ew_core/monero_wallet_keys.dart';
import 'package:ew_core/account.dart';
import 'package:ew_core/pending_transaction.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/sync_status.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/node.dart';
import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/port_redirector.dart';

part 'wownero_wallet.g.dart';

const wowneroBlockSize = 1000;

class WowneroWallet = WowneroWalletBase with _$WowneroWallet;

abstract class WowneroWalletBase extends WalletBase<WowneroBalance,
    WowneroTransactionHistory, WowneroTransactionInfo> with Store {
  WowneroWalletBase({required WalletInfo walletInfo})
      : balance = ObservableMap<CryptoCurrency, WowneroBalance>.of({
            CryptoCurrency.xmr: WowneroBalance(
              fullBalance: wownero_wallet.getFullBalance(accountIndex: 0),
              unlockedBalance: wownero_wallet.getFullBalance(accountIndex: 0))
            }),
        _isTransactionUpdating = false,
        _hasSyncAfterStartup = false,
        walletAddresses = WowneroWalletAddresses(walletInfo),
        syncStatus = NotConnectedSyncStatus(),
        super(walletInfo) {
    transactionHistory = WowneroTransactionHistory();
    _onAccountChangeReaction = reaction((_) => walletAddresses.account,
            (Account? account) {
      if (account == null) {
        return;
      }

      balance = ObservableMap<CryptoCurrency, WowneroBalance>.of(
        <CryptoCurrency, WowneroBalance>{
          currency: WowneroBalance(
            fullBalance: wownero_wallet.getFullBalance(accountIndex: account.id),
            unlockedBalance:
                wownero_wallet.getUnlockedBalance(accountIndex: account.id))
        });
      walletAddresses.updateSubaddressList(accountIndex: account.id);
    });
  }

  static const int _autoSaveInterval = 30;
  static const connectionTimeout = Duration(seconds: 5);

  PortRedirector? _portRedirector;

  @override
  WowneroWalletAddresses walletAddresses;

  @override
  @observable
  SyncStatus syncStatus;

  @override
  @observable
  ObservableMap<CryptoCurrency, WowneroBalance> balance;

  @override
  String get seed => wownero_wallet.getSeed();

  @override
  MoneroWalletKeys get keys => MoneroWalletKeys(
      privateSpendKey: wownero_wallet.getSecretSpendKey(),
      privateViewKey: wownero_wallet.getSecretViewKey(),
      publicSpendKey: wownero_wallet.getPublicSpendKey(),
      publicViewKey: wownero_wallet.getPublicViewKey());

  SyncListener? _listener;
  ReactionDisposer? _onAccountChangeReaction;
  bool _isTransactionUpdating;
  bool _hasSyncAfterStartup;
  Timer? _autoSaveTimer;

  Future<void> init() async {
    await walletAddresses.init();
    balance =  ObservableMap<CryptoCurrency, WowneroBalance>.of(
       <CryptoCurrency, WowneroBalance>{
          currency: WowneroBalance(
            fullBalance: wownero_wallet.getFullBalance(accountIndex: walletAddresses.account!.id),
            unlockedBalance: wownero_wallet.getUnlockedBalance(accountIndex: walletAddresses.account!.id))
          });
    _setListeners();
    await updateTransactions();

    if (walletInfo.isRecovery) {
      wownero_wallet.setRecoveringFromSeed(isRecovery: walletInfo.isRecovery);

      if (wownero_wallet.getCurrentHeight() <= 1) {
        wownero_wallet.setRefreshFromBlockHeight(
            height: walletInfo.restoreHeight);
      }
    }

    _autoSaveTimer = Timer.periodic(
       Duration(seconds: _autoSaveInterval),
       (_) async => await save());
  }

  @override
  Future<void>? updateBalance() => null;

  @override
  void close() {
    _listener?.stop();
    _onAccountChangeReaction?.reaction.dispose();
    _autoSaveTimer?.cancel();
  }

  @override
  Future<void> connectToNode({
    required Node node,
    required SettingsStore settingsStore}) async {
    String host = node.uri.host;
    int port = node.uri.port;
    PortRedirector portRedirector = await PortRedirector.start(
      settingsStore, host, port, timeout: connectionTimeout);
    host = portRedirector.host;
    port = portRedirector.port;
    _portRedirector = portRedirector;
    String uriString = host + ":" + port.toString();

    try {
      syncStatus = ConnectingSyncStatus();
      await wownero_wallet.setupNode(
          address: uriString,
          login: node.login,
          password: node.password,
          useSSL: node.isSSL,
          isLightWallet: false); // FIXME: hardcoded value

      wownero_wallet.setTrustedDaemon(node.trusted);
      syncStatus = ConnectedSyncStatus();
    } catch (e) {
      syncStatus = FailedSyncStatus();
      print(e);
    }
  }

  @override
  Future<void> startSync() async {
    try {
      _setInitialHeight();
    } catch (_) {}

    try {
      syncStatus = AttemptingSyncStatus();
      wownero_wallet.startRefresh();
      _setListeners();
      _listener?.start();
    } catch (e) {
      syncStatus = FailedSyncStatus();
      print(e);
      rethrow;
    }
  }

  @override
  Future<PendingTransaction> createTransaction(Object credentials) async {
    final _credentials = credentials as WowneroTransactionCreationCredentials;
    final outputs = _credentials.outputs;
    final hasMultiDestination = outputs.length > 1;
    final unlockedBalance =
    wownero_wallet.getUnlockedBalance(accountIndex: walletAddresses.account!.id);

    PendingTransactionDescription pendingTransactionDescription;

    if (!(syncStatus is SyncedSyncStatus)) {
      throw WowneroTransactionCreationException('The wallet is not synced.');
    }

    if (hasMultiDestination) {
      if (outputs.any((item) => item.sendAll
          || (item.formattedCryptoAmount ?? 0) <= 0)) {
        throw WowneroTransactionCreationException('You do not have enough coins to send this amount.');
      }

      final int totalAmount = outputs.fold(0, (acc, value) =>
          acc + (value.formattedCryptoAmount ?? 0));

      if (unlockedBalance < totalAmount) {
        throw WowneroTransactionCreationException('You do not have enough coins to send this amount.');
      }

      final wowneroOutputs = outputs.map((output) {
      final outputAddress = output.isParsedAddress
          ? output.extractedAddress
          : output.address;

      return MoneroOutput(
          address: outputAddress!,
          amount: output.cryptoAmount!.replaceAll(',', '.'));
      }).toList();

      pendingTransactionDescription =
      await transaction_history.createTransactionMultDest(
          outputs: wowneroOutputs,
          priorityRaw: _credentials.priority.serialize(),
          accountIndex: walletAddresses.account!.id);
    } else {
      final output = outputs.first;
      final address = output.isParsedAddress
          ? output.extractedAddress
          : output.address;
      final amount = output.sendAll
          ? null
          : output.cryptoAmount!.replaceAll(',', '.');
      final formattedAmount = output.sendAll
          ? null
          : output.formattedCryptoAmount;

      if ((formattedAmount != null && unlockedBalance < formattedAmount) ||
          (formattedAmount == null && unlockedBalance <= 0)) {
        final formattedBalance = wowneroAmountToString(amount: unlockedBalance);

        throw WowneroTransactionCreationException(
            'You do not have enough unlocked balance. Unlocked: $formattedBalance. Transaction amount: ${output.cryptoAmount}.');
      }

      pendingTransactionDescription =
      await transaction_history.createTransaction(
          address: address!,
          amount: amount,
          priorityRaw: _credentials.priority.serialize(),
          accountIndex: walletAddresses.account!.id);
    }

    return PendingWowneroTransaction(pendingTransactionDescription);
  }

  @override
  int calculateEstimatedFee(TransactionPriority priority, int? amount) {
    // FIXME: hardcoded value;

    if (priority is MoneroTransactionPriority) {
      switch (priority) {
        case MoneroTransactionPriority.slow:
          return 24590000;
        case MoneroTransactionPriority.automatic:
          return 123050000;
        case MoneroTransactionPriority.medium:
          return 245029999;
        case MoneroTransactionPriority.fast:
          return 614530000;
        case MoneroTransactionPriority.fastest:
          return 26021600000;
      }
    }

    return 0;
  }

  @override
  Future<void> save() async {
    await walletAddresses.updateAddressesInBox();
    await backupWalletFiles(name);
    await wownero_wallet.store();
  }

  @override
  Future<void> changePassword(String password) async {
    wownero_wallet.setPasswordSync(password);
  }

  Future<int> getNodeHeight() async => wownero_wallet.getNodeHeight();

  int getSeedHeight(String seed) => wownero_wallet.getSeedHeightSync(seed);

  Future<bool> isConnected() async => wownero_wallet.isConnected();

  Future<void> setAsRecovered() async {
    walletInfo.isRecovery = false;
    await walletInfo.save();
  }

  @override
  Future<void> rescan({required int height}) async {
    walletInfo.restoreHeight = height;
    walletInfo.isRecovery = true;
    wownero_wallet.setRefreshFromBlockHeight(height: height);
    wownero_wallet.rescanBlockchainAsync();
    await startSync();
    _askForUpdateBalance();
    walletAddresses.accountList.update();
    await _askForUpdateTransactionHistory();
    await save();
    await walletInfo.save();
  }

  String getTransactionAddress(int accountIndex, int addressIndex) =>
      wownero_wallet.getAddress(
          accountIndex: accountIndex,
          addressIndex: addressIndex);

  @override
  Future<Map<String, WowneroTransactionInfo>> fetchTransactions() async {
    wownero_transaction_history.refreshTransactions();
    return _getAllTransactions(null).fold<Map<String, WowneroTransactionInfo>>(
        <String, WowneroTransactionInfo>{},
        (Map<String, WowneroTransactionInfo> acc, WowneroTransactionInfo tx) {
      acc[tx.id] = tx;
      return acc;
    });
  }

  Future<void> updateTransactions() async {
    try {
      if (_isTransactionUpdating) {
        return;
      }

      _isTransactionUpdating = true;
      final transactions = await fetchTransactions();
      transactionHistory.addMany(transactions);
      await transactionHistory.save();
      _isTransactionUpdating = false;
    } catch (e) {
      print(e);
      _isTransactionUpdating = false;
    }
  }

  String getSubaddressLabel(int accountIndex, int addressIndex) {
    return wownero_wallet.getSubaddressLabel(accountIndex, addressIndex);
  }

  List<WowneroTransactionInfo> _getAllTransactions(dynamic _) =>
      wownero_transaction_history
          .getAllTransations()
          .map((row) => WowneroTransactionInfo.fromRow(row))
          .toList();

  void _setListeners() {
    _listener?.stop();
    _listener = wownero_wallet.setListeners(_onNewBlock, _onNewTransaction);
  }

  void _setInitialHeight() {
    if (walletInfo.isRecovery) {
      return;
    }

    final currentHeight = getCurrentHeight();

    if (currentHeight <= 1) {
      final height = _getHeightByDate(walletInfo.date);
      wownero_wallet.setRecoveringFromSeed(isRecovery: true);
      wownero_wallet.setRefreshFromBlockHeight(height: height);
    }
  }

  int _getHeightDistance(DateTime date) {
    final distance =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    final distance_sec = distance / 1000;
    final daysTmp = (distance_sec / 86400).round();
    final days = daysTmp < 1 ? 1 : daysTmp;

    return days * 2000;
  }

  int _getHeightByDate(DateTime date) {
    final nodeHeight = wownero_wallet.getNodeHeightSync();
    final heightDistance = _getHeightDistance(date);

    if (nodeHeight <= 0) {
      return 0;
    }

    return nodeHeight - heightDistance;
  }

  void _askForUpdateBalance() {
    final unlockedBalance = _getUnlockedBalance();
    final fullBalance = _getFullBalance();

    if (balance[currency]!.fullBalance != fullBalance ||
        balance[currency]!.unlockedBalance != unlockedBalance) {
      balance[currency] = WowneroBalance(
          fullBalance: fullBalance, unlockedBalance: unlockedBalance);
    }
  }

  Future<void> _askForUpdateTransactionHistory() async =>
      await updateTransactions();

  int _getFullBalance() =>
      wownero_wallet.getFullBalance(accountIndex: walletAddresses.account!.id);

  int _getUnlockedBalance() =>
      wownero_wallet.getUnlockedBalance(accountIndex: walletAddresses.account!.id);

  void _onNewBlock(int height, int blocksLeft, double ptc) async {
    try {
      if (walletInfo.isRecovery) {
        await _askForUpdateTransactionHistory();
        _askForUpdateBalance();
        walletAddresses.accountList.update();
      }

      if (blocksLeft < 100) {
        await _askForUpdateTransactionHistory();
        _askForUpdateBalance();
        walletAddresses.accountList.update();
        syncStatus = SyncedSyncStatus();

        if (!_hasSyncAfterStartup) {
           _hasSyncAfterStartup = true;
           await save();
         }

        if (walletInfo.isRecovery) {
          await setAsRecovered();
        }
      } else {
        syncStatus = SyncingSyncStatus(blocksLeft, ptc);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _onNewTransaction() async {
    try {
      await _askForUpdateTransactionHistory();
      _askForUpdateBalance();
      await Future<void>.delayed(Duration(seconds: 1));
    } catch (e) {
      print(e.toString());
    }
  }
}
