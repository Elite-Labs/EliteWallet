import 'package:ew_bitcoin/bitcoin_transaction_priority.dart';
import 'package:ew_core/output_info.dart';

class BitcoinTransactionCredentials {
  BitcoinTransactionCredentials(this.outputs, {required this.priority, this.feeRate});

  final List<OutputInfo> outputs;
  final BitcoinTransactionPriority? priority;
  final int? feeRate;
}
