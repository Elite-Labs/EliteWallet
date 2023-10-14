import 'package:ew_core/crypto_currency.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ew_core/http_port_redirector.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/proxy_settings_store.dart';

Future<double> _fetchPrice(Map<String, dynamic> args) async {
  if (args['provider'] == 'CoinGecko') {
    return _fetchCoinGeckoPrice(args);
  }
  if (args['provider'] == 'MajesticBank') {
    return _fetchMajesticBankPrice(args);
  }

  return 0.0;
}

Future<double> _fetchCoinGeckoPrice(Map<String, dynamic> args) async {
  const fiatApiAuthority = 'api.coingecko.com';
  const fiatApiPath = '/api/v3/coins/';
  const cryptoTickerToCoingeckoId = {
    'BTC' : 'bitcoin',
    'LTC' : 'litecoin',
    'XMR' : 'monero',
    'XHV' : 'haven',
    'WOW' : 'wownero',
    'ETH' : 'ethereum',
    'USDT': 'tether',
    'USDC': 'usd-coin',
    'DAI' : 'dai',
    'WBTC': 'wrapped-bitcoin',
    'AAVE': 'aave',
    'UNI' : 'uniswap',
    'MKR' : 'maker',
    'BNB' : 'binancecoin',
    'stETH' : 'staked-ether',
    'LDO' : 'lido-dao',
    'ARB' : 'arbitrum',
    'GRT' : 'the-graph',
    'BUSD': 'binance-usd',
    'TUSD': 'true-usd',
    'CRO' : 'crypto-com-chain'};

  final crypto = args['crypto'] as CryptoCurrency;
  final fiat = args['fiat'] as FiatCurrency;
  final settingsStore = args['settings'] as SettingsStore;

  final congeckoId = cryptoTickerToCoingeckoId[crypto.title] ?? "";
  if (congeckoId == "") {
    return 0.0;
  }

  try {
    final uri = Uri.https(fiatApiAuthority, fiatApiPath + congeckoId);
    final response = await get(settingsStore, uri);

    if (response.statusCode != 200) {
      return 0.0;
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    if (responseJSON.containsKey("market_data") &&
        responseJSON["market_data"].containsKey("current_price") &&
        responseJSON["market_data"]["current_price"].containsKey(
          fiat.title.toLowerCase())) {
      return double.parse(responseJSON["market_data"]["current_price"]
        [fiat.title.toLowerCase()].toString());
    }

    return 0.0;
  } catch (e) {
    return 0.0;
  }
}

Future<double> _fetchMajesticBankPrice(Map<String, dynamic> args) async {
  const fiatApiAuthority = 'majesticbank.is';
  const fiatApiPath = '/api/v1/rates';

  final crypto = args['crypto'] as CryptoCurrency;
  final fiat = args['fiat'] as FiatCurrency;
  final settingsStore = args['settings'] as SettingsStore;

  try {
    final uri = Uri.https(
      fiatApiAuthority, fiatApiPath);
    final response = await get(settingsStore, uri.toString());

    if (response.statusCode != 200) {
      return 0.0;
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    String priceKey = crypto.title + "-" + fiat.title;
    if (responseJSON.containsKey(priceKey)) {
      return double.parse(responseJSON[priceKey].toString());
    }

    return 0.0;
  } catch (e) {
    return 0.0;
  }
}

Future<double> _fetchPriceAsync(
        CryptoCurrency crypto,
        FiatCurrency fiat,
        SettingsStore settingsStore) async =>
    _fetchPrice({'fiat': fiat, 'crypto': crypto, 'settings': settingsStore,
                 'provider': settingsStore.cryptoPriceProvider});

class FiatConversionService {
  static List<String> get services => ["CoinGecko", "MajesticBank"];

  static Future<double> fetchPrice(
          CryptoCurrency crypto,
          FiatCurrency fiat,
          SettingsStore settingsStore) async =>
      await _fetchPriceAsync(crypto, fiat, settingsStore);
}
