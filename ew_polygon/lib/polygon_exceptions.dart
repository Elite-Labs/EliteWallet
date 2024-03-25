import 'package:ew_core/crypto_currency.dart';
import 'package:ew_ethereum/ethereum_exceptions.dart';

class PolygonTransactionCreationException extends EthereumTransactionCreationException {
  PolygonTransactionCreationException(CryptoCurrency currency) : super(currency);
}
