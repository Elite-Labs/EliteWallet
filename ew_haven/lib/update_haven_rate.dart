//import 'package:elite_wallet/store/dashboard/fiat_conversion_store.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/monero_amount_format.dart';
import 'package:ew_haven/api/balance_list.dart';

//Future<void> updateHavenRate(FiatConversionStore fiatConversionStore) async {
//  final rate = getRate();
//  final base = rate.firstWhere((row) => row.getAssetType() == 'XUSD', orElse: () => null);
//  rate.forEach((row) {
//    final cur = CryptoCurrency.fromString(row.getAssetType());
//    final baseRate = moneroAmountToDouble(amount: base.getRate());
//    final rowRate = moneroAmountToDouble(amount: row.getRate());
//    fiatConversionStore.prices[cur] = baseRate * rowRate;
//  });
//}