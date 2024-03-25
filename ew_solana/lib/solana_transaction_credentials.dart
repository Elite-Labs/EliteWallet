import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/output_info.dart';

class SolanaTransactionCredentials {
  SolanaTransactionCredentials(
    this.outputs, {
    required this.currency,
  });

  final List<OutputInfo> outputs;
  final CryptoCurrency currency;
}
