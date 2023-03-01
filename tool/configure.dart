import 'dart:convert';
import 'dart:io';

const bitcoinOutputPath = 'lib/bitcoin/bitcoin.dart';
const moneroOutputPath = 'lib/monero/monero.dart';
const havenOutputPath = 'lib/haven/haven.dart';
const wowneroOutputPath = 'lib/wownero/wownero.dart';
const walletTypesPath = 'lib/wallet_types.g.dart';
const pubspecDefaultPath = 'pubspec_default.yaml';
const pubspecOutputPath = 'pubspec.yaml';

Future<void> main(List<String> args) async {
  const prefix = '--';
  final hasBitcoin = args.contains('${prefix}bitcoin');
  final hasMonero = args.contains('${prefix}monero');
  final hasHaven = args.contains('${prefix}haven');
  final hasWownero = args.contains('${prefix}wownero');
  await generateBitcoin(hasBitcoin);
  await generateMonero(hasMonero);
  await generateHaven(hasHaven);
  await generateWownero(hasWownero);
  await generatePubspec(hasMonero: hasMonero, hasBitcoin: hasBitcoin, hasHaven: hasHaven, hasWownero: hasWownero);
  await generateWalletTypes(hasMonero: hasMonero, hasBitcoin: hasBitcoin, hasHaven: hasHaven, hasWownero: hasWownero);
}

Future<void> generateBitcoin(bool hasImplementation) async {
  final outputFile = File(bitcoinOutputPath);
  const bitcoinCommonHeaders = """
import 'package:ew_core/wallet_credentials.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_core/unspent_coins_info.dart';
import 'package:ew_core/wallet_service.dart';
import 'package:elite_wallet/view_model/send/output.dart';
import 'package:hive/hive.dart';""";
  const bitcoinEWHeaders = """
import 'package:ew_bitcoin/electrum_wallet.dart';
import 'package:ew_bitcoin/bitcoin_unspent.dart';
import 'package:ew_bitcoin/bitcoin_mnemonic.dart';
import 'package:ew_bitcoin/bitcoin_transaction_priority.dart';
import 'package:ew_bitcoin/bitcoin_wallet.dart';
import 'package:ew_bitcoin/bitcoin_wallet_service.dart';
import 'package:ew_bitcoin/bitcoin_wallet_creation_credentials.dart';
import 'package:ew_bitcoin/bitcoin_amount_format.dart';
import 'package:ew_bitcoin/bitcoin_address_record.dart';
import 'package:ew_bitcoin/bitcoin_transaction_credentials.dart';
import 'package:ew_bitcoin/litecoin_wallet_service.dart';
""";
  const bitcoinEWPart = "part 'ew_bitcoin.dart';";
  const bitcoinContent = """
class Unspent {
  Unspent(this.address, this.hash, this.value, this.vout)
      : isSending = true,
        isFrozen = false,
        note = '';

  final String address;
  final String hash;
  final int value;
  final int vout;
  
  bool isSending;
  bool isFrozen;
  String note;

  bool get isP2wpkh => address.startsWith('bc') || address.startsWith('ltc');
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
  Future<void> generateNewAddress(Object wallet);
  Object createBitcoinTransactionCredentials(List<Output> outputs, {required TransactionPriority priority, int? feeRate});
  Object createBitcoinTransactionCredentialsRaw(List<OutputInfo> outputs, {TransactionPriority? priority, required int feeRate});

  List<String> getAddresses(Object wallet);
  String getAddress(Object wallet);

  String formatterBitcoinAmountToString({required int amount});
  double formatterBitcoinAmountToDouble({required int amount});
  int formatterStringDoubleToBitcoinAmount(String amount);
  String bitcoinTransactionPriorityWithLabel(TransactionPriority priority, int rate);

  List<Unspent> getUnspents(Object wallet);
  void updateUnspents(Object wallet);
  WalletService createBitcoinWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  WalletService createLitecoinWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  TransactionPriority getBitcoinTransactionPriorityMedium();
  TransactionPriority getLitecoinTransactionPriorityMedium();
  TransactionPriority getBitcoinTransactionPrioritySlow();
  TransactionPriority getLitecoinTransactionPrioritySlow();
}
  """;

  const bitcoinEmptyDefinition = 'Bitcoin? bitcoin;\n';
  const bitcoinEWDefinition = 'Bitcoin? bitcoin = EWBitcoin();\n';

  final output = '$bitcoinCommonHeaders\n'
    + (hasImplementation ? '$bitcoinEWHeaders\n' : '\n')
    + (hasImplementation ? '$bitcoinEWPart\n\n' : '\n')
    + (hasImplementation ? bitcoinEWDefinition : bitcoinEmptyDefinition)
    + '\n'
    + bitcoinContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generateMonero(bool hasImplementation) async {
  final outputFile = File(moneroOutputPath);
  const moneroCommonHeaders = """
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
  const moneroEWHeaders = """
import 'package:ew_core/get_height_by_date.dart';
import 'package:ew_core/monero_amount_format.dart';
import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_monero/monero_wallet_service.dart';
import 'package:ew_monero/monero_wallet.dart';
import 'package:ew_monero/monero_transaction_info.dart';
import 'package:ew_monero/monero_transaction_history.dart';
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

  int getHeigthByDate({required DateTime date});
  TransactionPriority getDefaultTransactionPriority();
  TransactionPriority getMoneroTransactionPrioritySlow();
  TransactionPriority getMoneroTransactionPriorityAutomatic();
  TransactionPriority deserializeMoneroTransactionPriority({required int raw});
  List<TransactionPriority> getTransactionPriorities();
  List<String> getMoneroWordList(String language);

  WalletCredentials createMoneroRestoreWalletFromKeysCredentials({
    required String name,
    required String spendKey,
    required String viewKey,
    required String address,
    required String password,
    required String language,
    required int height});
  WalletCredentials createMoneroRestoreWalletFromSeedCredentials({required String name, required String password, required int height, required String mnemonic});
  WalletCredentials createMoneroNewWalletCredentials({required String name, required String language, String password,});
  Map<String, String> getKeys(Object wallet);
  Object createMoneroTransactionCreationCredentials({required List<Output> outputs, required TransactionPriority priority});
  Object createMoneroTransactionCreationCredentialsRaw({required List<OutputInfo> outputs, required TransactionPriority priority});
  String formatterMoneroAmountToString({required int amount});
  double formatterMoneroAmountToDouble({required int amount});
  int formatterMoneroParseAmount({required String amount});
  Account getCurrentAccount(Object wallet);
  void setCurrentAccount(Object wallet, int id, String label);
  void onStartup();
  int getTransactionInfoAccountId(TransactionInfo tx);
  WalletService createMoneroWalletService(Box<WalletInfo> walletInfoSource);
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

  final output = '$moneroCommonHeaders\n'
    + (hasImplementation ? '$moneroEWHeaders\n' : '\n')
    + (hasImplementation ? '$moneroEWPart\n\n' : '\n')
    + (hasImplementation ? moneroEWDefinition : moneroEmptyDefinition)
    + '\n'
    + moneroContent;

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
  // FIX-ME: it's abstruct class
  @observable
  late Account account;
  // FIX-ME: it's abstruct class
  @observable
  late HavenBalance balance;
}

abstract class Haven {
  HavenAccountList getAccountList(Object wallet);
  
  MoneroSubaddressList getSubaddressList(Object wallet);

  TransactionHistoryBase getTransactionHistory(Object wallet);

  HavenWalletDetails getMoneroWalletDetails(Object wallet);

  String getTransactionAddress(Object wallet, int accountIndex, int addressIndex);

  int getHeigthByDate({required DateTime date});
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

  final output = '$havenCommonHeaders\n'
    + (hasImplementation ? '$havenEWHeaders\n' : '\n')
    + (hasImplementation ? '$havenEWPart\n\n' : '\n')
    + (hasImplementation ? havenEWDefinition : havenEmptyDefinition)
    + '\n'
    + havenContent;

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

  final output = '$wowneroCommonHeaders\n'
      + (hasImplementation ? '$wowneroEWHeaders\n' : '\n')
      + (hasImplementation ? '$wowneroEWPart\n\n' : '\n')
      + (hasImplementation ? wowneroEWDefinition : wowneroEmptyDefinition)
      + '\n'
      + wowneroContent;

  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(output);
}

Future<void> generatePubspec({required bool hasMonero, required bool hasBitcoin, required bool hasHaven, required bool hasWownero}) async {
  const ewCore =  """
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

  final outputLines = output.split('\n');
  inputLines.insertAll(dependenciesIndex + 1, outputLines);
  final outputContent = inputLines.join('\n');
  final outputFile = File(pubspecOutputPath);
  
  if (outputFile.existsSync()) {
    await outputFile.delete();
  }

  await outputFile.writeAsString(outputContent);
}

Future<void> generateWalletTypes({required bool hasMonero, required bool hasBitcoin, required bool hasHaven, required bool hasWownero}) async {
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
    outputContent += '\tWalletType.bitcoin,\n\tWalletType.litecoin,\n';
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