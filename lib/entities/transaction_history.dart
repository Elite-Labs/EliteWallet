import 'package:mobx/mobx.dart';
import 'package:ew_core/transaction_info.dart';

abstract class TransactionHistory {
  TransactionHistory()
    : transactions = Observable<List<TransactionInfo>>(<TransactionInfo>[]);

  Observable<List<TransactionInfo>> transactions;
  Future<List<TransactionInfo>> getAll();
  Future update();
}
