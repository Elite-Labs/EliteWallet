import 'dart:io';

const bitcoinOutputPath = 'lib/bitcoin/bitcoin.dart';
const moneroOutputPath = 'lib/monero/monero.dart';
const havenOutputPath = 'lib/haven/haven.dart';
const wowneroOutputPath = 'lib/wownero/wownero.dart';
const ethereumOutputPath = 'lib/ethereum/ethereum.dart';
const bitcoinCashOutputPath = 'lib/bitcoin_cash/bitcoin_cash.dart';
const nanoOutputPath = 'lib/nano/nano.dart';
const polygonOutputPath = 'lib/polygon/polygon.dart';
const solanaOutputPath = 'lib/solana/solana.dart';
const walletTypesPath = 'lib/wallet_types.g.dart';
const pubspecDefaultPath = 'pubspec_default.yaml';
const pubspecOutputPath = 'pubspec.yaml';

Future<void> main(List<String> args) async {
  const prefix = '--';
  final hasBitcoin = args.contains('${prefix}bitcoin');
  final hasMonero = args.contains('${prefix}monero');
  final hasHaven = args.contains('${prefix}haven');
  final hasWownero = args.contains('${prefix}wownero');
  final hasEthereum = args.contains('${prefix}ethereum');
  final hasBitcoinCash = args.contains('${prefix}bitcoinCash');
  final hasNano = args.contains('${prefix}nano');
  final hasBanano = args.contains('${prefix}banano');
  final hasPolygon = args.contains('${prefix}polygon');
  final hasSolana = args.contains('${prefix}solana');

  await generateBitcoin(hasBitcoin);
  await generateMonero(hasMonero);
  await generateHaven(hasHaven);
  await generateWownero(hasWownero);
  await generateEthereum(hasEthereum);
  await generateBitcoinCash(hasBitcoinCash);
  await generateNano(hasNano);
  await generatePolygon(hasPolygon);
  await generateSolana(hasSolana);
  // await generateBanano(hasEthereum);

  await generatePubspec(
    hasMonero: hasMonero,
    hasBitcoin: hasBitcoin,
    hasHaven: hasHaven,
    hasWownero: hasWownero,
    hasEthereum: hasEthereum,
    hasNano: hasNano,
    hasBanano: hasBanano,
    hasBitcoinCash: hasBitcoinCash,
    hasPolygon: hasPolygon,
    hasSolana: hasSolana,
  );
  await generateWalletTypes(
    hasMonero: hasMonero,
    hasBitcoin: hasBitcoin,
    hasHaven: hasHaven,
    hasWownero: hasWownero,
    hasEthereum: hasEthereum,
    hasNano: hasNano,
    hasBanano: hasBanano,
    hasBitcoinCash: hasBitcoinCash,
    hasPolygon: hasPolygon,
    hasSolana: hasSolana,
  );
}

Future<void> generateBitcoin(bool hasImplementation) async {
  final outputFile = File(bitcoinOutputPath);
  const bitcoinCommonHeaders = """
import 'package:ew_core/receive_page_option.dart';
import 'package:ew_core/unspent_transaction_output.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/unspent_coins_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:hive/hive.dart';
import 'package:bitcoin_base/bitcoin_base.dart';""";
  const bitcoinEWHeaders = """
import 'package:ew_bitcoin/bitcoin_receive_page_option.dart';
import 'package:ew_bitcoin/electrum_wallet.dart';
import 'package:ew_bitcoin/bitcoin_unspent.dart';
import 'package:ew_bitcoin/bitcoin_mnemonic.dart';
import 'package:ew_bitcoin/bitcoin_transaction_priority.dart';
import 'package:ew_bitcoin/bitcoin_wallet_service.dart';
import 'package:ew_bitcoin/bitcoin_wallet_creation_credentials.dart';
import 'package:ew_bitcoin/bitcoin_amount_format.dart';
import 'package:ew_bitcoin/bitcoin_address_record.dart';
import 'package:ew_bitcoin/bitcoin_transaction_credentials.dart';
import 'package:ew_bitcoin/litecoin_wallet_service.dart';
import 'package:mobx/mobx.dart';
""";
  const bitcoinEWPart = "part 'ew_bitcoin.dart';";
  const bitcoinContent = """
  
  class ElectrumSubAddress {
  ElectrumSubAddress({
    required this.id,
    required this.name,
    required this.address,
    required this.txCount,
    required this.balance,
    required this.isChange});
  final int id;
  final String name;
  final String address;
  final int txCount;
  final int balance;
  final bool isChange;
}

abstract class Bitcoin {
  TransactionPriority getMediumTransactionPriority();

  WalletCredentials createBitcoinRestoreWalletFromSeedCredentials({required String name, required String mnemonic, required String password});
  WalletCredentials createBitcoinRestoreWalletFromWIFCredentials({required String name, required String password, required String wif, WalletInfo? walletInfo});
  WalletCredentials createBitcoinNewWalletCredentials({required String name, WalletInfo? walletInfo});
  List<String> getWordList();
  Map<String, String> getWalletKeys(Object wallet);
  List<TransactionPriority> getTransactionPriorities();
  List<TransactionPriority> getLitecoinTransactionPriorities();
  TransactionPriority deserializeBitcoinTransactionPriority(int raw);
  TransactionPriority deserializeLitecoinTransactionPriority(int raw);
  int getFeeRate(Object wallet, TransactionPriority priority);
  Future<void> generateNewAddress(Object wallet, String label);
  Future<void> updateAddress(Object wallet,String address, String label);
  Object createBitcoinTransactionCredentials(List<Output> outputs, {required TransactionPriority priority, int? feeRate});
  Object createBitcoinTransactionCredentialsRaw(List<OutputInfo> outputs, {TransactionPriority? priority, required int feeRate});

  List<String> getAddresses(Object wallet);
  String getAddress(Object wallet);

  Future<int> estimateFakeSendAllTxAmount(Object wallet, TransactionPriority priority);
  List<ElectrumSubAddress> getSubAddresses(Object wallet);

  String formatterBitcoinAmountToString({required int amount});
  double formatterBitcoinAmountToDouble({required int amount});
  int formatterStringDoubleToBitcoinAmount(String amount);
  String bitcoinTransactionPriorityWithLabel(TransactionPriority priority, int rate);

  List<Unspent> getUnspents(Object wallet);
  Future<void> updateUnspents(Object wallet);
  WalletService createBitcoinWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  WalletService createLitecoinWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  TransactionPriority getBitcoinTransactionPriorityMedium();
  TransactionPriority getLitecoinTransactionPriorityMedium();
  TransactionPriority getBitcoinTransactionPrioritySlow();
  TransactionPriority getLitecoinTransactionPrioritySlow();

  Future<void> setAddressType(Object wallet, dynamic option);
  ReceivePageOption getSelectedAddressType(Object wallet);
  List<ReceivePageOption> getBitcoinReceivePageOptions();
  BitcoinAddressType getBitcoinAddressType(ReceivePageOption option);
}
  """;

  const bitcoinEmptyDefinition = 'Bitcoin? bitcoin;\n';
  const bitcoinEWDefinition = 'Bitcoin? bitcoin = EWBitcoin();\n';

  final output = '$bitcoinCommonHeaders\n' +
      (hasImplementation ? '$bitcoinEWHeaders\n' : '\n') +
      (hasImplementation ? '$bitcoinEWPart\n\n' : '\n') +
      (hasImplementation ? bitcoinEWDefinition : bitcoinEmptyDefinition) +
      '\n' +
      bitcoinContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateMonero(bool hasImplementation) async {
  final outputFile = File(moneroOutputPath);
  const moneroCommonHeaders = """
import 'package:ew_core/unspent_transaction_output.dart';
import 'package:ew_core/unspent_coins_info.dart';
import 'package:ew_monero/monero_unspent.dart';
import 'package:mobx/mobx.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/output_info.dart';
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:polyseed/polyseed.dart';""";
  const moneroEWHeaders = """
import 'package:ew_core/get_height_by_date.dart';
import 'package:ew_core/monero_amount_format.dart';
import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_monero/monero_wallet_service.dart';
import 'package:ew_monero/monero_wallet.dart';
import 'package:ew_monero/monero_transaction_info.dart';
import 'package:ew_monero/monero_transaction_creation_credentials.dart';
import 'package:ew_core/account.dart' as monero_account;
import 'package:ew_monero/api/wallet.dart' as monero_wallet_api;
import 'package:ew_monero/mnemonics/english.dart';
import 'package:ew_monero/mnemonics/chinese_simplified.dart';
import 'package:ew_monero/mnemonics/dutch.dart';
import 'package:ew_monero/mnemonics/german.dart';
import 'package:ew_monero/mnemonics/japanese.dart';
import 'package:ew_monero/mnemonics/russian.dart';
import 'package:ew_monero/mnemonics/spanish.dart';
import 'package:ew_monero/mnemonics/portuguese.dart';
import 'package:ew_monero/mnemonics/french.dart';
import 'package:ew_monero/mnemonics/italian.dart';
import 'package:ew_monero/pending_monero_transaction.dart';
""";
  const moneroEWPart = "part 'ew_monero.dart';";
  const moneroContent = """
class Account {
  Account({required this.id, required this.label, this.balance});
  final int id;
  final String label;
  final String? balance;
}

class Subaddress {
  Subaddress({
    required this.id,
    required this.label,
    required this.address});
  final int id;
  final String label;
  final String address;
}

class MoneroBalance extends Balance {
  MoneroBalance({required this.fullBalance, required this.unlockedBalance})
      : formattedFullBalance = monero!.formatterMoneroAmountToString(amount: fullBalance),
        formattedUnlockedBalance =
            monero!.formatterMoneroAmountToString(amount: unlockedBalance),
        super(unlockedBalance, fullBalance);

  MoneroBalance.fromString(
      {required this.formattedFullBalance,
      required this.formattedUnlockedBalance})
      : fullBalance = monero!.formatterMoneroParseAmount(amount: formattedFullBalance),
        unlockedBalance = monero!.formatterMoneroParseAmount(amount: formattedUnlockedBalance),
        super(monero!.formatterMoneroParseAmount(amount: formattedUnlockedBalance),
            monero!.formatterMoneroParseAmount(amount: formattedFullBalance));

  final int fullBalance;
  final int unlockedBalance;
  final String formattedFullBalance;
  final String formattedUnlockedBalance;

  @override
  String get formattedAvailableBalance => formattedUnlockedBalance;

  @override
  String get formattedAdditionalBalance => formattedFullBalance;
}

abstract class MoneroWalletDetails {
  @observable
  late Account account;

  @observable
  late MoneroBalance balance;
}

abstract class Monero {
  MoneroAccountList getAccountList(Object wallet);
  
  MoneroSubaddressList getSubaddressList(Object wallet);

  TransactionHistoryBase getTransactionHistory(Object wallet);

  MoneroWalletDetails getMoneroWalletDetails(Object wallet);

  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex);

  String getSubaddressLabel(Object wallet, int accountIndex, int addressIndex);

  int getHeightByDate({required DateTime date});
  int getCurrentHeight();
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority getMoneroTransactionPrioritySlow();
  TransactionPriority getMoneroTransactionPriorityAutomatic();
  TransactionPriority deserializeMoneroTransactionPriority({required int raw});
  List<TransactionPriority> getTransactionPriorities();
  List<String> getMoneroWordList(String language);
  
  List<Unspent> getUnspents(Object wallet);
  Future<void> updateUnspents(Object wallet);

  WalletCredentials createMoneroRestoreWalletFromKeysCredentials({
    required String name,
    required String spendKey,
    required String viewKey,
    required String address,
    required String password,
    required String language,
    required int height});
  WalletCredentials createMoneroRestoreWalletFromSeedCredentials({required String name, required String password, required int height, required String mnemonic});
  WalletCredentials createMoneroNewWalletCredentials({required String name, required String language, required bool isPolyseed, String password});
  Map<String, String> getKeys(Object wallet);
  Object createMoneroTransactionCreationCredentials({required List<Output> outputs, required TransactionPriority priority});
  Object createMoneroTransactionCreationCredentialsRaw({required List<OutputInfo> outputs, required TransactionPriority priority});
  String formatterMoneroAmountToString({required int amount});
  double formatterMoneroAmountToDouble({required int amount});
  int formatterMoneroParseAmount({required String amount});
  Account getCurrentAccount(Object wallet);
  void setCurrentAccount(Object wallet, int id, String label, String? balance);
  void onStartup();
  int getTransactionInfoAccountId(TransactionInfo tx);
  WalletService createMoneroWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  Map<String, String> pendingTransactionInfo(Object transaction);
}

abstract class MoneroSubaddressList {
  ObservableList<Subaddress> get subaddresses;
  void update(Object wallet, {required int accountIndex});
  void refresh(Object wallet, {required int accountIndex});
  List<Subaddress> getAll(Object wallet);
  Future<void> addSubaddress(Object wallet, {required int accountIndex, required String label});
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label});
}

abstract class MoneroAccountList {
  ObservableList<Account> get accounts;
  void update(Object wallet);
  void refresh(Object wallet);
  List<Account> getAll(Object wallet);
  Future<void> addAccount(Object wallet, {required String label});
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label});
}
  """;

  const moneroEmptyDefinition = 'Monero? monero;\n';
  const moneroEWDefinition = 'Monero? monero = EWMonero();\n';

  final output = '$moneroCommonHeaders\n' +
      (hasImplementation ? '$moneroEWHeaders\n' : '\n') +
      (hasImplementation ? '$moneroEWPart\n\n' : '\n') +
      (hasImplementation ? moneroEWDefinition : moneroEmptyDefinition) +
      '\n' +
      moneroContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateHaven(bool hasImplementation) async {
  final outputFile = File(havenOutputPath);
  const havenCommonHeaders = """
import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/output_info.dart';
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:ew_core/crypto_currency.dart';""";
  const havenEWHeaders = """
import 'package:ew_core/get_height_by_date.dart';
import 'package:ew_core/monero_amount_format.dart';
import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_haven/haven_wallet_service.dart';
import 'package:ew_haven/haven_wallet.dart';
import 'package:ew_haven/haven_transaction_info.dart';
import 'package:ew_haven/haven_transaction_history.dart';
import 'package:ew_core/account.dart' as monero_account;
import 'package:ew_haven/api/wallet.dart' as monero_wallet_api;
import 'package:ew_haven/mnemonics/english.dart';
import 'package:ew_haven/mnemonics/chinese_simplified.dart';
import 'package:ew_haven/mnemonics/dutch.dart';
import 'package:ew_haven/mnemonics/german.dart';
import 'package:ew_haven/mnemonics/japanese.dart';
import 'package:ew_haven/mnemonics/russian.dart';
import 'package:ew_haven/mnemonics/spanish.dart';
import 'package:ew_haven/mnemonics/portuguese.dart';
import 'package:ew_haven/mnemonics/french.dart';
import 'package:ew_haven/mnemonics/italian.dart';
import 'package:ew_haven/haven_transaction_creation_credentials.dart';
import 'package:ew_haven/api/balance_list.dart';
""";
  const havenEWPart = "part 'ew_haven.dart';";
  const havenContent = """
class Account {
  Account({required this.id, required this.label});
  final int id;
  final String label;
}

class Subaddress {
  Subaddress({
    required this.id,
    required this.label,
    required this.address});
  final int id;
  final String label;
  final String address;
}

class HavenBalance extends Balance {
  HavenBalance({required this.fullBalance, required this.unlockedBalance})
      : formattedFullBalance = haven!.formatterMoneroAmountToString(amount: fullBalance),
        formattedUnlockedBalance =
            haven!.formatterMoneroAmountToString(amount: unlockedBalance),
        super(unlockedBalance, fullBalance);

  HavenBalance.fromString(
      {required this.formattedFullBalance,
      required this.formattedUnlockedBalance})
      : fullBalance = haven!.formatterMoneroParseAmount(amount: formattedFullBalance),
        unlockedBalance = haven!.formatterMoneroParseAmount(amount: formattedUnlockedBalance),
        super(haven!.formatterMoneroParseAmount(amount: formattedUnlockedBalance),
            haven!.formatterMoneroParseAmount(amount: formattedFullBalance));

  final int fullBalance;
  final int unlockedBalance;
  final String formattedFullBalance;
  final String formattedUnlockedBalance;

  @override
  String get formattedAvailableBalance => formattedUnlockedBalance;

  @override
  String get formattedAdditionalBalance => formattedFullBalance;
}

class AssetRate {
  AssetRate(this.asset, this.rate);

  final String asset;
  final int rate;
}

abstract class HavenWalletDetails {
  // FIX-ME: it's abstract class
  @observable
  late Account account;
  // FIX-ME: it's abstract class
  @observable
  late HavenBalance balance;
}

abstract class Haven {
  HavenAccountList getAccountList(Object wallet);
  
  MoneroSubaddressList getSubaddressList(Object wallet);

  TransactionHistoryBase getTransactionHistory(Object wallet);

  HavenWalletDetails getMoneroWalletDetails(Object wallet);

  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex);

  int getHeightByDate({required DateTime date});
  Future<int> getCurrentHeight();
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority deserializeMoneroTransactionPriority({required int raw});
  List<TransactionPriority> getTransactionPriorities();
  List<String> getMoneroWordList(String language);

  WalletCredentials createHavenRestoreWalletFromKeysCredentials({
      required String name,
      required String spendKey,
      required String viewKey,
      required String address,
      required String password,
      required String language,
      required int height});
  WalletCredentials createHavenRestoreWalletFromSeedCredentials({required String name, required String password, required int height, required String mnemonic});
  WalletCredentials createHavenNewWalletCredentials({required String name, required String language, String password});
  Map<String, String> getKeys(Object wallet);
  Object createHavenTransactionCreationCredentials({required List<Output> outputs, required TransactionPriority priority, required String assetType});
  String formatterMoneroAmountToString({required int amount});
  double formatterMoneroAmountToDouble({required int amount});
  int formatterMoneroParseAmount({required String amount});
  Account getCurrentAccount(Object wallet);
  void setCurrentAccount(Object wallet, int id, String label);
  void onStartup();
  int getTransactionInfoAccountId(TransactionInfo tx);
  WalletService createHavenWalletService(Box<WalletInfo> walletInfoSource);
  CryptoCurrency assetOfTransaction(TransactionInfo tx);
  List<AssetRate> getAssetRate();
}

abstract class MoneroSubaddressList {
  ObservableList<Subaddress> get subaddresses;
  void update(Object wallet, {required int accountIndex});
  void refresh(Object wallet, {required int accountIndex});
  List<Subaddress> getAll(Object wallet);
  Future<void> addSubaddress(Object wallet, {required int accountIndex, required String label});
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label});
}

abstract class HavenAccountList {
  ObservableList<Account> get accounts;
  void update(Object wallet);
  void refresh(Object wallet);
  List<Account> getAll(Object wallet);
  Future<void> addAccount(Object wallet, {required String label});
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label});
}
  """;

  const havenEmptyDefinition = 'Haven? haven;\n';
  const havenEWDefinition = 'Haven? haven = EWHaven();\n';

  final output = '$havenCommonHeaders\n' +
      (hasImplementation ? '$havenEWHeaders\n' : '\n') +
      (hasImplementation ? '$havenEWPart\n\n' : '\n') +
      (hasImplementation ? havenEWDefinition : havenEmptyDefinition) +
      '\n' +
      havenContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateWownero(bool hasImplementation) async {
  final outputFile = File(wowneroOutputPath);
  const wowneroCommonHeaders = """
import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/balance.dart';
import 'package:ew_core/output_info.dart';
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';""";
  const wowneroEWHeaders = """
import 'package:ew_core/get_height_by_date.dart';
import 'package:ew_core/monero_amount_format.dart';
import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_wownero/wownero_amount_format.dart';
import 'package:ew_wownero/wownero_wallet_service.dart';
import 'package:ew_wownero/wownero_wallet.dart';
import 'package:ew_wownero/wownero_transaction_info.dart';
import 'package:ew_wownero/wownero_transaction_history.dart';
import 'package:ew_wownero/wownero_transaction_creation_credentials.dart';
import 'package:ew_core/account.dart' as wownero_account;
import 'package:ew_wownero/api/wallet.dart' as wownero_wallet_api;
import 'package:ew_wownero/mnemonics/english.dart';
""";
  const wowneroEWPart = "part 'ew_wownero.dart';";
  const wowneroContent = """
class Account {
  Account({required this.id, required this.label});
  final int id;
  final String label;
}

class Subaddress {
  Subaddress({
    required this.id,
    required this.label,
    required this.address});
  final int id;
  final String label;
  final String address;
}

class WowneroBalance extends Balance {
  WowneroBalance({required this.fullBalance, required this.unlockedBalance})
      : formattedFullBalance = wownero!.formatterWowneroAmountToString(amount: fullBalance),
        formattedUnlockedBalance =
            wownero!.formatterWowneroAmountToString(amount: unlockedBalance),
        super(unlockedBalance, fullBalance);

  WowneroBalance.fromString(
      {required this.formattedFullBalance,
      required this.formattedUnlockedBalance})
      : fullBalance = wownero!.formatterWowneroParseAmount(amount: formattedFullBalance),
        unlockedBalance = wownero!.formatterWowneroParseAmount(amount: formattedUnlockedBalance),
        super(wownero!.formatterWowneroParseAmount(amount: formattedUnlockedBalance),
            wownero!.formatterWowneroParseAmount(amount: formattedFullBalance));

  final int fullBalance;
  final int unlockedBalance;
  final String formattedFullBalance;
  final String formattedUnlockedBalance;

  @override
  String get formattedAvailableBalance => formattedUnlockedBalance;

  @override
  String get formattedAdditionalBalance => formattedFullBalance;
}

abstract class WowneroWalletDetails {
  @observable
  late Account account;

  @observable
  late WowneroBalance balance;
}

abstract class Wownero {
  WowneroAccountList getAccountList(Object wallet);
  
  WowneroSubaddressList getSubaddressList(Object wallet);

  TransactionHistoryBase getTransactionHistory(Object wallet);

  WowneroWalletDetails getWowneroWalletDetails(Object wallet);

  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex);

  int getHeightByDate({required DateTime date});
  int getCurrentHeight();

  String getSubaddressLabel(Object wallet, int accountIndex, int addressIndex);

  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority deserializeMoneroTransactionPriority({required int raw});
  List<TransactionPriority> getTransactionPriorities();
  List<String> getWowneroWordList(String language);

  WalletCredentials createWowneroRestoreWalletFromKeysCredentials({
    required String name,
    required String spendKey,
    required String viewKey,
    required String address,
    required String password,
    required String language,
    required int height});
  WalletCredentials createWowneroRestoreWalletFromSeedCredentials({required String name, required String password, required int height, required String mnemonic});
  WalletCredentials createWowneroNewWalletCredentials({required String name, required String language, String password,});
  Map<String, String> getKeys(Object wallet);
  Object createWowneroTransactionCreationCredentials({required List<Output> outputs, required TransactionPriority priority});
  String formatterWowneroAmountToString({required int amount});
  double formatterWowneroAmountToDouble({required int amount});
  int formatterWowneroParseAmount({required String amount});
  Account getCurrentAccount(Object wallet);
  void setCurrentAccount(Object wallet, int id, String label);
  void onStartup();
  int getTransactionInfoAccountId(TransactionInfo tx);
  WalletService createWowneroWalletService(Box<WalletInfo> walletInfoSource);
}

abstract class WowneroSubaddressList {
  ObservableList<Subaddress> get subaddresses;
  void update(Object wallet, {required int accountIndex});
  void refresh(Object wallet, {required int accountIndex});
  List<Subaddress> getAll(Object wallet);
  Future<void> addSubaddress(Object wallet, {required int accountIndex, required String label});
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label});
}

abstract class WowneroAccountList {
  ObservableList<Account> get accounts;
  void update(Object wallet);
  void refresh(Object wallet);
  List<Account> getAll(Object wallet);
  Future<void> addAccount(Object wallet, {required String label});
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label});
}
  """;

  const wowneroEmptyDefinition = 'Wownero? wownero;\n';
  const wowneroEWDefinition = 'Wownero? wownero = EWWownero();\n';

  final output = '$wowneroCommonHeaders\n' +
      (hasImplementation ? '$wowneroEWHeaders\n' : '\n') +
      (hasImplementation ? '$wowneroEWPart\n\n' : '\n') +
      (hasImplementation ? wowneroEWDefinition : wowneroEmptyDefinition) +
      '\n' +
      wowneroContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateEthereum(bool hasImplementation) async {
  final outputFile = File(ethereumOutputPath);
  const ethereumCommonHeaders = """
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/erc20_token.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';

""";
  const ethereumEWHeaders = """
import 'package:ew_evm/evm_chain_formatter.dart';
import 'package:ew_evm/evm_chain_mnemonics.dart';
import 'package:ew_evm/evm_chain_transaction_credentials.dart';
import 'package:ew_evm/evm_chain_transaction_info.dart';
import 'package:ew_evm/evm_chain_transaction_priority.dart';
import 'package:ew_evm/evm_chain_wallet_creation_credentials.dart';

import 'package:ew_ethereum/ethereum_client.dart';
import 'package:ew_ethereum/ethereum_wallet.dart';
import 'package:ew_ethereum/ethereum_wallet_service.dart';

import 'package:eth_sig_util/util/utils.dart';

""";
  const ethereumEWPart = "part 'ew_ethereum.dart';";
  const ethereumContent = """
abstract class Ethereum {
  List<String> getEthereumWordList(String language);
  WalletService createEthereumWalletService(Box<WalletInfo> walletInfoSource);
  WalletCredentials createEthereumNewWalletCredentials({required String name, WalletInfo? walletInfo});
  WalletCredentials createEthereumRestoreWalletFromSeedCredentials({required String name, required String mnemonic, required String password});
  WalletCredentials createEthereumRestoreWalletFromPrivateKey({required String name, required String privateKey, required String password});
  String getAddress(WalletBase wallet);
  String getPrivateKey(WalletBase wallet);
  String getPublicKey(WalletBase wallet);
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority getEthereumTransactionPrioritySlow();
  List<TransactionPriority> getTransactionPriorities();
  TransactionPriority deserializeEthereumTransactionPriority(int raw);

  Object createEthereumTransactionCredentials(
    List<Output> outputs, {
    required TransactionPriority priority,
    required CryptoCurrency currency,
    int? feeRate,
  });

  Object createEthereumTransactionCredentialsRaw(
    List<OutputInfo> outputs, {
    TransactionPriority? priority,
    required CryptoCurrency currency,
    required int feeRate,
  });

  int formatterEthereumParseAmount(String amount);
  double formatterEthereumAmountToDouble({TransactionInfo? transaction, BigInt? amount, int exponent = 18});
  List<Erc20Token> getERC20Currencies(WalletBase wallet);
  Future<void> addErc20Token(WalletBase wallet, CryptoCurrency token);
  Future<void> deleteErc20Token(WalletBase wallet, CryptoCurrency token);
  Future<Erc20Token?> getErc20Token(WalletBase wallet, String contractAddress);
  
  CryptoCurrency assetOfTransaction(WalletBase wallet, TransactionInfo transaction);
  void updateEtherscanUsageState(WalletBase wallet, bool isEnabled);
  Web3Client? getWeb3Client(WalletBase wallet);
  String getTokenAddress(CryptoCurrency asset);
}
  """;

  const ethereumEmptyDefinition = 'Ethereum? ethereum;\n';
  const ethereumEWDefinition = 'Ethereum? ethereum = EWEthereum();\n';

  final output = '$ethereumCommonHeaders\n' +
      (hasImplementation ? '$ethereumEWHeaders\n' : '\n') +
      (hasImplementation ? '$ethereumEWPart\n\n' : '\n') +
      (hasImplementation ? ethereumEWDefinition : ethereumEmptyDefinition) +
      '\n' +
      ethereumContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generatePolygon(bool hasImplementation) async {
  final outputFile = File(polygonOutputPath);
  const polygonCommonHeaders = """
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/erc20_token.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';

""";
  const polygonEWHeaders = """
import 'package:ew_evm/evm_chain_formatter.dart';
import 'package:ew_evm/evm_chain_mnemonics.dart';
import 'package:ew_evm/evm_chain_transaction_info.dart';
import 'package:ew_evm/evm_chain_transaction_priority.dart';
import 'package:ew_evm/evm_chain_transaction_credentials.dart';
import 'package:ew_evm/evm_chain_wallet_creation_credentials.dart';

import 'package:ew_polygon/polygon_client.dart';
import 'package:ew_polygon/polygon_wallet.dart';
import 'package:ew_polygon/polygon_wallet_service.dart';

import 'package:eth_sig_util/util/utils.dart';

""";
  const polygonEWPart = "part 'ew_polygon.dart';";
  const polygonContent = """
abstract class Polygon {
  List<String> getPolygonWordList(String language);
  WalletService createPolygonWalletService(Box<WalletInfo> walletInfoSource);
  WalletCredentials createPolygonNewWalletCredentials({required String name, WalletInfo? walletInfo});
  WalletCredentials createPolygonRestoreWalletFromSeedCredentials({required String name, required String mnemonic, required String password});
  WalletCredentials createPolygonRestoreWalletFromPrivateKey({required String name, required String privateKey, required String password});
  String getAddress(WalletBase wallet);
  String getPrivateKey(WalletBase wallet);
  String getPublicKey(WalletBase wallet);
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority getPolygonTransactionPrioritySlow();
  List<TransactionPriority> getTransactionPriorities();
  TransactionPriority deserializePolygonTransactionPriority(int raw);

  Object createPolygonTransactionCredentials(
    List<Output> outputs, {
    required TransactionPriority priority,
    required CryptoCurrency currency,
    int? feeRate,
  });

  Object createPolygonTransactionCredentialsRaw(
    List<OutputInfo> outputs, {
    TransactionPriority? priority,
    required CryptoCurrency currency,
    required int feeRate,
  });

  int formatterPolygonParseAmount(String amount);
  double formatterPolygonAmountToDouble({TransactionInfo? transaction, BigInt? amount, int exponent = 18});
  List<Erc20Token> getERC20Currencies(WalletBase wallet);
  Future<void> addErc20Token(WalletBase wallet, CryptoCurrency token);
  Future<void> deleteErc20Token(WalletBase wallet, CryptoCurrency token);
  Future<Erc20Token?> getErc20Token(WalletBase wallet, String contractAddress);
  
  CryptoCurrency assetOfTransaction(WalletBase wallet, TransactionInfo transaction);
  void updatePolygonScanUsageState(WalletBase wallet, bool isEnabled);
  Web3Client? getWeb3Client(WalletBase wallet);
  String getTokenAddress(CryptoCurrency asset);
}
  """;

  const polygonEmptyDefinition = 'Polygon? polygon;\n';
  const polygonEWDefinition = 'Polygon? polygon = EWPolygon();\n';

  final output = '$polygonCommonHeaders\n' +
      (hasImplementation ? '$polygonEWHeaders\n' : '\n') +
      (hasImplementation ? '$polygonEWPart\n\n' : '\n') +
      (hasImplementation ? polygonEWDefinition : polygonEmptyDefinition) +
      '\n' +
      polygonContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateBitcoinCash(bool hasImplementation) async {
  final outputFile = File(bitcoinCashOutputPath);
  const bitcoinCashCommonHeaders = """
import 'dart:typed_data';

import 'package:ew_core/unspent_transaction_output.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/unspent_coins_info.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
""";
  const bitcoinCashEWHeaders = """
import 'package:ew_bitcoin_cash/ew_bitcoin_cash.dart';
import 'package:ew_bitcoin/bitcoin_transaction_priority.dart';
""";
  const bitcoinCashEWPart = "part 'ew_bitcoin_cash.dart';";
  const bitcoinCashContent = """
abstract class BitcoinCash {
  String getCashAddrFormat(String address);

  WalletService createBitcoinCashWalletService(
      Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);

  WalletCredentials createBitcoinCashNewWalletCredentials(
      {required String name, WalletInfo? walletInfo});

  WalletCredentials createBitcoinCashRestoreWalletFromSeedCredentials(
      {required String name, required String mnemonic, required String password});

  TransactionPriority deserializeBitcoinCashTransactionPriority(int raw);

  TransactionPriority getDefaultTransactionPriority();

  List<TransactionPriority> getTransactionPriorities();
  
  TransactionPriority getBitcoinCashTransactionPrioritySlow();
}
  """;

  const bitcoinCashEmptyDefinition = 'BitcoinCash? bitcoinCash;\n';
  const bitcoinCashEWDefinition = 'BitcoinCash? bitcoinCash = EWBitcoinCash();\n';

  final output = '$bitcoinCashCommonHeaders\n' +
      (hasImplementation ? '$bitcoinCashEWHeaders\n' : '\n') +
      (hasImplementation ? '$bitcoinCashEWPart\n\n' : '\n') +
      (hasImplementation ? bitcoinCashEWDefinition : bitcoinCashEmptyDefinition) +
      '\n' +
      bitcoinCashContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateNano(bool hasImplementation) async {
  final outputFile = File(nanoOutputPath);
  const nanoCommonHeaders = """
import 'package:ew_core/elite_hive.dart';
import 'package:ew_core/nano_account.dart';
import 'package:ew_core/account.dart';
import 'package:ew_core/node.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/transaction_history.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/nano_account_info_response.dart';
import 'package:mobx/mobx.dart';
import 'package:hive/hive.dart';
import 'package:elite_wallet/view_model/send/output.dart';
""";
  const nanoEWHeaders = """
import 'package:ew_nano/nano_client.dart';
import 'package:ew_nano/nano_mnemonic.dart';
import 'package:ew_nano/nano_wallet.dart';
import 'package:ew_nano/nano_wallet_service.dart';
import 'package:ew_nano/nano_transaction_info.dart';
import 'package:ew_nano/nano_transaction_credentials.dart';
import 'package:ew_nano/nano_wallet_creation_credentials.dart';
// needed for nano_util:
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import "package:ed25519_hd_key/ed25519_hd_key.dart";
import 'package:libcrypto/libcrypto.dart';
import 'package:nanodart/nanodart.dart' as ND;
import 'package:nanoutil/nanoutil.dart';
""";
  const nanoEWPart = "part 'ew_nano.dart';";
  const nanoContent = """
abstract class Nano {
  NanoAccountList getAccountList(Object wallet);

  Account getCurrentAccount(Object wallet);

  void setCurrentAccount(Object wallet, int id, String label, String? balance);

  WalletService createNanoWalletService(Box<WalletInfo> walletInfoSource);

  WalletCredentials createNanoNewWalletCredentials({
    required String name,
    String password,
  });
  
  WalletCredentials createNanoRestoreWalletFromSeedCredentials({
    required String name,
    required String password,
    required String mnemonic,
    DerivationType? derivationType,
  });

  WalletCredentials createNanoRestoreWalletFromKeysCredentials({
    required String name,
    required String password,
    required String seedKey,
    DerivationType? derivationType,
  });

  List<String> getNanoWordList(String language);
  Map<String, String> getKeys(Object wallet);
  Object createNanoTransactionCredentials(List<Output> outputs);
  Future<void> changeRep(Object wallet, String address);
  Future<bool> updateTransactions(Object wallet);
  BigInt getTransactionAmountRaw(TransactionInfo transactionInfo);
  String getRepresentative(Object wallet);
}

abstract class NanoAccountList {
  ObservableList<NanoAccount> get accounts;
  void update(Object wallet);
  void refresh(Object wallet);
  Future<List<NanoAccount>> getAll(Object wallet);
  Future<void> addAccount(Object wallet, {required String label});
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label});
}

abstract class NanoUtil {
  bool isValidBip39Seed(String seed);
  static const int maxDecimalDigits = 6; // Max digits after decimal
  BigInt rawPerNano = BigInt.parse("1000000000000000000000000000000");
  BigInt rawPerNyano = BigInt.parse("1000000000000000000000000");
  BigInt rawPerBanano = BigInt.parse("100000000000000000000000000000");
  BigInt rawPerXMR = BigInt.parse("1000000000000");
  BigInt convertXMRtoNano = BigInt.parse("1000000000000000000");
  String getRawAsUsableString(String? raw, BigInt rawPerCur);
  String getRawAccuracy(String? raw, BigInt rawPerCur);
  String getAmountAsRaw(String amount, BigInt rawPerCur);

  // derivationInfo:
  Future<AccountInfoResponse?> getInfoFromSeedOrMnemonic(
    DerivationType derivationType, {
    String? seedKey,
    String? mnemonic,
    required Node node,
  });
  Future<List<DerivationType>> compareDerivationMethods({
    String? mnemonic,
    String? privateKey,
    required Node node,
  });
}
  """;

  const nanoEmptyDefinition = 'Nano? nano;\nNanoUtil? nanoUtil;\n';
  const nanoEWDefinition = 'Nano? nano = EWNano();\nNanoUtil? nanoUtil = EWNanoUtil();\n';

  final output = '$nanoCommonHeaders\n' +
      (hasImplementation ? '$nanoEWHeaders\n' : '\n') +
      (hasImplementation ? '$nanoEWPart\n\n' : '\n') +
      (hasImplementation ? nanoEWDefinition : nanoEmptyDefinition) +
      '\n' +
      nanoContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateSolana(bool hasImplementation) async {
  final outputFile = File(solanaOutputPath);
  const solanaCommonHeaders = """
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:hive/hive.dart';
import 'package:solana/solana.dart';

""";
  const solanaEWHeaders = """
import 'package:ew_solana/spl_token.dart';
import 'package:ew_solana/solana_wallet.dart';
import 'package:ew_solana/solana_mnemonics.dart';
import 'package:ew_solana/solana_wallet_service.dart';
import 'package:ew_solana/solana_transaction_info.dart';
import 'package:ew_solana/solana_transaction_credentials.dart';
import 'package:ew_solana/solana_wallet_creation_credentials.dart';
""";
  const solanaEwPart = "part 'ew_solana.dart';";
  const solanaContent = """
abstract class Solana {
  List<String> getSolanaWordList(String language);
  WalletService createSolanaWalletService(Box<WalletInfo> walletInfoSource);
  WalletCredentials createSolanaNewWalletCredentials(
      {required String name, WalletInfo? walletInfo});
  WalletCredentials createSolanaRestoreWalletFromSeedCredentials(
      {required String name, required String mnemonic, required String password});
  WalletCredentials createSolanaRestoreWalletFromPrivateKey(
      {required String name, required String privateKey, required String password});

  String getAddress(WalletBase wallet);
  String getPrivateKey(WalletBase wallet);
  String getPublicKey(WalletBase wallet);
  Ed25519HDKeyPair? getWalletKeyPair(WalletBase wallet);

  Object createSolanaTransactionCredentials(
    List<Output> outputs, {
    required CryptoCurrency currency,
  });

  Object createSolanaTransactionCredentialsRaw(
    List<OutputInfo> outputs, {
    required CryptoCurrency currency,
  });
  List<CryptoCurrency> getSPLTokenCurrencies(WalletBase wallet);
  Future<void> addSPLToken(WalletBase wallet, CryptoCurrency token);
  Future<void> deleteSPLToken(WalletBase wallet, CryptoCurrency token);
  Future<CryptoCurrency?> getSPLToken(WalletBase wallet, String contractAddress);

  CryptoCurrency assetOfTransaction(WalletBase wallet, TransactionInfo transaction);
  double getTransactionAmountRaw(TransactionInfo transactionInfo);
  String getTokenAddress(CryptoCurrency asset);
  List<int>? getValidationLength(CryptoCurrency type);
}

  """;

  const solanaEmptyDefinition = 'Solana? solana;\n';
  const solanaEWDefinition = 'Solana? solana = EWSolana();\n';

  final output = '$solanaCommonHeaders\n' +
      (hasImplementation ? '$solanaEWHeaders\n' : '\n') +
      (hasImplementation ? '$solanaEwPart\n\n' : '\n') +
      (hasImplementation ? solanaEWDefinition : solanaEmptyDefinition) +
      '\n' +
      solanaContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generatePubspec(
    {required bool hasMonero,
    required bool hasBitcoin,
    required bool hasHaven,
    required bool hasWownero,
    required bool hasEthereum,
    required bool hasNano,
    required bool hasBanano,
    required bool hasBitcoinCash,
    required bool hasPolygon,
    required bool hasSolana}) async {
  const ewCore = """
  ew_core:
    path: ./ew_core
    """;
  const ewMonero = """
  ew_monero:
    path: ./ew_monero
  """;
  const ewBitcoin = """
  ew_bitcoin:
    path: ./ew_bitcoin
  """;
  const ewHaven = """
  ew_haven:
    path: ./ew_haven
  """;
  const ewWownero = """
  ew_wownero:
    path: ./ew_wownero
  """;
  const ewSharedExternal = """
  ew_shared_external:
    path: ./ew_shared_external
  """;
  const ewEthereum = """
  ew_ethereum:
    path: ./ew_ethereum
  """;
  const ewBitcoinCash = """
  ew_bitcoin_cash:
    path: ./ew_bitcoin_cash
  """;
  const ewNano = """
  ew_nano:
    path: ./ew_nano
  """;
  const ewBanano = """
  ew_banano:
    path: ./ew_banano
  """;
  const ewPolygon = """
  ew_polygon:
    path: ./ew_polygon
  """;
  const ewSolana = """
  ew_solana:
    path: ./ew_solana
  """;
  const ewEVM = """
  ew_evm:
    path: ./ew_evm
    """;
  final inputFile = File(pubspecOutputPath);
  final inputText = await inputFile.readAsString();
  final inputLines = inputText.split('\n');
  final dependenciesIndex = inputLines.indexWhere((line) => line.toLowerCase() == 'dependencies:');
  var output = ewCore;

  if (hasMonero) {
    output += '\n$ewMonero\n$ewSharedExternal';
  }

  if (hasBitcoin) {
    output += '\n$ewBitcoin';
  }

  if (hasEthereum) {
    output += '\n$ewEthereum';
  }

  if (hasNano) {
    output += '\n$ewNano';
  }

  if (hasBanano) {
    output += '\n$ewBanano';
  }

  if (hasBitcoinCash) {
    output += '\n$ewBitcoinCash';
  }

  if (hasPolygon) {
    output += '\n$ewPolygon';
  }

  if (hasSolana) {
    output += '\n$ewSolana';
  }

  if (hasHaven && !hasMonero) {
    output += '\n$ewSharedExternal\n$ewHaven';
  } else if (hasHaven) {
    output += '\n$ewHaven';
  }

  if (hasWownero && !hasMonero) {
    output += '\n$ewSharedExternal\n$ewWownero';
  } else if (hasWownero) {
    output += '\n$ewWownero';
  }

  if (hasEthereum || hasPolygon) {
    output += '\n$ewEVM';
  }

  final outputLines = output.split('\n');
  inputLines.insertAll(dependenciesIndex + 1, outputLines);
  final outputContent = inputLines.join('\n');
  final outputFile = File(pubspecOutputPath);

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(outputContent);
}

Future<void> generateWalletTypes(
    {required bool hasMonero,
    required bool hasBitcoin,
    required bool hasHaven,
    required bool hasWownero,
    required bool hasEthereum,
    required bool hasNano,
    required bool hasBanano,
    required bool hasBitcoinCash,
    required bool hasPolygon,
    required bool hasSolana}) async {
  final walletTypesFile = File(walletTypesPath);

  if (walletTypesFile.existsSync()) {
    await walletTypesFile.delete();
  }

  const outputHeader = "import 'package:ew_core/wallet_type.dart';";
  const outputDefinition = 'final availableWalletTypes = <WalletType>[';
  var outputContent = outputHeader + '\n\n' + outputDefinition + '\n';

  if (hasMonero) {
    outputContent += '\tWalletType.monero,\n';
  }

  if (hasBitcoin) {
    outputContent += '\tWalletType.bitcoin,\n';
  }

  if (hasEthereum) {
    outputContent += '\tWalletType.ethereum,\n';
  }

  if (hasBitcoin) {
    outputContent += '\tWalletType.litecoin,\n';
  }

  if (hasBitcoinCash) {
    outputContent += '\tWalletType.bitcoinCash,\n';
  }

  if (hasPolygon) {
    outputContent += '\tWalletType.polygon,\n';
  }

  if (hasSolana) {
    outputContent += '\tWalletType.solana,\n';
  }

  if (hasNano) {
    outputContent += '\tWalletType.nano,\n';
  }

  if (hasBanano) {
    outputContent += '\tWalletType.banano,\n';
  }

  if (hasHaven) {
    outputContent += '\tWalletType.haven,\n';
  }

  if (hasWownero) {
    outputContent += '\tWalletType.wownero,\n';
  }

  outputContent += '];\n';
  await walletTypesFile.writeAsString(outputContent);
}
