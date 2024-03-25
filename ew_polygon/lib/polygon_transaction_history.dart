import 'dart:core';

import 'package:ew_evm/evm_chain_transaction_history.dart';
import 'package:ew_evm/evm_chain_transaction_info.dart';
import 'package:ew_polygon/polygon_transaction_info.dart';

class PolygonTransactionHistory extends EVMChainTransactionHistory {
  PolygonTransactionHistory({
    required super.walletInfo,
    required super.password,
  });

  @override
  String getTransactionHistoryFileName() => 'polygon_transactions.json';

  @override
  EVMChainTransactionInfo getTransactionInfo(Map<String, dynamic> val) =>
      PolygonTransactionInfo.fromJson(val);
}
