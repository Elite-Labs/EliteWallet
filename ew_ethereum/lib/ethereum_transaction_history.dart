import 'dart:core';
import 'package:ew_ethereum/ethereum_transaction_info.dart';
import 'package:ew_evm/evm_chain_transaction_history.dart';
import 'package:ew_evm/evm_chain_transaction_info.dart';

class EthereumTransactionHistory extends EVMChainTransactionHistory {
  EthereumTransactionHistory({
    required super.walletInfo,
    required super.password,
  });

  @override
  String getTransactionHistoryFileName() => 'transactions.json';

  @override
  EVMChainTransactionInfo getTransactionInfo(Map<String, dynamic> val) =>
      EthereumTransactionInfo.fromJson(val);
}
