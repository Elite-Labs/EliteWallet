import 'package:elite_wallet/store/dashboard/fiat_conversion_store.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/monero_amount_format.dart';
import 'package:elite_wallet/haven/haven.dart';

Future<void> updateHavenRate(FiatConversionStore fiatConversionStore) async {
  final rate = haven.getAssetRate();
  final base = rate.firstWhere((row) => row.asset == 'XUSD', orElse: () => null);
  rate.forEach((row) {
    final cur = CryptoCurrency.fromString(row.asset);
    final baseRate = moneroAmountToDouble(amount: base.rate);
    final rowRate = moneroAmountToDouble(amount: row.rate);

    if (cur == CryptoCurrency.xusd) {
      fiatConversionStore.prices[cur] = 1.0;
      return;
    }

    fiatConversionStore.prices[cur] = baseRate / rowRate;
  });
}