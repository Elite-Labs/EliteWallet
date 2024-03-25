import 'dart:convert';

import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/elite_hive.dart';
import 'package:ew_core/erc20_token.dart';
import 'package:ew_core/pathForWallet.dart';
import 'package:ew_core/transaction_direction.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_evm/evm_chain_transaction_history.dart';
import 'package:ew_evm/evm_chain_transaction_info.dart';
import 'package:ew_evm/evm_chain_transaction_model.dart';
import 'package:ew_evm/evm_chain_wallet.dart';
import 'package:ew_evm/evm_erc20_balance.dart';
import 'package:ew_evm/file.dart';
import 'package:ew_polygon/default_polygon_erc20_tokens.dart';
import 'package:ew_polygon/polygon_transaction_info.dart';
import 'package:ew_polygon/polygon_client.dart';
import 'package:ew_polygon/polygon_transaction_history.dart';

class PolygonWallet extends EVMChainWallet {
  PolygonWallet({
    required super.walletInfo,
    required super.password,
    super.mnemonic,
    super.initialBalance,
    super.privateKey,
    required super.client,
  }) : super(nativeCurrency: CryptoCurrency.maticpoly);

  @override
  Future<void> initErc20TokensBox() async {
    final boxName = "${walletInfo.name.replaceAll(" ", "_")}_ ${Erc20Token.polygonBoxName}";
    if (await EliteHive.boxExists(boxName)) {
      evmChainErc20TokensBox = await EliteHive.openBox<Erc20Token>(boxName);
    } else {
      evmChainErc20TokensBox = await EliteHive.openBox<Erc20Token>(boxName.replaceAll(" ", ""));
    }
  }

  @override
  void addInitialTokens() {
    final initialErc20Tokens = DefaultPolygonErc20Tokens().initialPolygonErc20Tokens;

    for (var token in initialErc20Tokens) {
      evmChainErc20TokensBox.put(token.contractAddress, token);
    }
  }

  @override
  Future<bool> checkIfScanProviderIsEnabled() async {
    bool isPolygonScanEnabled = (await sharedPrefs.future).getBool("use_polygonscan") ?? true;
    return isPolygonScanEnabled;
  }

  @override
  String getTransactionHistoryFileName() => 'polygon_transactions.json';

  @override
  Erc20Token createNewErc20TokenObject(Erc20Token token, String? iconPath) {
    return Erc20Token(
      name: token.name,
      symbol: token.symbol,
      contractAddress: token.contractAddress,
      decimal: token.decimal,
      enabled: token.enabled,
      tag: token.tag ?? "MATIC",
      iconPath: iconPath,
    );
  }

  @override
  EVMChainTransactionInfo getTransactionInfo(
      EVMChainTransactionModel transactionModel, String address) {
    final model = PolygonTransactionInfo(
      id: transactionModel.hash,
      height: transactionModel.blockNumber,
      ethAmount: transactionModel.amount,
      direction: transactionModel.from == address
          ? TransactionDirection.outgoing
          : TransactionDirection.incoming,
      isPending: false,
      date: transactionModel.date,
      confirmations: transactionModel.confirmations,
      ethFee: BigInt.from(transactionModel.gasUsed) * transactionModel.gasPrice,
      exponent: transactionModel.tokenDecimal ?? 18,
      tokenSymbol: transactionModel.tokenSymbol ?? "MATIC",
      to: transactionModel.to,
      from: transactionModel.from,
    );
    return model;
  }

  @override
  EVMChainTransactionHistory setUpTransactionHistory(WalletInfo walletInfo, String password) {
    return PolygonTransactionHistory(walletInfo: walletInfo, password: password);
  }

  static Future<PolygonWallet> open(
      {required String name, required String password, required WalletInfo walletInfo}) async {
    final path = await pathForWallet(name: name, type: walletInfo.type);
    final jsonSource = await read(path: path, password: password);
    final data = json.decode(jsonSource) as Map;
    final mnemonic = data['mnemonic'] as String?;
    final privateKey = data['private_key'] as String?;
    final balance = EVMChainERC20Balance.fromJSON(data['balance'] as String) ??
        EVMChainERC20Balance(BigInt.zero);

    return PolygonWallet(
      walletInfo: walletInfo,
      password: password,
      mnemonic: mnemonic,
      privateKey: privateKey,
      initialBalance: balance,
      client: PolygonClient(),
    );
  }
}
