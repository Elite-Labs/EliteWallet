import 'package:mobx/mobx.dart';
import 'package:elite_wallet/core/fiat_conversion_service.dart';
import 'package:elite_wallet/store/dashboard/fiat_conversion_store.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/store/app_store.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';

ReactionDisposer _onCurrentFiatCurrencyChangeDisposer;

void startCurrentFiatChangeReaction(AppStore appStore,
    SettingsStore settingsStore, FiatConversionStore fiatConversionStore) {
  _onCurrentFiatCurrencyChangeDisposer?.reaction?.dispose();
  _onCurrentFiatCurrencyChangeDisposer = reaction(
      (_) => settingsStore.fiatCurrency, (FiatCurrency fiatCurrency) async {
    final cryptoCurrency = appStore.wallet.currency;
    fiatConversionStore.prices[appStore.wallet.currency] =
        await FiatConversionService.fetchPrice(
          cryptoCurrency, fiatCurrency, settingsStore);
  });
}
