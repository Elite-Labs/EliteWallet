import 'package:ew_core/monero_transaction_priority.dart';
import 'package:ew_core/output_info.dart';

class WowneroTransactionCreationCredentials {
  WowneroTransactionCreationCredentials({
    required this.outputs,
    required this.priority,
    required this.assetType});

  final List<OutputInfo> outputs;
  final MoneroTransactionPriority priority;
  final String assetType;
}
