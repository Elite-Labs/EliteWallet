import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/output_info.dart';
import 'package:ew_ethereum/ethereum_transaction_priority.dart';

class EthereumTransactionCredentials {
  EthereumTransactionCredentials(
    this.outputs, {
    required this.priority,
    required this.currency,
    this.feeRate,
  });

  final List<OutputInfo> outputs;
  final EthereumTransactionPriority? priority;
  final int? feeRate;
  final CryptoCurrency currency;
}
