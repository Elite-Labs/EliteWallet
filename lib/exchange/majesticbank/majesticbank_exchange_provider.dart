import 'dart:convert';
import 'package:elite_wallet/exchange/trade_not_found_exeption.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/http_port_redirector.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/.secrets.g.dart' as secrets;
import 'package:ew_core/crypto_currency.dart';
import 'package:elite_wallet/exchange/exchange_pair.dart';
import 'package:elite_wallet/exchange/exchange_provider.dart';
import 'package:elite_wallet/exchange/limits.dart';
import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/exchange/trade_request.dart';
import 'package:elite_wallet/exchange/trade_state.dart';
import 'package:elite_wallet/exchange/majesticbank/majesticbank_request.dart';
import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/exchange/trade_not_created_exeption.dart';
import 'package:elite_wallet/entities/exchange_api_mode.dart';

class MajesticBankExchangeProvider extends ExchangeProvider {
  MajesticBankExchangeProvider(this.settingsStore)
      : super(pairList: _supportedPairs());
  static const List<CryptoCurrency> _supported = [
    CryptoCurrency.bch,
    CryptoCurrency.btc,
    CryptoCurrency.firo,
    CryptoCurrency.ltc,
    CryptoCurrency.wow,
    CryptoCurrency.xmr,
    CryptoCurrency.eth,
  ];

  static List<ExchangePair> _supportedPairs() {
    final supportedCurrencies = CryptoCurrency.all
        .where((element) => _supported.contains(element))
        .toList();

    return supportedCurrencies
        .map((i) => supportedCurrencies
            .map((k) => ExchangePair(from: i, to: k, reverse: true)))
        .expand((i) => i)
        .toList();
  }

  static const referralCode = 'BVIQmf';
  static const apiAuthorityDirect = 'majesticbank.sc';
  static const apiAuthorityDirectAlt = 'majesticbank.ru';
  static const apiAuthorityOnion =
    'majestictfvnfjgo5hqvmuzynak4kjl5tjs3j5zdabawe6n2aaebldad.onion';
  static const createTradePath = '/api/v1/exchange';
  static const createFixedTradePath = '/api/v1/pay';
  static const findTradeByIdPath = '/api/v1/track';
  static const calculatePath = '/api/v1/calculate';
  static const limitsPath = '/api/v1/limits';

  @override
  String get title => 'Majestic Bank';

  @override
  bool get isAvailable => true;

  @override
  bool get isEnabled => true;

  @override
  bool get supportsFixedRate => true;

  @override
  bool get supportsOnionAddress => true;

  @override
  ExchangeProviderDescription get description =>
      ExchangeProviderDescription.majesticBank;

  @override
  Future<bool> checkIsAvailable() async => true;

  SettingsStore settingsStore;

  @override
  Future<Limits> fetchLimits({
    required CryptoCurrency from, required CryptoCurrency to,
    required bool isFixedRateMode}) async {

    Object? exception;
    for (final apiAuthority in getApiAuthorities()) {
      try {
        return await _fetchLimitsInternal(
          from: from, to: to, isFixedRateMode: isFixedRateMode,
          apiAuthority: apiAuthority);
      } catch (e) {
        exception = e;
      }
    }
    throw exception!;
  }

  Future<Limits> _fetchLimitsInternal({required CryptoCurrency from,
    required CryptoCurrency to, required bool isFixedRateMode,
    required String apiAuthority}) async {

    final normalizedFrom = normalizeCryptoCurrency(from);
    final params = <String, String>{
      'from_currency': normalizedFrom};
    final uri = Uri.https(apiAuthority, limitsPath, params);
    final response = await get(settingsStore, uri);

    if (response.statusCode == 400) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final error = responseJSON['error'] as String;
      final message = responseJSON['message'] as String;
      throw Exception('${error}\n$message');
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    double min = _toDouble(responseJSON['min']);
    double max = _toDouble(responseJSON['max']);
    return Limits(min: min, max: max);
  }

  @override
  Future<Trade> createTrade({
    required TradeRequest request, required bool isFixedRateMode}) async {

    Object? exception;
    for (final apiAuthority in getApiAuthorities()) {
      try {
        return await _createTradeInternal(
          request: request, isFixedRateMode: isFixedRateMode,
          apiAuthority: apiAuthority);
      } catch (e) {
        exception = e;
      }
    }
    throw exception!;
  }

  Future<Trade> _createTradeInternal({
    required TradeRequest request, required bool isFixedRateMode,
    required String apiAuthority}) async {

    final _request = request as MajesticBankRequest;
    final headers = <String, String>{
      'from_currency': normalizeCryptoCurrency(_request.from), 
      'receive_currency': normalizeCryptoCurrency(_request.to),
      'receive_address': _request.address,
      'referral_code': referralCode
    };

    if (isFixedRateMode && _request.isReverse) {
      headers["receive_amount"] = _request.toAmount;
    } else {
      headers["from_amount"] = _request.fromAmount;
    }

    Uri uri;
    if (isFixedRateMode) {
      uri = Uri.https(apiAuthority, createFixedTradePath, headers);
    } else {
      uri = Uri.https(apiAuthority, createTradePath, headers);
    }

    final response = await get(settingsStore, uri);

    if (response.statusCode == 400) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final error = responseJSON['error'] as String;
      final message = responseJSON['message'] as String;
      throw Exception('${error}\n$message');
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final id = responseJSON['trx'] as String;
    final inputAddress = responseJSON['address'] as String;
    final fromAmount = responseJSON['from_amount'] as String;
    final expiration = _toDouble(responseJSON['expiration']);
    DateTime now = DateTime.now();
    DateTime expiredAt = now.add(Duration(minutes: expiration.round()));

    return Trade(
        id: id,
        from: _request.from,
        to: _request.to,
        provider: description,
        inputAddress: inputAddress,
        payoutAddress: _request.address,
        refundAddress: _request.refundAddress,
        createdAt: now,
        expiredAt: expiredAt,
        amount: fromAmount,
        state: TradeState.created);
  }

  @override
  Future<Trade> findTradeById({
    required String id}) async {
    Object? exception;
    for (final apiAuthority in getApiAuthorities()) {
      try {
        return await _findTradeByIdInternal(
          id: id, apiAuthority: apiAuthority);
      } catch (e) {
        exception = e;
      }
    }
    throw exception!;
  }

  Future<Trade> _findTradeByIdInternal({
    required String id,
    required String apiAuthority}) async {

    final params = <String, String>{'trx': id};
    final uri = Uri.https(apiAuthority, findTradeByIdPath, params);
    final response = await get(settingsStore, uri);

    if (response.statusCode == 404) {
      throw TradeNotFoundException(id, provider: description);
    }

    if (response.statusCode == 400) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final error = responseJSON['message'] as String;

      throw TradeNotFoundException(id,
          provider: description, description: error);
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    CryptoCurrency? from;
    if (responseJSON.containsKey('from_currency')) {
      final fromCurrency = responseJSON['from_currency'] as String;
      from = CryptoCurrency.fromString(fromCurrency);
    }

    CryptoCurrency? to;
    if (responseJSON.containsKey('receive_currency')) {
      final toCurrency = responseJSON['receive_currency'] as String;
      to = CryptoCurrency.fromString(toCurrency);
    }

    String? inputAddress;
    if (responseJSON.containsKey('address')) {
      inputAddress = responseJSON['address'] as String;
    }

    String expectedSendAmount = "";
    if (responseJSON.containsKey('from_amount')) {
      expectedSendAmount = responseJSON['from_amount'].toString();
    }

    double? confirmed;
    if (responseJSON.containsKey('confirmed')) {
      confirmed = _toDouble(responseJSON['confirmed']);
    }

    double? receiveAmount;
    if (responseJSON.containsKey('receive_amount')) {
      receiveAmount = _toDouble(responseJSON['receive_amount']);
    }

    double? received;
    if (responseJSON.containsKey('received')) {
      received = _toDouble(responseJSON['received']);
    }

    final status = responseJSON['status'] as String;
    final state = TradeState.deserialize(raw: _parseStatus(status));

    return Trade(
        id: id,
        from: from,
        to: to,
        provider: description,
        inputAddress: inputAddress,
        amount: expectedSendAmount,
        confirmed: confirmed,
        receiveAmount: receiveAmount,
        received: received,
        state: state);
  }

  @override
  Future<double> fetchRate(
      {required CryptoCurrency from,
      required CryptoCurrency to,
      required double amount,
      required bool isFixedRateMode,
      required bool isReceiveAmount}) async {

    for (final apiAuthority in getApiAuthorities()) {
      try {
        double t = await _fetchRateInternal(
          from: from, to: to, amount: amount, isFixedRateMode: isFixedRateMode,
          isReceiveAmount: isReceiveAmount, apiAuthority: apiAuthority);
        return t;
      } catch (_) {}
    }
    return 0.0;
  }

  List<String> getApiAuthorities() {
    if (settingsStore.exchangeStatus == ExchangeApiMode.torOnly) {
      return [apiAuthorityOnion];
    }
    return [apiAuthorityOnion, apiAuthorityDirect, apiAuthorityDirectAlt];
  }

  Future<double> _fetchRateInternal(
      {required CryptoCurrency from,
      required CryptoCurrency to,
      required double amount,
      required bool isFixedRateMode,
      required bool isReceiveAmount,
      required String apiAuthority}) async {

    if (amount == 0) {
      return 0.0;
    }

    final isReverse = isReceiveAmount;
    final params = <String, String>{
      'from_currency': normalizeCryptoCurrency(from),
      'receive_currency': normalizeCryptoCurrency(to),
      };

    params['from_amount'] = amount.toString();

    final uri = Uri.https(apiAuthority, calculatePath, params);
    final response = await get(settingsStore, uri);
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    return _toDouble(responseJSON['receive_amount']) / amount;
  }

  static String _parseStatus(String input) {
    if (input == "Waiting for funds") {
      return "waitingPayment";
    }
    if (input == "Funds confirming") {
      return "waitingPayment";
    }
    if (input == "Completed") {
      return "complete";
    }
    if (input == "Not found") {
      return "complete";
    }
    return input;
  }

  static double _toDouble(dynamic input) {
    return double.parse(input.toString());
  }

  static String normalizeCryptoCurrency(CryptoCurrency currency) {
    return currency.title.toUpperCase();
  }
}
