import 'package:elite_wallet/entities/contact_base.dart';
import 'package:ew_core/crypto_currency.dart';

class WalletContact implements ContactBase {
  WalletContact(this.address, this.name, this.type);
    //: super(name, address, type);

  @override
  String address;

  @override
  String name;

  @override
  CryptoCurrency type;
}
