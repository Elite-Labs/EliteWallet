import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/wallet_type.dart';

CryptoCurrency currencyForWalletType(WalletType type) {
  switch (type) {
    case WalletType.bitcoin:
      return CryptoCurrency.btc;
    case WalletType.monero:
      return CryptoCurrency.xmr;
    case WalletType.litecoin:
      return CryptoCurrency.ltc;
    case WalletType.haven:
      return CryptoCurrency.xhv;
    case WalletType.wownero:
      return CryptoCurrency.wow;
    default:
      throw Exception('Unexpected wallet type: ${type.toString()} for CryptoCurrency currencyForWalletType');
  }
}
