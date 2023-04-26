import 'package:ew_core/crypto_currency.dart';

class BitcoinTransactionWrongBalanceException implements Exception {
  BitcoinTransactionWrongBalanceException(this.currency);

  final CryptoCurrency currency;

  @override
  String toString() => 'You do not have enough ${currency.title} to send this amount.';
}